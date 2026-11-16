import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Champs de la fiche App Store (fichiers de `fastlane deliver`).
enum AppStoreField {
  name(30, 'name.txt'),
  subtitle(30, 'subtitle.txt'),
  description(4000, 'description.txt'),
  keywords(100, 'keywords.txt'),
  promotionalText(170, 'promotional_text.txt'),
  releaseNotes(4000, 'release_notes.txt');

  const AppStoreField(this.limit, this.file);
  final int limit;
  final String file;
}

const appStoreLocales = ['fr-FR', 'en-US'];

@immutable
class AppStoreListing {
  const AppStoreListing([this.values = const {}]);

  final Map<AppStoreField, String> values;

  String operator [](AppStoreField f) => values[f] ?? '';

  bool get isEmpty => values.values.every((v) => v.trim().isEmpty);

  List<AppStoreField> get overLimit => [
    for (final f in AppStoreField.values)
      if (this[f].runes.length > f.limit) f,
  ];

  List<AppStoreField> get missing => [
    for (final f in const [
      AppStoreField.name,
      AppStoreField.description,
      AppStoreField.keywords,
    ])
      if (this[f].trim().isEmpty) f,
  ];

  Map<String, String> toJson() => {
    for (final e in values.entries) e.key.name: e.value,
  };

  factory AppStoreListing.fromJson(Map<String, Object?> j) => AppStoreListing({
    for (final f in AppStoreField.values)
      if (j[f.name] case final String v) f: v,
  });
}

/// Réglages iOS d'un projet (identifiants publics, aucun secret).
@immutable
class IosConfig {
  const IosConfig({
    this.teamId = '',
    this.appleAppId = '',
    this.supportUrl = '',
    this.privacyUrl = '',
    this.marketingUrl = '',
    this.copyright = '',
    this.ci = CiProvider.githubActions,
  });

  /// Identifiant d'équipe Apple (10 caractères).
  final String teamId;

  /// Identifiant numérique de l'application dans App Store Connect.
  final String appleAppId;
  final String supportUrl;
  final String privacyUrl;
  final String marketingUrl;
  final String copyright;
  final CiProvider ci;

  bool get teamValid => RegExp(r'^[A-Z0-9]{10}$').hasMatch(teamId);
  bool get appleAppIdValid => RegExp(r'^\d{6,12}$').hasMatch(appleAppId);

  IosConfig copyWith({
    String? teamId,
    String? appleAppId,
    String? supportUrl,
    String? privacyUrl,
    String? marketingUrl,
    String? copyright,
    CiProvider? ci,
  }) => IosConfig(
    teamId: teamId ?? this.teamId,
    appleAppId: appleAppId ?? this.appleAppId,
    supportUrl: supportUrl ?? this.supportUrl,
    privacyUrl: privacyUrl ?? this.privacyUrl,
    marketingUrl: marketingUrl ?? this.marketingUrl,
    copyright: copyright ?? this.copyright,
    ci: ci ?? this.ci,
  );

  Map<String, Object?> toJson() => {
    'teamId': teamId,
    'appleAppId': appleAppId,
    'supportUrl': supportUrl,
    'privacyUrl': privacyUrl,
    'marketingUrl': marketingUrl,
    'copyright': copyright,
    'ci': ci.name,
  };

  factory IosConfig.fromJson(Map<String, Object?> j) => IosConfig(
    teamId: '${j['teamId'] ?? ''}',
    appleAppId: '${j['appleAppId'] ?? ''}',
    supportUrl: '${j['supportUrl'] ?? ''}',
    privacyUrl: '${j['privacyUrl'] ?? ''}',
    marketingUrl: '${j['marketingUrl'] ?? ''}',
    copyright: '${j['copyright'] ?? ''}',
    ci:
        CiProvider.values.where((c) => c.name == j['ci']).firstOrNull ??
        CiProvider.githubActions,
  );

  @override
  bool operator ==(Object other) =>
      other is IosConfig && jsonEncode(other.toJson()) == jsonEncode(toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;
}

enum CiProvider {
  githubActions('GitHub Actions'),
  codemagic('Codemagic');

