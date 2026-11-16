import 'package:path/path.dart' as p;

enum ProjectPathIssue { empty, notAbsolute, notFound, alreadyRegistered }

class ProjectPathException implements Exception {
  const ProjectPathException(this.issue);
  final ProjectPathIssue issue;

  @override
  String toString() => 'ProjectPathException(${issue.name})';
}

enum VersionIssue { empty, invalid }

class InvalidVersionException implements Exception {
  const InvalidVersionException(this.issue);
  final VersionIssue issue;

  @override
  String toString() => 'InvalidVersionException(${issue.name})';
}

/// Une seule session active par projet : il faut reprendre ou clore
/// l'existante avant d'en commencer une autre.
class ActiveSessionExistsException implements Exception {
  const ActiveSessionExistsException(this.sessionId);
  final int sessionId;
}

abstract final class ProjectValidation {
  /// Chemin POSIX absolu et normalisé, ou exception. `~` désigne [home].
  static String normalizePath(String raw, {String? home}) {
    var value = raw.trim();
    if (value.isEmpty) {
      throw const ProjectPathException(ProjectPathIssue.empty);
    }
    if (home != null && (value == '~' || value.startsWith('~/'))) {
      value = home + value.substring(1);
    }
    if (!p.posix.isAbsolute(value)) {
      throw const ProjectPathException(ProjectPathIssue.notAbsolute);
    }
    return p.posix.normalize(value);
  }

  static final _version = RegExp(r'^[0-9A-Za-z][0-9A-Za-z.+_\-]{0,63}$');

  static String normalizeVersion(String raw) {
    final value = raw.trim();
    if (value.isEmpty) throw const InvalidVersionException(VersionIssue.empty);
    if (!_version.hasMatch(value)) {
      throw const InvalidVersionException(VersionIssue.invalid);
    }
    return value;
  }

  /// Nom lisible déduit du chemin, borné à la taille autorisée en base.
  static String nameFor(String normalizedPath, [String? requested]) {
    final name = (requested?.trim().isNotEmpty ?? false)
        ? requested!.trim()
        : p.posix.basename(normalizedPath);
    final fallback = name.isEmpty ? normalizedPath : name;
    return fallback.length > 120 ? fallback.substring(0, 120) : fallback;
  }
}
