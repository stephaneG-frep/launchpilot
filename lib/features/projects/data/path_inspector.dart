import 'dart:io';

/// Vérifie l'existence d'un dossier sans jamais en lire le contenu.
/// Abstrait pour les tests (les E/S réelles ne progressent pas dans le
/// temps simulé des tests de widgets).
abstract interface class PathInspector {
  Future<bool> isDirectory(String path);

  /// Dossier personnel, pour interpréter les chemins commençant par `~`.
  String? get homeDirectory;
}

class LocalPathInspector implements PathInspector {
  const LocalPathInspector();

  @override
  Future<bool> isDirectory(String path) async {
    try {
      return await FileSystemEntity.isDirectory(path);
    } on FileSystemException {
      return false;
    }
  }

  @override
  String? get homeDirectory => Platform.environment['HOME'];
}
