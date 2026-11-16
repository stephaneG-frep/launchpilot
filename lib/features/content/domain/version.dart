import 'package:flutter/foundation.dart';

enum VersionBump { major, minor, patch, none }

/// Version sémantique MAJEUR.MINEUR.CORRECTIF[-pré][+build].
@immutable
class SemVer implements Comparable<SemVer> {
  const SemVer(this.major, this.minor, this.patch, {this.pre, this.build});

  final int major;
  final int minor;
  final int patch;
  final String? pre;

  /// Numéro de build (partie après « + »), seulement s'il est numérique.
  final int? build;

  static final _pattern = RegExp(
    r'^v?(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.\-]+))?(?:\+(\d+))?$',
  );

  static SemVer? tryParse(String raw) {
    final m = _pattern.firstMatch(raw.trim());
    if (m == null) return null;
    return SemVer(
      int.parse(m[1]!),
      int.parse(m[2]!),
      int.parse(m[3]!),
      pre: m[4],
      build: m[5] == null ? null : int.parse(m[5]!),
    );
  }

  /// Nouvelle version. Le numéro de build, s'il existe, augmente toujours
  /// d'au moins 1 : un store refuse deux envois avec le même numéro.
  SemVer bumped(VersionBump bump, {bool incrementBuild = true}) {
    final nextBuild = build == null
        ? null
        : (incrementBuild ? build! + 1 : build);
    return switch (bump) {
      VersionBump.major => SemVer(major + 1, 0, 0, build: nextBuild),
      VersionBump.minor => SemVer(major, minor + 1, 0, build: nextBuild),
      VersionBump.patch => SemVer(major, minor, patch + 1, build: nextBuild),
      VersionBump.none => SemVer(
        major,
        minor,
        patch,
        pre: pre,
        build: nextBuild,
      ),
    };
  }

  SemVer withBuild(int? value) =>
      SemVer(major, minor, patch, pre: pre, build: value);

  String get name => '$major.$minor.$patch${pre == null ? '' : '-$pre'}';

  @override
  String toString() => build == null ? name : '$name+$build';

  @override
  int compareTo(SemVer o) {
    for (final (a, b) in [
      (major, o.major),
      (minor, o.minor),
      (patch, o.patch),
    ]) {
      if (a != b) return a.compareTo(b);
    }
    return (build ?? 0).compareTo(o.build ?? 0);
  }

  @override
  bool operator ==(Object other) =>
      other is SemVer && other.toString() == toString();

  @override
  int get hashCode => toString().hashCode;
}

/// Fichier qui porte la version du projet.
enum VersionFileKind { pubspec, packageJson }

@immutable
class VersionLocation {
  const VersionLocation(this.kind, this.path, this.raw);

  final VersionFileKind kind;

  /// Chemin relatif du manifeste.
  final String path;

  /// Valeur telle qu'écrite dans le fichier.
  final String raw;

  SemVer? get version => SemVer.tryParse(raw);

  /// Le Play Store et l'App Store utilisent un numéro de build ; npm non.
  bool get supportsBuild => kind == VersionFileKind.pubspec;
}

final _pubspecVersion = RegExp(
  r'''^(version:\s*)(["']?)([^\s"'#]+)(["']?)''',
  multiLine: true,
);
final _packageVersion = RegExp(r'("version"\s*:\s*")([^"]*)(")');

/// Version lue dans le contenu d'un manifeste, sans l'interpréter.
String? readVersion(VersionFileKind kind, String content) => switch (kind) {
  VersionFileKind.pubspec => _pubspecVersion.firstMatch(content)?[3],
  VersionFileKind.packageJson => _packageVersion.firstMatch(content)?[2],
};

/// Remplace uniquement la valeur de la version : le reste du fichier
/// (commentaires, ordre, mise en forme) est conservé à l'octet près.
/// Renvoie null si aucune ligne de version n'existe.
String? writeVersion(VersionFileKind kind, String content, String version) {
  switch (kind) {
    case VersionFileKind.pubspec:
      final m = _pubspecVersion.firstMatch(content);
      if (m == null) return null;
      return content.replaceRange(
        m.start,
        m.end,
        '${m[1]}${m[2]}$version${m[4]}',
      );
    case VersionFileKind.packageJson:
      final m = _packageVersion.firstMatch(content);
      if (m == null) return null;
      return content.replaceRange(m.start, m.end, '${m[1]}$version${m[3]}');
  }
}
