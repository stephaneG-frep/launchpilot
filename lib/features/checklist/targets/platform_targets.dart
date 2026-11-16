import '../../../core/domain/action_level.dart';
import '../../detection/domain/detection_report.dart';
import '../../detection/domain/detectors.dart' show SeoCheck;
import '../../settings/domain/app_settings.dart';
import '../../android/domain/android_audit.dart';
import '../../web/domain/web_build.dart';
import '../domain/checklist_step.dart';
import '../domain/launch_target.dart';
import 'common_target.dart';
import 'step_helpers.dart';

/// Base des cibles de plateforme : détection reprise du rapport, activation
/// seulement si l'utilisateur a retenu la cible.
abstract class PlatformLaunchTarget implements LaunchTarget {
  const PlatformLaunchTarget(this.platform);

  final PlatformTarget platform;

  @override
  String get id => platform.name;

  @override
  bool get alwaysActive => false;

  @override
  Future<TargetDetection?> detect(ProjectInfo project) async =>
      project.report.targetFor(platform);

  /// Dépendances qui n'existent que pour certains projets (le moteur ignore
  /// celles qui manquent).
  static const qualityGate = ['common.flutter.analyze', 'common.flutter.test'];
}

// ------------------------------------------------------------------ Android

class AndroidTarget extends PlatformLaunchTarget {
  const AndroidTarget() : super(PlatformTarget.android);

  @override
  String label(AppLanguage language) => 'Android';

