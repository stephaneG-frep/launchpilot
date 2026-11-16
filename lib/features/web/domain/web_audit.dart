import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../core/domain/audit_status.dart';

export '../../../core/domain/audit_status.dart';

/// Contenu lu d'un site (dossier de sortie ou sources), chemins relatifs.
@immutable
class SiteSnapshot {
  const SiteSnapshot({
    required this.files,
    required this.texts,
    this.truncated = false,
  });

  /// Tous les fichiers vus.
  final Set<String> files;

  /// Contenu des fichiers texte utiles (HTML, manifeste, robots, sitemap,
  /// service worker).
  final Map<String, String> texts;

  /// Limites atteintes : l'audit ne couvre qu'une partie du site.
  final bool truncated;

  Iterable<String> get htmlFiles =>
      texts.keys.where((f) => f.endsWith('.html') || f.endsWith('.htm'));

  /// Ajoute les fichiers de [other], servis à la même racine.
  SiteSnapshot merge(SiteSnapshot other) => SiteSnapshot(
    files: {...files, ...other.files},
    texts: {...texts, ...other.texts},
    truncated: truncated || other.truncated,
  );
}

enum AuditArea {
  seo,
  responsive,
  pwa,
  accessibility,
  links,
  https,
  forms,
  errors,
}

/// Résultat d'un contrôle ; [id] sert à la traduction, [values] aux détails.
@immutable
class AuditItem {
  const AuditItem(this.area, this.id, this.status, [this.values = const []]);

  final AuditArea area;
  final String id;
  final AuditStatus status;
  final List<String> values;

  @override
  String toString() => '$area.$id:$status$values';
}

@immutable
class WebAudit {
  const WebAudit(this.items, {this.truncated = false, this.index});

  final List<AuditItem> items;
  final bool truncated;

  /// Page principale examinée.
  final String? index;

  Iterable<AuditItem> inArea(AuditArea a) => items.where((i) => i.area == a);

  int count(AuditStatus s) => items.where((i) => i.status == s).length;

  AuditItem? find(String id) => items.where((i) => i.id == id).firstOrNull;
}

RegExp _re(String pattern) => RegExp(pattern, caseSensitive: false);

/// Valeur d'un attribut dans une balise (guillemets simples ou doubles).
String? attr(String tag, String name) =>
    _re('\\s$name\\s*=\\s*(?:"([^"]*)"|\'([^\']*)\')')
        .firstMatch(tag)
        ?.let((m) => m.group(1) ?? m.group(2));

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

Iterable<String> tags(String html, String name) =>
    _re('<$name\\b[^>]*>').allMatches(html).map((m) => m.group(0)!);

String? metaContent(String html, String key, {String by = 'name'}) {
  for (final t in tags(html, 'meta')) {
    if (attr(t, by)?.toLowerCase() == key.toLowerCase()) {
      return attr(t, 'content');
    }
  }
  return null;
}

String? pageTitle(String html) =>
    _re(r'<title[^>]*>([^<]*)</title>').firstMatch(html)?.group(1)?.trim();

String? linkHref(String html, String rel) {
  for (final t in tags(html, 'link')) {
    final r = attr(t, 'rel')?.toLowerCase().split(RegExp(r'\s+')) ?? const [];
    if (r.contains(rel)) return attr(t, 'href');
  }
  return null;
}

