import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Fichier d'icône à produire.
@immutable
class IconTarget {
  const IconTarget(
    this.path,
    this.size, {
    this.opaque = false,
    this.maskable = false,
  });

  /// Chemin relatif au projet.
  final String path;
  final int size;

  /// Sans transparence (icône App Store) : aplatie sur la couleur de fond.
  final bool opaque;

  /// Icône PWA « maskable » : motif réduit dans la zone de sécurité (80 %).
  final bool maskable;
}

enum IconIssue {
  unreadable,
  tooSmall,
  belowRecommended,
  notSquare,
  transparent,
}

@immutable
class SourceIconReport {
  const SourceIconReport({
    required this.width,
    required this.height,
    required this.issues,
  });

  final int width;
  final int height;
  final List<IconIssue> issues;

  /// Seule une image illisible ou minuscule est refusée ; le reste est
  /// signalé (une image non carrée est centrée, jamais étirée).
  bool get usable =>
      !issues.contains(IconIssue.unreadable) &&
      !issues.contains(IconIssue.tooSmall);
}

const recommendedIconSize = 1024;
const minimumIconSize = 512;

SourceIconReport inspectIcon(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) {
    return const SourceIconReport(
      width: 0,
      height: 0,
      issues: [IconIssue.unreadable],
    );
  }
  final side = image.width < image.height ? image.width : image.height;
  return SourceIconReport(
    width: image.width,
    height: image.height,
    issues: [
      if (side < minimumIconSize)
        IconIssue.tooSmall
      else if (side < recommendedIconSize)
        IconIssue.belowRecommended,
      if (image.width != image.height) IconIssue.notSquare,
      if (image.hasAlpha && _hasTransparentPixel(image)) IconIssue.transparent,
    ],
  );
}

bool _hasTransparentPixel(img.Image image) {
  // Échantillonnage : suffisant pour savoir si l'icône a des zones vides.
  final step = (image.width / 64).ceil().clamp(1, 1 << 20);
  for (var y = 0; y < image.height; y += step) {
    for (var x = 0; x < image.width; x += step) {
      if (image.getPixel(x, y).a < 255) return true;
    }
  }
  return false;
}

// ---------------------------------------------------------------- plans

const _androidDensities = {
  'mdpi': 48,
  'hdpi': 72,
  'xhdpi': 96,
  'xxhdpi': 144,
  'xxxhdpi': 192,
};

/// Icônes Android (mipmap) d'un projet Flutter dont le dossier android est
/// [androidDir] (relatif, ex. `android`).
List<IconTarget> androidIcons(String androidDir) => [
  for (final e in _androidDensities.entries)
    IconTarget(
      '$androidDir/app/src/main/res/mipmap-${e.key}/ic_launcher.png',
      e.value,
    ),
];

/// Jeu d'icônes iOS d'après un `Contents.json` existant, pour produire
/// exactement les fichiers qu'il référence.
List<IconTarget> iosIconsFromContents(String appIconDir, String contentsJson) {
  final decoded = jsonDecode(contentsJson);
  final images = decoded is Map ? decoded['images'] : null;
  final out = <IconTarget>[];
  final seen = <String>{};
  if (images is! List) return out;
  for (final e in images) {
    if (e is! Map) continue;
    final filename = e['filename'];
    final size = e['size'];
    final scale = e['scale'];
    if (filename is! String || size is! String || !seen.add(filename)) continue;
    final points = double.tryParse(size.split('x').first) ?? 0;
    final factor = double.tryParse('$scale'.replaceAll('x', '')) ?? 1;
    final px = (points * factor).round();
    if (px <= 0) continue;
    out.add(IconTarget('$appIconDir/$filename', px, opaque: true));
  }
  return out;
}

/// Jeu iOS standard (modèle Flutter) quand aucun `Contents.json` n'existe.
(List<IconTarget>, String) iosDefaultIcons(String appIconDir) {
  const specs = [
    ('iphone', '20x20', 2),
    ('iphone', '20x20', 3),
    ('iphone', '29x29', 1),
    ('iphone', '29x29', 2),
    ('iphone', '29x29', 3),
    ('iphone', '40x40', 2),
    ('iphone', '40x40', 3),
    ('iphone', '60x60', 2),
    ('iphone', '60x60', 3),
    ('ipad', '20x20', 1),
    ('ipad', '20x20', 2),
    ('ipad', '29x29', 1),
    ('ipad', '29x29', 2),
    ('ipad', '40x40', 1),
    ('ipad', '40x40', 2),
    ('ipad', '76x76', 1),
    ('ipad', '76x76', 2),
    ('ipad', '83.5x83.5', 2),
    ('ios-marketing', '1024x1024', 1),
  ];
  final images = [
    for (final (idiom, size, scale) in specs)
      {
        'size': size,
        'idiom': idiom,
        'filename': 'Icon-App-$size@${scale}x.png',
        'scale': '${scale}x',
      },
  ];
  final json = const JsonEncoder.withIndent('  ').convert({
    'images': images,
    'info': {'version': 1, 'author': 'xcode'},
  });
  return (iosIconsFromContents(appIconDir, json), '$json\n');
}

