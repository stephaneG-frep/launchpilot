import 'package:flutter/foundation.dart';

/// Raisons pour lesquelles une analyse est partielle.
abstract final class PartialReason {
  static const maxFiles = 'maxFiles';
  static const maxDepth = 'maxDepth';
  static const readBudget = 'readBudget';
  static const timeout = 'timeout';
  static const unreadable = 'unreadable';
}

/// Contenu brut de `.git`, lu sans exécuter git.
@immutable
class GitRaw {
  const GitRaw({
    this.present = false,
    this.isFile = false,
    this.head,
    this.packedRefs,
    this.looseTags = const [],
  });

  final bool present;
  final bool isFile;
  final String? head;
  final String? packedRefs;
  final List<String> looseTags;
}

/// Ce que le scanner a vu : chemins relatifs (séparateur `/`) et contenu des
/// seuls fichiers utiles à la détection.
@immutable
class ScanSnapshot {
  const ScanSnapshot({
    required this.files,
    this.contents = const {},
    this.sensitiveFiles = const [],
    this.partialReasons = const [],
    this.git = const GitRaw(),
  });

  final List<String> files;
  final Map<String, String> contents;
  final List<String> sensitiveFiles;
  final List<String> partialReasons;
  final GitRaw git;

  bool has(String path) => files.contains(path);
  bool hasPrefix(String prefix) => files.any((f) => f.startsWith(prefix));
}
