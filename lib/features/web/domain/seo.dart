import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/domain/hosting.dart';

/// Informations SEO saisies par l'utilisateur.
@immutable
class SeoMeta {
  const SeoMeta({
    this.title = '',
    this.description = '',
    this.siteUrl = '',
    this.imageUrl = '',
    this.siteName = '',
    this.twitterHandle = '',
    this.locale = 'fr_FR',
    this.schemaType = SchemaType.website,
  });

  final String title;
  final String description;

  /// Adresse publique, ex. https://meteo.example.
  final String siteUrl;
  final String imageUrl;
  final String siteName;
  final String twitterHandle;
  final String locale;
  final SchemaType schemaType;

  String get normalizedUrl => normalizeSiteUrl(siteUrl);

  bool get siteUrlValid => isValidSiteUrl(siteUrl);

  SeoMeta copyWith({
    String? title,
    String? description,
    String? siteUrl,
    String? imageUrl,
    String? siteName,
    String? twitterHandle,
    String? locale,
    SchemaType? schemaType,
  }) => SeoMeta(
    title: title ?? this.title,
    description: description ?? this.description,
    siteUrl: siteUrl ?? this.siteUrl,
    imageUrl: imageUrl ?? this.imageUrl,
    siteName: siteName ?? this.siteName,
    twitterHandle: twitterHandle ?? this.twitterHandle,
    locale: locale ?? this.locale,
    schemaType: schemaType ?? this.schemaType,
  );

  Map<String, Object?> toJson() => {
    'title': title,
    'description': description,
    'siteUrl': siteUrl,
    'imageUrl': imageUrl,
    'siteName': siteName,
    'twitterHandle': twitterHandle,
    'locale': locale,
    'schemaType': schemaType.name,
  };

  factory SeoMeta.fromJson(Map<String, Object?> j) => SeoMeta(
    title: '${j['title'] ?? ''}',
    description: '${j['description'] ?? ''}',
    siteUrl: '${j['siteUrl'] ?? ''}',
    imageUrl: '${j['imageUrl'] ?? ''}',
    siteName: '${j['siteName'] ?? ''}',
    twitterHandle: '${j['twitterHandle'] ?? ''}',
    locale: '${j['locale'] ?? 'fr_FR'}',
    schemaType:
        SchemaType.values.where((t) => t.name == j['schemaType']).firstOrNull ??
        SchemaType.website,
  );
}

/// Type schema.org décrivant le site.
enum SchemaType {
  website('WebSite'),
  application('WebApplication'),
  organization('Organization');

  const SchemaType(this.type);
  final String type;
}

/// `https://exemple.fr/` → `https://exemple.fr` (sans barre finale).
String normalizeSiteUrl(String url) {
  var u = url.trim();
  while (u.endsWith('/')) {
    u = u.substring(0, u.length - 1);
  }
  return u;
}

bool isValidSiteUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  return uri != null &&
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.contains('.') &&
      !uri.host.contains(' ');
}

String _escape(String v) =>
    const HtmlEscape(HtmlEscapeMode.attribute).convert(v);

const _seoStart = '<!-- LaunchPilot SEO -->';
const _seoEnd = '<!-- /LaunchPilot SEO -->';

/// Bloc de balises à placer dans `<head>`.
String seoHeadBlock(SeoMeta m, {String indent = '  '}) {
  final url = m.normalizedUrl;
  final lines = <String>[
    if (m.description.isNotEmpty)
      '<meta name="description" content="${_escape(m.description)}">',
    if (url.isNotEmpty) '<link rel="canonical" href="${_escape('$url/')}">',
    '<meta property="og:type" content="website">',
    if (m.title.isNotEmpty)
      '<meta property="og:title" content="${_escape(m.title)}">',
    if (m.description.isNotEmpty)
      '<meta property="og:description" content="${_escape(m.description)}">',
    if (url.isNotEmpty)
      '<meta property="og:url" content="${_escape('$url/')}">',
    if (m.imageUrl.isNotEmpty)
      '<meta property="og:image" content="${_escape(m.imageUrl)}">',
    if (m.siteName.isNotEmpty)
      '<meta property="og:site_name" content="${_escape(m.siteName)}">',
    '<meta property="og:locale" content="${_escape(m.locale)}">',
    '<meta name="twitter:card" content="${m.imageUrl.isEmpty ? 'summary' : 'summary_large_image'}">',
    if (m.twitterHandle.isNotEmpty)
      '<meta name="twitter:site" content="${_escape(_handle(m.twitterHandle))}">',
    '<script type="application/ld+json">${structuredData(m)}</script>',
  ];
  return [
    '$indent$_seoStart',
    for (final l in lines) '$indent$l',
    '$indent$_seoEnd',
  ].join('\n');
}

String _handle(String h) => h.startsWith('@') ? h : '@$h';

/// Données structurées schema.org (JSON compact, `</` neutralisé).
String structuredData(SeoMeta m) {
  final data = <String, Object?>{
    '@context': 'https://schema.org',
    '@type': m.schemaType.type,
    'name': m.siteName.isNotEmpty ? m.siteName : m.title,
    if (m.normalizedUrl.isNotEmpty) 'url': '${m.normalizedUrl}/',
    if (m.description.isNotEmpty) 'description': m.description,
    if (m.schemaType == SchemaType.application) ...{
      'applicationCategory': 'UtilitiesApplication',
      'operatingSystem': 'Web',
    },
    if (m.schemaType == SchemaType.organization && m.imageUrl.isNotEmpty)
      'logo': m.imageUrl,
  };
  return jsonEncode(data).replaceAll('</', r'<\/');
}

