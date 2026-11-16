import 'package:flutter/foundation.dart';

/// Comment le build release est signé, d'après build.gradle.
enum ReleaseSigning {
  /// `signingConfig = signingConfigs.getByName("debug")` : refusé par Play.
  debugKey,

  /// Le build release utilise la configuration « release ».
  releaseConfig,

  /// Aucune configuration de signature pour le build release.
  missing,
}

@immutable
class ManifestPermission {
  const ManifestPermission(this.name, {this.maxSdk});

  /// Nom complet (android.permission.CAMERA…).
  final String name;
  final int? maxSdk;

  String get short => name.startsWith('android.permission.')
      ? name.substring('android.permission.'.length)
      : name;
}

/// Ce que LaunchPilot sait du module Android d'un projet Flutter. Les
/// fichiers de signature (key.properties, keystores) ne sont jamais lus :
/// seule leur présence est connue.
@immutable
class AndroidProject {
  const AndroidProject({
    required this.androidDir,
    this.gradlePath,
    this.kts = false,
    this.manifestPath,
    this.applicationId,
    this.namespace,
    this.minSdk,
    this.targetSdk,
    this.compileSdk,
    this.versionCode,
    this.versionName,
    this.signing = ReleaseSigning.missing,
    this.hasReleaseSigningConfig = false,
    this.minify = false,
    this.permissions = const [],
    this.cleartextTraffic = false,
    this.debuggable = false,
    this.label,
    this.keyPropertiesExists = false,
    this.keystoreFiles = const [],
    this.gradleVersion,
    this.agpVersion,
    this.kotlinVersion,
    this.mipmaps = const {},
  });

  /// Dossier `android` relatif à la racine du projet.
  final String androidDir;
  final String? gradlePath;
  final bool kts;
  final String? manifestPath;
  final String? applicationId;
  final String? namespace;

  /// Valeurs brutes : un nombre ou une référence (`flutter.minSdkVersion`).
  final String? minSdk;
  final String? targetSdk;
  final String? compileSdk;
  final String? versionCode;
  final String? versionName;
  final ReleaseSigning signing;
  final bool hasReleaseSigningConfig;
  final bool minify;
  final List<ManifestPermission> permissions;
  final bool cleartextTraffic;
  final bool debuggable;
  final String? label;
  final bool keyPropertiesExists;

  /// Keystores trouvés dans le projet (présence seulement).
  final List<String> keystoreFiles;
  final String? gradleVersion;
  final String? agpVersion;
  final String? kotlinVersion;

  /// Densités mipmap présentes (`hdpi`, `xhdpi`…).
  final Set<String> mipmaps;
}

String? _first(RegExp re, String s) => re.firstMatch(s)?.group(1)?.trim();

/// Retire les commentaires `//` et `/* */` (sans toucher aux URL).
String _stripComments(String s) => s
    .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
    .replaceAll(RegExp(r'(^|[^:])//[^\n]*'), r'$1');

/// Valeur d'une propriété Gradle, Groovy (`minSdkVersion 21`,
/// `minSdk = 21`) ou Kotlin (`minSdk = 21`). Les guillemets sont retirés.
String? gradleValue(String content, List<String> names) {
  final clean = _stripComments(content);
  for (final n in names) {
    final m = RegExp(
      '(?:^|\\s)$n\\s*(?:=\\s*|\\s+)([^\\s\\n]+(?:\\.[A-Za-z]+)*)',
      multiLine: true,
    ).firstMatch(clean);
    if (m != null) {
      var v = m.group(1)!.trim();
      if ((v.startsWith('"') && v.endsWith('"')) ||
          (v.startsWith("'") && v.endsWith("'"))) {
        v = v.substring(1, v.length - 1);
      }
      return v;
    }
  }
  return null;
}

/// Bloc `name { … }` (accolades équilibrées), ou null.
String? gradleBlock(String content, String name) {
  final m = RegExp(
    '(?:^|\\s)$name\\s*\\{',
    multiLine: true,
  ).firstMatch(content);
  if (m == null) return null;
  var depth = 0;
  for (var i = m.end - 1; i < content.length; i++) {
    if (content[i] == '{') depth++;
    if (content[i] == '}') {
      depth--;
      if (depth == 0) return content.substring(m.end, i);
    }
  }
  return null;
}

