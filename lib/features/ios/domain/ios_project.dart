import 'package:flutter/foundation.dart';

/// Ce que LaunchPilot sait du module iOS d'un projet Flutter (lu sur
/// disque, sans Xcode).
@immutable
class IosProject {
  const IosProject({
    required this.iosDir,
    this.infoPlistPath,
    this.pbxprojPath,
    this.plist = const {},
    this.bundleId,
    this.deploymentTarget,
    this.developmentTeam,
    this.automaticSigning = false,
    this.privacyManifestFile = false,
    this.privacyManifestInProject = false,
    this.marketingIcon,
    this.usesCocoaPods = false,
  });

  /// Dossier `ios` relatif à la racine du projet.
  final String iosDir;
  final String? infoPlistPath;
  final String? pbxprojPath;

  /// Clés de premier niveau d'Info.plist (chaînes et booléens).
  final Map<String, Object> plist;
  final String? bundleId;
  final String? deploymentTarget;
  final String? developmentTeam;
  final bool automaticSigning;

  /// ios/Runner/PrivacyInfo.xcprivacy présent sur le disque…
  final bool privacyManifestFile;

  /// … et référencé par le projet Xcode (sinon il n'est pas embarqué).
  final bool privacyManifestInProject;

  /// Icône App Store 1024 px : (présente, avec canal alpha).
  final ({bool present, bool alpha})? marketingIcon;
  final bool usesCocoaPods;

  String get privacyManifestPath => '$iosDir/Runner/PrivacyInfo.xcprivacy';

  String? stringValue(String key) => switch (plist[key]) {
    final String s => s,
    _ => null,
  };
}

/// Clés de premier niveau d'un Info.plist : chaînes et booléens seulement.
Map<String, Object> plistTopLevel(String xml) {
  final out = <String, Object>{};
  final clean = xml.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
  final start = clean.indexOf('<dict>');
  if (start < 0) return out;
  var depth = 0;
  final token = RegExp(
    r'<(/?)(dict|array)>|<key>([^<]*)</key>\s*(?:<string>([^<]*)</string>|<(true|false)\s*/>)?',
  );
  for (final m in token.allMatches(clean, start)) {
    if (m.group(2) != null) {
      depth += m.group(1) == '/' ? -1 : 1;
      if (depth == 0) break;
      continue;
    }
    if (depth != 1) continue;
    final key = m.group(3)!;
    if (m.group(4) != null) {
      out[key] = _unescape(m.group(4)!);
    } else if (m.group(5) != null) {
      out[key] = m.group(5) == 'true';
    }
  }
  return out;
}

String _unescape(String s) => s
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&amp;', '&');

typedef PbxInfo = ({
  String? bundleId,
  String? deploymentTarget,
  String? developmentTeam,
  bool automaticSigning,
  bool privacyManifest,
});

/// Réglages utiles du projet Xcode (cible Runner, hors tests).
PbxInfo parsePbxproj(String content) {
  final ids = [
    for (final m in RegExp(
      r'PRODUCT_BUNDLE_IDENTIFIER = "?([^";\s]+)"?;',
    ).allMatches(content))
      m.group(1)!,
  ].where((id) => !id.endsWith('.RunnerTests')).toList();
  String? first(String key) =>
      RegExp('$key = "?([^";\\n]+)"?;').firstMatch(content)?.group(1)?.trim();
  return (
    bundleId: ids.firstOrNull,
    deploymentTarget: first('IPHONEOS_DEPLOYMENT_TARGET'),
    developmentTeam: first('DEVELOPMENT_TEAM'),
    automaticSigning: !content.contains('CODE_SIGN_STYLE = Manual'),
    privacyManifest: content.contains('PrivacyInfo.xcprivacy'),
  );
}
