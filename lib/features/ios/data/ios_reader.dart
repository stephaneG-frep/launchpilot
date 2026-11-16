import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../android/data/android_reader.dart';
import '../../detection/domain/detection_report.dart';
import '../domain/app_store.dart';
import '../domain/ios_project.dart';

/// Lit le module iOS d'un projet Flutter (synchrone, sans Xcode).
class IosReader {
  const IosReader();

  String? _read(String root, String rel) {
    final f = File(p.join(root, rel));
    try {
      return f.existsSync() ? f.readAsStringSync() : null;
    } on FileSystemException {
      return null;
    }
  }

  /// Null si le projet n'a pas de dossier ios.
  IosProject? read(String root, DetectionReport report) {
    final pub = AndroidReader.pubDir(report);
    final ios = pub.isEmpty ? 'ios' : '$pub/ios';
    if (!Directory(p.join(root, ios)).existsSync()) return null;
    final plistPath = '$ios/Runner/Info.plist';
    final pbxPath = '$ios/Runner.xcodeproj/project.pbxproj';
    final plist = _read(root, plistPath);
    final pbx = _read(root, pbxPath);
    final info = pbx == null ? null : parsePbxproj(pbx);

    ({bool present, bool alpha})? icon;
    final contents = _read(
      root,
      '$ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
    );
    if (contents != null) {
      String? file;
      try {
        final images = (jsonDecode(contents) as Map)['images'] as List;
        for (final i in images.whereType<Map>()) {
          if (i['size'] == '1024x1024' && i['filename'] is String) {
            file = i['filename'] as String;
          }
        }
      } on Object {
        file = null;
      }
      final f = file == null
          ? null
          : File(
              p.join(
                root,
                ios,
                'Runner/Assets.xcassets/AppIcon.appiconset',
                file,
              ),
            );
      if (f == null || !f.existsSync()) {
        icon = (present: false, alpha: false);
      } else {
        final decoded = img.decodeImage(f.readAsBytesSync());
        icon = (present: decoded != null, alpha: decoded?.hasAlpha ?? false);
      }
    }

    return IosProject(
      iosDir: ios,
      infoPlistPath: plist == null ? null : plistPath,
      pbxprojPath: pbx == null ? null : pbxPath,
      plist: plist == null ? const {} : plistTopLevel(plist),
      bundleId: info?.bundleId,
      deploymentTarget: info?.deploymentTarget,
      developmentTeam: info?.developmentTeam,
      automaticSigning: info?.automaticSigning ?? false,
      privacyManifestFile: File(
        p.join(root, ios, 'Runner/PrivacyInfo.xcprivacy'),
      ).existsSync(),
      privacyManifestInProject: info?.privacyManifest ?? false,
      marketingIcon: icon,
      usesCocoaPods: File(p.join(root, ios, 'Podfile')).existsSync(),
    );
  }
}

/// Réglages iOS par projet, dans les préférences (aucun secret).
class IosConfigRepository {
  IosConfigRepository(this._prefs);

  final SharedPreferences _prefs;

  static String key(int projectId) => 'lp.ios.$projectId';

  IosConfig load(int projectId) {
    final raw = _prefs.getString(key(projectId));
    if (raw == null) return const IosConfig();
    try {
      return IosConfig.fromJson((jsonDecode(raw) as Map).cast());
    } on Object {
      return const IosConfig();
    }
  }

  Future<void> save(int projectId, IosConfig config) =>
      _prefs.setString(key(projectId), jsonEncode(config.toJson()));

  Future<void> delete(int projectId) => _prefs.remove(key(projectId));

  Future<void> deleteAll() async {
    for (final k in _prefs.getKeys().where((k) => k.startsWith('lp.ios.'))) {
      await _prefs.remove(k);
    }
  }
}