/// Icônes web : favicon et icônes PWA. [webDir] est `web` pour Flutter,
/// `public` pour la plupart des outils JavaScript.
List<IconTarget> webIcons(String webDir, {required bool flutter}) {
  String at(String file) => webDir.isEmpty ? file : '$webDir/$file';
  return flutter
      ? [
          IconTarget(at('favicon.png'), 32),
          IconTarget(at('icons/Icon-192.png'), 192),
          IconTarget(at('icons/Icon-512.png'), 512),
          IconTarget(at('icons/Icon-maskable-192.png'), 192, maskable: true),
          IconTarget(at('icons/Icon-maskable-512.png'), 512, maskable: true),
        ]
      : [
          IconTarget(at('favicon.png'), 32),
          IconTarget(at('apple-touch-icon.png'), 180, opaque: true),
          IconTarget(at('icons/icon-192.png'), 192),
          IconTarget(at('icons/icon-512.png'), 512),
          IconTarget(at('icons/icon-maskable-512.png'), 512, maskable: true),
        ];
}

// ----------------------------------------------------------- génération

/// Produit toutes les icônes. L'image source est d'abord centrée sur un
/// carré transparent (jamais étirée), puis réduite pour chaque taille.
/// [background] (ARGB) sert aux icônes opaques et maskables.
Map<String, Uint8List> generateIcons(
  Uint8List source,
  List<IconTarget> targets, {
  int background = 0xFFFFFFFF,
}) {
  final decoded = img.decodeImage(source);
  if (decoded == null) throw const FormatException('image illisible');
  final square = _letterbox(decoded);
  final bg = img.ColorRgba8(
    (background >> 16) & 0xFF,
    (background >> 8) & 0xFF,
    background & 0xFF,
    255,
  );

  final out = <String, Uint8List>{};
  for (final t in targets) {
    img.Image icon;
    if (t.maskable) {
      // Le motif occupe 80 % : le système peut rogner la forme sans couper.
      final inner = (t.size * 0.8).round();
      final canvas = img.Image(width: t.size, height: t.size, numChannels: 4);
      img.fill(canvas, color: bg);
      img.compositeImage(
        canvas,
        _resize(square, inner),
        dstX: (t.size - inner) ~/ 2,
        dstY: (t.size - inner) ~/ 2,
      );
      icon = canvas;
    } else {
      icon = _resize(square, t.size);
    }
    if (t.opaque) {
      final flat = img.Image(width: t.size, height: t.size, numChannels: 3);
      img.fill(flat, color: bg);
      img.compositeImage(flat, icon);
      icon = flat;
    }
    out[t.path] = img.encodePng(icon);
  }
  return out;
}

img.Image _letterbox(img.Image src) {
  final source = src.numChannels == 4 ? src : src.convert(numChannels: 4);
  if (source.width == source.height) return source;
  final side = source.width > source.height ? source.width : source.height;
  final canvas = img.Image(width: side, height: side, numChannels: 4);
  img.compositeImage(
    canvas,
    source,
    dstX: (side - source.width) ~/ 2,
    dstY: (side - source.height) ~/ 2,
  );
  return canvas;
}

img.Image _resize(img.Image square, int size) => square.width == size
    ? square.clone()
    : img.copyResize(
        square,
        width: size,
        height: size,
        interpolation: size < square.width
            ? img.Interpolation.average
            : img.Interpolation.cubic,
      );

/// Données transmises à l'isolat de génération.
typedef IconJob = ({
  Uint8List source,
  List<IconTarget> targets,
  int background,
});

/// Point d'entrée pour `Isolate.run` (fonction de niveau supérieur).
Map<String, Uint8List> runIconJob(IconJob job) =>
    generateIcons(job.source, job.targets, background: job.background);
