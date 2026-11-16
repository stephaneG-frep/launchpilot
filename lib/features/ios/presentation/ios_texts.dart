import '../../settings/domain/app_settings.dart';
import '../domain/ios_audit.dart';

/// Libellé et conseil d'un contrôle iOS (contenu pédagogique bilingue).
typedef IosCheckText = ({String label, String fix});

IosCheckText iosCheckText(IosCheck c, AppLanguage lang) {
  final fr = lang == AppLanguage.fr;
  IosCheckText t(String lf, String ff, String le, String fe) =>
      fr ? (label: lf, fix: ff) : (label: le, fix: fe);
  final v = c.values;
  String at(int i) => i < v.length ? v[i] : '?';

  return switch (c.id) {
    'linuxHost' => t(
      'LaunchPilot tourne sous Linux',
      'Aucun build iOS n\'est possible ici : il sera fait par une CI macOS avec Xcode ${at(0)} ou plus récent (exigé par App Store Connect depuis le 28 avril 2026).',
      'LaunchPilot runs on Linux',
      'No iOS build is possible here: a macOS CI will do it with Xcode ${at(0)} or newer (required by App Store Connect since 28 April 2026).',
    ),
    'macHost' => t(
      'Mac détecté',
      'Tu peux aussi construire avec Xcode ${at(0)} sur cette machine ; LaunchPilot prépare les mêmes fichiers.',
      'Mac detected',
      'You can also build with Xcode ${at(0)} on this machine; LaunchPilot prepares the same files.',
    ),
    'noProject' => t(
      'Projet Xcode',
      'Info.plist ou project.pbxproj introuvable : génère le module iOS avec « flutter create --platforms=ios . ».',
      'Xcode project',
      'Info.plist or project.pbxproj not found: generate the iOS module with "flutter create --platforms=ios .".',
    ),
    'bundleId' => t(
      'Identifiant (bundle ID) : ${at(0)}',
      'Aucun PRODUCT_BUNDLE_IDENTIFIER trouvé dans le projet.',
      'Bundle ID: ${at(0)}',
      'No PRODUCT_BUNDLE_IDENTIFIER found in the project.',
    ),
    'exampleBundleId' => t(
      'Identifiant (bundle ID) : ${at(0)}',
      'Apple refuse « com.example ». Choisis ton identifiant définitif (ex. fr.tonnom.appli) et enregistre-le sur le portail développeur avant le premier envoi.',
      'Bundle ID: ${at(0)}',
      'Apple rejects "com.example". Pick your permanent ID (e.g. com.yourname.app) and register it on the developer portal before the first upload.',
    ),
    'displayName' => t(
      'Nom affiché : ${at(0)}',
      'Il ressemble à un nom de paquet : corrige CFBundleDisplayName dans Info.plist.',
      'Displayed name: ${at(0)}',
      'It looks like a package name: fix CFBundleDisplayName in Info.plist.',
    ),
    'deploymentTarget' => t(
      'iOS minimum : ${at(0)}',
      'Les appareils plus anciens ne pourront pas installer l\'application.',
      'Minimum iOS: ${at(0)}',
      'Older devices will not be able to install the app.',
    ),
    'versionFromPubspec' => t(
      'Version issue du pubspec',
      '',
      'Version from pubspec',
      '',
    ),
    'versionHardcoded' => t(
      'Version écrite en dur (${at(0)})',
      'Utilise \$(FLUTTER_BUILD_NAME) et \$(FLUTTER_BUILD_NUMBER) pour suivre le pubspec.',
      'Hard-coded version (${at(0)})',
      'Use \$(FLUTTER_BUILD_NAME) and \$(FLUTTER_BUILD_NUMBER) to follow the pubspec.',
    ),
    'usageMissing' => t(
      'Texte d\'accès manquant : ${at(0)}',
      'Le plugin ${at(1)} en a besoin : sans lui, l\'application se ferme au premier accès et Apple la refuse. Rédige-le ci-dessous.',
      'Missing access text: ${at(0)}',
      'The ${at(1)} plugin needs it: without it, the app crashes on first access and Apple rejects it. Write it below.',
    ),
    'usageWeak' => t(
      'Texte d\'accès trop vague : ${at(0)}',
      '« ${at(1)} » n\'explique pas à quoi sert l\'accès : Apple demande une phrase concrète.',
      'Access text too vague: ${at(0)}',
      '"${at(1)}" does not explain what the access is for: Apple asks for a concrete sentence.',
    ),
    'usageOk' => t(
      'Texte d\'accès : ${at(0)}',
      '',
      'Access text: ${at(0)}',
      '',
    ),
    'usageExtra' => t(
      'Texte d\'accès sans plugin détecté : ${at(0)}',
      'Vérifie qu\'il sert encore ; sinon retire-le.',
      'Access text without a detected plugin: ${at(0)}',
      'Check it is still needed; otherwise remove it.',
    ),
    'privacyManifest' => t(
      'Manifeste de confidentialité',
      'Aucun PrivacyInfo.xcprivacy : Apple attend une déclaration des données collectées et des API sensibles. LaunchPilot peut le préparer depuis le questionnaire juridique.',
      'Privacy manifest',
      'No PrivacyInfo.xcprivacy: Apple expects a declaration of collected data and sensitive APIs. LaunchPilot can prepare it from the legal questionnaire.',
    ),
    'privacyManifestNotInProject' => t(
      'Manifeste de confidentialité',
      'Le fichier existe mais n\'est pas ajouté à la cible Runner : il ne sera pas embarqué.',
      'Privacy manifest',
      'The file exists but is not added to the Runner target: it will not be bundled.',
    ),
    'privacyManifestOk' => t(
      'Manifeste de confidentialité présent',
      '',
      'Privacy manifest present',
      '',
    ),
    'encryption' => t(
      'Déclaration de chiffrement',
      'ITSAppUsesNonExemptEncryption absent : App Store Connect posera la question à chaque envoi. Si l\'application n\'utilise que le chiffrement standard (HTTPS), déclare « false ».',
      'Encryption declaration',
      'ITSAppUsesNonExemptEncryption missing: App Store Connect will ask at every upload. If the app only uses standard encryption (HTTPS), declare "false".',
    ),
    'encryptionDeclared' => t(
      'Chiffrement déclaré (${at(0)})',
      '',
      'Encryption declared (${at(0)})',
      '',
    ),
    'noTeam' => t(
      'Équipe Apple (DEVELOPMENT_TEAM)',
      'Aucune équipe dans le projet : indique ton Team ID ci-dessous, il sera passé à la CI pour la signature automatique.',
      'Apple team (DEVELOPMENT_TEAM)',
      'No team in the project: enter your Team ID below, it will be passed to the CI for automatic signing.',
    ),
    'team' => t('Équipe Apple : ${at(0)}', '', 'Apple team: ${at(0)}', ''),
    'automaticSigning' => t(
      'Signature automatique',
      '',
      'Automatic signing',
      '',
    ),
    'manualSigning' => t(
      'Signature manuelle',
      'Le projet signe à la main : la CI devra recevoir certificat et profil (Codemagic les gère pour toi).',
      'Manual signing',
      'The project signs manually: the CI will need certificate and profile (Codemagic manages them for you).',
    ),
    'marketingIconMissing' => t(
      'Icône App Store 1024 px',
      'Absente : génère les icônes iOS avec l\'outil Icônes.',
      'App Store icon 1024 px',
      'Missing: generate the iOS icons with the Icons tool.',
    ),
    'marketingIconAlpha' => t(
      'Icône App Store 1024 px',
      'Elle contient un canal de transparence : Apple la refuse. Régénère-la avec l\'outil Icônes (fond opaque).',
      'App Store icon 1024 px',
      'It has a transparency channel: Apple rejects it. Regenerate it with the Icons tool (opaque background).',
    ),
    'marketingIcon' => t(
      'Icône App Store 1024 px, opaque',
      '',
      'App Store icon 1024 px, opaque',
      '',
    ),
    _ => t(c.id, '', c.id, ''),
  };
}