  const CiProvider(this.label);
  final String label;
}

/// Fichiers de métadonnées `deliver`, relatifs au dossier `fastlane`.
Map<String, String> deliverTextFiles(
  Map<String, AppStoreListing> listings,
  IosConfig config,
) => {
  for (final e in listings.entries)
    if (!e.value.isEmpty) ...{
      for (final f in AppStoreField.values)
        if (e.value[f].trim().isNotEmpty)
          'metadata/${e.key}/${f.file}': '${e.value[f].trim()}\n',
      if (config.supportUrl.isNotEmpty)
        'metadata/${e.key}/support_url.txt': '${config.supportUrl}\n',
      if (config.privacyUrl.isNotEmpty)
        'metadata/${e.key}/privacy_url.txt': '${config.privacyUrl}\n',
      if (config.marketingUrl.isNotEmpty)
        'metadata/${e.key}/marketing_url.txt': '${config.marketingUrl}\n',
    },
  if (config.copyright.isNotEmpty)
    'metadata/copyright.txt': '${config.copyright}\n',
};

/// Appfile iOS : identifiants publics seulement.
String iosAppfile(String bundleId, String teamId) =>
    '# Généré par LaunchPilot.\napp_identifier("$bundleId")\n'
    '${teamId.isEmpty ? '' : 'team_id("$teamId")\n'}';

/// Fastfile iOS, prévu pour un Mac ou une CI macOS (jamais lancé sous
/// Linux). La clé App Store Connect vient des variables d'environnement.
String iosFastfile() => r'''
# Généré par LaunchPilot. À lancer sur un Mac ou dans une CI macOS.
# Variables attendues : ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_P8_BASE64.
default_platform(:ios)

platform :ios do
  def asc_key
    app_store_connect_api_key(
      key_id: ENV["ASC_KEY_ID"],
      issuer_id: ENV["ASC_ISSUER_ID"],
      key_content: ENV["ASC_KEY_P8_BASE64"],
      is_key_content_base64: true
    )
  end

  desc "Envoie la fiche (textes et captures) sans build"
  lane :metadata do
    deliver(
      api_key: asc_key,
      skip_binary_upload: true,
      submit_for_review: false,
      force: true,
      precheck_include_in_app_purchases: false
    )
  end

  desc "Envoie un .ipa déjà construit sur TestFlight"
  lane :beta do |options|
    upload_to_testflight(
      api_key: asc_key,
      ipa: options[:ipa] || "../build/ios/ipa/Runner.ipa",
      skip_waiting_for_build_processing: true
    )
  end
end
''';

/// ExportOptions.plist : distribution App Store Connect, signature
/// automatique.
String exportOptionsPlist(String teamId) =>
    '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
\t<key>method</key>
\t<string>app-store-connect</string>
\t<key>destination</key>
\t<string>export</string>
\t<key>teamID</key>
\t<string>$teamId</string>
\t<key>signingStyle</key>
\t<string>automatic</string>
\t<key>uploadSymbols</key>
\t<true/>
\t<key>manageAppVersionAndBuildNumber</key>
\t<false/>
</dict>
</plist>
''';

/// Secrets à créer dans la CI (noms seulement, jamais de valeur).
const githubSecrets = ['ASC_KEY_ID', 'ASC_ISSUER_ID', 'ASC_KEY_P8_BASE64'];

/// Workflow GitHub Actions sur runner macOS : archive signée
/// automatiquement grâce à la clé App Store Connect, export .ipa puis envoi
/// sur TestFlight. Déclenché à la main uniquement.
String githubIosWorkflow({
  required String iosDir,
  required String teamId,
  String runner = 'macos-26',
}) {
  final project = iosDir.contains('/')
      ? iosDir.substring(0, iosDir.lastIndexOf('/'))
      : '.';
  return '''
# Généré par LaunchPilot. Lancement manuel uniquement (onglet Actions de
# GitHub) : LaunchPilot ne pousse jamais et ne déclenche aucun build.
# Secrets à créer : ${githubSecrets.join(', ')}.
name: iOS TestFlight

on:
  workflow_dispatch:

jobs:
  ios:
    runs-on: $runner
    timeout-minutes: 60
    defaults:
      run:
        working-directory: $project
    env:
      ASC_KEY_ID: \${{ secrets.ASC_KEY_ID }}
      ASC_ISSUER_ID: \${{ secrets.ASC_ISSUER_ID }}
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - name: Xcode 26 ou plus récent (exigé par App Store Connect)
        run: xcodebuild -version
      - run: flutter pub get
      - name: Préparer le projet iOS sans signature
        run: flutter build ios --release --no-codesign
      - name: Clé App Store Connect (fichier temporaire)
        env:
          ASC_KEY_P8_BASE64: \${{ secrets.ASC_KEY_P8_BASE64 }}
        run: |
          mkdir -p ~/.appstoreconnect/private_keys
          echo "\$ASC_KEY_P8_BASE64" | base64 --decode > ~/.appstoreconnect/private_keys/AuthKey_\$ASC_KEY_ID.p8
      - name: Archive signée (signature automatique)
        run: |
          xcodebuild -workspace $iosDir/Runner.xcworkspace -scheme Runner \\
            -configuration Release -destination 'generic/platform=iOS' \\
            -archivePath \$RUNNER_TEMP/Runner.xcarchive \\
            DEVELOPMENT_TEAM=$teamId \\
            -allowProvisioningUpdates \\
            -authenticationKeyPath ~/.appstoreconnect/private_keys/AuthKey_\$ASC_KEY_ID.p8 \\
            -authenticationKeyID \$ASC_KEY_ID -authenticationKeyIssuerID \$ASC_ISSUER_ID \\
            archive
      - name: Export .ipa
        run: |
          xcodebuild -exportArchive -archivePath \$RUNNER_TEMP/Runner.xcarchive \\
            -exportOptionsPlist $iosDir/ExportOptions.plist \\
            -exportPath \$RUNNER_TEMP/export \\
            -allowProvisioningUpdates \\
            -authenticationKeyPath ~/.appstoreconnect/private_keys/AuthKey_\$ASC_KEY_ID.p8 \\
            -authenticationKeyID \$ASC_KEY_ID -authenticationKeyIssuerID \$ASC_ISSUER_ID
      - name: Envoi sur TestFlight
        run: |
          xcrun altool --upload-app --type ios \\
            --file "\$(ls \$RUNNER_TEMP/export/*.ipa)" \\
            --apiKey \$ASC_KEY_ID --apiIssuer \$ASC_ISSUER_ID
      - uses: actions/upload-artifact@v4
        with:
          name: ios-ipa
          path: \${{ runner.temp }}/export/*.ipa
      - name: Supprimer la clé
        if: always()
        run: rm -f ~/.appstoreconnect/private_keys/*.p8
''';
}

/// codemagic.yaml : signature et publication gérées par l'intégration
/// App Store Connect de Codemagic (clé créée dans son interface).
String codemagicYaml({
  required String bundleId,
  required String appleAppId,
  required String pubDir,
}) =>
    '''
# Généré par LaunchPilot. À relier dans Codemagic : intégration App Store
# Connect nommée « launchpilot » (Teams → Integrations). Aucune clé ici.
workflows:
  ios-testflight:
    name: iOS TestFlight
    instance_type: mac_mini_m2
    max_build_duration: 60
${pubDir.isEmpty ? '' : '    working_directory: $pubDir\n'}    integrations:
      app_store_connect: launchpilot
    environment:
      ios_signing:
        distribution_type: app_store
        bundle_identifier: $bundleId
      vars:
        APP_STORE_APPLE_ID: ${appleAppId.isEmpty ? '0000000000 # identifiant numérique App Store Connect' : appleAppId}
      flutter: stable
      xcode: latest
    scripts:
      - name: Profils de signature
        script: xcode-project use-profiles
      - name: Dépendances
        script: flutter pub get
      - name: Build .ipa
        script: |
          flutter build ipa --release \\
            --build-number=\$((\$(app-store-connect get-latest-app-store-build-number "\$APP_STORE_APPLE_ID") + 1)) \\
            --export-options-plist=/Users/builder/export_options.plist
    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log
    publishing:
      app_store_connect:
        auth: integration
        submit_to_testflight: true
        submit_to_app_store: false
''';

/// Données à déclarer dans « Confidentialité de l'app » d'App Store Connect
/// (étiquettes de confidentialité), à saisir à la main.
const appPrivacyLabels = {
  'contact': 'Coordonnées (e-mail, nom)',
  'location': 'Localisation précise',
  'photos': 'Photos ou vidéos',
  'audio': 'Données audio',
  'contacts': 'Contacts',
  'usage': 'Utilisation : interactions avec le produit',
  'crashDiagnostics': 'Diagnostics : données de plantage',
  'advertisingId': 'Identifiants : identifiant de l\'appareil (publicité)',
  'payment': 'Achats / informations de paiement',
};