  @override
  Future<List<ChecklistStep>> buildChecklist(ProjectInfo p) async {
    final pub = pubPackage(p);
    if (pub == null || !p.hasTech('flutter')) return const [];
    final permissions = [
      for (final perm in p.report.permissions)
        if (perm.target == PlatformTarget.android)
          perm.name.replaceFirst('android.permission.', ''),
    ];
    final signingFiles = p.report.findingsOf(FindingCategory.signing);
    final restricted = [
      for (final perm in permissions)
        if (permissionLevel(perm) == PermissionLevel.restricted) perm,
    ];

    return [
      ChecklistStep(
        id: 'android.audit',
        level: ActionLevel.analyze,
        kind: StepKind.manual,
        targetId: id,
        toolTab: 'android',
        dependsOn: const ['common.flutter.doctor'],
        title: p.t('Auditer le module Android', 'Audit the Android module'),
        objective: p.t(
          'Vérifier identifiant, version, API cible, signature et icônes.',
          'Check ID, version, target API, signing and icons.',
        ),
        explanation: p.t(
          'L\'outil Android vérifie l\'environnement (SDK, Java, licences), '
              'puis lit build.gradle et AndroidManifest.xml : identifiant '
              'd\'application (com.example est refusé), API cible (Google '
              'Play exige l\'API $playTargetSdk), signature release, trafic HTTP '
              'en clair, permissions et icônes. Les fichiers de signature ne '
              'sont jamais lus.',
          'The Android tool checks the environment (SDK, Java, licenses), '
              'then reads build.gradle and AndroidManifest.xml: application ID '
              '(com.example is rejected), target API (Google Play requires API '
              '$playTargetSdk), release signing, cleartext HTTP, permissions and '
              'icons. Signing files are never read.',
        ),
        whyRequired: p.t(
          'Chacun de ces points peut bloquer l\'envoi sur Google Play.',
          'Each of these points can block the Google Play upload.',
        ),
        affectedFiles: const [
          'android/app/build.gradle(.kts)',
          'android/app/src/main/AndroidManifest.xml',
        ],
        expectedResult: p.t(
          'Aucun problème bloquant dans l\'audit Android.',
          'No blocking problem in the Android audit.',
        ),
        verificationMethod: p.t(
          'Le résumé de l\'audit affiche 0 problème.',
          'The audit summary shows 0 problems.',
        ),
        glossary: const ['permission', 'keystore'],
      ),
      ChecklistStep(
        id: 'android.permissions',
        toolTab: 'android',
        level: ActionLevel.analyze,
        kind: StepKind.pedagogical,
        targetId: id,
        title: p.t('Comprendre les permissions', 'Understand permissions'),
        objective: p.t(
          'Savoir ce que l\'application demande à l\'utilisateur.',
          'Know what the app asks the user for.',
        ),
        explanation: p.t(
          permissions.isEmpty
              ? 'Aucune permission déclarée dans AndroidManifest.xml.'
              : 'Permissions déclarées : ${permissions.join(', ')}. Chacune doit '
                    'correspondre à une vraie fonction : le Play Store demande '
                    'de justifier les permissions sensibles (caméra, '
                    'localisation…).',
          permissions.isEmpty
              ? 'No permission declared in AndroidManifest.xml.'
              : 'Declared permissions: ${permissions.join(', ')}. Each must '
                    'match a real feature: the Play Store asks you to justify '
                    'sensitive ones (camera, location…).',
        ),
        summary: restricted.isEmpty
            ? null
            : p.t(
                'Permissions restreintes : ${restricted.join(', ')}.',
                'Restricted permissions: ${restricted.join(', ')}.',
              ),
        whyRequired: p.t(
          'Une permission injustifiée peut faire refuser l\'application.',
          'An unjustified permission can get the app rejected.',
        ),
        affectedFiles: const ['android/app/src/main/AndroidManifest.xml'],
        expectedResult: p.t(
          'Tu sais pourquoi chaque permission est là.',
          'You know why each permission is there.',
        ),
        verificationMethod: p.t(
          'Pour chaque permission, cite la fonction qui l\'utilise.',
          'For each permission, name the feature using it.',
        ),
        glossary: const ['permission'],
      ),
      ChecklistStep(
        id: 'android.keystore',
        toolTab: 'android',
        level: ActionLevel.prepare,
        kind: StepKind.manual,
        targetId: id,
        dependsOn: [if (p.report.sensitiveFiles.isNotEmpty) 'common.secrets'],
        title: p.t('Préparer la clé de signature', 'Prepare the signing key'),
        objective: p.t(
          'Disposer d\'un keystore conservé en lieu sûr.',
          'Have a keystore kept somewhere safe.',
        ),
        summary: p.t(
          signingFiles.isEmpty
              ? 'Aucun fichier de signature détecté.'
              : 'Fichiers de signature détectés (non lus).',
          signingFiles.isEmpty
              ? 'No signing file detected.'
              : 'Signing files detected (not read).',
        ),
        explanation: p.t(
          'Le keystore prouve que chaque mise à jour vient bien de toi. On le '
              'crée une seule fois avec « keytool » (fourni avec Java), puis '
              'on le référence dans android/key.properties. LaunchPilot ne lit '
              'jamais ces fichiers et ne crée pas de clé à ta place. Garde une '
              'copie de sauvegarde hors du projet.',
          'The keystore proves every update really comes from you. You create '
              'it once with "keytool" (shipped with Java), then reference it in '
              'android/key.properties. LaunchPilot never reads these files and '
              'does not create a key for you. Keep a backup copy outside the '
              'project.',
        ),
        whyRequired: p.t(
          'Toute version Android publiée doit être signée.',
          'Every published Android release must be signed.',
        ),
        affectedFiles: const ['android/key.properties'],
        expectedResult: p.t(
          'Keystore créé, sauvegardé, et ignoré par Git.',
          'Keystore created, backed up, and ignored by Git.',
        ),
        risks: [
          p.t(
            'Keystore perdu : mises à jour bloquées.',
            'Lost keystore: updates blocked.',
          ),
          p.t(
            'Keystore publié : clé à révoquer.',
            'Published keystore: key to revoke.',
          ),
        ],
        verificationMethod: p.t(
          'Relance l\'analyse : « Signature » affiche key.properties '
              '(présent, non lu).',
          'Analyze again: "Signing" shows key.properties (present, not read).',
        ),
        glossary: const ['keystore'],
      ),
      ChecklistStep(
        id: 'android.signing',
        toolTab: 'android',
        level: ActionLevel.prepare,
        kind: StepKind.manual,
        targetId: id,
        dependsOn: const ['android.keystore'],
        title: p.t(
          'Configurer la signature release',
          'Configure release signing',
        ),
        objective: p.t(
          'Faire signer le build release avec ton keystore.',
          'Have the release build signed with your keystore.',
        ),
        explanation: p.t(
          'android/app/build.gradle doit déclarer un bloc signingConfigs '
              'release qui lit key.properties. Sans lui, Flutter signe avec la '
              'clé de débogage, refusée par le Play Store.',
          'android/app/build.gradle must declare a release signingConfigs '
              'block reading key.properties. Without it, Flutter signs with the '
              'debug key, which the Play Store rejects.',
        ),
        whyRequired: p.t(
          'Un AAB signé en debug est refusé.',
          'A debug-signed AAB is rejected.',
        ),
        affectedFiles: const ['android/app/build.gradle'],
        expectedResult: p.t(
          'Le bloc signingConfigs release existe.',
          'The release signingConfigs block exists.',
        ),
        verificationMethod: p.t(
          'Relance l\'analyse : « Signature » mentionne signingConfigs.',
          'Analyze again: "Signing" mentions signingConfigs.',
        ),
        glossary: const ['keystore', 'releaseMode'],
      ),
      ChecklistStep(
        id: 'android.appbundle',
        level: ActionLevel.build,
        kind: StepKind.command,
        targetId: id,
        dependsOn: const [
          ...PlatformLaunchTarget.qualityGate,
          'android.signing',
        ],
        title: p.t('Construire l\'App Bundle', 'Build the App Bundle'),
        objective: p.t(
          'Produire le fichier .aab attendu par le Play Store.',
          'Produce the .aab file expected by the Play Store.',
        ),
        explanation: p.t(
          'L\'App Bundle contient toutes les variantes de l\'application ; '
              'Google génère ensuite l\'APK adapté à chaque téléphone.',
          'The App Bundle contains every variant of the app; Google then '
              'generates the right APK for each phone.',
        ),
        whyRequired: p.t(
          'Le Play Store n\'accepte que ce format.',
          'The Play Store only accepts this format.',
        ),
        affectedFiles: const ['build/app/outputs/bundle/release/'],
        commands: [
          command(p, 'flutter', const [
            'build',
            'appbundle',
            '--release',
          ], pkg: pub),
        ],
        expectedResult: 'build/app/outputs/bundle/release/app-release.aab',
        risks: [
          p.t(
            'Signature de débogage si la configuration manque.',
            'Debug signing if configuration is missing.',
          ),
        ],
        verificationMethod: p.t(
          'Le fichier .aab existe dans le dossier indiqué.',
          'The .aab file exists in the folder above.',
        ),
        rollbackMethod: p.t(
          'Aucun fichier source modifié : ignore simplement le livrable.',
          'No source file changed: just ignore the deliverable.',
        ),
        glossary: const ['aab', 'releaseMode', 'build'],
      ),
      ChecklistStep(
        id: 'android.deliverables',
        level: ActionLevel.build,
        kind: StepKind.manual,
        targetId: id,
        toolTab: 'android',
        dependsOn: const ['android.appbundle'],
        title: p.t('Contrôler les livrables', 'Check the deliverables'),
        objective: p.t(
          'S\'assurer que le fichier produit est le bon et bien signé.',
          'Make sure the produced file is the right one and properly signed.',
        ),
        explanation: p.t(
          'LaunchPilot affiche le chemin, la taille et l\'empreinte SHA-256 '
              'de chaque App Bundle ou APK, et repère une signature avec la '
              'clé de débogage, que Google Play refuse.',
          'LaunchPilot shows the path, size and SHA-256 fingerprint of each '
              'App Bundle or APK, and spots signing with the debug key, which '
              'Google Play rejects.',
        ),
        whyRequired: p.t(
          'Envoyer un mauvais fichier consomme un numéro de build.',
          'Uploading the wrong file uses up a build number.',
        ),
        expectedResult: p.t(
          'L\'App Bundle est signé avec ta clé.',
          'The App Bundle is signed with your key.',
        ),
        verificationMethod: p.t(
          'La carte du livrable indique « Signé avec ta clé ».',
          'The deliverable card says "Signed with your key".',
        ),
        glossary: const ['aab', 'sha256'],
      ),
      ChecklistStep(
        id: 'android.listing',
        level: ActionLevel.prepare,
        kind: StepKind.manual,
        targetId: id,
        toolTab: 'play',
        dependsOn: const ['common.texts'],
        title: p.t(
          'Préparer la fiche Play Store',
          'Prepare the Play Store listing',
        ),
        objective: p.t(
          'Réunir textes, icône 512 px, visuel 1024 × 500 et captures.',
          'Gather texts, 512 px icon, 1024 × 500 graphic and screenshots.',
        ),
        explanation: p.t(
          'La fiche reprend les textes de store et le changelog de la '
              'session, avec les limites de Google Play (nom 30, description '
              'courte 80, complète 4000, notes de version 500 caractères).',
          'The listing reuses the session\'s store texts and changelog, with '
              'Google Play limits (name 30, short description 80, full 4000, '
              'release notes 500 characters).',
        ),
        whyRequired: p.t(
          'Une fiche incomplète empêche la publication.',
          'An incomplete listing prevents publishing.',
        ),
        expectedResult: p.t(
          'Textes dans les limites, visuels prêts.',
          'Texts within limits, graphics ready.',
        ),
        verificationMethod: p.t(
          'Aucun compteur en rouge, au moins 2 captures.',
          'No red counter, at least 2 screenshots.',
        ),
        glossary: const ['storeListing'],
      ),
      ChecklistStep(
        id: 'android.fastlane',
        level: ActionLevel.prepare,
        kind: StepKind.manual,
        targetId: id,
        toolTab: 'play',
        dependsOn: const ['android.listing'],
        title: p.t('Préparer Fastlane', 'Prepare Fastlane'),
        objective: p.t(
          'Automatiser les envois suivants vers Google Play.',
          'Automate the next uploads to Google Play.',
        ),
        explanation: p.t(
          'LaunchPilot écrit android/fastlane (Appfile, Fastfile, métadonnées '
              '« supply »), après aperçu. La clé du compte de service n\'y est '
              'jamais écrite : son chemin est donné au moment de l\'envoi.',
          'LaunchPilot writes android/fastlane (Appfile, Fastfile, "supply" '
              'metadata), after a preview. The service account key is never '
              'written there: its path is given at upload time.',
        ),
        whyRequired: p.t(
          'Recommandé : chaque envoi devient reproductible.',
          'Recommended: each upload becomes reproducible.',
        ),
        affectedFiles: const ['android/fastlane/'],
        expectedResult: p.t(
          'Le dossier android/fastlane existe.',
          'The android/fastlane folder exists.',
        ),
        verificationMethod: p.t(
          'Relis le Fastfile dans l\'aperçu avant de confirmer.',
          'Review the Fastfile in the preview before confirming.',
        ),
        glossary: const ['fastlane'],
      ),
      ChecklistStep(
        id: 'android.play',
        level: ActionLevel.publish,
        kind: StepKind.manual,
        targetId: id,
        toolTab: 'play',
        dependsOn: const ['android.deliverables', 'android.fastlane'],
        title: p.t(
          'Publier sur la piste de test interne',
          'Publish to the internal track',
        ),
        objective: p.t(
          'Mettre la version entre les mains de testeurs.',
          'Put the release in testers\' hands.',
        ),
        explanation: p.t(
          'Le tout premier App Bundle s\'envoie à la main dans la Play '
              'Console (création de l\'application). Ensuite, l\'outil Play '
              'Store envoie la version en brouillon sur la piste interne, '
              'après un récapitulatif et une confirmation renforcée ; tu la '
              'déploies toi-même auprès des testeurs.',
          'The very first App Bundle is uploaded by hand in the Play Console '
              '(app creation). After that, the Play Store tool uploads the '
              'release as a draft to the internal track, after a summary and a '
              'reinforced confirmation; you roll it out to testers yourself.',
        ),
        whyRequired: p.t(
          'Tester sur de vrais appareils avant le grand public.',
          'Test on real devices before the general public.',
        ),
        expectedResult: p.t(
          'La version apparaît sur la piste de test interne.',
          'The release shows on the internal testing track.',
        ),
        risks: [
          p.t(
            'Un envoi consomme définitivement le numéro de build.',
            'An upload uses up the build number for good.',
          ),
        ],
        verificationMethod: p.t(
          'Ouvre la Play Console et vérifie la piste.',
          'Open the Play Console and check the track.',
        ),
        requiresConfirmation: true,
        isReversible: false,
        glossary: const ['internalTrack', 'buildNumber', 'fastlane'],
      ),
    ];
  }
}