typedef GradleInfo = ({
  String? applicationId,
  String? namespace,
  String? minSdk,
  String? targetSdk,
  String? compileSdk,
  String? versionCode,
  String? versionName,
  ReleaseSigning signing,
  bool hasReleaseSigningConfig,
  bool minify,
});

GradleInfo parseAppGradle(String content) {
  final clean = _stripComments(content);
  final release = gradleBlock(
    gradleBlock(clean, 'buildTypes') ?? '',
    'release',
  );
  final signingConfigs = gradleBlock(clean, 'signingConfigs') ?? '';
  final hasRelease = RegExp(
    r'(create\s*\(\s*"release"\s*\)|(?:^|\s)release\s*\{)',
    multiLine: true,
  ).hasMatch(signingConfigs);
  ReleaseSigning signing;
  if (release == null || !release.contains('signingConfig')) {
    signing = ReleaseSigning.missing;
  } else if (RegExp(
    r'''signingConfigs\.(getByName\(\s*["']debug["']\s*\)|debug)''',
  ).hasMatch(release)) {
    signing = ReleaseSigning.debugKey;
  } else if (RegExp(
    r'''signingConfigs\.(getByName\(\s*["']release["']\s*\)|release)''',
  ).hasMatch(release)) {
    signing = ReleaseSigning.releaseConfig;
  } else {
    signing = ReleaseSigning.missing;
  }
  return (
    applicationId: gradleValue(clean, ['applicationId']),
    namespace: gradleValue(clean, ['namespace']),
    minSdk: gradleValue(clean, ['minSdk', 'minSdkVersion']),
    targetSdk: gradleValue(clean, ['targetSdk', 'targetSdkVersion']),
    compileSdk: gradleValue(clean, ['compileSdk', 'compileSdkVersion']),
    versionCode: gradleValue(clean, ['versionCode']),
    versionName: gradleValue(clean, ['versionName']),
    signing: signing,
    hasReleaseSigningConfig: hasRelease,
    minify: RegExp(r'(isMinifyEnabled|minifyEnabled)\s*=?\s*true')
        .hasMatch(release ?? ''),
  );
}

typedef ManifestInfo = ({
  List<ManifestPermission> permissions,
  bool cleartextTraffic,
  bool debuggable,
  String? label,
});

ManifestInfo parseManifest(String xml) {
  final clean = xml.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
  final perms = <ManifestPermission>[];
  for (final m in RegExp(
    r'<uses-permission(?:-sdk-23)?\b[^>]*>',
  ).allMatches(clean)) {
    final tag = m.group(0)!;
    final name = _first(RegExp(r'android:name\s*=\s*"([^"]+)"'), tag);
    if (name == null) continue;
    final max = int.tryParse(
      _first(RegExp(r'android:maxSdkVersion\s*=\s*"(\d+)"'), tag) ?? '',
    );
    perms.add(ManifestPermission(name, maxSdk: max));
  }
  final app = RegExp(r'<application\b[^>]*>').firstMatch(clean)?.group(0) ?? '';
  return (
    permissions: perms,
    cleartextTraffic: RegExp(r'android:usesCleartextTraffic\s*=\s*"true"')
        .hasMatch(app),
    debuggable: RegExp(r'android:debuggable\s*=\s*"true"').hasMatch(app),
    label: _first(RegExp(r'android:label\s*=\s*"([^"]+)"'), app),
  );
}

/// Version de Gradle d'après `gradle-wrapper.properties`.
String? gradleWrapperVersion(String properties) =>
    _first(RegExp(r'gradle-([0-9][0-9.]*[0-9])-(?:all|bin)\.zip'), properties);

/// Versions du plugin Android (AGP) et de Kotlin d'après settings.gradle(.kts)
/// ou le build.gradle racine.
({String? agp, String? kotlin}) pluginVersions(String content) => (
  agp:
      _first(
        RegExp(
          r'''id\s*\(?\s*["']com\.android\.application["']\s*\)?\s*version\s*["']([^"']+)["']''',
        ),
        content,
      ) ??
      _first(
        RegExp(r'''com\.android\.tools\.build:gradle:([0-9][^"']*)'''),
        content,
      ),
  kotlin:
      _first(
        RegExp(
          r'''id\s*\(?\s*["']org\.jetbrains\.kotlin\.android["']\s*\)?\s*version\s*["']([^"']+)["']''',
        ),
        content,
      ) ??
      _first(
        RegExp(r'''ext\.kotlin_version\s*=\s*["']([^"']+)["']'''),
        content,
      ),
);
