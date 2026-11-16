import 'android_project.dart';

/// Résultat de la préparation de la signature release.
enum SigningEditOutcome {
  /// Nouveau contenu proposé (à prévisualiser).
  changed,

  /// Déjà configuré : rien à faire.
  alreadyConfigured,

  /// Fichier trop différent du modèle Flutter : extrait à recopier.
  unrecognized,
}

typedef SigningEdit = ({SigningEditOutcome outcome, String? content});

const _ktsLoader = '''
// Ajouté par LaunchPilot : lit android/key.properties (jamais versionné).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
''';

const _groovyLoader = '''
// Ajouté par LaunchPilot : lit android/key.properties (jamais versionné).
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
''';

const _ktsConfig = '''
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

''';

const _groovyConfig = '''
    signingConfigs {
        release {
            keyAlias = keystoreProperties['keyAlias']
            keyPassword = keystoreProperties['keyPassword']
            storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword = keystoreProperties['storePassword']
        }
    }

''';

/// Imports nécessaires en tête d'un script Kotlin : dans Gradle, `java`
/// désigne l'extension Java et masque le paquet du même nom.
const _ktsImports = [
  'import java.io.FileInputStream',
  'import java.util.Properties',
];

/// Extrait à recopier à la main quand le fichier n'est pas reconnu.
String signingSnippet({required bool kts}) => kts
    ? '${_ktsImports.join('\n')}\n\n$_ktsLoader\nandroid {\n$_ktsConfig    buildTypes {\n        release {\n            signingConfig = signingConfigs.getByName("release")\n        }\n    }\n}\n'
    : '$_groovyLoader\nandroid {\n$_groovyConfig    buildTypes {\n        release {\n            signingConfig = signingConfigs.release\n        }\n    }\n}\n';

/// Configure la signature release à partir de key.properties, sur le modèle
/// de la documentation Flutter. Ne lit ni n'écrit aucun secret : les mots de
/// passe restent dans key.properties, rempli par l'utilisateur.
SigningEdit applyReleaseSigning(String content, {required bool kts}) {
  final info = parseAppGradle(content);
  if (info.signing == ReleaseSigning.releaseConfig &&
      info.hasReleaseSigningConfig) {
    return (outcome: SigningEditOutcome.alreadyConfigured, content: null);
  }
  if (content.contains('keystoreProperties') ||
      info.hasReleaseSigningConfig ||
      !RegExp(r'^android\s*\{', multiLine: true).hasMatch(content)) {
    return (outcome: SigningEditOutcome.unrecognized, content: null);
  }

  var out = content;
  // Signature du build release : debug → release.
  final debugRef = kts
      ? RegExp(
          r'''signingConfig\s*=\s*signingConfigs\.getByName\(\s*"debug"\s*\)''',
        )
      : RegExp(r'''signingConfig\s*(=\s*)?signingConfigs\.debug''');
  final release = kts
      ? 'signingConfig = signingConfigs.getByName("release")'
      : 'signingConfig = signingConfigs.release';
  if (debugRef.allMatches(out).length == 1) {
    out = out.replaceFirst(debugRef, release);
    // Les commentaires du modèle Flutter ne sont plus vrais.
    out = out.replaceAll(
      RegExp(
        r'[ \t]*// TODO: Add your own signing config for the release build\.\n',
      ),
      '',
    );
    out = out.replaceAll(
      RegExp(r'[ \t]*// Signing with the debug keys for now.*\n'),
      '',
    );
  } else if (info.signing == ReleaseSigning.missing) {
    final releaseBlock = RegExp(r'buildTypes\s*\{\s*release\s*\{')
        .firstMatch(out);
    if (releaseBlock == null) {
      return (outcome: SigningEditOutcome.unrecognized, content: null);
    }
    out = out.replaceRange(
      releaseBlock.end,
      releaseBlock.end,
      '\n            $release',
    );
  } else {
    return (outcome: SigningEditOutcome.unrecognized, content: null);
  }

  // Bloc signingConfigs juste avant buildTypes.
  final buildTypes = RegExp(
    r'^([ \t]*)buildTypes\s*\{',
    multiLine: true,
  ).firstMatch(out);
  if (buildTypes == null) {
    return (outcome: SigningEditOutcome.unrecognized, content: null);
  }
  out = out.replaceRange(
    buildTypes.start,
    buildTypes.start,
    kts ? _ktsConfig : _groovyConfig,
  );

  // Lecture de key.properties juste avant `android {`.
  final android = RegExp(r'^android\s*\{', multiLine: true).firstMatch(out)!;
  out = out.replaceRange(
    android.start,
    android.start,
    '${kts ? _ktsLoader : _groovyLoader}\n',
  );
  if (kts) {
    final missing = [
      for (final i in _ktsImports)
        if (!out.contains(
          RegExp('^${RegExp.escape(i)}\\s*\$', multiLine: true),
        ))
          i,
    ];
    if (missing.isNotEmpty) out = '${missing.join('\n')}\n\n$out';
  }
  return (outcome: SigningEditOutcome.changed, content: out);
}

/// Création du keystore, à lancer dans son propre terminal : keytool demande
/// les mots de passe lui-même, ils ne passent jamais par LaunchPilot.
String keytoolCommand({
  String alias = 'upload',
  String path = '~/upload-keystore.jks',
}) =>
    'keytool -genkey -v -keystore $path -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias $alias';

/// Modèle de android/key.properties, à remplir par l'utilisateur.
String keyPropertiesTemplate({
  String alias = 'upload',
  required String storeFile,
}) =>
    'storePassword=<mot de passe du keystore>\n'
    'keyPassword=<mot de passe de la clé>\n'
    'keyAlias=$alias\n'
    'storeFile=$storeFile\n';

/// Entrées `.gitignore` des secrets de signature Android.
List<String> signingGitignoreEntries(String androidDir) => [
  '$androidDir/key.properties',
  '*.jks',
  '*.keystore',
];
