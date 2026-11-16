import '../../settings/domain/app_settings.dart';
import '../domain/android_audit.dart';

/// Libellé et conseil d'un contrôle Android. Contenu pédagogique bilingue,
/// gardé hors des fichiers ARB (comme le lexique).
typedef CheckText = ({String label, String fix});

CheckText androidCheckText(AndroidCheck c, AppLanguage lang) {
  final fr = lang == AppLanguage.fr;
  CheckText t(String lf, String ff, String le, String fe) =>
      fr ? (label: lf, fix: ff) : (label: le, fix: fe);
  final v = c.values;
  String at(int i) => i < v.length ? v[i] : '?';

  return switch (c.id) {
    'noGradle' => t(
      'Fichier android/app/build.gradle',
      'Introuvable : le module Android n\'a pas été généré (flutter create --platforms=android .).',
      'android/app/build.gradle file',
      'Not found: the Android module was not generated (flutter create --platforms=android .).',
    ),
    'applicationId' => t(
      'Identifiant d\'application : ${at(0)}',
      'Ajoute applicationId dans defaultConfig : c\'est l\'identité définitive de l\'application sur Google Play.',
      'Application ID: ${at(0)}',
      'Add applicationId in defaultConfig: it is the app\'s permanent identity on Google Play.',
    ),
    'exampleId' => t(
      'Identifiant d\'application : ${at(0)}',
      'Google Play refuse les identifiants « com.example ». Choisis-en un à toi (ex. fr.tonnom.appli) avant le premier envoi : il ne pourra plus changer.',
      'Application ID: ${at(0)}',
      'Google Play rejects "com.example" IDs. Pick your own (e.g. com.yourname.app) before the first upload: it can never change.',
    ),
    'applicationIdInvalid' => t(
      'Identifiant d\'application : ${at(0)}',
      'Format attendu : au moins deux segments séparés par des points, lettres, chiffres et _.',
      'Application ID: ${at(0)}',
      'Expected format: at least two dot-separated segments, letters, digits and _.',
    ),
    'label' => t(
      'Nom affiché : ${at(0)}',
      'Il ressemble à un nom de paquet : remplace android:label dans AndroidManifest.xml par le vrai nom de l\'application.',
      'Displayed name: ${at(0)}',
      'It looks like a package name: replace android:label in AndroidManifest.xml with the real app name.',
    ),
    'versionFromPubspec' => t(
      'Version issue du pubspec (${at(0)})',
      '',
      'Version from pubspec (${at(0)})',
      '',
    ),
    'noBuildNumber' => t(
      'Numéro de build',
      'Ajoute « +N » à la version du pubspec (ex. 1.0.0+1) : Google Play exige un versionCode qui augmente à chaque envoi.',
      'Build number',
      'Add "+N" to the pubspec version (e.g. 1.0.0+1): Google Play requires a versionCode that increases with each upload.',
    ),
    'versionHardcoded' => t(
      'Version écrite en dur (${at(0)}, code ${at(1)})',
      'Utilise flutter.versionName et flutter.versionCode pour suivre automatiquement le pubspec (outil Version).',
      'Hard-coded version (${at(0)}, code ${at(1)})',
      'Use flutter.versionName and flutter.versionCode to follow the pubspec automatically (Version tool).',
    ),
    'targetSdk' => t('API cible ${at(0)}', '', 'Target API ${at(0)}', ''),
    'targetSdkTooLow' => t(
      'API cible ${at(0)}',
      'Google Play exige l\'API ${at(1)} (Android 16) pour les nouvelles applications et les mises à jour depuis le 31 août 2026 : passe targetSdk à ${at(1)} puis reteste l\'application.',
      'Target API ${at(0)}',
      'Google Play requires API ${at(1)} (Android 16) for new apps and updates since 31 August 2026: set targetSdk to ${at(1)} then retest the app.',
    ),
    'targetSdkFlutter' => t(
      'API cible fournie par Flutter (${at(0)})',
      'La valeur dépend de ta version de Flutter. Google Play exige l\'API ${at(1)} : la Play Console te préviendra à l\'envoi si elle est trop basse.',
      'Target API provided by Flutter (${at(0)})',
      'The value depends on your Flutter version. Google Play requires API ${at(1)}: the Play Console will warn you on upload if it is too low.',
    ),
    'minSdk' => t(
      'API minimale ${at(0)}',
      'Les téléphones plus anciens ne pourront pas installer l\'application.',
      'Minimum API ${at(0)}',
      'Older phones will not be able to install the app.',
    ),
    'debugSigning' => t(
      'Signature du build release',
      'Le build release est signé avec la clé de débogage : Google Play le refuse. Utilise « Configurer la signature release ».',
      'Release build signing',
      'The release build is signed with the debug key: Google Play rejects it. Use "Configure release signing".',
    ),
    'noSigning' => t(
      'Signature du build release',
      'Aucune signature configurée pour le build release.',
      'Release build signing',
      'No signing configured for the release build.',
    ),
    'releaseSigning' => t(
      'Signature release configurée',
      '',
      'Release signing configured',
      '',
    ),
    'keyProperties' => t(
      'android/key.properties',
      'Absent : crée le keystore puis ce fichier (modèle ci-dessous). LaunchPilot ne le lit jamais.',
      'android/key.properties',
      'Missing: create the keystore then this file (template below). LaunchPilot never reads it.',
    ),
    'gitignore' => t(
      'Secrets de signature ignorés par Git',
      'Non ignorés : ${v.join(', ')}. Ajoute-les au .gitignore avant tout commit.',
      'Signing secrets ignored by Git',
      'Not ignored: ${v.join(', ')}. Add them to .gitignore before any commit.',
    ),
    'debuggable' => t(
      'android:debuggable',
      'L\'application est marquée débogable : Google Play refuse ce build. Retire l\'attribut du manifeste.',
      'android:debuggable',
      'The app is marked debuggable: Google Play rejects this build. Remove the attribute from the manifest.',
    ),
    'cleartext' => t(
      'Trafic HTTP en clair',
      'usesCleartextTraffic="true" autorise des échanges non chiffrés : préfère HTTPS partout et retire l\'attribut.',
      'Cleartext HTTP traffic',
      'usesCleartextTraffic="true" allows unencrypted traffic: prefer HTTPS everywhere and remove the attribute.',
    ),
    'permRestricted' => t(
      'Permission restreinte : ${at(0)}',
      'Google Play exige une déclaration justifiée dans la Play Console (et parfois une vidéo). Si la fonction n\'est pas indispensable, retire cette permission.',
      'Restricted permission: ${at(0)}',
      'Google Play requires a justified declaration in the Play Console (sometimes a video). If the feature is not essential, remove this permission.',
    ),
    'permDangerous' => t(
      'Permission sensible : ${at(0)}',
      'Demandée à l\'utilisateur au moment de l\'usage : explique pourquoi dans l\'application et déclare la donnée dans la section « Sécurité des données ».',
      'Sensitive permission: ${at(0)}',
      'Asked to the user at use time: explain why in the app and declare the data in the "Data safety" section.',
    ),
    'permUnexplained' => t(
      'Permission sans fonction détectée : ${at(0)}',
      'Aucun plugin du projet ne semble l\'utiliser. Vérifie qu\'elle sert vraiment, sinon retire-la : une permission injustifiée peut faire refuser l\'application.',
      'Permission without a detected feature: ${at(0)}',
      'No plugin in the project seems to use it. Check it is really needed, otherwise remove it: an unjustified permission can get the app rejected.',
    ),
    'pluginNoPermission' => t(
      'Plugin ${at(0)} sans permission déclarée',
      'Certains plugins ajoutent leurs permissions automatiquement (fusion du manifeste), d\'autres demandent de les déclarer : vérifie sa documentation.',
      'Plugin ${at(0)} without a declared permission',
      'Some plugins add their permissions automatically (manifest merge), others ask you to declare them: check its documentation.',
    ),
    'adId' => t(
      'Identifiant publicitaire',
      'Le SDK publicitaire ajoute la permission AD_ID : déclare l\'identifiant publicitaire dans « Sécurité des données » et le questionnaire juridique.',
      'Advertising ID',
      'The ads SDK adds the AD_ID permission: declare the advertising ID in "Data safety" and the legal questionnaire.',
    ),
    'mipmaps' => t(
      'Icônes de l\'application',
      'Densités manquantes : ${v.join(', ')} (outil Icônes).',
      'App icons',
      'Missing densities: ${v.join(', ')} (Icons tool).',
    ),
    _ => t(c.id, '', c.id, ''),
  };
}
