import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../content/domain/legal.dart';

String _xml(String v) => const HtmlEscape(HtmlEscapeMode.element).convert(v);

/// Fin du dictionnaire racine (dernier `</dict>` avant `</plist>`).
int? _rootDictEnd(String xml) {
  final plistEnd = xml.lastIndexOf('</plist>');
  if (plistEnd < 0) return null;
  final i = xml.lastIndexOf('</dict>', plistEnd);
  return i < 0 ? null : i;
}

/// Ajoute ou remplace une valeur de premier niveau d'Info.plist. Les autres
/// lignes sont conservées. Null si le fichier n'a pas la forme attendue.
String? setPlistValue(String xml, String key, Object value) {
  final element = switch (value) {
    final bool b => b ? '<true/>' : '<false/>',
    _ => '<string>${_xml('$value')}</string>',
  };
  final existing = RegExp(
    '(<key>${RegExp.escape(key)}</key>\\s*)(<string>[^<]*</string>|<true\\s*/>|<false\\s*/>)',
  );
  if (existing.hasMatch(xml)) {
    return xml.replaceFirstMapped(existing, (m) => '${m.group(1)}$element');
  }
  final end = _rootDictEnd(xml);
  if (end == null) return null;
  // Indentation des clés existantes (tabulation dans le modèle Flutter).
  final indent = RegExp(r'\n([ \t]+)<key>').firstMatch(xml)?.group(1) ?? '\t';
  return '${xml.substring(0, end)}$indent<key>$key</key>\n$indent$element\n${xml.substring(end)}';
}

// ------------------------------------------------- manifeste de confidentialité

/// Type de donnée Apple correspondant à chaque catégorie du questionnaire.
const _collected = {
  DataCategory.contact: [
    'NSPrivacyCollectedDataTypeEmailAddress',
    'NSPrivacyCollectedDataTypeName',
  ],
  DataCategory.location: ['NSPrivacyCollectedDataTypePreciseLocation'],
  DataCategory.photos: ['NSPrivacyCollectedDataTypePhotosorVideos'],
  DataCategory.audio: ['NSPrivacyCollectedDataTypeAudioData'],
  DataCategory.contacts: ['NSPrivacyCollectedDataTypeContacts'],
  DataCategory.usage: ['NSPrivacyCollectedDataTypeProductInteraction'],
  DataCategory.crashDiagnostics: ['NSPrivacyCollectedDataTypeCrashData'],
  DataCategory.advertisingId: ['NSPrivacyCollectedDataTypeDeviceID'],
  DataCategory.payment: ['NSPrivacyCollectedDataTypePaymentInfo'],
};

String _purpose(DataCategory c) => switch (c) {
  DataCategory.usage => 'NSPrivacyCollectedDataTypePurposeAnalytics',
  DataCategory.advertisingId =>
    'NSPrivacyCollectedDataTypePurposeThirdPartyAdvertising',
  _ => 'NSPrivacyCollectedDataTypePurposeAppFunctionality',
};

/// PrivacyInfo.xcprivacy à partir du questionnaire juridique. Les API à
/// « raison requise » utilisées par les plugins sont déclarées dans leurs
/// propres manifestes ; la liste de l'application reste vide par défaut.
String privacyManifest(LegalAnswers a, {bool tracking = false}) {
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
    )
    ..writeln(
      '<!-- Généré par LaunchPilot à partir du questionnaire juridique : à relire. -->',
    )
    ..writeln('<plist version="1.0">')
    ..writeln('<dict>')
    ..writeln('\t<key>NSPrivacyTracking</key>')
    ..writeln('\t<${tracking ? 'true' : 'false'}/>')
    ..writeln('\t<key>NSPrivacyTrackingDomains</key>')
    ..writeln('\t<array/>')
    ..writeln('\t<key>NSPrivacyCollectedDataTypes</key>')
    ..writeln('\t<array>');
  for (final c in DataCategory.values.where(a.data.contains)) {
    for (final type in _collected[c]!) {
      final tracked = tracking && c == DataCategory.advertisingId;
      b
        ..writeln('\t\t<dict>')
        ..writeln('\t\t\t<key>NSPrivacyCollectedDataType</key>')
        ..writeln('\t\t\t<string>$type</string>')
        ..writeln('\t\t\t<key>NSPrivacyCollectedDataTypeLinked</key>')
        ..writeln(
          '\t\t\t<${c == DataCategory.contact || c == DataCategory.payment ? 'true' : 'false'}/>',
        )
        ..writeln('\t\t\t<key>NSPrivacyCollectedDataTypeTracking</key>')
        ..writeln('\t\t\t<${tracked ? 'true' : 'false'}/>')
        ..writeln('\t\t\t<key>NSPrivacyCollectedDataTypePurposes</key>')
        ..writeln('\t\t\t<array>')
        ..writeln('\t\t\t\t<string>${_purpose(c)}</string>')
        ..writeln('\t\t\t</array>')
        ..writeln('\t\t</dict>');
    }
  }
  b
    ..writeln('\t</array>')
    ..writeln('\t<key>NSPrivacyAccessedAPITypes</key>')
    ..writeln('\t<array/>')
    ..writeln('</dict>')
    ..writeln('</plist>');
  return b.toString();
}