// ---------------------------------------------------------------------- iOS

class IosTarget extends PlatformLaunchTarget {
  const IosTarget() : super(PlatformTarget.ios);

  @override
  String label(AppLanguage language) => 'iOS';

  @override
  Future<List<ChecklistStep>> buildChecklist(ProjectInfo p) async {
    final usages = [
      for (final perm in p.report.permissions)
        if (perm.target == PlatformTarget.ios) perm.name,
    ];
    return [
      ChecklistStep(
        id: 'ios.linux',
        level: ActionLevel.analyze,
        kind: StepKind.pedagogical,
        targetId: id,
        title: p.t(
          'iOS depuis Linux : le principe',
          'iOS from Linux: how it works',
        ),
        objective: p.t(
          'Comprendre pourquoi le build iOS passe par une CI.',
          'Understand why the iOS build goes through CI.',
        ),
        explanation: p.t(
          'Construire et signer une application iOS exige un Mac avec Xcode. '
              'Sous Linux, on prépare tout (textes, captures, confidentialité) '
              'et une CI macOS (Codemagic ou GitHub Actions) se charge du build '
              'et de la signature. LaunchPilot ne simule jamais un faux build.',
          'Building and signing an iOS app requires a Mac with Xcode. On '
              'Linux, you prepare everything (texts, screenshots, privacy) and a '
              'macOS CI (Codemagic or GitHub Actions) builds and signs. '
              'LaunchPilot never fakes a build.',
        ),
        whyRequired: p.t(
          'Pour choisir le bon chemin dès le départ.',
          'To pick the right path from the start.',
        ),
        expectedResult: p.t(
          'Tu sais qu\'un service CI macOS sera nécessaire.',
          'You know a macOS CI service will be needed.',
        ),
        verificationMethod: p.t(
          'Tu peux expliquer qui construira l\'application iOS.',
          'You can explain who will build the iOS app.',
        ),
        glossary: const ['ci', 'provisioning'],
      ),
      ChecklistStep(
        id: 'ios.audit',
        level: ActionLevel.analyze,
        kind: StepKind.manual,
        targetId: id,
        toolTab: 'ios',
        dependsOn: const ['ios.linux'],
        title: p.t('Auditer le module iOS', 'Audit the iOS module'),
        objective: p.t(
          'Vérifier identifiant, textes d\'accès, confidentialité et icône.',
          'Check ID, access texts, privacy and icon.',
        ),
        explanation: p.t(
          'L\'outil iOS lit Info.plist, project.pbxproj et l\'icône App Store, '
              'sans Xcode : identifiant (com.example est refusé), textes '
              'd\'accès exigés par les plugins, manifeste de confidentialité, '
              'déclaration de chiffrement, équipe Apple et icône sans '
              'transparence.',
          'The iOS tool reads Info.plist, project.pbxproj and the App Store '
              'icon, without Xcode: ID (com.example is rejected), access texts '
              'required by plugins, privacy manifest, encryption declaration, '
              'Apple team and icon without transparency.',
        ),
        whyRequired: p.t(
          'Chacun de ces points peut faire échouer le build ou refuser '
              'l\'application.',
          'Each of these points can break the build or get the app rejected.',
        ),
        affectedFiles: const [
          'ios/Runner/Info.plist',
          'ios/Runner.xcodeproj/project.pbxproj',
        ],
        expectedResult: p.t(
          'Aucun problème bloquant dans l\'audit iOS.',
          'No blocking problem in the iOS audit.',
        ),
        verificationMethod: p.t(
          'Le résumé de l\'audit affiche 0 problème.',
          'The audit summary shows 0 problems.',
        ),
        glossary: const ['provisioning'],
      ),
      ChecklistStep(
        id: 'ios.usage',
        level: ActionLevel.prepare,
        kind: StepKind.manual,
        targetId: id,
        toolTab: 'ios',
        dependsOn: const ['ios.audit'],
        title: p.t('Justifier les accès sensibles', 'Justify sensitive access'),
        objective: p.t(
          'Vérifier les textes affichés lors des demandes d\'accès.',
          'Check the texts shown when access is requested.',
        ),
        explanation: p.t(
          usages.isEmpty
              ? 'Aucune clé NS…UsageDescription trouvée dans Info.plist.'
              : 'Clés trouvées : ${usages.join(', ')}. Apple refuse une '
                    'application dont le texte n\'explique pas clairement à '
                    'quoi sert l\'accès.',
          usages.isEmpty
              ? 'No NS…UsageDescription key found in Info.plist.'
              : 'Keys found: ${usages.join(', ')}. Apple rejects an app whose '
                    'text does not clearly explain what the access is for.',
        ),
        whyRequired: p.t(
          'Motif de refus fréquent sur l\'App Store.',
          'A frequent App Store rejection reason.',
        ),
        affectedFiles: const ['ios/Runner/Info.plist'],
        expectedResult: p.t(
          'Chaque texte explique concrètement l\'usage.',
          'Each text concretely explains the use.',
        ),
        verificationMethod: p.t(
          'Relis chaque texte à voix haute : est-il compréhensible ?',
          'Read each text aloud: is it understandable?',
        ),
        glossary: const ['permission'],
      ),
      ChecklistStep(
        id: 'ios.privacy',
        level: ActionLevel.prepare,
        kind: StepKind.manual,
        targetId: id,
        toolTab: 'ios',
        dependsOn: const ['ios.audit', 'common.legal'],
        title: p.t(
          'Préparer le manifeste de confidentialité',
          'Prepare the privacy manifest',
        ),
        objective: p.t(
          'Déclarer à Apple les données collectées.',
          'Declare collected data to Apple.',
        ),
        explanation: p.t(
          'PrivacyInfo.xcprivacy est préparé à partir du questionnaire '
              'juridique puis ajouté à la cible Runner du projet Xcode, avec '
              'aperçu. C\'est un point de départ à relire.',
          'PrivacyInfo.xcprivacy is prepared from the legal questionnaire '
              'then added to the Runner target of the Xcode project, with a '
              'preview. It is a starting point to review.',
        ),
        whyRequired: p.t(
          'Apple attend une déclaration cohérente avec la fiche et la '
              'politique de confidentialité.',
          'Apple expects a declaration consistent with the listing and the '
              'privacy policy.',
        ),
        affectedFiles: const ['ios/Runner/PrivacyInfo.xcprivacy'],
        expectedResult: p.t(
          'Le manifeste est présent et référencé par le projet.',
          'The manifest is present and referenced by the project.',
        ),
        verificationMethod: p.t(
          'L\'audit iOS indique « Manifeste de confidentialité présent ».',
          'The iOS audit says "Privacy manifest present".',
        ),
        glossary: const ['privacyManifest'],
      ),
      ChecklistStep(
        id: 'ios.apple',
        level: ActionLevel.prepare,
        kind: StepKind.pedagogical,
        targetId: id,
        toolTab: 'ios',
        dependsOn: const ['ios.audit'],
        title: p.t('Préparer le compte Apple', 'Prepare the Apple account'),
        objective: p.t(
          'Réunir ce que la CI ne peut pas faire à ta place.',
          'Gather what the CI cannot do for you.',
        ),
        explanation: p.t(
          'Dans un navigateur : adhésion à l\'Apple Developer Program, '
              'identifiant de l\'application, fiche dans App Store Connect, '
              'clé API pour la CI. Certificats et profils de provisioning '
              'sont ensuite créés automatiquement par la CI.',
          'In a browser: Apple Developer Program membership, app identifier, '
              'App Store Connect record, API key for the CI. Certificates and '
              'provisioning profiles are then created automatically by the CI.',
        ),
        whyRequired: p.t(
          'Sans ces éléments, aucun build ne peut être signé ni envoyé.',
          'Without them, no build can be signed or uploaded.',
        ),
        expectedResult: p.t(
          'Team ID, fiche App Store Connect et clé API prêts.',
          'Team ID, App Store Connect record and API key ready.',
        ),
        verificationMethod: p.t(
          'L\'application apparaît dans App Store Connect.',
          'The app appears in App Store Connect.',
        ),
        glossary: const ['provisioning', 'appStoreConnect'],
      ),
      ChecklistStep(
        id: 'ios.listing',
        level: ActionLevel.prepare,
        kind: StepKind.manual,
        targetId: id,
        toolTab: 'appStore',
        dependsOn: const ['common.texts'],
        title: p.t(
          'Préparer la fiche App Store',
          'Prepare the App Store listing',
        ),
        objective: p.t(
          'Textes, adresses, captures et étiquettes de confidentialité.',
          'Texts, URLs, screenshots and privacy labels.',
        ),
        explanation: p.t(
          'La fiche reprend les textes de store et le changelog de la '
              'session, avec les limites d\'Apple. Les captures viennent de '
              'l\'outil Captures, faute de simulateur sous Linux. Les fichiers '
              'Fastlane deliver sont préparés pour un Mac ou la CI.',
          'The listing reuses the session\'s store texts and changelog, with '
              'Apple\'s limits. Screenshots come from the Screenshots tool, as '
              'there is no simulator on Linux. Fastlane deliver files are '
              'prepared for a Mac or the CI.',
        ),
        whyRequired: p.t(
          'Une fiche incomplète empêche la soumission.',
          'An incomplete listing prevents submission.',
        ),
        expectedResult: p.t(
          'Textes dans les limites, adresses en https, captures prêtes.',
          'Texts within limits, https URLs, screenshots ready.',
        ),
        verificationMethod: p.t(
          'Aucun compteur en rouge, au moins une capture iPhone.',
          'No red counter, at least one iPhone screenshot.',
        ),
        glossary: const ['storeListing', 'fastlane'],
      ),
      ChecklistStep(
        id: 'ios.ci',
        level: ActionLevel.build,
        kind: StepKind.manual,
        targetId: id,
        toolTab: 'ios',
        dependsOn: const [
          ...PlatformLaunchTarget.qualityGate,
          'ios.usage',
          'ios.apple',
        ],
        title: p.t('Construire via une CI macOS', 'Build through macOS CI'),
        objective: p.t(
          'Obtenir un build iOS signé.',
          'Get a signed iOS build.',
        ),
        explanation: p.t(
          'L\'outil iOS prépare le workflow GitHub Actions (runner macOS 26, '
              'Xcode 26) ou le fichier codemagic.yaml, avec aperçu. Tu crées '
              'les secrets dans la CI, tu valides et pousses ces fichiers, '
              'puis tu lances le build toi-même : LaunchPilot ne pousse '
              'jamais et n\'affiche jamais un build qu\'il n\'a pas vu.',
          'The iOS tool prepares the GitHub Actions workflow (macOS 26 '
              'runner, Xcode 26) or the codemagic.yaml file, with a preview. '
              'You create the secrets in the CI, commit and push these files, '
              'then launch the build yourself: LaunchPilot never pushes and '
              'never shows a build it has not seen.',
        ),
        whyRequired: p.t(
          'Pas de build iOS sous Linux.',
          'No iOS build on Linux.',
        ),
        expectedResult: p.t(
          'Un build réussi sur la CI.',
          'A successful CI build.',
        ),
        verificationMethod: p.t(
          'Le tableau de bord de la CI affiche un build vert.',
          'The CI dashboard shows a green build.',
        ),
        glossary: const ['ci', 'provisioning'],
      ),
      ChecklistStep(
        id: 'ios.testflight',
        level: ActionLevel.publish,
        kind: StepKind.manual,
        targetId: id,
        toolTab: 'ios',
        dependsOn: const ['ios.ci', 'ios.listing'],
        title: p.t('Distribuer sur TestFlight', 'Distribute on TestFlight'),
        objective: p.t(
          'Faire tester la version iOS.',
          'Get the iOS release tested.',
        ),
        explanation: p.t(
          'La CI envoie le build sur App Store Connect ; après son traitement '
              'par Apple, ajoute des testeurs TestFlight. Les testeurs '
              'externes nécessitent une vérification d\'Apple.',
          'The CI uploads the build to App Store Connect; once Apple has '
              'processed it, add TestFlight testers. External testers require '
              'an Apple review.',
        ),
        whyRequired: p.t(
          'Tester avant la mise en vente.',
          'Test before release.',
        ),
        expectedResult: p.t(
          'Les testeurs reçoivent l\'invitation.',
          'Testers receive the invitation.',
        ),
        verificationMethod: p.t(
          'App Store Connect affiche la version dans TestFlight.',
          'App Store Connect shows the build in TestFlight.',
        ),
        requiresConfirmation: true,
        isReversible: false,
        glossary: const ['testflight', 'buildNumber'],
      ),
    ];
  }
}

