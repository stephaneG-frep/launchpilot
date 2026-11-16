import 'package:flutter/foundation.dart';

import '../../../core/domain/audit_status.dart';
import 'ios_project.dart';

/// Version de Xcode / du SDK exigée par App Store Connect depuis le
/// 28 avril 2026.
const requiredXcode = 26;

enum IosArea { linux, identity, privacy, signing, icons }

@immutable
class IosCheck {
  const IosCheck(this.area, this.id, this.status, [this.values = const []]);

  final IosArea area;
  final String id;
  final AuditStatus status;
  final List<String> values;

  @override
  String toString() => '$id:$status$values';
}

/// Clés d'Info.plist exigées par les plugins courants : sans elles,
/// l'application se ferme dès l'accès et Apple la refuse.
const usageKeysByPlugin = {
  'camera': ['NSCameraUsageDescription', 'NSMicrophoneUsageDescription'],
  'image_picker': [
    'NSCameraUsageDescription',
    'NSPhotoLibraryUsageDescription',
  ],
  'mobile_scanner': ['NSCameraUsageDescription'],
  'geolocator': ['NSLocationWhenInUseUsageDescription'],
  'location': ['NSLocationWhenInUseUsageDescription'],
  'google_maps_flutter': ['NSLocationWhenInUseUsageDescription'],
  'record': ['NSMicrophoneUsageDescription'],
  'speech_to_text': [
    'NSMicrophoneUsageDescription',
    'NSSpeechRecognitionUsageDescription',
  ],
  'flutter_contacts': ['NSContactsUsageDescription'],
  'contacts_service': ['NSContactsUsageDescription'],
  'photo_manager': ['NSPhotoLibraryUsageDescription'],
  'flutter_blue_plus': ['NSBluetoothAlwaysUsageDescription'],
  'device_calendar': ['NSCalendarsUsageDescription'],
  'local_auth': ['NSFaceIDUsageDescription'],
  'app_tracking_transparency': ['NSUserTrackingUsageDescription'],
};

/// Texte trop court ou générique pour expliquer un accès.
bool weakUsageText(String text) {
  final t = text.trim();
  return t.length < 25 ||
      RegExp(
        r'^(localisation|location|caméra|camera|photos?|micro(phone)?|contacts?|needed|required|nécessaire|requis)\.?$',
        caseSensitive: false,
      ).hasMatch(t);
}

/// Contrôles du module iOS. [linuxHost] : LaunchPilot tourne sous Linux.
List<IosCheck> auditIos(
  IosProject a, {
  required bool linuxHost,
  Set<String> dependencies = const {},
}) {
  final out = <IosCheck>[];
  void add(
    IosArea area,
    String id,
    AuditStatus s, [
    List<String> v = const [],
  ]) => out.add(IosCheck(area, id, s, v));

  add(IosArea.linux, linuxHost ? 'linuxHost' : 'macHost', AuditStatus.info, [
    '$requiredXcode',
  ]);
  if (a.infoPlistPath == null || a.pbxprojPath == null) {
    add(IosArea.identity, 'noProject', AuditStatus.failure);
    return out;
  }

  // Identité
  final id = a.bundleId;
  if (id == null) {
    add(IosArea.identity, 'bundleId', AuditStatus.failure);
  } else if (id.startsWith('com.example')) {
    add(IosArea.identity, 'exampleBundleId', AuditStatus.failure, [id]);
  } else {
    add(IosArea.identity, 'bundleId', AuditStatus.ok, [id]);
  }
  final name =
      a.stringValue('CFBundleDisplayName') ?? a.stringValue('CFBundleName');
  if (name != null) {
    add(
      IosArea.identity,
      'displayName',
      RegExp(r'^[a-z0-9_]+$').hasMatch(name)
          ? AuditStatus.warning
          : AuditStatus.ok,
      [name],
    );
  }
  if (a.deploymentTarget != null) {
    add(IosArea.identity, 'deploymentTarget', AuditStatus.info, [
      a.deploymentTarget!,
    ]);
  }
  final version = a.stringValue('CFBundleShortVersionString') ?? '';
  add(
    IosArea.identity,
    version.contains('FLUTTER_BUILD_NAME')
        ? 'versionFromPubspec'
        : 'versionHardcoded',
    version.contains('FLUTTER_BUILD_NAME')
        ? AuditStatus.ok
        : AuditStatus.warning,
    [version],
  );

  // Confidentialité : textes d'accès, manifeste, chiffrement.
  final required = <String, String>{
    for (final dep in dependencies)
      for (final key in usageKeysByPlugin[dep] ?? const <String>[]) key: dep,
  };
  for (final e in required.entries) {
    final text = a.stringValue(e.key);
    if (text == null || text.trim().isEmpty) {
      add(IosArea.privacy, 'usageMissing', AuditStatus.failure, [
        e.key,
        e.value,
      ]);
    } else if (weakUsageText(text)) {
      add(IosArea.privacy, 'usageWeak', AuditStatus.warning, [e.key, text]);
    } else {
      add(IosArea.privacy, 'usageOk', AuditStatus.ok, [e.key]);
    }
  }
  for (final key in a.plist.keys.where(
    (k) => k.endsWith('UsageDescription') && !required.containsKey(k),
  )) {
    final text = a.stringValue(key) ?? '';
    add(
      IosArea.privacy,
      weakUsageText(text) ? 'usageWeak' : 'usageExtra',
      weakUsageText(text) ? AuditStatus.warning : AuditStatus.info,
      [key, text],
    );
  }
  if (!a.privacyManifestFile) {
    add(IosArea.privacy, 'privacyManifest', AuditStatus.warning);
  } else if (!a.privacyManifestInProject) {
    add(IosArea.privacy, 'privacyManifestNotInProject', AuditStatus.failure);
  } else {
    add(IosArea.privacy, 'privacyManifestOk', AuditStatus.ok);
  }
  final encryption = a.plist['ITSAppUsesNonExemptEncryption'];
  add(
    IosArea.privacy,
    encryption == null ? 'encryption' : 'encryptionDeclared',
    encryption == null ? AuditStatus.info : AuditStatus.ok,
    [if (encryption != null) '$encryption'],
  );

  // Signature
  add(
    IosArea.signing,
    a.developmentTeam == null ? 'noTeam' : 'team',
    a.developmentTeam == null ? AuditStatus.warning : AuditStatus.ok,
    [?a.developmentTeam],
  );
  add(
    IosArea.signing,
    a.automaticSigning ? 'automaticSigning' : 'manualSigning',
    a.automaticSigning ? AuditStatus.ok : AuditStatus.info,
  );

  // Icône App Store
  final icon = a.marketingIcon;
  if (icon == null || !icon.present) {
    add(IosArea.icons, 'marketingIconMissing', AuditStatus.failure);
  } else {
    add(
      IosArea.icons,
      icon.alpha ? 'marketingIconAlpha' : 'marketingIcon',
      icon.alpha ? AuditStatus.failure : AuditStatus.ok,
    );
  }
  return out;
}
