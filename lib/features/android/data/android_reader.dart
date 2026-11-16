import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../../detection/domain/detection_report.dart';
import '../domain/android_project.dart';

/// Lit le module Android d'un projet Flutter (synchrone, compatible avec le
/// temps simulé des tests). key.properties et les keystores ne sont jamais
/// ouverts : seule leur présence est vérifiée.
class AndroidReader {
  const AndroidReader();

  /// Dossier du pubspec (relatif, vide à la racine).
  static String pubDir(DetectionReport r) {
    final pub = r.packages.where((x) => x.manager == 'pub').firstOrNull;
    if (pub == null) return '';
    final d = p.posix.dirname(pub.manifest);
    return d == '.' ? '' : d;
  }

  static String _join(String a, String b) => a.isEmpty ? b : '$a/$b';

  String? _read(String root, String rel) {
    final f = File(p.join(root, rel));
    try {
      return f.existsSync() ? f.readAsStringSync() : null;
    } on FileSystemException {
      return null;
    }
  }

  /// Null si le projet n'a pas de dossier android.
  AndroidProject? read(String root, DetectionReport report) {
    final android = _join(pubDir(report), 'android');
    if (!Directory(p.join(root, android)).existsSync()) return null;

    String? gradlePath;
    var kts = false;
    for (final (name, isKts) in const [
      ('app/build.gradle.kts', true),
      ('app/build.gradle', false),
    ]) {
      if (File(p.join(root, android, name)).existsSync()) {
        gradlePath = '$android/$name';
        kts = isKts;
        break;
      }
    }
    final gradle = gradlePath == null ? null : _read(root, gradlePath);
    final g = gradle == null ? null : parseAppGradle(gradle);

    final manifestPath = '$android/app/src/main/AndroidManifest.xml';
    final manifest = _read(root, manifestPath);
    final m = manifest == null ? null : parseManifest(manifest);

    final wrapper = _read(
      root,
      '$android/gradle/wrapper/gradle-wrapper.properties',
    );
    final settings =
        _read(root, '$android/settings.gradle.kts') ??
        _read(root, '$android/settings.gradle') ??
        '';
    final rootGradle =
        _read(root, '$android/build.gradle.kts') ??
        _read(root, '$android/build.gradle') ??
        '';
    final plugins = pluginVersions('$settings\n$rootGradle');

    final res = Directory(p.join(root, android, 'app/src/main/res'));
    final mipmaps = <String>{};
    if (res.existsSync()) {
      for (final d in res.listSync(followLinks: false).whereType<Directory>()) {
        final name = p.basename(d.path);
        if (name.startsWith('mipmap-') &&
            File(p.join(d.path, 'ic_launcher.png')).existsSync()) {
          mipmaps.add(name.substring('mipmap-'.length));
        }
      }
    }

    return AndroidProject(
      androidDir: android,
      gradlePath: gradlePath,
      kts: kts,
      manifestPath: manifest == null ? null : manifestPath,
      applicationId: g?.applicationId,
      namespace: g?.namespace,
      minSdk: g?.minSdk,
      targetSdk: g?.targetSdk,
      compileSdk: g?.compileSdk,
      versionCode: g?.versionCode,
      versionName: g?.versionName,
      signing: g?.signing ?? ReleaseSigning.missing,
      hasReleaseSigningConfig: g?.hasReleaseSigningConfig ?? false,
      minify: g?.minify ?? false,
      permissions: m?.permissions ?? const [],
      cleartextTraffic: m?.cleartextTraffic ?? false,
      debuggable: m?.debuggable ?? false,
      label: m?.label,
      keyPropertiesExists: File(p.join(root, android, 'key.properties'))
          .existsSync(),
      keystoreFiles: [
        for (final f in report.sensitiveFiles)
          if (f.endsWith('.jks') || f.endsWith('.keystore')) f,
      ],
      gradleVersion: wrapper == null ? null : gradleWrapperVersion(wrapper),
      agpVersion: plugins.agp,
      kotlinVersion: plugins.kotlin,
      mipmaps: mipmaps,
    );
  }

  /// Version et dépendances du pubspec.
  ({String? version, Set<String> dependencies}) pubspec(
    String root,
    DetectionReport report,
  ) {
    final raw = _read(root, _join(pubDir(report), 'pubspec.yaml'));
    if (raw == null) return (version: null, dependencies: const {});
    try {
      final y = loadYaml(raw);
      if (y is! YamlMap) return (version: null, dependencies: const {});
      final deps = <String>{
        if (y['dependencies'] is YamlMap)
          ...(y['dependencies'] as YamlMap).keys.cast<String>(),
      };
      return (version: y['version']?.toString(), dependencies: deps);
    } on Object {
      return (version: null, dependencies: const {});
    }
  }
}