/// Contrôles statiques, sans réseau ni navigateur. [spa] : les routes
/// sans extension sont servies par index.html et ne sont pas vérifiées.
WebAudit auditSite(SiteSnapshot site, {bool spa = false}) {
  final items = <AuditItem>[];
  void add(
    AuditArea a,
    String id,
    AuditStatus s, [
    List<String> v = const [],
  ]) => items.add(AuditItem(a, id, s, v));

  final pages = site.htmlFiles.toList()..sort();
  final index = pages.contains('index.html')
      ? 'index.html'
      : pages.where((f) => p.posix.basename(f) == 'index.html').firstOrNull ??
            pages.firstOrNull;
  if (index == null) {
    add(AuditArea.errors, 'noIndex', AuditStatus.failure);
    return WebAudit(items, truncated: site.truncated);
  }
  final html = site.texts[index]!;
  final base = p.posix.dirname(index) == '.' ? '' : p.posix.dirname(index);
  String rel(String name) => base.isEmpty ? name : '$base/$name';

  // ------------------------------------------------------------------ SEO
  final title = pageTitle(html);
  if (title == null || title.isEmpty) {
    add(AuditArea.seo, 'title', AuditStatus.failure);
  } else if (title.length < 10 || title.length > 60) {
    add(AuditArea.seo, 'titleLength', AuditStatus.warning, [
      title,
      '${title.length}',
    ]);
  } else {
    add(AuditArea.seo, 'title', AuditStatus.ok, [title]);
  }
  final description = metaContent(html, 'description');
  if (description == null || description.trim().isEmpty) {
    add(AuditArea.seo, 'description', AuditStatus.failure);
  } else if (description.length < 50 || description.length > 160) {
    add(AuditArea.seo, 'descriptionLength', AuditStatus.warning, [
      '${description.length}',
    ]);
  } else {
    add(AuditArea.seo, 'description', AuditStatus.ok);
  }
  final canonical = linkHref(html, 'canonical');
  add(
    AuditArea.seo,
    'canonical',
    canonical == null ? AuditStatus.warning : AuditStatus.ok,
    [?canonical],
  );
  final og = [
    for (final k in const ['og:title', 'og:description', 'og:image'])
      if (metaContent(html, k, by: 'property') == null) k,
  ];
  add(
    AuditArea.seo,
    'openGraph',
    og.isEmpty ? AuditStatus.ok : AuditStatus.warning,
    og,
  );
  add(
    AuditArea.seo,
    'twitterCard',
    metaContent(html, 'twitter:card') == null
        ? AuditStatus.warning
        : AuditStatus.ok,
  );
  final ld = _re(r'<script[^>]+application/ld\+json[^>]*>([\s\S]*?)</script>')
      .firstMatch(html);
  if (ld == null) {
    add(AuditArea.seo, 'structuredData', AuditStatus.warning);
  } else {
    try {
      jsonDecode(ld.group(1)!);
      add(AuditArea.seo, 'structuredData', AuditStatus.ok);
    } on FormatException {
      add(AuditArea.seo, 'structuredDataInvalid', AuditStatus.failure);
    }
  }
  final lang = _re(r'<html[^>]*\slang\s*=').hasMatch(html);
  add(AuditArea.seo, 'lang', lang ? AuditStatus.ok : AuditStatus.warning);
  final robotsMeta = metaContent(html, 'robots') ?? '';
  if (robotsMeta.toLowerCase().contains('noindex')) {
    add(AuditArea.seo, 'noindex', AuditStatus.failure);
  }
  final robots = site.texts[rel('robots.txt')];
  if (robots == null) {
    add(AuditArea.seo, 'robots', AuditStatus.warning);
  } else if (RegExp(
    r'^\s*disallow:\s*/\s*$',
    multiLine: true,
    caseSensitive: false,
  ).hasMatch(robots)) {
    add(AuditArea.seo, 'robotsBlocksAll', AuditStatus.failure);
  } else {
    add(AuditArea.seo, 'robots', AuditStatus.ok);
  }
  final sitemapName = site.files
      .where(
        (f) =>
            p.posix.dirname(f) == (base.isEmpty ? '.' : base) &&
            p.posix.basename(f).startsWith('sitemap') &&
            f.endsWith('.xml'),
      )
      .firstOrNull;
  if (sitemapName == null) {
    add(AuditArea.seo, 'sitemap', AuditStatus.warning);
  } else {
    final xml = site.texts[sitemapName] ?? '';
    add(
      AuditArea.seo,
      'sitemap',
      xml.contains('<urlset') || xml.contains('<sitemapindex')
          ? AuditStatus.ok
          : AuditStatus.failure,
      [sitemapName],
    );
  }

  // ----------------------------------------------------------- Responsive
  final viewport = metaContent(html, 'viewport');
  add(
    AuditArea.responsive,
    'viewport',
    viewport == null
        ? AuditStatus.failure
        : viewport.contains('width=device-width')
        ? AuditStatus.ok
        : AuditStatus.warning,
  );

  // ------------------------------------------------------------------ PWA
  final manifestHref = linkHref(html, 'manifest');
  Map<String, Object?>? manifest;
  if (manifestHref == null) {
    add(AuditArea.pwa, 'manifestLink', AuditStatus.warning);
  } else {
    final path = _resolve(base, manifestHref);
    final raw = path == null ? null : site.texts[path];
    if (raw == null) {
      add(AuditArea.pwa, 'manifestMissing', AuditStatus.failure, [
        manifestHref,
      ]);
    } else {
      try {
        manifest = (jsonDecode(raw) as Map).cast<String, Object?>();
      } on Object {
        add(AuditArea.pwa, 'manifestInvalid', AuditStatus.failure);
      }
    }
  }
  if (manifest != null) {
    final missing = [
      for (final k in const [
        'name',
        'short_name',
        'start_url',
        'display',
        'theme_color',
        'background_color',
      ])
        if ('${manifest[k] ?? ''}'.isEmpty) k,
    ];
    add(
      AuditArea.pwa,
      'manifestFields',
      missing.isEmpty ? AuditStatus.ok : AuditStatus.warning,
      missing,
    );
    final icons = (manifest['icons'] as List?)?.whereType<Map>().toList() ?? [];
    final sizes = {
      for (final i in icons) ...'${i['sizes'] ?? ''}'.split(RegExp(r'\s+')),
    };
    final needed = [
      for (final s in const ['192x192', '512x512'])
        if (!sizes.contains(s)) s,
    ];
    add(
      AuditArea.pwa,
      'manifestIcons',
      needed.isEmpty ? AuditStatus.ok : AuditStatus.failure,
      needed,
    );
    final maskable = icons.any(
      (i) => '${i['purpose'] ?? ''}'.contains('maskable'),
    );
    add(
      AuditArea.pwa,
      'maskable',
      maskable ? AuditStatus.ok : AuditStatus.info,
    );
    final manifestDir = p.posix.dirname(_resolve(base, manifestHref!)!);
    final missingIcons = [
      for (final i in icons)
        if (_resolve(manifestDir == '.' ? '' : manifestDir, '${i['src']}')
            case final path? when !site.files.contains(path))
          '${i['src']}',
    ];
    if (missingIcons.isNotEmpty) {
      add(AuditArea.pwa, 'iconFiles', AuditStatus.failure, missingIcons);
    }
  }
  add(
    AuditArea.pwa,
    'themeColor',
    metaContent(html, 'theme-color') == null
        ? AuditStatus.info
        : AuditStatus.ok,
  );
  final registers = site.texts.entries.any(
    (e) =>
        (e.key.endsWith('.html') || e.key.endsWith('.js')) &&
        e.value.contains('serviceWorker.register'),
  );
  final workers = site.files.where(
    (f) => const {
      'sw.js',
      'service-worker.js',
      'serviceWorker.js',
      'flutter_service_worker.js',
    }.contains(p.posix.basename(f)),
  );
  if (!registers && workers.isEmpty) {
    add(AuditArea.pwa, 'serviceWorker', AuditStatus.info);
  } else {
    final offline = workers.any(
      (w) =>
          (site.texts[w] ?? '').contains("addEventListener('fetch'") ||
          (site.texts[w] ?? '').contains('addEventListener("fetch"'),
    );
    add(
      AuditArea.pwa,
      offline ? 'offline' : 'serviceWorkerNoFetch',
      offline ? AuditStatus.ok : AuditStatus.warning,
      workers.toList(),
    );
  }

  // -------------------------------------------- Accessibilité, liens, etc.
  var noAlt = 0;
  var unlabeled = 0;
  var emptyButtons = 0;
  final broken = <String>{};
  final mixed = <String>{};
  final insecureForms = <String>{};
  var forms = 0;
  for (final page in pages) {
    final content = site.texts[page]!;
    final dir = p.posix.dirname(page) == '.' ? '' : p.posix.dirname(page);
    noAlt += tags(content, 'img').where((t) => attr(t, 'alt') == null).length;

    final labelled = {for (final t in tags(content, 'label')) ?attr(t, 'for')};
    for (final t in tags(content, 'input')) {
      final type = attr(t, 'type')?.toLowerCase() ?? 'text';
      if (const {
        'hidden',
        'submit',
        'button',
        'reset',
        'image',
      }.contains(type)) {
        continue;
      }
      final id = attr(t, 'id');
      if ((id == null || !labelled.contains(id)) &&
          attr(t, 'aria-label') == null &&
          attr(t, 'aria-labelledby') == null &&
          attr(t, 'title') == null) {
        unlabeled++;
      }
    }
    emptyButtons += _re(r'<button\b([^>]*)>\s*</button>')
        .allMatches(content)
        .where((m) => !m.group(1)!.contains('aria-label'))
        .length;

    for (final t in tags(content, 'form')) {
      forms++;
      final action = attr(t, 'action') ?? '';
      if (action.toLowerCase().startsWith('http://')) insecureForms.add(action);
    }

    for (final m in _re(
      r'''\s(?:src|href)\s*=\s*["']([^"']+)["']''',
    ).allMatches(content)) {
      final url = m.group(1)!.trim();
      final lower = url.toLowerCase();
      final tag = content.substring(content.lastIndexOf('<', m.start), m.end);
      final isLink = tag.toLowerCase().startsWith('<a');
      if (lower.startsWith('http://')) {
        // Ressource chargée en HTTP sur une page HTTPS : bloquée.
        if (!isLink && !lower.startsWith('http://localhost')) mixed.add(url);
        continue;
      }
      if (lower.startsWith('https://') ||
          lower.startsWith('//') ||
          lower.startsWith('#') ||
          lower.startsWith('mailto:') ||
          lower.startsWith('tel:') ||
          lower.startsWith('data:') ||
          lower.startsWith('javascript:') ||
          url.contains('{{') ||
          url.contains(r'${')) {
        continue;
      }
      final clean = url.split(RegExp(r'[?#]')).first;
      if (clean.isEmpty) continue;
      final ext = p.posix.extension(clean);
      if (spa && ext.isEmpty) continue;
      final target = _resolve(clean.startsWith('/') ? base : dir, clean);
      if (target == null) continue;
      final exists =
          site.files.contains(target) ||
          site.files.contains('$target/index.html') ||
          (ext.isEmpty && site.files.contains('$target.html')) ||
          (target.isEmpty && site.files.contains('index.html'));
      if (!exists) broken.add(url);
    }
  }
  add(
    AuditArea.accessibility,
    'imgAlt',
    noAlt == 0 ? AuditStatus.ok : AuditStatus.warning,
    ['$noAlt'],
  );
  add(
    AuditArea.accessibility,
    'labels',
    unlabeled == 0 ? AuditStatus.ok : AuditStatus.warning,
    ['$unlabeled'],
  );
  if (emptyButtons > 0) {
    add(AuditArea.accessibility, 'emptyButtons', AuditStatus.warning, [
      '$emptyButtons',
    ]);
  }
  add(
    AuditArea.links,
    'broken',
    broken.isEmpty ? AuditStatus.ok : AuditStatus.failure,
    broken.take(20).toList(),
  );
  add(
    AuditArea.https,
    'mixedContent',
    mixed.isEmpty ? AuditStatus.ok : AuditStatus.failure,
    mixed.take(20).toList(),
  );
  add(AuditArea.forms, 'forms', AuditStatus.info, ['$forms']);
  if (insecureForms.isNotEmpty) {
    add(
      AuditArea.forms,
      'insecureAction',
      AuditStatus.failure,
      insecureForms.toList(),
    );
  }
  final has404 = site.files.contains(rel('404.html'));
  add(
    AuditArea.errors,
    'notFoundPage',
    has404
        ? AuditStatus.ok
        : spa
        ? AuditStatus.info
        : AuditStatus.warning,
  );

  return WebAudit(items, truncated: site.truncated, index: index);
}

/// Chemin relatif au site d'une URL locale ; null si elle sort du site.
String? _resolve(String dir, String url) {
  final clean = url.split(RegExp(r'[?#]')).first;
  final joined = clean.startsWith('/')
      ? p.posix.join(dir, clean.substring(1))
      : p.posix.join(dir, clean);
  final n = p.posix.normalize(joined);
  if (n == '.') return '';
  if (n.startsWith('..')) return null;
  return n.endsWith('/') ? n.substring(0, n.length - 1) : n;
}
