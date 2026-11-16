import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'scan_snapshot.dart';
import 'detection_report.dart';

/// Détecteurs purs : du même instantané sortira toujours le même rapport.
/// Chaque détection cite ses preuves (fichier et élément trouvé).
DetectionReport detectProject(ScanSnapshot s, {required DateTime now}) {
  final ctx = _Context(s);
  final technologies = _technologies(ctx);
  return DetectionReport(
    scannedAt: now,
    filesScanned: s.files.length,
    technologies: technologies,
    targets: _targets(ctx, technologies),
    packages: _packages(ctx),
    git: _git(s.git),
    findings: _findings(ctx),
    permissions: _permissions(ctx),
    services: _services(ctx),
    sensitiveFiles: s.sensitiveFiles,
    partialReasons: s.partialReasons,
  );
}

class _Context {
  _Context(this.s) {
    pubspecPath = _shallowest('pubspec.yaml');
    packageJsonPath = _shallowest('package.json');
    pubspec = _yaml(pubspecPath);
    packageJson = _json(packageJsonPath);
    pubDeps = {
      ..._mapOf(pubspec?['dependencies']),
      ..._mapOf(pubspec?['dev_dependencies']),
    };
    npmDeps = {
      ..._mapOf(packageJson?['dependencies']),
      ..._mapOf(packageJson?['devDependencies']),
    };
  }

  final ScanSnapshot s;
  late final String? pubspecPath;
  late final String? packageJsonPath;
  late final Map<Object?, Object?>? pubspec;
  late final Map<String, Object?>? packageJson;
  late final Map<String, Object?> pubDeps;
  late final Map<String, Object?> npmDeps;

  bool has(String path) => s.has(path);
  bool hasPrefix(String prefix) => s.hasPrefix(prefix);

  /// Fichier de ce nom le plus proche de la racine.
  String? _shallowest(String name) {
    final matches =
        s.files
            .where(
              (f) => p.posix.basename(f) == name && s.contents.containsKey(f),
            )
            .toList()
          ..sort((a, b) {
            final depth = a.split('/').length.compareTo(b.split('/').length);
            return depth != 0 ? depth : a.compareTo(b);
          });
    return matches.isEmpty ? null : matches.first;
  }

  Map<Object?, Object?>? _yaml(String? path) {
    if (path == null) return null;
    try {
      final doc = loadYaml(s.contents[path]!);
      return doc is Map ? doc : null;
    } on YamlException {
      return null;
    }
  }

  Map<String, Object?>? _json(String? path) {
    if (path == null) return null;
    try {
      final doc = jsonDecode(s.contents[path]!);
      return doc is Map ? doc.cast<String, Object?>() : null;
    } on FormatException {
      return null;
    }
  }

  static Map<String, Object?> _mapOf(Object? v) =>
      v is Map ? {for (final e in v.entries) '${e.key}': e.value} : {};

  Iterable<MapEntry<String, String>> contentsWhere(
    bool Function(String path) test,
  ) => s.contents.entries.where((e) => test(e.key));

  /// Contenus des fichiers de dépendances Python, en minuscules.
  late final Map<String, String> pythonManifests = {
    for (final e in contentsWhere(
      (f) => const {
        'requirements.txt',
        'pyproject.toml',
        'Pipfile',
      }.contains(p.posix.basename(f)),
    ))
      e.key: e.value.toLowerCase(),
  };

  late final List<String> htmlFiles =
      s.contents.keys
          .where((f) => f.endsWith('.html') || f.endsWith('.htm'))
          .toList()
        ..sort((a, b) => a.split('/').length.compareTo(b.split('/').length));
}

// ----------------------------------------------------------- technologies

