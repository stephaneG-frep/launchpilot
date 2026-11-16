import 'package:flutter/foundation.dart';

import '../../../core/domain/audit_status.dart';
import 'android_project.dart';

/// API cible exigée par Google Play pour les nouvelles applications et les
/// mises à jour depuis le 31 août 2026 (Android 16).
const playTargetSdk = 36;

enum AndroidArea {
  identity,
  version,
  sdk,
  signing,
  security,
  permissions,
  icons,
}

@immutable
class AndroidCheck {
  const AndroidCheck(this.area, this.id, this.status, [this.values = const []]);

  final AndroidArea area;
  final String id;
  final AuditStatus status;
  final List<String> values;

  @override
  String toString() => '$id:$status$values';
}

/// Sensibilité d'une permission pour Google Play.
enum PermissionLevel {
  /// Accordée à l'installation (INTERNET…).
  normal,

  /// Demandée à l'utilisateur pendant l'utilisation.
  dangerous,

  /// Soumise à une déclaration dans la Play Console (politique restrictive).
  restricted,
}

const _dangerous = {
  'CAMERA',
  'RECORD_AUDIO',
  'ACCESS_FINE_LOCATION',
  'ACCESS_COARSE_LOCATION',
  'READ_CONTACTS',
  'WRITE_CONTACTS',
  'GET_ACCOUNTS',
  'READ_EXTERNAL_STORAGE',
  'WRITE_EXTERNAL_STORAGE',
  'READ_MEDIA_AUDIO',
  'READ_MEDIA_VISUAL_USER_SELECTED',
  'POST_NOTIFICATIONS',
  'BODY_SENSORS',
  'ACTIVITY_RECOGNITION',
  'READ_PHONE_STATE',
  'CALL_PHONE',
  'READ_CALENDAR',
  'WRITE_CALENDAR',
  'BLUETOOTH_SCAN',
  'BLUETOOTH_CONNECT',
  'NEARBY_WIFI_DEVICES',
};

const _restricted = {
  'ACCESS_BACKGROUND_LOCATION',
  'READ_SMS',
  'SEND_SMS',
  'RECEIVE_SMS',
  'RECEIVE_MMS',
  'READ_CALL_LOG',
  'WRITE_CALL_LOG',
  'PROCESS_OUTGOING_CALLS',
  'MANAGE_EXTERNAL_STORAGE',
  'QUERY_ALL_PACKAGES',
  'REQUEST_INSTALL_PACKAGES',
  'READ_MEDIA_IMAGES',
  'READ_MEDIA_VIDEO',
  'USE_EXACT_ALARM',
  'SCHEDULE_EXACT_ALARM',
  'USE_FULL_SCREEN_INTENT',
  'BIND_ACCESSIBILITY_SERVICE',
};

PermissionLevel permissionLevel(String short) => _restricted.contains(short)
    ? PermissionLevel.restricted
    : _dangerous.contains(short)
    ? PermissionLevel.dangerous
    : PermissionLevel.normal;

/// Fonction (famille) qu'une permission sert, pour la confronter aux
/// plugins détectés.
String? permissionFeature(String short) => switch (short) {
  'CAMERA' => 'camera',
  'RECORD_AUDIO' => 'microphone',
  'ACCESS_FINE_LOCATION' ||
  'ACCESS_COARSE_LOCATION' ||
  'ACCESS_BACKGROUND_LOCATION' => 'location',
  'READ_CONTACTS' || 'WRITE_CONTACTS' => 'contacts',
  'READ_EXTERNAL_STORAGE' ||
  'WRITE_EXTERNAL_STORAGE' ||
  'MANAGE_EXTERNAL_STORAGE' ||
  'READ_MEDIA_IMAGES' ||
  'READ_MEDIA_VIDEO' ||
  'READ_MEDIA_AUDIO' => 'storage',
  'POST_NOTIFICATIONS' => 'notifications',
  'BLUETOOTH_SCAN' || 'BLUETOOTH_CONNECT' => 'bluetooth',
  'READ_CALENDAR' || 'WRITE_CALENDAR' => 'calendar',
  _ => null,
};

/// Plugins pub qui expliquent chaque famille de permissions.
const featurePlugins = {
  'camera': {
    'camera',
    'image_picker',
    'mobile_scanner',
    'qr_code_scanner',
    'qr_code_scanner_plus',
    'camerawesome',
  },
  'microphone': {
    'record',
    'speech_to_text',
    'flutter_sound',
    'audio_waveforms',
    'camera',
    'agora_rtc_engine',
    'flutter_webrtc',
  },
  'location': {
    'geolocator',
    'location',
    'google_maps_flutter',
    'flutter_map_location_marker',
    'background_location',
  },
  'contacts': {'flutter_contacts', 'contacts_service', 'fast_contacts'},
  'storage': {
    'image_picker',
    'file_picker',
    'photo_manager',
    'path_provider',
    'gallery_saver',
    'image_gallery_saver',
  },
  'notifications': {
    'firebase_messaging',
    'flutter_local_notifications',
    'awesome_notifications',
    'onesignal_flutter',
  },
  'bluetooth': {'flutter_blue_plus', 'flutter_reactive_ble', 'flutter_blue'},
  'calendar': {'device_calendar', 'add_2_calendar'},
};

/// Densités d'icônes attendues pour une application Android.
const mipmapDensities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

bool _isNumber(String? v) => v != null && int.tryParse(v) != null;

