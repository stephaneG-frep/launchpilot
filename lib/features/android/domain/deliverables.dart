import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

enum DeliverableKind { aab, apk }

/// Signature constatée dans le fichier produit.
enum DeliverableSigning {
  /// Certificat « Android Debug » : refusé par Google Play.
  debug,

  /// Signé avec un autre certificat (ta clé d'envoi).
  signed,

  /// Aucune signature trouvée.
  unsigned,
}

@immutable
class Deliverable {
  const Deliverable({
    required this.path,
    required this.kind,
    required this.size,
    required this.sha256,
    required this.signing,
    required this.modified,
  });

  /// Chemin relatif à la racine du projet.
  final String path;
  final DeliverableKind kind;
  final int size;
  final String sha256;
  final DeliverableSigning signing;
  final DateTime modified;

  Map<String, Object?> toJson() => {
    'path': path,
    'kind': kind.name,
    'size': size,
    'sha256': sha256,
    'signing': signing.name,
    'modified': modified.toIso8601String(),
  };
}

/// Emplacements des livrables produits par Flutter, relatifs au dossier du
/// pubspec ([pubDir], vide à la racine).
List<String> deliverableCandidates(String pubDir) {
  String at(String path) => pubDir.isEmpty ? path : '$pubDir/$path';
  return [
    at('build/app/outputs/bundle/release/app-release.aab'),
    at('build/app/outputs/flutter-apk/app-release.apk'),
    for (final abi in const ['arm64-v8a', 'armeabi-v7a', 'x86_64'])
      at('build/app/outputs/flutter-apk/app-$abi-release.apk'),
  ];
}

final _debugMarker = ascii.encode('Android Debug');
final _apkSigBlock = ascii.encode('APK Sig Block 42');

bool _contains(Uint8List haystack, List<int> needle) {
  outer:
  for (var i = 0; i <= haystack.length - needle.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}

/// Signature d'un AAB ou d'un APK. Le certificat de débogage de Flutter
/// porte le nom « CN=Android Debug ».
DeliverableSigning detectSigning(Uint8List bytes, DeliverableKind kind) {
  // Signature APK v2/v3 : bloc non compressé avant le répertoire central.
  if (kind == DeliverableKind.apk && _contains(bytes, _apkSigBlock)) {
    return _contains(bytes, _debugMarker)
        ? DeliverableSigning.debug
        : DeliverableSigning.signed;
  }
  // Signature JAR (AAB, anciens APK) : certificat dans META-INF/*.RSA|DSA|EC.
  try {
    final archive = ZipDecoder().decodeBytes(bytes);
    final certs = archive.files.where(
      (f) =>
          f.isFile &&
          f.name.startsWith('META-INF/') &&
          RegExp(r'\.(RSA|DSA|EC)$', caseSensitive: false).hasMatch(f.name),
    );
    if (certs.isEmpty) return DeliverableSigning.unsigned;
    for (final c in certs) {
      if (_contains(Uint8List.fromList(c.content), _debugMarker)) {
        return DeliverableSigning.debug;
      }
    }
    return DeliverableSigning.signed;
  } on Object {
    return DeliverableSigning.unsigned;
  }
}

/// Inspection synchrone (à lancer dans un isolat pour les gros fichiers).
/// Null si le fichier n'existe pas.
Deliverable? inspectDeliverable(String root, String relative) {
  final file = File(p.join(root, relative));
  if (!file.existsSync()) return null;
  final bytes = file.readAsBytesSync();
  final kind = relative.endsWith('.aab')
      ? DeliverableKind.aab
      : DeliverableKind.apk;
  return Deliverable(
    path: relative,
    kind: kind,
    size: bytes.length,
    sha256: sha256.convert(bytes).toString(),
    signing: detectSigning(bytes, kind),
    modified: file.lastModifiedSync(),
  );
}

typedef DeliverableJob = ({String root, List<String> paths});

List<Deliverable> inspectDeliverables(DeliverableJob job) => [
  for (final path in job.paths) ?inspectDeliverable(job.root, path),
];

/// Taille lisible (1,4 Mo).
String formatSize(int bytes, {String locale = 'fr'}) {
  final sep = locale == 'fr' ? ',' : '.';
  String fmt(double v, String unit) =>
      '${v.toStringAsFixed(1).replaceAll('.', sep)} $unit';
  if (bytes >= 1024 * 1024) {
    return fmt(bytes / (1024 * 1024), locale == 'fr' ? 'Mo' : 'MB');
  }
  if (bytes >= 1024) return fmt(bytes / 1024, locale == 'fr' ? 'Ko' : 'KB');
  return '$bytes ${locale == 'fr' ? 'o' : 'B'}';
}

// ------------------------------------------------------------ flutter doctor

/// Ligne d'une section de `flutter doctor -v`.
typedef DoctorLine = ({String status, String text});

/// Sections Android (toolchain, Android Studio) de `flutter doctor -v`.
/// [status] : ✓, !, ✗ ou • (détail).
List<DoctorLine> androidDoctorLines(String output) {
  final out = <DoctorLine>[];
  var inAndroid = false;
  for (final raw in const LineSplitter().convert(output)) {
    final line = raw.trimRight();
    final header = RegExp(r'^\[(✓|!|✗|☠)\]\s*(.*)$').firstMatch(line);
    if (header != null) {
      final title = header.group(2)!;
      inAndroid =
          title.startsWith('Android toolchain') ||
          title.startsWith('Android Studio');
      if (inAndroid) out.add((status: header.group(1)!, text: title));
      continue;
    }
    if (!inAndroid) continue;
    final detail = RegExp(r'^\s+([•✗!])\s*(.*)$').firstMatch(line);
    if (detail != null) {
      out.add((status: detail.group(1)!, text: detail.group(2)!));
    }
  }
  return out;
}

/// Version de Java signalée par `flutter doctor -v`.
String? doctorJavaVersion(String output) => RegExp(
  r'Java version\s+(.+)$',
  multiLine: true,
).firstMatch(output)?.group(1)?.trim();