List<TechDetection> _technologies(_Context c) {
  final out = <TechDetection>[];

  // Flutter / Dart
  final pubspecPath = c.pubspecPath;
  if (pubspecPath != null && c.pubspec != null) {
    final flutterDep = c.pubDeps['flutter'];
    final isFlutter =
        (flutterDep is Map && flutterDep['sdk'] == 'flutter') ||
        c.pubspec!['flutter'] != null;
    final base = p.posix.dirname(pubspecPath);
    final main = base == '.' ? 'lib/main.dart' : '$base/lib/main.dart';
    if (isFlutter) {
      out.add(
        TechDetection(
          id: 'flutter',
          label: 'Flutter',
          kind: TechKind.framework,
          confidence: 0.99,
          evidence: [
            Evidence(pubspecPath, 'dependencies.flutter: sdk: flutter'),
            if (c.has(main)) Evidence(main),
          ],
        ),
      );
    }
    out.add(
      TechDetection(
        id: 'dart',
        label: 'Dart',
        kind: TechKind.language,
        confidence: 0.95,
        evidence: [Evidence(pubspecPath, 'name: ${c.pubspec!['name'] ?? '?'}')],
      ),
    );
  }

  // Écosystème JavaScript
  final pkg = c.packageJsonPath;
  if (pkg != null && c.packageJson != null) {
    out.add(
      TechDetection(
        id: 'node',
        label: 'Node.js',
        kind: TechKind.runtime,
        confidence: 0.9,
        evidence: [Evidence(pkg)],
      ),
    );
    final deps = c.npmDeps;
    bool dep(String name) => deps.containsKey(name);
    String? config(String prefix) {
      for (final f in c.s.files) {
        if (p.posix.basename(f).startsWith(prefix) &&
            f.split('/').length <= 2) {
          return f;
        }
      }
      return null;
    }

    void framework(
      String id,
      String label,
      String depName, {
      String? configPrefix,
      String? configFile,
    }) {
      final hasDep = dep(depName);
      final cfg =
          configFile ?? (configPrefix == null ? null : config(configPrefix));
      final hasCfg = cfg != null && (configFile == null || c.has(configFile));
      if (!hasDep && !hasCfg) return;
      out.add(
        TechDetection(
          id: id,
          label: label,
          kind: TechKind.framework,
          confidence: hasDep && hasCfg ? 0.98 : (hasDep ? 0.92 : 0.7),
          evidence: [
            if (hasDep) Evidence(pkg, '$depName ${deps[depName]}'),
            if (hasCfg) Evidence(cfg),
          ],
        ),
      );
    }

    framework('nextjs', 'Next.js', 'next', configPrefix: 'next.config.');
    framework('nuxt', 'Nuxt', 'nuxt', configPrefix: 'nuxt.config.');
    framework('astro', 'Astro', 'astro', configPrefix: 'astro.config.');
    framework(
      'sveltekit',
      'SvelteKit',
      '@sveltejs/kit',
      configPrefix: 'svelte.config.',
    );
    if (!dep('@sveltejs/kit')) framework('svelte', 'Svelte', 'svelte');
    framework(
      'angular',
      'Angular',
      '@angular/core',
      configFile: 'angular.json',
    );
    if (!dep('next')) framework('react', 'React', 'react');
    if (!dep('nuxt')) framework('vue', 'Vue', 'vue');
    framework('vite', 'Vite', 'vite', configPrefix: 'vite.config.');
  }

  // Site statique : HTML sans framework JavaScript ni Flutter.
  final hasWebFramework = out.any(
    (t) => t.kind == TechKind.framework && t.id != 'vite',
  );
  if (!hasWebFramework) {
    final index = [
      'index.html',
      'public/index.html',
      'site/index.html',
      'docs/index.html',
      'src/index.html',
    ].where(c.has).firstOrNull;
    if (index != null) {
      final css = c.s.files.where((f) => f.endsWith('.css')).length;
      final js = c.s.files.where((f) => f.endsWith('.js')).length;
      out.add(
        TechDetection(
          id: 'static',
          label: 'HTML / CSS / JavaScript',
          kind: TechKind.framework,
          confidence: 0.85,
          evidence: [
            Evidence(index),
            if (css > 0) Evidence('*.css', '$css'),
            if (js > 0) Evidence('*.js', '$js'),
          ],
        ),
      );
    }
  }

  // Python : signalé à titre informatif.
  final py = c.pythonManifests;
  final pySources = c.contentsWhere((f) => f.endsWith('.py'));
  Evidence? pythonEvidence(String module) {
    final pattern = RegExp('\\b$module\\b', caseSensitive: false);
    for (final e in py.entries) {
      if (pattern.hasMatch(e.value)) return Evidence(e.key, module);
    }
    final import = RegExp('^\\s*(from|import)\\s+$module\\b', multiLine: true);
    for (final e in pySources) {
      if (import.hasMatch(e.value)) return Evidence(e.key, 'import $module');
    }
    return null;
  }

  final hasPython = py.isNotEmpty || c.s.files.any((f) => f.endsWith('.py'));
  if (hasPython) {
    out.add(
      TechDetection(
        id: 'python',
        label: 'Python',
        kind: TechKind.language,
        confidence: py.isNotEmpty ? 0.9 : 0.6,
        evidence: [
          for (final f in py.keys) Evidence(f),
          if (py.isEmpty)
            Evidence(c.s.files.firstWhere((f) => f.endsWith('.py'))),
        ],
        informative: true,
      ),
    );
    final django = pythonEvidence('django');
    final managePy = c.s.files.where((f) => p.posix.basename(f) == 'manage.py');
    if (django != null || managePy.isNotEmpty) {
      out.add(
        TechDetection(
          id: 'django',
          label: 'Django',
          kind: TechKind.backend,
          confidence: django != null && managePy.isNotEmpty ? 0.95 : 0.8,
          evidence: [
            ?django,
            if (managePy.isNotEmpty) Evidence(managePy.first),
          ],
          informative: true,
        ),
      );
    }
    for (final (id, label) in [('flask', 'Flask'), ('fastapi', 'FastAPI')]) {
      final ev = pythonEvidence(id);
      if (ev != null) {
        out.add(
          TechDetection(
            id: id,
            label: label,
            kind: TechKind.backend,
            confidence: 0.85,
            evidence: [ev],
            informative: true,
          ),
        );
      }
    }
  }
  return out;
}

