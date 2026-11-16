import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../commands/domain/command_spec.dart';
import '../../content/domain/icons.dart';

/// Champs de la fiche Play Store et leurs limites.
enum PlayField {
  title(30, 'title.txt'),
  shortDescription(80, 'short_description.txt'),
  fullDescription(4000, 'full_description.txt'),
  changelog(500, null);

  const PlayField(this.limit, this.file);
  final int limit;

  /// Fichier Fastlane (le changelog dépend du versionCode).
  final String? file;
}

/// Langues proposées (codes Play / Fastlane).
const playLocales = ['fr-FR', 'en-US'];

@immutable
class PlayListing {
  const PlayListing([this.values = const {}]);

  final Map<PlayField, String> values;

  String operator [](PlayField f) => values[f] ?? '';

  PlayListing copyWith(PlayField f, String v) => PlayListing({...values, f: v});

  bool get isEmpty => values.values.every((v) => v.trim().isEmpty);

  List<PlayField> get overLimit => [
    for (final f in PlayField.values)
      if (this[f].runes.length > f.limit) f,
  ];

  List<PlayField> get missing => [
    for (final f in const [
      PlayField.title,
      PlayField.shortDescription,
      PlayField.fullDescription,
    ])
      if (this[f].trim().isEmpty) f,
  ];

  Map<String, String> toJson() => {
    for (final e in values.entries) e.key.name: e.value,
  };

  factory PlayListing.fromJson(Map<String, Object?> j) => PlayListing({
    for (final f in PlayField.values)
      if (j[f.name] case final String v) f: v,
  });
}

/// Fichiers texte de métadonnées pour `fastlane supply`, relatifs au dossier
/// `fastlane` (ex. `metadata/android/fr-FR/title.txt`).
Map<String, String> supplyTextFiles(
  Map<String, PlayListing> listings, {
  required int versionCode,
}) => {
  for (final e in listings.entries)
    if (!e.value.isEmpty) ...{
      for (final f in PlayField.values)
        if (f.file != null)
          'metadata/android/${e.key}/${f.file}': '${e.value[f].trim()}\n',
      if (e.value[PlayField.changelog].trim().isNotEmpty)
        'metadata/android/${e.key}/changelogs/$versionCode.txt':
            '${e.value[PlayField.changelog].trim()}\n',
    },
};

/// Appfile : identifiant de l'application seulement. La clé du compte de
/// service n'y figure jamais : elle est passée au lancement (`json_key:`).
String appfile(String packageName) =>
    '# Généré par LaunchPilot.\npackage_name("$packageName")\n';

/// Fastfile : envoi sur la piste de test interne, en brouillon.
String fastfile({required String aabPath}) =>
    '''
# Généré par LaunchPilot. La clé du compte de service est passée au
# lancement (json_key:/chemin/hors/du/projet.json) et n'est jamais stockée.
default_platform(:android)

platform :android do
  desc "Vérifie la clé du compte de service"
  lane :check do |options|
    validate_play_store_json_key(json_key: options[:json_key])
  end

  desc "Envoie l'App Bundle sur la piste de test interne (brouillon)"
  lane :internal do |options|
    upload_to_play_store(
      json_key: options[:json_key],
      track: "internal",
      release_status: "draft",
      aab: "$aabPath",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end

  desc "Met à jour la fiche (textes, icône, captures) sans envoyer de build"
  lane :metadata do |options|
    upload_to_play_store(
      json_key: options[:json_key],
      skip_upload_apk: true,
      skip_upload_aab: true,
      skip_upload_changelogs: true
    )
  end
end
''';

/// Lanes générées et acceptées par la politique de commandes.
const fastlaneLanes = {'check', 'internal', 'metadata'};

/// Commande d'envoi du flux dédié, lancée dans le dossier `android`.
CommandSpec fastlaneCommand(
  String androidDirAbs,
  String lane,
  String jsonKey,
) => CommandSpec(
  executable: 'fastlane',
  arguments: [lane, 'json_key:$jsonKey'],
  workingDirectory: androidDirAbs,
  timeout: const Duration(minutes: 15),
  purpose: lane == 'check' ? CommandPurpose.general : CommandPurpose.deployment,
);

/// Visuel de présentation 1024 × 500 exigé par Google Play : fond uni et
/// icône centrée (sans étirement).
Uint8List featureGraphic(Uint8List icon, int argb) {
  final canvas = img.Image(width: 1024, height: 500, numChannels: 4);
  img.fill(
    canvas,
    color: img.ColorRgba8(
      (argb >> 16) & 0xFF,
      (argb >> 8) & 0xFF,
      argb & 0xFF,
      255,
    ),
  );
  final source = img.decodeImage(icon);
  if (source != null) {
    final side = 360;
    final scale =
        side / (source.width > source.height ? source.width : source.height);
    final resized = img.copyResize(
      source,
      width: (source.width * scale).round(),
      height: (source.height * scale).round(),
      interpolation: img.Interpolation.average,
    );
    img.compositeImage(
      canvas,
      resized,
      dstX: (1024 - resized.width) ~/ 2,
      dstY: (500 - resized.height) ~/ 2,
    );
  }
  return img.encodePng(canvas);
}

/// Icône Play : 512 × 512, PNG 32 bits, sans déformation (image non carrée
/// centrée sur fond transparent). Null si la source fait moins de 512 px.
Uint8List? playIcon(Uint8List source) {
  final report = inspectIcon(source);
  if (!report.usable) return null;
  return generateIcons(source, const [IconTarget('icon.png', 512)])['icon.png'];
}