/// Contrôles du module Android. [dependencies] : paquets pub du projet ;
/// [pubVersion] : version du pubspec ; [gitIgnored] : fichiers de
/// signature déjà ignorés par Git (null si le projet n'est pas sous Git).
List<AndroidCheck> auditAndroid(
  AndroidProject a, {
  Set<String> dependencies = const {},
  String? pubVersion,
  Set<String>? gitIgnored,
}) {
  final out = <AndroidCheck>[];
  void add(
    AndroidArea area,
    String id,
    AuditStatus s, [
    List<String> v = const [],
  ]) => out.add(AndroidCheck(area, id, s, v));

  if (a.gradlePath == null) {
    add(AndroidArea.identity, 'noGradle', AuditStatus.failure);
    return out;
  }

  // Identité
  final id = a.applicationId;
  if (id == null) {
    add(AndroidArea.identity, 'applicationId', AuditStatus.failure);
  } else if (id.startsWith('com.example')) {
    add(AndroidArea.identity, 'exampleId', AuditStatus.failure, [id]);
  } else if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$')
      .hasMatch(id)) {
    add(AndroidArea.identity, 'applicationIdInvalid', AuditStatus.failure, [
      id,
    ]);
  } else {
    add(AndroidArea.identity, 'applicationId', AuditStatus.ok, [id]);
  }
  if (a.label != null) {
    final looksLikePackage = RegExp(r'^[a-z0-9_]+$').hasMatch(a.label!);
    add(
      AndroidArea.identity,
      'label',
      looksLikePackage ? AuditStatus.warning : AuditStatus.ok,
      [a.label!],
    );
  }

  // Version
  final fromFlutter =
      (a.versionCode?.startsWith('flutter.') ?? false) &&
      (a.versionName?.startsWith('flutter.') ?? false);
  if (fromFlutter) {
    final build = pubVersion?.split('+').elementAtOrNull(1);
    add(
      AndroidArea.version,
      build == null ? 'noBuildNumber' : 'versionFromPubspec',
      build == null ? AuditStatus.warning : AuditStatus.ok,
      [?pubVersion],
    );
  } else {
    add(AndroidArea.version, 'versionHardcoded', AuditStatus.warning, [
      a.versionName ?? '?',
      a.versionCode ?? '?',
    ]);
  }

  // SDK
  final target = a.targetSdk;
  if (_isNumber(target)) {
    final n = int.parse(target!);
    add(
      AndroidArea.sdk,
      n >= playTargetSdk ? 'targetSdk' : 'targetSdkTooLow',
      n >= playTargetSdk ? AuditStatus.ok : AuditStatus.failure,
      [target, '$playTargetSdk'],
    );
  } else {
    add(AndroidArea.sdk, 'targetSdkFlutter', AuditStatus.info, [
      target ?? '?',
      '$playTargetSdk',
    ]);
  }
  if (_isNumber(a.minSdk)) {
    add(AndroidArea.sdk, 'minSdk', AuditStatus.info, [a.minSdk!]);
  }

  // Signature
  switch (a.signing) {
    case ReleaseSigning.debugKey:
      add(AndroidArea.signing, 'debugSigning', AuditStatus.failure);
    case ReleaseSigning.missing:
      add(AndroidArea.signing, 'noSigning', AuditStatus.failure);
    case ReleaseSigning.releaseConfig:
      add(AndroidArea.signing, 'releaseSigning', AuditStatus.ok);
  }
  add(
    AndroidArea.signing,
    'keyProperties',
    a.keyPropertiesExists ? AuditStatus.ok : AuditStatus.warning,
  );
  if (gitIgnored != null) {
    final exposed = [
      if (a.keyPropertiesExists &&
          !gitIgnored.contains('${a.androidDir}/key.properties'))
        '${a.androidDir}/key.properties',
      for (final k in a.keystoreFiles)
        if (!gitIgnored.contains(k)) k,
    ];
    add(
      AndroidArea.signing,
      'gitignore',
      exposed.isEmpty ? AuditStatus.ok : AuditStatus.failure,
      exposed,
    );
  }

  // Sécurité
  if (a.debuggable) {
    add(AndroidArea.security, 'debuggable', AuditStatus.failure);
  }
  add(
    AndroidArea.security,
    'cleartext',
    a.cleartextTraffic ? AuditStatus.warning : AuditStatus.ok,
  );

  // Permissions : niveau et cohérence avec les plugins.
  for (final perm in a.permissions) {
    final short = perm.short;
    final level = permissionLevel(short);
    final feature = permissionFeature(short);
    final explained =
        feature == null || featurePlugins[feature]!.any(dependencies.contains);
    if (level == PermissionLevel.restricted) {
      add(AndroidArea.permissions, 'permRestricted', AuditStatus.failure, [
        short,
      ]);
    } else if (level == PermissionLevel.dangerous) {
      add(
        AndroidArea.permissions,
        explained ? 'permDangerous' : 'permUnexplained',
        explained ? AuditStatus.info : AuditStatus.warning,
        [short],
      );
    }
  }
  final declaredFeatures = {
    for (final perm in a.permissions) ?permissionFeature(perm.short),
  };
  for (final e in featurePlugins.entries) {
    if (e.key == 'storage') continue;
    final plugins = e.value.where(dependencies.contains).toList();
    if (plugins.isNotEmpty && !declaredFeatures.contains(e.key)) {
      add(AndroidArea.permissions, 'pluginNoPermission', AuditStatus.info, [
        plugins.first,
        e.key,
      ]);
    }
  }
  if (dependencies.contains('google_mobile_ads')) {
    add(AndroidArea.permissions, 'adId', AuditStatus.info);
  }

  // Icônes
  final missing = [
    for (final d in mipmapDensities)
      if (!a.mipmaps.contains(d)) d,
  ];
  add(
    AndroidArea.icons,
    'mipmaps',
    missing.isEmpty ? AuditStatus.ok : AuditStatus.warning,
    missing,
  );
  return out;
}