// ---------------------------------------------------------------- cibles

List<TargetDetection> _targets(_Context c, List<TechDetection> techs) {
  bool tech(String id) => techs.any((t) => t.id == id);
  final result = <PlatformTarget, TargetDetection>{};

  void add(PlatformTarget t, double confidence, List<Evidence> evidence) {
    final current = result[t];
    if (current == null || current.confidence < confidence) {
      result[t] = TargetDetection(
        target: t,
        confidence: confidence,
        evidence: evidence,
      );
    }
  }

  if (tech('flutter')) {
    // (cible, fichier probant, dossier de repli)
    const markers = [
      (
        PlatformTarget.android,
        'android/app/src/main/AndroidManifest.xml',
        'android/',
      ),
      (PlatformTarget.ios, 'ios/Runner/Info.plist', 'ios/'),
      (PlatformTarget.web, 'web/index.html', 'web/'),
      (PlatformTarget.linux, 'linux/CMakeLists.txt', 'linux/'),
      (PlatformTarget.windows, 'windows/CMakeLists.txt', 'windows/'),
      (PlatformTarget.macos, 'macos/Runner/Info.plist', 'macos/'),
    ];
    // Les dossiers de plateforme sont à côté du pubspec.yaml.
    final base = p.posix.dirname(c.pubspecPath!);
    final prefix = base == '.' ? '' : '$base/';
    for (final (target, file, folder) in markers) {
      if (c.has('$prefix$file')) {
        add(target, 0.95, [Evidence('$prefix$file')]);
      } else if (c.hasPrefix('$prefix$folder')) {
        add(target, 0.6, [Evidence('$prefix$folder', 'dossier présent')]);
      }
    }
  }

  const webFrameworks = [
    'nextjs',
    'nuxt',
    'astro',
    'sveltekit',
    'svelte',
    'angular',
    'react',
    'vue',
    'static',
  ];
  for (final t in techs.where((t) => webFrameworks.contains(t.id))) {
    add(PlatformTarget.web, 0.9, [Evidence(t.evidence.first.path, t.label)]);
  }

  return [
    for (final t in PlatformTarget.values)
      result[t] ??
          TargetDetection(target: t, confidence: 0, evidence: const []),
  ];
}

// -------------------------------------------------------------- paquets

