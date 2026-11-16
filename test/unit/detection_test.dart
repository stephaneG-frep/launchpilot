import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/features/detection/data/project_scanner.dart';
import 'package:launchpilot/features/detection/domain/detection_report.dart';
import 'package:launchpilot/features/detection/domain/detectors.dart';
import 'package:path/path.dart' as p;

const fixtures = 'test/fixtures/projects';
final now = DateTime(2026, 10, 2, 9);

DetectionReport analyzeFixture(String name) =>
    detectProject(ProjectScanner.scan('$fixtures/$name'), now: now);

DetectionReport analyzeSnapshot(
  List<String> files, [
  Map<String, String> contents = const {},
]) => detectProject(
  ScanSnapshot(files: [...files, ...contents.keys], contents: contents),
  now: now,
);

TechDetection? tech(DetectionReport r, String id) =>
    r.technologies.where((t) => t.id == id).firstOrNull;

double target(DetectionReport r, PlatformTarget t) => r.targetFor(t).confidence;

List<String> findings(DetectionReport r, FindingCategory c) => [
  for (final f in r.findingsOf(c)) f.detail ?? f.path,
];

void main() {
  group('ProjectScanner', () {
    late Directory tmp;
    setUp(() => tmp = Directory.systemTemp.createTempSync('lp_scan_'));
    tearDown(() => tmp.deleteSync(recursive: true));

    void write(String relative, [String content = 'x']) {
      final file = File(p.join(tmp.path, relative));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(content);
    }

    test('ignore les dossiers générés et les dépendances', () {
      write('lib/main.dart');
      write('node_modules/react/package.json', '{}');
      write('build/app/output.txt');
      write('.dart_tool/package_config.json');
      write('android/app/build/intermediates/x.txt');
      write('.next/cache.txt');
      write('test/fixtures/autre/package.json', '{}');
      final s = ProjectScanner.scan(tmp.path);
      expect(s.files, ['lib/main.dart']);
      expect(s.partialReasons, isEmpty);
    });

    test('ne suit pas les liens symboliques (pas de sortie du projet)', () {
      final outside = Directory.systemTemp.createTempSync('lp_outside_');
      addTearDown(() => outside.deleteSync(recursive: true));
      File(p.join(outside.path, 'package.json')).writeAsStringSync('{}');
      write('index.html', '<title>t</title>');
      Link(p.join(tmp.path, 'lien')).createSync(outside.path);
      Link(p.join(tmp.path, 'lien.json'))
          .createSync(p.join(outside.path, 'package.json'));
      final s = ProjectScanner.scan(tmp.path);
      expect(s.files, ['index.html']);
    });

    test('ne lit jamais un fichier sensible, le signale seulement', () {
      write('android/key.properties', 'storePassword=secret-a-ne-pas-lire');
      write('.env', 'API_KEY=autre-secret');
      write('pubspec.yaml', 'name: x');
      final s = ProjectScanner.scan(tmp.path);
      expect(
        s.sensitiveFiles,
        unorderedEquals(['.env', 'android/key.properties']),
      );
      expect(s.contents.keys, ['pubspec.yaml']);
      expect(jsonEncode(s.contents), isNot(contains('secret')));
    });

    test('ne lit que les fichiers utiles et de taille raisonnable', () {
      write('package.json', '{"name":"a"}');
      write('src/huge.js', 'x' * 10);
      write('notes.txt', 'texte');
      write('pubspec.yaml', 'a' * 2000);
      final s = ProjectScanner.scan(
        tmp.path,
        limits: const ScanLimits(maxFileBytes: 1000),
      );
      expect(s.contents.keys, ['package.json']);
      expect(s.files, hasLength(4));
    });

    test('limites atteintes : analyse marquée partielle', () {
      for (var i = 0; i < 30; i++) {
        write('f$i.txt');
      }
      write('a/b/c/d/e/deep.txt');
      final byFiles = ProjectScanner.scan(
        tmp.path,
        limits: const ScanLimits(maxFiles: 10),
      );
      expect(byFiles.files, hasLength(10));
      expect(byFiles.partialReasons, contains(PartialReason.maxFiles));

      final byDepth = ProjectScanner.scan(
        tmp.path,
        limits: const ScanLimits(maxDepth: 2),
      );
      expect(byDepth.partialReasons, contains(PartialReason.maxDepth));
      expect(byDepth.files, isNot(contains('a/b/c/d/e/deep.txt')));
    });

    test('lit la branche et les tags dans .git sans exécuter git', () {
      write('.git/HEAD', 'ref: refs/heads/release/1.3\n');
      write('.git/refs/tags/v1.0.0', 'abc');
      write('.git/refs/tags/beta/b1', 'abc');
      write(
        '.git/packed-refs',
        '# pack-refs with: peeled\n'
            '${'a' * 40} refs/tags/v0.9.0\n'
            '^${'b' * 40}\n'
            '${'c' * 40} refs/heads/main\n',
      );
      write('.git/objects/aa/blob', 'binaire');
      write('README.md');
      final r = detectProject(ProjectScanner.scan(tmp.path), now: now);
      expect(r.git.present, isTrue);
      expect(r.git.branch, 'release/1.3');
      expect(r.git.tags, ['beta/b1', 'v0.9.0', 'v1.0.0']);
      expect(r.filesScanned, 1, reason: 'le contenu de .git n\'est pas listé');
    });

    test('HEAD détachée et .git en fichier (worktree)', () {
      write('.git/HEAD', '${'f' * 40}\n');
      expect(
        detectProject(
          ProjectScanner.scan(tmp.path),
          now: now,
        ).git.detachedCommit,
        'fffffff',
      );
      Directory(p.join(tmp.path, '.git')).deleteSync(recursive: true);
      write('.git', 'gitdir: ../main/.git/worktrees/x');
      final git = detectProject(ProjectScanner.scan(tmp.path), now: now).git;
      expect(git.present, isTrue);
      expect(git.linkedWorktree, isTrue);
    });
  });

  group('projets d\'exemple', () {
    test('application Flutter', () {
      final r = analyzeFixture('flutter_app');
      expect(tech(r, 'flutter')!.confidence, greaterThan(0.95));
      expect(tech(r, 'flutter')!.evidence.first.path, 'pubspec.yaml');
      expect(tech(r, 'dart'), isNotNull);
      expect(target(r, PlatformTarget.android), 0.95);
      expect(target(r, PlatformTarget.ios), 0.95);
      expect(target(r, PlatformTarget.web), 0.95);
      for (final t in [
        PlatformTarget.linux,
        PlatformTarget.windows,
        PlatformTarget.macos,
      ]) {
        expect(r.targetFor(t).detected, isFalse, reason: t.name);
      }
      expect(r.packages.single.manager, 'pub');
      expect(r.packages.single.lockFile, 'pubspec.lock');

      expect(findings(r, FindingCategory.icon), [
        'android mipmap ×1',
        'assets/app_icon.png',
        'flutter_launcher_icons',
      ]);
      expect(findings(r, FindingCategory.fastlane), ['fastlane/Fastfile']);
      expect(findings(r, FindingCategory.ci), ['.github/workflows/build.yml']);
      expect(findings(r, FindingCategory.pwa), ['manifest']);
      expect(findings(r, FindingCategory.legal), ['PRIVACY.md']);
      expect(
        findings(r, FindingCategory.signing),
        unorderedEquals(['notRead', 'signingConfigs']),
      );
      expect(r.sensitiveFiles, ['android/key.properties']);
      expect(
        jsonEncode(r.toJson()),
        isNot(contains('valeur-fixture-ne-doit-pas-etre-lue')),
      );

      expect(
        [for (final p in r.permissions) '${p.target.name}:${p.name}'],
        [
          'android:android.permission.INTERNET',
          'android:android.permission.CAMERA',
          'ios:NSCameraUsageDescription',
          'ios:NSLocationWhenInUseUsageDescription',
        ],
      );
      expect(r.services.map((s) => s.id), ['firebase_analytics', 'admob']);
      expect(r.partial, isFalse);
    });

    test('React + Vite', () {
      final r = analyzeFixture('react_vite');
      expect(tech(r, 'react')!.confidence, 0.92);
      expect(tech(r, 'vite')!.confidence, 0.98);
      expect(tech(r, 'node'), isNotNull);
      expect(tech(r, 'static'), isNull);
      expect(target(r, PlatformTarget.web), 0.9);
      expect(target(r, PlatformTarget.android), 0);
      final pkg = r.packages.single;
      expect(pkg.manager, 'pnpm');
      expect(pkg.scripts.keys, ['dev', 'build', 'preview']);
      expect(pkg.scripts['build'], 'tsc && vite build');
      expect(
        findings(r, FindingCategory.seo),
        unorderedEquals(['robots', 'title', 'description', 'openGraph']),
      );
      expect(findings(r, FindingCategory.hosting), ['Vercel']);
      expect(findings(r, FindingCategory.icon), ['public/favicon.svg']);
      expect(
        r.services.map((s) => s.id),
        unorderedEquals(['google_analytics', 'sentry']),
      );
    });

    test('site statique', () {
      final r = analyzeFixture('static_site');
      expect(tech(r, 'static'), isNotNull);
      expect(tech(r, 'node'), isNull);
      expect(target(r, PlatformTarget.web), 0.9);
      expect(
        findings(r, FindingCategory.seo),
        unorderedEquals(['sitemap', 'title', 'canonical', 'structuredData']),
      );
      expect(findings(r, FindingCategory.hosting), ['GitHub Pages']);
      expect(findings(r, FindingCategory.legal), ['mentions-legales.html']);
      expect(
        findings(r, FindingCategory.pwa),
        unorderedEquals(['manifest', 'service worker']),
      );
      expect(r.services.single.id, 'plausible');
    });

    test('Next.js', () {
      final r = analyzeFixture('nextjs');
      expect(tech(r, 'nextjs')!.confidence, 0.98);
      expect(tech(r, 'react'), isNull, reason: 'Next.js englobe React');
      expect(findings(r, FindingCategory.hosting), ['Netlify']);
      expect(r.packages.single.manager, 'npm');
      expect(r.packages.single.lockFile, isNull);
    });

    test('API FastAPI : détection informative, aucune cible', () {
      final r = analyzeFixture('python_api');
      expect(tech(r, 'python')!.informative, isTrue);
      expect(tech(r, 'fastapi')!.informative, isTrue);
      expect(tech(r, 'flask'), isNull);
      expect(r.targets.where((t) => t.detected), isEmpty);
      expect(r.packages.single.manager, 'pip');
    });
  });

  group('détecteurs sur instantanés', () {
    test('Vue + Vite, Nuxt, Angular, SvelteKit, Astro', () {
      String pkg(Map<String, String> deps) =>
          jsonEncode({'dependencies': deps});

      final vue = analyzeSnapshot(
        ['vite.config.js'],
        {
          'package.json': pkg({'vue': '^3', 'vite': '^5'}),
        },
      );
      expect(tech(vue, 'vue'), isNotNull);
      expect(tech(vue, 'vite')!.confidence, 0.98);

      final nuxt = analyzeSnapshot(
        ['nuxt.config.ts'],
        {
          'package.json': pkg({'nuxt': '^3', 'vue': '^3'}),
        },
      );
      expect(tech(nuxt, 'nuxt'), isNotNull);
      expect(tech(nuxt, 'vue'), isNull);

      final angular = analyzeSnapshot(
        ['angular.json'],
        {
          'package.json': pkg({'@angular/core': '^18'}),
        },
      );
      expect(tech(angular, 'angular')!.confidence, 0.98);

      final kit = analyzeSnapshot(
        ['svelte.config.js'],
        {
          'package.json': pkg({'@sveltejs/kit': '^2', 'svelte': '^5'}),
        },
      );
      expect(tech(kit, 'sveltekit'), isNotNull);
      expect(tech(kit, 'svelte'), isNull);

      final astro = analyzeSnapshot(
        ['astro.config.mjs'],
        {
          'package.json': pkg({'astro': '^4'}),
        },
      );
      expect(tech(astro, 'astro'), isNotNull);
      expect(target(astro, PlatformTarget.web), 0.9);
    });

    test('Django et Flask', () {
      final django = analyzeSnapshot(
        ['manage.py'],
        {'requirements.txt': 'Django==5.0\n'},
      );
      expect(tech(django, 'django')!.confidence, 0.95);

      final flask = analyzeSnapshot(const [], {
        'app.py': 'from flask import Flask\n',
      });
      expect(tech(flask, 'flask'), isNotNull);
      expect(tech(flask, 'python')!.confidence, 0.6);
    });

    test('dossier Flutter sans fichier probant : confiance moyenne', () {
      final r = analyzeSnapshot(
        ['macos/notes.txt'],
        {
          'pubspec.yaml':
              'name: a\ndependencies:\n  flutter:\n    sdk: flutter\n',
        },
      );
      expect(target(r, PlatformTarget.macos), 0.6);
      expect(r.targetFor(PlatformTarget.macos).detected, isTrue);
    });

    test(
      'Flutter dans un sous-dossier : cibles cherchées à côté du pubspec',
      () {
        final r = analyzeSnapshot(
          ['examples/app/android/app/src/main/AndroidManifest.xml'],
          {
            'examples/app/pubspec.yaml':
                'name: a\ndependencies:\n  flutter:\n    sdk: flutter\n',
          },
        );
        expect(target(r, PlatformTarget.android), 0.95);
        expect(
          r.targetFor(PlatformTarget.android).evidence.single.path,
          'examples/app/android/app/src/main/AndroidManifest.xml',
        );
      },
    );

    test('projet vide ou manifestes illisibles : aucun plantage', () {
      final empty = analyzeSnapshot(const []);
      expect(empty.technologies, isEmpty);
      expect(empty.targets, hasLength(PlatformTarget.values.length));
      expect(empty.targets.every((t) => t.confidence == 0), isTrue);

      final broken = analyzeSnapshot(const [], {
        'package.json': '{ pas du json',
        'pubspec.yaml': ': : :',
      });
      expect(tech(broken, 'node'), isNull);
      expect(tech(broken, 'flutter'), isNull);
    });
  });

  test('le rapport survit à un aller-retour JSON', () {
    final r = analyzeFixture('flutter_app');
    final back = DetectionReport.fromJson(
      (jsonDecode(jsonEncode(r.toJson())) as Map).cast(),
    );
    expect(jsonEncode(back.toJson()), jsonEncode(r.toJson()));
  });
}