/// Résultat de l'ajout du manifeste au projet Xcode.
enum PbxEditOutcome { changed, alreadyPresent, unrecognized }

typedef PbxEdit = ({PbxEditOutcome outcome, String? content});

/// Identifiant d'objet Xcode (24 caractères hexadécimaux) absent du fichier.
String _objectId(String content, String seed) {
  for (var i = 0; ; i++) {
    final id = sha1
        .convert(utf8.encode('launchpilot:$seed:$i'))
        .toString()
        .substring(0, 24)
        .toUpperCase();
    if (!content.contains(id)) return id;
  }
}

/// Référence PrivacyInfo.xcprivacy dans le groupe Runner et la phase
/// « Copy Bundle Resources » de la cible Runner, comme le ferait Xcode.
/// Le fichier n'est pas modifié s'il ne ressemble pas au modèle Flutter.
PbxEdit addPrivacyManifestToProject(String content) {
  if (content.contains('PrivacyInfo.xcprivacy')) {
    return (outcome: PbxEditOutcome.alreadyPresent, content: null);
  }
  const unrecognized = (outcome: PbxEditOutcome.unrecognized, content: null);
  final buildFileEnd = content.indexOf('/* End PBXBuildFile section */');
  final fileRefEnd = content.indexOf('/* End PBXFileReference section */');
  // Groupe Runner : bloc PBXGroup qui se termine par « path = Runner; ».
  final group = RegExp(
    r'/\* Runner \*/ = \{\s*isa = PBXGroup;\s*children = \(\n',
  ).firstMatch(content);
  // Phase de ressources de la cible Runner : celle qui copie Assets.xcassets.
  final resources = RegExp(
    r'isa = PBXResourcesBuildPhase;\s*buildActionMask = \d+;\s*files = \(\n(?=[^)]*Assets\.xcassets in Resources)',
  ).firstMatch(content);
  if (buildFileEnd < 0 ||
      fileRefEnd < 0 ||
      group == null ||
      resources == null) {
    return unrecognized;
  }
  final fileRef = _objectId(content, 'PrivacyInfo.ref');
  final buildFile = _objectId('$content$fileRef', 'PrivacyInfo.build');
  final inserts = <(int, String)>[
    (
      buildFileEnd,
      '\t\t$buildFile /* PrivacyInfo.xcprivacy in Resources */ = {isa = PBXBuildFile; fileRef = $fileRef /* PrivacyInfo.xcprivacy */; };\n',
    ),
    (
      fileRefEnd,
      '\t\t$fileRef /* PrivacyInfo.xcprivacy */ = {isa = PBXFileReference; lastKnownFileType = text.xml; path = PrivacyInfo.xcprivacy; sourceTree = "<group>"; };\n',
    ),
    (group.end, '\t\t\t\t$fileRef /* PrivacyInfo.xcprivacy */,\n'),
    (
      resources.end,
      '\t\t\t\t$buildFile /* PrivacyInfo.xcprivacy in Resources */,\n',
    ),
  ]..sort((x, y) => y.$1.compareTo(x.$1));
  var out = content;
  for (final (at, text) in inserts) {
    out = out.replaceRange(at, at, text);
  }
  return (outcome: PbxEditOutcome.changed, content: out);
}

/// Textes d'accès proposés (à adapter), par clé d'Info.plist.
String suggestedUsageText(String key, String appName, {required bool fr}) {
  final app = appName.isEmpty ? (fr ? 'L\'application' : 'The app') : appName;
  return switch (key) {
    'NSCameraUsageDescription' =>
      fr
          ? '$app utilise l\'appareil photo pour prendre les photos que tu ajoutes à ton carnet.'
          : '$app uses the camera to take the photos you add to your notebook.',
    'NSMicrophoneUsageDescription' =>
      fr
          ? '$app utilise le micro pour enregistrer le son de tes vidéos.'
          : '$app uses the microphone to record the sound of your videos.',
    'NSPhotoLibraryUsageDescription' =>
      fr
          ? '$app accède à tes photos pour que tu choisisses celles à importer.'
          : '$app accesses your photos so you can choose which ones to import.',
    'NSLocationWhenInUseUsageDescription' =>
      fr
          ? '$app utilise ta position pendant son utilisation pour situer tes contenus sur la carte.'
          : '$app uses your location while in use to place your content on the map.',
    'NSContactsUsageDescription' =>
      fr
          ? '$app accède à tes contacts pour que tu puisses les inviter.'
          : '$app accesses your contacts so you can invite them.',
    _ =>
      fr
          ? '$app a besoin de cet accès pour [explique la fonction concrète].'
          : '$app needs this access to [explain the concrete feature].',
  };
}