List<PackageManagerInfo> _packages(_Context c) {
  final out = <PackageManagerInfo>[];
  String sibling(String manifest, String name) {
    final dir = p.posix.dirname(manifest);
    return dir == '.' ? name : '$dir/$name';
  }

  final pubspec = c.pubspecPath;
  if (pubspec != null) {
    final lock = sibling(pubspec, 'pubspec.lock');
    out.add(
      PackageManagerInfo(
        manager: 'pub',
        manifest: pubspec,
        lockFile: c.has(lock) ? lock : null,
      ),
    );
  }

  final pkg = c.packageJsonPath;
  if (pkg != null && c.packageJson != null) {
    const locks = [
      ('pnpm', 'pnpm-lock.yaml'),
      ('yarn', 'yarn.lock'),
      ('bun', 'bun.lockb'),
      ('bun', 'bun.lock'),
      ('npm', 'package-lock.json'),
    ];
    String manager = 'npm';
    String? lockFile;
    for (final (m, name) in locks) {
      if (c.has(sibling(pkg, name))) {
        manager = m;
        lockFile = sibling(pkg, name);
        break;
      }
    }
    final declared = c.packageJson!['packageManager'];
    if (lockFile == null && declared is String && declared.contains('@')) {
      manager = declared.split('@').first;
    }
    final scripts = c.packageJson!['scripts'];
    out.add(
      PackageManagerInfo(
        manager: manager,
        manifest: pkg,
        lockFile: lockFile,
        scripts: scripts is Map
            ? {for (final e in scripts.entries) '${e.key}': '${e.value}'}
            : const {},
      ),
    );
  }

  final py = c.pythonManifests.keys.toList()..sort();
  if (py.isNotEmpty) {
    final poetry = c.s.files.where((f) => p.posix.basename(f) == 'poetry.lock');
    final pipfile = py.where((f) => p.posix.basename(f) == 'Pipfile');
    out.add(
      poetry.isNotEmpty
          ? PackageManagerInfo(
              manager: 'poetry',
              manifest: py.firstWhere(
                (f) => f.endsWith('pyproject.toml'),
                orElse: () => py.first,
              ),
              lockFile: poetry.first,
            )
          : pipfile.isNotEmpty
          ? PackageManagerInfo(manager: 'pipenv', manifest: pipfile.first)
          : PackageManagerInfo(manager: 'pip', manifest: py.first),
    );
  }
  return out;
}

// ------------------------------------------------------------------- git

GitSnapshot _git(GitRaw raw) {
  if (!raw.present) return GitSnapshot.absent;
  if (raw.isFile) {
    return const GitSnapshot(present: true, linkedWorktree: true);
  }
  String? branch;
  String? detached;
  final head = raw.head?.trim();
  if (head != null && head.startsWith('ref: refs/heads/')) {
    branch = head.substring('ref: refs/heads/'.length);
  } else if (head != null && RegExp(r'^[0-9a-f]{40,64}$').hasMatch(head)) {
    detached = head.substring(0, 7);
  }
  final tags = <String>{...raw.looseTags};
  for (final line in LineSplitter.split(raw.packedRefs ?? '')) {
    final m = RegExp(r'^[0-9a-f]{40,64} refs/tags/(.+)$').firstMatch(line);
    if (m != null) tags.add(m[1]!);
  }
  return GitSnapshot(
    present: true,
    branch: branch,
    detachedCommit: detached,
    tags: tags.toList()..sort(),
  );
}

// ------------------------------------------------------- fichiers utiles

const _imageExtensions = {'.png', '.jpg', '.jpeg', '.webp', '.ico', '.svg'};

