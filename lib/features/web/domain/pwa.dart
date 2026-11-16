import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Champs du manifeste gérés par LaunchPilot.
@immutable
class PwaSettings {
  const PwaSettings({
    this.name = '',
    this.shortName = '',
    this.description = '',
    this.themeColor = '#3F4BD1',
    this.backgroundColor = '#0E1433',
    this.display = 'standalone',
    this.startUrl = '.',
  });

  final String name;
  final String shortName;
  final String description;
  final String themeColor;
  final String backgroundColor;
  final String display;
  final String startUrl;

  static const displays = ['standalone', 'fullscreen', 'minimal-ui', 'browser'];

  PwaSettings copyWith({
    String? name,
    String? shortName,
    String? description,
    String? themeColor,
    String? backgroundColor,
    String? display,
    String? startUrl,
  }) => PwaSettings(
    name: name ?? this.name,
    shortName: shortName ?? this.shortName,
    description: description ?? this.description,
    themeColor: themeColor ?? this.themeColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    display: display ?? this.display,
    startUrl: startUrl ?? this.startUrl,
  );

  /// Lecture d'un manifeste existant (valeurs absentes = défauts).
  factory PwaSettings.fromManifest(String? json, {String fallbackName = ''}) {
    Map<String, Object?> m = const {};
    try {
      if (json != null) m = (jsonDecode(json) as Map).cast();
    } on Object {
      m = const {};
    }
    const d = PwaSettings();
    String s(String k, String def) {
      final v = m[k];
      return v is String && v.isNotEmpty ? v : def;
    }

    return PwaSettings(
      name: s('name', fallbackName),
      shortName: s('short_name', fallbackName),
      description: s('description', ''),
      themeColor: s('theme_color', d.themeColor),
      backgroundColor: s('background_color', d.backgroundColor),
      display: s('display', d.display),
      startUrl: s('start_url', d.startUrl),
    );
  }

  List<String> get problems => [
    if (name.trim().isEmpty) 'name',
    if (shortName.trim().isEmpty) 'short_name',
    if (shortName.length > 12) 'short_name_length',
    if (!isHexColor(themeColor)) 'theme_color',
    if (!isHexColor(backgroundColor)) 'background_color',
  ];
}

bool isHexColor(String v) =>
    RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})$').hasMatch(v);

/// Icônes par défaut, correspondant à ce que génère l'outil Icônes.
List<Map<String, Object?>> defaultManifestIcons({required bool flutter}) => [
  for (final (size, maskable) in const [
    (192, false),
    (512, false),
    (192, true),
    (512, true),
  ])
    {
      'src': flutter
          ? 'icons/Icon-${maskable ? 'maskable-' : ''}$size.png'
          : 'icons/icon-${maskable ? 'maskable-' : ''}$size.png',
      'sizes': '${size}x$size',
      'type': 'image/png',
      if (maskable) 'purpose': 'maskable',
    },
];

/// Met à jour (ou crée) le manifeste en conservant les clés inconnues et
/// les icônes déjà déclarées.
String updateManifest(
  String? existing,
  PwaSettings s, {
  required bool flutter,
}) {
  Map<String, Object?> m = {};
  try {
    if (existing != null) m = (jsonDecode(existing) as Map).cast();
  } on Object {
    m = {};
  }
  m
    ..['name'] = s.name
    ..['short_name'] = s.shortName
    ..['start_url'] = s.startUrl
    ..['display'] = s.display
    ..['background_color'] = s.backgroundColor
    ..['theme_color'] = s.themeColor;
  if (s.description.isNotEmpty) m['description'] = s.description;
  final icons = m['icons'];
  if (icons is! List || icons.isEmpty) {
    m['icons'] = defaultManifestIcons(flutter: flutter);
  }
  return '${const JsonEncoder.withIndent('    ').convert(m)}\n';
}

/// Service worker minimal : pages en réseau d'abord (repli hors ligne sur
/// la page d'accueil en cache), fichiers statiques en cache d'abord.
String serviceWorkerJs({
  required String version,
  List<String> precache = const ['./', 'index.html'],
}) =>
    '''
// Service worker généré par LaunchPilot. Change CACHE pour forcer la mise à jour.
const CACHE = 'launchpilot-$version';
const PRECACHE = ${jsonEncode(precache)};

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE).then((cache) => cache.addAll(PRECACHE)));
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))),
    ),
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET' || new URL(request.url).origin !== location.origin) {
    return;
  }
  if (request.mode === 'navigate') {
    // Pages : réseau d'abord, page d'accueil en cache si hors ligne.
    event.respondWith(fetch(request).catch(() => caches.match('index.html')));
    return;
  }
  // Fichiers statiques : cache d'abord, puis réseau (et mise en cache).
  event.respondWith(
    caches.match(request).then((cached) =>
      cached ||
      fetch(request).then((response) => {
        if (response.ok) {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put(request, copy));
        }
        return response;
      }),
    ),
  );
});
''';

const _swStart = '<!-- LaunchPilot service worker -->';
const _swEnd = '<!-- /LaunchPilot service worker -->';

/// Ajoute à la page : lien vers le manifeste, couleur de thème et
/// (si [registerWorker]) l'enregistrement du service worker. Null sans
/// `<head>` ou `</body>`.
String? applyPwaTags(
  String html, {
  required String manifestHref,
  required String themeColor,
  bool registerWorker = false,
}) {
  final headClose = RegExp('</head>', caseSensitive: false);
  final bodyClose = RegExp('</body>', caseSensitive: false);
  if (!headClose.hasMatch(html)) return null;
  var out = html;
  final head = <String>[];
  if (!RegExp(
    r'''<link[^>]+rel=["']manifest["']''',
    caseSensitive: false,
  ).hasMatch(out)) {
    head.add('<link rel="manifest" href="$manifestHref">');
  }
  final theme = RegExp(
    r'''<meta[^>]+name=["']theme-color["'][^>]*>''',
    caseSensitive: false,
  );
  if (theme.hasMatch(out)) {
    out = out.replaceFirst(
      theme,
      '<meta name="theme-color" content="$themeColor">',
    );
  } else {
    head.add('<meta name="theme-color" content="$themeColor">');
  }
  if (head.isNotEmpty) {
    final close = headClose.firstMatch(out)!;
    out =
        '${out.substring(0, close.start)}${head.map((h) => '  $h\n').join()}${out.substring(close.start)}';
  }
  out = out.replaceAll(
    RegExp(
      '[ \\t]*${RegExp.escape(_swStart)}[\\s\\S]*?${RegExp.escape(_swEnd)}\\n?',
    ),
    '',
  );
  if (registerWorker) {
    if (!bodyClose.hasMatch(out)) return null;
    const script =
        "  $_swStart\n  <script>\n    if ('serviceWorker' in navigator) {\n      window.addEventListener('load', () => navigator.serviceWorker.register('sw.js'));\n    }\n  </script>\n  $_swEnd\n";
    final close = bodyClose.firstMatch(out)!;
    out =
        '${out.substring(0, close.start)}$script${out.substring(close.start)}';
  }
  return out;
}