// ---------------------------------------------------------------------- Web

class WebTarget extends PlatformLaunchTarget {
  const WebTarget() : super(PlatformTarget.web);

  @override
  String label(AppLanguage language) => 'Web';

  @override
  Future<List<ChecklistStep>> buildChecklist(ProjectInfo p) async {
    final seoFound = {
      for (final f in p.report.findingsOf(FindingCategory.seo)) f.detail,
    };
    final missing = SeoCheck.all.where((c) => !seoFound.contains(c)).toList();
    final plan = planWebBuild(p.report);
    final node = nodePackage(p);
    final pwaRelevant =
        (plan?.isFlutter ?? false) ||
        p.report.findingsOf(FindingCategory.pwa).isNotEmpty;
    final static = plan?.gap != WebBuildGap.serverRendered;

    ChecklistStep tool(
      String id,
      ActionLevel level,
      String tab, {
      required String title,
      required String objective,
      required String explanation,
      required String why,
      required String expected,
      required String verification,
      List<String> dependsOn = const [],
      List<String> files = const [],
      List<String> risks = const [],
      String? rollback,
      List<String> glossary = const [],
      StepKind kind = StepKind.manual,
      bool confirmation = false,
    }) => ChecklistStep(
      id: id,
      level: level,
      kind: kind,
      targetId: this.id,
      toolTab: tab,
      dependsOn: dependsOn,
      title: title,
      objective: objective,
      explanation: explanation,
      whyRequired: why,
      affectedFiles: files,
      risks: risks,
      expectedResult: expected,
      verificationMethod: verification,
      rollbackMethod: rollback,
      requiresConfirmation: confirmation,
      glossary: glossary,
    );

    return [
      tool(
        'web.seo',
        ActionLevel.prepare,
        'seo',
        title: p.t('Référencement (SEO)', 'Search optimization (SEO)'),
        objective: p.t(
          'Décrire le site aux moteurs de recherche et aux réseaux sociaux.',
          'Describe the site to search engines and social networks.',
        ),
        explanation: p.t(
          '${missing.isEmpty ? 'Tous les éléments SEO repérés sont présents. ' : 'Éléments absents : ${missing.join(', ')}. '}'
              'L\'outil SEO prépare titre, description, adresse canonique, '
              'Open Graph, carte Twitter, données schema.org, robots.txt et '
              'sitemap.xml, avec aperçu avant écriture.',
          '${missing.isEmpty ? 'All SEO items checked are present. ' : 'Missing items: ${missing.join(', ')}. '}'
              'The SEO tool prepares title, description, canonical URL, Open '
              'Graph, Twitter card, schema.org data, robots.txt and '
              'sitemap.xml, with a preview before writing.',
        ),
        why: p.t(
          'Un site bien décrit est mieux référencé et mieux partagé.',
          'A well-described site ranks and shares better.',
        ),
        expected: p.t(
          'Balises et fichiers SEO en place.',
          'SEO tags and files in place.',
        ),
        verification: p.t(
          'L\'audit du site ne signale plus d\'élément SEO manquant.',
          'The site audit no longer reports missing SEO items.',
        ),
        rollback: p.t(
          'Le bouton « Restaurer » annule chaque fichier modifié.',
          'The "Restore" button undoes each modified file.',
        ),
        glossary: const ['seo', 'sitemap', 'openGraph'],
      ),
      if (pwaRelevant)
        tool(
          'web.pwa',
          ActionLevel.prepare,
          'pwa',
          title: p.t('Application installable (PWA)', 'Installable app (PWA)'),
          objective: p.t(
            'Compléter le manifeste et, si utile, le mode hors ligne.',
            'Complete the manifest and, if useful, offline mode.',
          ),
          explanation: p.t(
            'Le manifeste donne le nom, les couleurs et les icônes de '
                'l\'application installée. Le service worker, facultatif, '
                'permet d\'ouvrir le site sans réseau.',
            'The manifest gives the installed app\'s name, colours and '
                'icons. The service worker, optional, lets the site open '
                'without a network.',
          ),
          why: p.t(
            'Sans manifeste complet, le navigateur ne propose pas '
                'l\'installation.',
            'Without a complete manifest, the browser does not offer '
                'installation.',
          ),
          expected: p.t(
            'Manifeste complet, icônes 192 et 512 px présentes.',
            'Complete manifest, 192 and 512 px icons present.',
          ),
          verification: p.t(
            'La section PWA de l\'audit est au vert ; le mode hors ligne se '
                'teste dans l\'aperçu local.',
            'The PWA section of the audit is green; offline mode is tested '
                'in the local preview.',
          ),
          glossary: const ['pwa', 'serviceWorker'],
        ),
      if (plan != null && plan.hasCommand && static)
        ChecklistStep(
          id: 'web.build',
          level: ActionLevel.build,
          kind: StepKind.command,
          targetId: id,
          dependsOn: plan.isFlutter
              ? PlatformLaunchTarget.qualityGate
              : [
                  'common.node.install',
                  for (final script in const ['lint', 'test'])
                    if (node?.scripts.containsKey(script) ?? false)
                      'common.node.$script',
                ],
          title: p.t('Construire le site', 'Build the site'),
          objective: p.t(
            'Produire les fichiers à mettre en ligne.',
            'Produce the files to put online.',
          ),
          explanation: p.t(
            '« ${plan.commandLine} » produit le dossier ${plan.outputDir.isEmpty ? '.' : plan.outputDir}/ '
                '(${plan.framework}).',
            '"${plan.commandLine}" produces the ${plan.outputDir.isEmpty ? '.' : plan.outputDir}/ folder '
                '(${plan.framework}).',
          ),
          whyRequired: p.t(
            'L\'hébergeur sert ces fichiers optimisés.',
            'The host serves these optimized files.',
          ),
          commands: [
            CommandPreview(
              executable: plan.executable!,
              arguments: plan.arguments,
              workingDirectory: plan.workingDir.isEmpty
                  ? p.root
                  : '${p.root}/${plan.workingDir}',
            ),
          ],
          affectedFiles: ['${plan.outputDir}/'],
          expectedResult: p.t(
            'Le dossier ${plan.outputDir}/ contient index.html.',
            'The ${plan.outputDir}/ folder contains index.html.',
          ),
          verificationMethod: p.t(
            'L\'onglet Site web indique « Le dossier de sortie contient '
                'index.html ».',
            'The Website tab says "The output folder contains index.html".',
          ),
          glossary: const ['build', 'releaseMode'],
        ),
      if (plan != null &&
          (!plan.hasCommand || !static) &&
          plan.framework != 'HTML')
        tool(
          'web.build',
          ActionLevel.build,
          'web',
          title: p.t('Construire le site', 'Build the site'),
          objective: p.t(
            'Obtenir un dossier prêt à mettre en ligne.',
            'Get a folder ready to put online.',
          ),
          explanation: static
              ? p.t(
                  'Le projet ne déclare pas de script « build » : LaunchPilot '
                      'n\'invente pas de commande. Ajoute un script « build » '
                      'dans package.json, puis relance l\'analyse.',
                  'The project declares no "build" script: LaunchPilot does '
                      'not invent a command. Add a "build" script to '
                      'package.json, then analyze again.',
                )
              : p.t(
                  '${plan.framework} rend les pages côté serveur : il n\'y a '
                      'pas de dossier statique. Publie avec l\'intégration Git '
                      'de Vercel ou Netlify, ou configure un export statique.',
                  '${plan.framework} renders pages on the server: there is no '
                      'static folder. Publish with the Vercel or Netlify Git '
                      'integration, or configure a static export.',
                ),
          why: p.t(
            'L\'hébergeur a besoin des fichiers produits.',
            'The host needs the produced files.',
          ),
          expected: p.t(
            'Une commande de build connue.',
            'A known build command.',
          ),
          verification: p.t(
            'L\'onglet Site web affiche la commande.',
            'The Website tab shows the command.',
          ),
          glossary: const ['build'],
        ),
      tool(
        'web.audit',
        ActionLevel.build,
        'web',
        dependsOn: const ['web.build'],
        title: p.t('Auditer le site', 'Audit the site'),
        objective: p.t(
          'Repérer les défauts avant la mise en ligne.',
          'Spot issues before going live.',
        ),
        explanation: p.t(
          'L\'audit lit le site construit : SEO, affichage mobile, PWA, '
              'accessibilité, liens internes, contenu mixte, formulaires et '
              'page 404. L\'aperçu local permet de vérifier à la main, et '
              'Lighthouse (facultatif) mesure les performances.',
          'The audit reads the built site: SEO, mobile display, PWA, '
              'accessibility, internal links, mixed content, forms and 404 '
              'page. The local preview lets you check by hand, and Lighthouse '
              '(optional) measures performance.',
        ),
        why: p.t(
          'Un lien cassé ou une ressource en HTTP se voient tout de suite '
              'en ligne.',
          'A broken link or an HTTP resource shows up immediately online.',
        ),
        expected: p.t(
          'Aucun problème bloquant dans l\'audit.',
          'No blocking problem in the audit.',
        ),
        verification: p.t(
          'Le résumé de l\'audit affiche 0 problème.',
          'The audit summary shows 0 problems.',
        ),
        glossary: const ['lighthouse', 'https'],
      ),
      tool(
        'web.hosting',
        ActionLevel.prepare,
        'hosting',
        title: p.t('Préparer l\'hébergement', 'Prepare hosting'),
        objective: p.t(
          'Écrire la configuration de l\'hébergeur choisi.',
          'Write the chosen host\'s configuration.',
        ),
        explanation: p.t(
          'Firebase Hosting, Vercel, Netlify ou GitHub Pages : LaunchPilot '
              'prépare le fichier de configuration (dossier publié, '
              'redirections d\'une application monopage, cache), avec aperçu.',
          'Firebase Hosting, Vercel, Netlify or GitHub Pages: LaunchPilot '
              'prepares the configuration file (published folder, single-page '
              'app redirects, cache), with a preview.',
        ),
        why: p.t(
          'Sans configuration, les routes de l\'application peuvent renvoyer '
              'une erreur 404.',
          'Without configuration, the app\'s routes may return a 404 error.',
        ),
        expected: p.t(
          'Le fichier de configuration est dans le projet.',
          'The configuration file is in the project.',
        ),
        verification: p.t(
          'Relis le fichier dans l\'aperçu avant de confirmer.',
          'Review the file in the preview before confirming.',
        ),
        glossary: const ['spa'],
      ),
      tool(
        'web.deploy',
        ActionLevel.publish,
        'hosting',
        dependsOn: const ['web.build', 'web.hosting', 'web.audit'],
        confirmation: true,
        title: p.t('Mettre en ligne', 'Deploy'),
        objective: p.t(
          'Publier le site chez l\'hébergeur.',
          'Publish the site to the host.',
        ),
        explanation: p.t(
          'La mise en ligne passe par un récapitulatif à cocher puis par '
              'l\'aperçu de la commande avec confirmation renforcée. '
              'Commence par une prévisualisation si l\'hébergeur le permet. '
              'Pour GitHub Pages, c\'est ton push sur main qui publie : '
              'LaunchPilot ne pousse jamais.',
          'Deployment goes through a summary to tick, then the command '
              'preview with reinforced confirmation. Start with a preview if '
              'the host allows it. For GitHub Pages, your push to main '
              'publishes: LaunchPilot never pushes.',
        ),
        why: p.t('Rendre le site accessible.', 'Make the site reachable.'),
        expected: p.t(
          'Le site répond à son adresse.',
          'The site answers at its address.',
        ),
        risks: [
          p.t(
            'Le site public est remplacé : vérifie l\'aperçu d\'abord.',
            'The public site is replaced: check the preview first.',
          ),
        ],
        verification: p.t(
          'Ouvre l\'adresse dans une fenêtre de navigation privée.',
          'Open the address in a private browser window.',
        ),
        rollback: p.t(
          'Chaque hébergeur garde l\'historique des déploiements : la '
              'version précédente se republie depuis sa console.',
          'Each host keeps a deployment history: the previous version can '
              'be republished from its console.',
        ),
      ),
      tool(
        'web.dns',
        ActionLevel.publish,
        'hosting',
        kind: StepKind.pedagogical,
        dependsOn: const ['web.deploy'],
        title: p.t('Relier le domaine (DNS)', 'Connect the domain (DNS)'),
        objective: p.t(
          'Faire pointer ton domaine vers l\'hébergeur.',
          'Point your domain to the host.',
        ),
        explanation: p.t(
          'L\'outil Hébergement affiche les enregistrements recommandés. '
              'Tu les saisis toi-même chez le gestionnaire du domaine : '
              'LaunchPilot ne modifie jamais le DNS.',
          'The Hosting tool shows the recommended records. You enter them '
              'yourself at the domain provider: LaunchPilot never changes '
              'DNS.',
        ),
        why: p.t(
          'Un domaine à ton nom inspire confiance et reste stable si tu '
              'changes d\'hébergeur.',
          'A domain in your name inspires trust and stays stable if you '
              'change hosts.',
        ),
        risks: [
          p.t(
            'Une erreur DNS peut rendre le site (et parfois les e-mails) '
                'inaccessibles : ne supprime pas les enregistrements MX.',
            'A DNS mistake can make the site (and sometimes email) '
                'unreachable: do not delete MX records.',
          ),
        ],
        expected: p.t(
          'Le domaine se résout vers l\'hébergeur.',
          'The domain resolves to the host.',
        ),
        verification: p.t(
          '« Vérifier la résolution » affiche les adresses attendues.',
          '"Check resolution" shows the expected addresses.',
        ),
        glossary: const ['dns'],
      ),
      tool(
        'web.online',
        ActionLevel.publish,
        'hosting',
        dependsOn: const ['web.deploy'],
        title: p.t('Vérifier le site en ligne', 'Check the live site'),
        objective: p.t(
          'Confirmer HTTPS et le bon fonctionnement en conditions réelles.',
          'Confirm HTTPS and correct behaviour in real conditions.',
        ),
        explanation: p.t(
          'La vérification interroge l\'adresse publique : HTTPS, '
              'redirection depuis HTTP, HSTS. Lighthouse peut ensuite '
              'auditer le site en ligne. Teste aussi sur un vrai téléphone.',
          'The check queries the public address: HTTPS, redirect from '
              'HTTP, HSTS. Lighthouse can then audit the live site. Also '
              'test on a real phone.',
        ),
        why: p.t(
          'Un certificat manquant affiche une alerte qui fait fuir les '
              'visiteurs.',
          'A missing certificate shows a warning that drives visitors away.',
        ),
        expected: p.t(
          'HTTPS répond et HTTP y redirige.',
          'HTTPS answers and HTTP redirects to it.',
        ),
        verification: p.t(
          'Les contrôles de « Vérification en ligne » sont au vert.',
          'The "Online check" controls are green.',
        ),
        glossary: const ['https', 'lighthouse'],
      ),
    ];
  }
}