List<FileFinding> _findings(_Context c) {
  final out = <FileFinding>[];
  final files = c.s.files;
  bool isImage(String f) =>
      _imageExtensions.contains(p.posix.extension(f).toLowerCase());

  // Icônes : regroupées par famille pour rester lisibles.
  final mipmaps = files
      .where(
        (f) =>
            f.contains('/res/mipmap-') &&
            p.posix.basename(f).startsWith('ic_launcher'),
      )
      .toList();
  if (mipmaps.isNotEmpty) {
    out.add(
      FileFinding(
        FindingCategory.icon,
        p.posix.dirname(p.posix.dirname(mipmaps.first)),
        'android mipmap ×${mipmaps.length}',
      ),
    );
  }
  final appIcon = files
      .where((f) => f.contains('AppIcon.appiconset/') && isImage(f))
      .toList();
  if (appIcon.isNotEmpty) {
    out.add(
      FileFinding(
        FindingCategory.icon,
        p.posix.dirname(appIcon.first),
        'iOS/macOS AppIcon ×${appIcon.length}',
      ),
    );
  }
  for (final f in files) {
    final name = p.posix.basename(f).toLowerCase();
    if (!isImage(f)) continue;
    if (f.contains('/res/mipmap-') || f.contains('AppIcon.appiconset/')) {
      continue;
    }
    if (name.startsWith('favicon') ||
        name.startsWith('apple-touch-icon') ||
        (name.contains('icon') &&
            (f.startsWith('assets/') ||
                f.startsWith('web/icons/') ||
                f.startsWith('public/')))) {
      out.add(FileFinding(FindingCategory.icon, f));
    }
  }
  if (c.pubDeps.containsKey('flutter_launcher_icons')) {
    out.add(
      FileFinding(
        FindingCategory.icon,
        c.pubspecPath!,
        'flutter_launcher_icons',
      ),
    );
  }

  // Captures d'écran
  out.addAll(
    files
        .where(
          (f) =>
              isImage(f) &&
              (f.toLowerCase().contains('screenshot') ||
                  f.contains('phoneScreenshots/') ||
                  f.contains('/screenshots/')),
        )
        .take(30)
        .map((f) => FileFinding(FindingCategory.screenshot, f)),
  );

  // Fastlane
  out.addAll(
    files
        .where(
          (f) =>
              (f.startsWith('fastlane/') || f.contains('/fastlane/')) &&
              const {
                'Fastfile',
                'Appfile',
                'Pluginfile',
              }.contains(p.posix.basename(f)),
        )
        .map((f) => FileFinding(FindingCategory.fastlane, f)),
  );

  // Intégration continue
  for (final f in files) {
    final ci =
        (f.startsWith('.github/workflows/') &&
            (f.endsWith('.yml') || f.endsWith('.yaml'))) ||
        const {
          '.gitlab-ci.yml',
          'codemagic.yaml',
          'bitrise.yml',
          '.circleci/config.yml',
          'azure-pipelines.yml',
          '.travis.yml',
          'Jenkinsfile',
        }.contains(f);
    if (ci) out.add(FileFinding(FindingCategory.ci, f));
  }

  // Hébergement
  const hosting = {
    'firebase.json': 'Firebase Hosting',
    '.firebaserc': 'Firebase',
    'vercel.json': 'Vercel',
    'netlify.toml': 'Netlify',
    'CNAME': 'GitHub Pages',
    '.nojekyll': 'GitHub Pages',
    '_redirects': 'Netlify',
    'render.yaml': 'Render',
    'fly.toml': 'Fly.io',
  };
  for (final f in files) {
    final label = hosting[f];
    if (label != null) out.add(FileFinding(FindingCategory.hosting, f, label));
  }

  // PWA : manifeste avec les champs attendus, service worker.
  for (final e in c.contentsWhere(
    (f) => const {
      'manifest.json',
      'manifest.webmanifest',
      'site.webmanifest',
    }.contains(p.posix.basename(f)),
  )) {
    if (e.value.contains('"icons"') || e.value.contains('"start_url"')) {
      out.add(FileFinding(FindingCategory.pwa, e.key, 'manifest'));
    }
  }
  for (final f in files) {
    if (const {
      'sw.js',
      'service-worker.js',
      'serviceWorker.js',
      'workbox-config.js',
    }.contains(p.posix.basename(f))) {
      out.add(FileFinding(FindingCategory.pwa, f, 'service worker'));
    }
  }

  // SEO
  for (final f in files) {
    final name = p.posix.basename(f);
    if (name == 'robots.txt') {
      out.add(FileFinding(FindingCategory.seo, f, SeoCheck.robots));
    } else if (name.startsWith('sitemap') && name.endsWith('.xml')) {
      out.add(FileFinding(FindingCategory.seo, f, SeoCheck.sitemap));
    }
  }
  final index = c.htmlFiles.firstWhere(
    (f) => p.posix.basename(f) == 'index.html',
    orElse: () => c.htmlFiles.firstOrNull ?? '',
  );
  if (index.isNotEmpty) {
    final html = c.s.contents[index]!;
    final checks = {
      SeoCheck.title: RegExp(
        r'<title>\s*[^<\s][^<]*</title>',
        caseSensitive: false,
      ),
      SeoCheck.description: RegExp(
        r'''<meta[^>]+name=["']description["']''',
        caseSensitive: false,
      ),
      SeoCheck.canonical: RegExp(
        r'''<link[^>]+rel=["']canonical["']''',
        caseSensitive: false,
      ),
      SeoCheck.openGraph: RegExp(
        r'''<meta[^>]+property=["']og:''',
        caseSensitive: false,
      ),
      SeoCheck.twitterCard: RegExp(
        r'''<meta[^>]+name=["']twitter:''',
        caseSensitive: false,
      ),
      SeoCheck.structuredData: RegExp(
        r'application/ld\+json',
        caseSensitive: false,
      ),
    };
    checks.forEach((check, pattern) {
      if (pattern.hasMatch(html)) {
        out.add(FileFinding(FindingCategory.seo, index, check));
      }
    });
  }

  // Documents juridiques
  final legal = RegExp(
    r'^(privacy|confidentialit|politique[-_]de[-_]confidentialit|terms|cgu|cgv|conditions|mentions[-_]?legales|legal|license|licence)',
    caseSensitive: false,
  );
  for (final f in files) {
    final name = p.posix.basename(f);
    final ext = p.posix.extension(name).toLowerCase();
    if (legal.hasMatch(name) &&
        const {'', '.md', '.txt', '.html', '.htm', '.pdf'}.contains(ext)) {
      out.add(FileFinding(FindingCategory.legal, f));
    }
  }

  // Signature : présence seulement, ces fichiers ne sont jamais lus.
  for (final f in c.s.sensitiveFiles) {
    final name = p.posix.basename(f).toLowerCase();
    if (name == 'key.properties' ||
        name.endsWith('.jks') ||
        name.endsWith('.keystore') ||
        name.endsWith('.p12') ||
        name.endsWith('.mobileprovision')) {
      out.add(FileFinding(FindingCategory.signing, f, 'notRead'));
    }
  }
  for (final e in c.contentsWhere(
    (f) => f.endsWith('build.gradle') || f.endsWith('build.gradle.kts'),
  )) {
    if (e.value.contains('signingConfigs')) {
      out.add(FileFinding(FindingCategory.signing, e.key, 'signingConfigs'));
    }
  }
  return out;
}