/// Insère ou remplace le bloc SEO de LaunchPilot dans une page HTML.
/// Les balises équivalentes déjà présentes hors du bloc sont retirées pour
/// éviter les doublons (visible dans le diff avant écriture). Renvoie null
/// si la page n'a pas de `<head>`.
String? applySeoMeta(String html, SeoMeta m) {
  final headClose = RegExp('</head>', caseSensitive: false);
  if (!headClose.hasMatch(html)) return null;

  var out = html;
  // Ancien bloc LaunchPilot.
  out = out.replaceAll(
    RegExp(
      '[ \\t]*${RegExp.escape(_seoStart)}[\\s\\S]*?${RegExp.escape(_seoEnd)}\\n?',
    ),
    '',
  );
  // Doublons hors bloc.
  final managed = [
    if (m.description.isNotEmpty)
      r'''<meta[^>]+name=["']description["'][^>]*>''',
    if (m.normalizedUrl.isNotEmpty)
      r'''<link[^>]+rel=["']canonical["'][^>]*>''',
    r'''<meta[^>]+property=["']og:[a-z_:]+["'][^>]*>''',
    r'''<meta[^>]+name=["']twitter:[a-z_:]+["'][^>]*>''',
    r'''<script[^>]+application/ld\+json[^>]*>[\s\S]*?</script>''',
  ];
  for (final pattern in managed) {
    out = out.replaceAll(
      RegExp('[ \\t]*$pattern[ \\t]*\\n?', caseSensitive: false),
      '',
    );
  }
  if (m.title.isNotEmpty) {
    final t = RegExp(r'<title[^>]*>[^<]*</title>', caseSensitive: false);
    final escaped = const HtmlEscape(HtmlEscapeMode.element).convert(m.title);
    out = t.hasMatch(out)
        ? out.replaceFirst(t, '<title>$escaped</title>')
        : out.replaceFirst(headClose, '  <title>$escaped</title>\n</head>');
  }
  final close = headClose.firstMatch(out)!;
  return '${out.substring(0, close.start)}${seoHeadBlock(m)}\n${out.substring(close.start)}';
}

/// robots.txt : tout autoriser (sauf [disallow]) et indiquer le sitemap.
String robotsTxt(String siteUrl, {List<String> disallow = const []}) {
  final url = normalizeSiteUrl(siteUrl);
  return [
    'User-agent: *',
    if (disallow.isEmpty) 'Allow: /',
    for (final d in disallow) 'Disallow: $d',
    '',
    if (url.isNotEmpty) 'Sitemap: $url/sitemap.xml',
    '',
  ].join('\n');
}

/// Chemins de pages d'un site (fichiers HTML) → chemins d'URL.
List<String> pagePaths(Iterable<String> htmlFiles, {String base = ''}) {
  final out = <String>{};
  for (var f in htmlFiles) {
    if (base.isNotEmpty) {
      if (!f.startsWith('$base/')) continue;
      f = f.substring(base.length + 1);
    }
    if (f == '404.html' || f.endsWith('/404.html')) continue;
    if (f == 'index.html') {
      out.add('/');
    } else if (f.endsWith('/index.html')) {
      out.add('/${f.substring(0, f.length - 'index.html'.length)}');
    } else {
      out.add('/$f');
    }
  }
  return out.toList()..sort();
}

String _xml(String v) => const HtmlEscape(HtmlEscapeMode.element).convert(v);

/// sitemap.xml pour [paths] (commençant par `/`).
String sitemapXml(String siteUrl, List<String> paths, DateTime lastmod) {
  final url = normalizeSiteUrl(siteUrl);
  final day =
      '${lastmod.year}-${lastmod.month.toString().padLeft(2, '0')}-${lastmod.day.toString().padLeft(2, '0')}';
  final unique = {for (final p in paths) p.startsWith('/') ? p : '/$p'};
  return [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    for (final path in unique) ...[
      '  <url>',
      '    <loc>${_xml('$url$path')}</loc>',
      '    <lastmod>$day</lastmod>',
      '  </url>',
    ],
    '</urlset>',
    '',
  ].join('\n');
}

// ---------------------------------------------------------- Statistiques

const _statsStart = '<!-- LaunchPilot statistiques -->';
const _statsEnd = '<!-- /LaunchPilot statistiques -->';

/// Script de statistiques sans cookie. [scriptUrl] permet un Umami
/// auto-hébergé ; [siteId] est l'identifiant Umami (non secret).
String analyticsSnippet(
  AnalyticsTool tool, {
  required String domain,
  String scriptUrl = '',
  String siteId = '',
}) => switch (tool) {
  AnalyticsTool.none => '',
  AnalyticsTool.plausible =>
    '<script defer data-domain="${_escape(domain)}" src="${_escape(scriptUrl.isEmpty ? 'https://plausible.io/js/script.js' : scriptUrl)}"></script>',
  AnalyticsTool.umami =>
    '<script defer src="${_escape(scriptUrl.isEmpty ? 'https://cloud.umami.is/script.js' : scriptUrl)}" data-website-id="${_escape(siteId)}"></script>',
};

/// Insère (ou remplace, ou retire si [snippet] est vide) le bloc de
/// statistiques. Null si la page n'a pas de `<head>`.
String? applyAnalytics(String html, String snippet) {
  final headClose = RegExp('</head>', caseSensitive: false);
  if (!headClose.hasMatch(html)) return null;
  final out = html.replaceAll(
    RegExp(
      '[ \\t]*${RegExp.escape(_statsStart)}[\\s\\S]*?${RegExp.escape(_statsEnd)}\\n?',
    ),
    '',
  );
  if (snippet.isEmpty) return out;
  final close = headClose.firstMatch(out)!;
  return '${out.substring(0, close.start)}  $_statsStart\n  $snippet\n  $_statsEnd\n${out.substring(close.start)}';
}