// ------------------------------------------------------- Linux et autres

class LinuxTarget extends PlatformLaunchTarget {
  const LinuxTarget() : super(PlatformTarget.linux);

  @override
  String label(AppLanguage language) => 'Linux';

  @override
  Future<List<ChecklistStep>> buildChecklist(ProjectInfo p) async {
    final pub = pubPackage(p);
    if (pub == null || !p.hasTech('flutter')) return const [];
    return [
      ChecklistStep(
        id: 'linux.build',
        level: ActionLevel.build,
        kind: StepKind.command,
        targetId: id,
        dependsOn: PlatformLaunchTarget.qualityGate,
        title: p.t('Construire pour Linux', 'Build for Linux'),
        objective: p.t(
          'Produire l\'exécutable Linux en mode release.',
          'Produce the Linux executable in release mode.',
        ),
        explanation: p.t(
          'Le paquet obtenu (dossier bundle) contient l\'exécutable et ses '
              'bibliothèques : il se copie tel quel.',
          'The resulting bundle folder contains the executable and its '
              'libraries: it can be copied as is.',
        ),
        whyRequired: p.t(
          'C\'est le livrable Linux.',
          'It is the Linux deliverable.',
        ),
        commands: [
          command(p, 'flutter', const [
            'build',
            'linux',
            '--release',
          ], pkg: pub),
        ],
        expectedResult: 'build/linux/x64/release/bundle/',
        verificationMethod: p.t(
          'Lance l\'exécutable du dossier bundle.',
          'Run the executable from the bundle folder.',
        ),
        glossary: const ['build', 'releaseMode'],
      ),
      ChecklistStep(
        id: 'linux.distribute',
        level: ActionLevel.publish,
        kind: StepKind.pedagogical,
        targetId: id,
        dependsOn: const ['linux.build'],
        title: p.t('Distribuer sous Linux', 'Distribute on Linux'),
        objective: p.t(
          'Choisir comment partager l\'application.',
          'Choose how to share the app.',
        ),
        explanation: p.t(
          'Une archive du dossier bundle suffit pour commencer. Snap et '
              'Flathub pourront s\'ajouter plus tard comme nouvelles cibles, '
              'sans modifier le moteur de checklist.',
          'An archive of the bundle folder is enough to start. Snap and '
              'Flathub can be added later as new targets, without changing the '
              'checklist engine.',
        ),
        whyRequired: p.t('Atteindre tes utilisateurs.', 'Reach your users.'),
        expectedResult: p.t(
          'Un mode de distribution choisi.',
          'A chosen distribution method.',
        ),
        verificationMethod: p.t(
          'Un proche peut installer et lancer l\'application.',
          'Someone else can install and run the app.',
        ),
      ),
    ];
  }
}