/// Éléments SEO repérés (stockés dans `FileFinding.detail`).
abstract final class SeoCheck {
  static const robots = 'robots';
  static const sitemap = 'sitemap';
  static const title = 'title';
  static const description = 'description';
  static const canonical = 'canonical';
  static const openGraph = 'openGraph';
  static const twitterCard = 'twitterCard';
  static const structuredData = 'structuredData';

  static const all = [
    title,
    description,
    canonical,
    openGraph,
    twitterCard,
    structuredData,
    robots,
    sitemap,
  ];
}

// ----------------------------------------------------------- permissions

List<PermissionFinding> _permissions(_Context c) {
  final out = <PermissionFinding>[];
  final seen = <String>{};
  final android = RegExp(
    r'''<uses-permission(?:-sdk-\d+)?\s[^>]*android:name\s*=\s*["']([^"']+)["']''',
  );
  for (final e in c.contentsWhere((f) => f.endsWith('AndroidManifest.xml'))) {
    for (final m in android.allMatches(e.value)) {
      if (seen.add('android:${m[1]}')) {
        out.add(PermissionFinding(PlatformTarget.android, m[1]!, e.key));
      }
    }
  }
  final apple = RegExp(r'<key>\s*(NS[A-Za-z]+UsageDescription)\s*</key>');
  for (final e in c.contentsWhere((f) => f.endsWith('Info.plist'))) {
    final target = e.key.startsWith('macos/')
        ? PlatformTarget.macos
        : PlatformTarget.ios;
    for (final m in apple.allMatches(e.value)) {
      if (seen.add('${target.name}:${m[1]}')) {
        out.add(PermissionFinding(target, m[1]!, e.key));
      }
    }
  }
  return out;
}

// -------------------------------------------------------------- services

class _ServiceRule {
  const _ServiceRule(
    this.id,
    this.label,
    this.kind, {
    this.pub = const [],
    this.npm = const [],
    this.html = const [],
  });

  final String id;
  final String label;
  final ServiceKind kind;
  final List<String> pub;

  /// Noms exacts, ou préfixes de portée terminés par `/`.
  final List<String> npm;
  final List<String> html;
}

