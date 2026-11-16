import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'line_diff.dart';

String bytesHash(List<int> bytes) => sha256.convert(bytes).toString();

String contentHash(String content) => bytesHash(utf8.encode(content));

/// Modification prévue d'un fichier, texte ou binaire, calculée à partir de
/// son état actuel.
@immutable
class PlannedFileChange {
  PlannedFileChange({
    required this.path,
    required String? before,
    required String after,
  }) : beforeBytes = before == null ? null : utf8.encode(before),
       afterBytes = utf8.encode(after),
       isText = true;

  const PlannedFileChange.binary({
    required this.path,
    required this.beforeBytes,
    required this.afterBytes,
  }) : isText = false;

  /// Chemin relatif à la racine du projet.
  final String path;

  /// Contenu actuel ; nul si le fichier sera créé.
  final Uint8List? beforeBytes;
  final Uint8List afterBytes;

  /// Texte : aperçu en diff. Binaire (image…) : aperçu visuel.
  final bool isText;

  String? get before => beforeBytes == null
      ? null
      : utf8.decode(beforeBytes!, allowMalformed: true);

  String get after => utf8.decode(afterBytes, allowMalformed: true);

  bool get creates => beforeBytes == null;

  bool get changes =>
      beforeBytes == null || bytesHash(beforeBytes!) != bytesHash(afterBytes);

  List<DiffHunk>? get diff => isText ? lineDiff(before, after) : null;
}

/// Ensemble de fichiers écrits ensemble, après une seule confirmation.
@immutable
class ChangeSet {
  const ChangeSet({required this.label, required this.files});

  final String label;
  final List<PlannedFileChange> files;

  /// Empreinte liant une confirmation à ce contenu exact.
  String get digest => sha256
      .convert(
        utf8.encode(
          jsonEncode([
            label,
            for (final f in files)
              [
                f.path,
                f.beforeBytes == null ? null : bytesHash(f.beforeBytes!),
                bytesHash(f.afterBytes),
              ],
          ]),
        ),
      )
      .toString();
}