/// Windows et macOS : impossible à construire depuis Linux.
class ForeignDesktopTarget extends PlatformLaunchTarget {
  const ForeignDesktopTarget(super.platform);

  @override
  String label(AppLanguage language) =>
      platform == PlatformTarget.windows ? 'Windows' : 'macOS';

  @override
  Future<List<ChecklistStep>> buildChecklist(ProjectInfo p) async {
    final name = label(p.language);
    return [
      ChecklistStep(
        id: '$id.build',
        level: ActionLevel.build,
        kind: StepKind.pedagogical,
        targetId: id,
        title: p.t('Construire pour $name', 'Build for $name'),
        objective: p.t(
          'Comprendre comment obtenir un build $name.',
          'Understand how to get a $name build.',
        ),
        explanation: p.t(
          'Flutter ne construit pour $name que depuis $name. Utilise une '
              'machine $name ou une CI (GitHub Actions propose des runners '
              '$name). La prise en charge guidée viendra plus tard.',
          'Flutter only builds for $name from $name. Use a $name machine or a '
              'CI (GitHub Actions offers $name runners). Guided support will '
              'come later.',
        ),
        whyRequired: p.t(
          'Éviter de chercher un build impossible ici.',
          'Avoid looking for a build that is impossible here.',
        ),
        expectedResult: p.t(
          'Tu sais où le build $name sera fait.',
          'You know where the $name build will be done.',
        ),
        verificationMethod: p.t(
          'Une machine ou une CI $name est identifiée.',
          'A $name machine or CI is identified.',
        ),
        glossary: const ['ci'],
      ),
    ];
  }
}

/// Cibles fournies avec LaunchPilot, dans l'ordre d'affichage.
const builtInTargets = <LaunchTarget>[
  CommonTarget(),
  AndroidTarget(),
  IosTarget(),
  WebTarget(),
  LinuxTarget(),
  ForeignDesktopTarget(PlatformTarget.windows),
  ForeignDesktopTarget(PlatformTarget.macos),
];