const _serviceRules = [
  _ServiceRule(
    'firebase_analytics',
    'Firebase Analytics',
    ServiceKind.analytics,
    pub: ['firebase_analytics'],
    npm: ['@react-native-firebase/analytics'],
  ),
  _ServiceRule(
    'google_analytics',
    'Google Analytics',
    ServiceKind.analytics,
    npm: ['react-ga4', 'vue-gtag', '@next/third-parties'],
    html: ['googletagmanager.com', 'google-analytics.com'],
  ),
  _ServiceRule(
    'plausible',
    'Plausible',
    ServiceKind.analytics,
    npm: ['plausible-tracker'],
    html: ['plausible.io/js'],
  ),
  _ServiceRule(
    'umami',
    'Umami',
    ServiceKind.analytics,
    html: ['umami.is', 'data-website-id'],
  ),
  _ServiceRule(
    'mixpanel',
    'Mixpanel',
    ServiceKind.analytics,
    pub: ['mixpanel_flutter'],
    npm: ['mixpanel-browser'],
  ),
  _ServiceRule(
    'amplitude',
    'Amplitude',
    ServiceKind.analytics,
    pub: ['amplitude_flutter'],
    npm: ['@amplitude/'],
  ),
  _ServiceRule(
    'posthog',
    'PostHog',
    ServiceKind.analytics,
    pub: ['posthog_flutter'],
    npm: ['posthog-js'],
  ),
  _ServiceRule('segment', 'Segment', ServiceKind.analytics, npm: ['@segment/']),
  _ServiceRule(
    'hotjar',
    'Hotjar',
    ServiceKind.analytics,
    html: ['static.hotjar.com'],
  ),
  _ServiceRule(
    'meta_pixel',
    'Meta (Facebook)',
    ServiceKind.ads,
    pub: ['facebook_app_events'],
    npm: ['react-facebook-pixel'],
    html: ['connect.facebook.net'],
  ),
  _ServiceRule(
    'admob',
    'Google AdMob',
    ServiceKind.ads,
    pub: ['google_mobile_ads'],
  ),
  _ServiceRule(
    'adsense',
    'Google AdSense',
    ServiceKind.ads,
    html: ['pagead2.googlesyndication.com'],
  ),
  _ServiceRule(
    'crashlytics',
    'Firebase Crashlytics',
    ServiceKind.crashReporting,
    pub: ['firebase_crashlytics'],
  ),
  _ServiceRule(
    'sentry',
    'Sentry',
    ServiceKind.crashReporting,
    pub: ['sentry_flutter', 'sentry'],
    npm: ['@sentry/'],
  ),
  _ServiceRule(
    'fcm',
    'Firebase Cloud Messaging',
    ServiceKind.messaging,
    pub: ['firebase_messaging'],
  ),
  _ServiceRule(
    'onesignal',
    'OneSignal',
    ServiceKind.messaging,
    pub: ['onesignal_flutter'],
    npm: ['react-onesignal'],
  ),
  _ServiceRule(
    'firebase',
    'Firebase',
    ServiceKind.backend,
    pub: ['firebase_core', 'firebase_auth', 'cloud_firestore'],
    npm: ['firebase'],
  ),
  _ServiceRule(
    'supabase',
    'Supabase',
    ServiceKind.backend,
    pub: ['supabase_flutter'],
    npm: ['@supabase/supabase-js'],
  ),
  _ServiceRule(
    'stripe',
    'Stripe',
    ServiceKind.payments,
    pub: ['flutter_stripe'],
    npm: ['@stripe/stripe-js', 'stripe'],
    html: ['js.stripe.com'],
  ),
  _ServiceRule(
    'in_app_purchase',
    'Achats intégrés',
    ServiceKind.payments,
    pub: ['in_app_purchase', 'purchases_flutter'],
  ),
];

List<ServiceFinding> _services(_Context c) {
  final out = <ServiceFinding>[];
  for (final rule in _serviceRules) {
    Evidence? evidence;
    for (final name in rule.pub) {
      if (c.pubDeps.containsKey(name)) {
        evidence = Evidence(c.pubspecPath!, name);
        break;
      }
    }
    if (evidence == null) {
      for (final name in rule.npm) {
        final match = name.endsWith('/')
            ? c.npmDeps.keys.where((k) => k.startsWith(name)).firstOrNull
            : (c.npmDeps.containsKey(name) ? name : null);
        if (match != null) {
          evidence = Evidence(c.packageJsonPath!, match);
          break;
        }
      }
    }
    if (evidence == null) {
      outer:
      for (final f in c.htmlFiles) {
        for (final needle in rule.html) {
          if (c.s.contents[f]!.contains(needle)) {
            evidence = Evidence(f, needle);
            break outer;
          }
        }
      }
    }
    if (evidence != null) {
      out.add(
        ServiceFinding(
          id: rule.id,
          label: rule.label,
          kind: rule.kind,
          evidence: evidence,
        ),
      );
    }
  }
  return out;
}
