import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:launchpilot/core/domain/audit_status.dart';
import 'package:launchpilot/features/android/data/android_reader.dart';
import 'package:launchpilot/features/android/domain/android_audit.dart';
import 'package:launchpilot/features/android/domain/android_project.dart';
import 'package:launchpilot/features/android/domain/deliverables.dart';
import 'package:launchpilot/features/android/domain/play_store.dart';
import 'package:launchpilot/features/android/domain/signing.dart';
import 'package:launchpilot/features/commands/domain/command_policy.dart';
import 'package:launchpilot/features/commands/domain/command_spec.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:path/path.dart' as p;

const fixtures = 'test/fixtures/projects';

String fixtureFile(String path) => File('$fixtures/$path').readAsStringSync();

Uint8List zipWith(Map<String, List<int>> entries) {
  final archive = Archive();
  for (final e in entries.entries) {
    archive.addFile(ArchiveFile(e.key, e.value.length, e.value));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

Uint8List png(int w, int h) {
  final image = img.Image(width: w, height: h, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(200, 30, 30, 255));
  return img.encodePng(image);
}

void main() {
  group('lecture Gradle et manifeste', () {
    test('modèle Flutter Kotlin : identifiant, SDK, signature de débogage', () {
      final g = parseAppGradle(
        fixtureFile('flutter_android/android/app/build.gradle.kts'),
      );
      expect(g.applicationId, 'com.example.carnet_velo');
      expect(g.namespace, 'com.example.carnet_velo');
      expect(g.targetSdk, '34');
      expect(g.minSdk, 'flutter.minSdkVersion');
      expect(g.versionCode, 'flutter.versionCode');
      expect(g.signing, ReleaseSigning.debugKey);
      expect(g.hasReleaseSigningConfig, isFalse);
    });

    test('Groovy configuré', () {
      final g = parseAppGradle('''
android {
    defaultConfig {
        applicationId "fr.atelier.meteo"
        minSdkVersion 23
        targetSdkVersion 36
        versionCode 12
        versionName "1.2.0"
    }
    signingConfigs { release { keyAlias keystoreProperties['keyAlias'] } }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
        }
    }
}''');
      expect(g.applicationId, 'fr.atelier.meteo');
      expect(g.minSdk, '23');
      expect(g.targetSdk, '36');
      expect(g.versionName, '1.2.0');
      expect(g.signing, ReleaseSigning.releaseConfig);
      expect(g.hasReleaseSigningConfig, isTrue);
      expect(g.minify, isTrue);
    });

    test('commentaires ignorés', () {
      final g = parseAppGradle(
        'android {\n  // applicationId = "com.faux"\n  defaultConfig { applicationId = "fr.vrai.app" }\n}',
      );
      expect(g.applicationId, 'fr.vrai.app');
    });

    test('manifeste : permissions, HTTP en clair, libellé', () {
      final m = parseManifest(
        fixtureFile('flutter_android/android/app/src/main/AndroidManifest.xml'),
      );
      expect(m.permissions.map((x) => x.short), [
        'ACCESS_FINE_LOCATION',
        'ACCESS_BACKGROUND_LOCATION',
        'READ_CONTACTS',
      ]);
      expect(m.cleartextTraffic, isTrue);
      expect(m.debuggable, isFalse);
      expect(m.label, 'carnet_velo');
    });

    test('versions des outils', () {
      expect(
        gradleWrapperVersion(
          fixtureFile(
            'flutter_android/android/gradle/wrapper/gradle-wrapper.properties',
          ),
        ),
        '8.12',
      );
      final v = pluginVersions(
        fixtureFile('flutter_android/android/settings.gradle.kts'),
      );
      expect(v.agp, '8.9.1');
      expect(v.kotlin, '2.1.0');
    });

    test('lecteur : projet complet, fichiers de signature jamais lus', () {
      final root = '$fixtures/flutter_android';
      final report = analyzeProjectSync(root);
      final a = const AndroidReader().read(root, report)!;
      expect(a.kts, isTrue);
      expect(a.gradlePath, 'android/app/build.gradle.kts');
      expect(a.mipmaps, {'hdpi', 'xhdpi'});
      expect(a.keyPropertiesExists, isFalse);
      final pub = const AndroidReader().pubspec(root, report);
      expect(pub.version, '2.1.0+15');
      expect(
        pub.dependencies,
        containsAll(['geolocator', 'firebase_messaging']),
      );
      // key.properties présent dans l'autre projet d'exemple : détecté, non lu.
      final meteo = '$fixtures/flutter_app';
      expect(
        const AndroidReader()
            .read(meteo, analyzeProjectSync(meteo))!
            .keyPropertiesExists,
        isTrue,
      );
    });
  });

  group('audit Android', () {
    final root = '$fixtures/flutter_android';
    final report = analyzeProjectSync(root);
    final project = const AndroidReader().read(root, report)!;

    test('défauts du modèle par défaut repérés', () {
      final checks = auditAndroid(
        project,
        dependencies: const {'geolocator', 'firebase_messaging'},
        pubVersion: '2.1.0+15',
        gitIgnored: const {},
      );
      AndroidCheck? c(String id) => checks.where((x) => x.id == id).firstOrNull;
      expect(c('exampleId')!.status, AuditStatus.failure);
      expect(c('targetSdkTooLow')!.values, ['34', '$playTargetSdk']);
      expect(c('debugSigning')!.status, AuditStatus.failure);
      expect(c('keyProperties')!.status, AuditStatus.warning);
      expect(c('cleartext')!.status, AuditStatus.warning);
      expect(c('label')!.status, AuditStatus.warning);
      expect(c('versionFromPubspec')!.status, AuditStatus.ok);
      expect(c('mipmaps')!.values, ['mdpi', 'xxhdpi', 'xxxhdpi']);
      // Permissions : restreinte, expliquée par un plugin, sans fonction.
      final perms = checks
          .where((x) => x.area == AndroidArea.permissions)
          .toList();
      expect(perms.firstWhere((x) => x.id == 'permRestricted').values, [
        'ACCESS_BACKGROUND_LOCATION',
      ]);
      expect(
        perms.firstWhere((x) => x.values.first == 'ACCESS_FINE_LOCATION').id,
        'permDangerous',
      );
      expect(
        perms.firstWhere((x) => x.values.first == 'READ_CONTACTS').id,
        'permUnexplained',
      );
      // firebase_messaging sans POST_NOTIFICATIONS : information.
      expect(perms.firstWhere((x) => x.id == 'pluginNoPermission').values, [
        'firebase_messaging',
        'notifications',
      ]);
    });

    test('projet prêt : aucun problème bloquant', () {
      const ready = AndroidProject(
        androidDir: 'android',
        gradlePath: 'android/app/build.gradle.kts',
        applicationId: 'fr.atelier.velo',
        targetSdk: '36',
        versionCode: 'flutter.versionCode',
        versionName: 'flutter.versionName',
        signing: ReleaseSigning.releaseConfig,
        hasReleaseSigningConfig: true,
        keyPropertiesExists: true,
        label: 'Carnet Vélo',
        mipmaps: {'mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'},
      );
      final checks = auditAndroid(
        ready,
        pubVersion: '1.0.0+1',
        gitIgnored: const {'android/key.properties'},
      );
      expect(
        checks.where(
          (c) =>
              c.status == AuditStatus.failure ||
              c.status == AuditStatus.warning,
        ),
        isEmpty,
        reason: '$checks',
      );
    });

    test('key.properties non ignoré par Git : échec', () {
      const a = AndroidProject(
        androidDir: 'android',
        gradlePath: 'x',
        keyPropertiesExists: true,
        keystoreFiles: ['android/upload.jks'],
      );
      final c = auditAndroid(
        a,
        gitIgnored: const {},
      ).firstWhere((x) => x.id == 'gitignore');
      expect(c.status, AuditStatus.failure);
      expect(c.values, ['android/key.properties', 'android/upload.jks']);
      expect(
        auditAndroid(a).where((x) => x.id == 'gitignore'),
        isEmpty,
        reason: 'hors Git : non vérifiable',
      );
    });

    test('valeur fournie par Flutter et publicité', () {
      final checks = auditAndroid(
        const AndroidProject(
          androidDir: 'android',
          gradlePath: 'x',
          targetSdk: 'flutter.targetSdkVersion',
        ),
        dependencies: const {'google_mobile_ads'},
      );
      expect(
        checks.firstWhere((c) => c.id == 'targetSdkFlutter').status,
        AuditStatus.info,
      );
      expect(checks.any((c) => c.id == 'adId'), isTrue);
      expect(permissionLevel('INTERNET'), PermissionLevel.normal);
    });
  });

  group('signature release', () {
    test('modèle Kotlin : configuration ajoutée, une seule fois', () {
      final source = fixtureFile(
        'flutter_android/android/app/build.gradle.kts',
      );
      final edit = applyReleaseSigning(source, kts: true);
      expect(edit.outcome, SigningEditOutcome.changed);
      final out = edit.content!;
      expect(out, contains('rootProject.file("key.properties")'));
      // Lignes intactes : commentaire valide, indentation de 4 espaces.
      expect(out, contains('\n// Ajouté par LaunchPilot'));
      expect(
        out,
        contains('\n    signingConfigs {\n        create("release") {'),
      );
      expect(out, isNot(contains('\n/ Ajouté')));
      expect(
        out,
        startsWith(
          'import java.io.FileInputStream\nimport java.util.Properties\n\nplugins {',
        ),
      );
      expect(out, isNot(contains('java.util.Properties()')));
      expect(out, contains('create("release")'));
      expect(
        out,
        contains('signingConfig = signingConfigs.getByName("release")'),
      );
      expect(out, isNot(contains('getByName("debug")')));
      expect(out, isNot(contains('Signing with the debug keys')));
      expect(
        out.indexOf('keystoreProperties = '),
        lessThan(out.indexOf('android {')),
      );
      expect(
        out.indexOf('signingConfigs {'),
        lessThan(out.indexOf('buildTypes {')),
      );
      // Aucun secret écrit.
      expect(out, isNot(contains('Password=')));
      final again = parseAppGradle(out);
      expect(again.signing, ReleaseSigning.releaseConfig);
      expect(again.hasReleaseSigningConfig, isTrue);
      expect(
        applyReleaseSigning(out, kts: true).outcome,
        SigningEditOutcome.alreadyConfigured,
      );
    });

    test('modèle Groovy', () {
      const groovy = '''
android {
    defaultConfig { applicationId "fr.a.b" }
    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}
''';
      final out = applyReleaseSigning(groovy, kts: false).content!;
      expect(out, contains("rootProject.file('key.properties')"));
      expect(out, contains('signingConfig = signingConfigs.release'));
      expect(parseAppGradle(out).signing, ReleaseSigning.releaseConfig);
    });

    test('fichier non reconnu : extrait à recopier', () {
      expect(
        applyReleaseSigning('// vide', kts: true).outcome,
        SigningEditOutcome.unrecognized,
      );
      expect(signingSnippet(kts: true), contains('create("release")'));
    });

    test('keytool et key.properties : aucun mot de passe réel', () {
      expect(
        keytoolCommand(),
        startsWith('keytool -genkey -v -keystore ~/upload-keystore.jks'),
      );
      expect(keytoolCommand(), isNot(contains('-storepass')));
      expect(
        keyPropertiesTemplate(storeFile: '/home/a/upload.jks'),
        contains('<mot de passe du keystore>'),
      );
      expect(signingGitignoreEntries('android'), [
        'android/key.properties',
        '*.jks',
        '*.keystore',
      ]);
    });
  });

  group('livrables', () {
    test('AAB signé avec la clé de débogage, avec une clé, ou non signé', () {
      final debug = zipWith({
        'base/manifest/AndroidManifest.xml': [1, 2, 3],
        'META-INF/ANDROIDD.RSA': [
          ...utf8.encode('xx CN=Android Debug, O=Android'),
          0,
        ],
      });
      expect(
        detectSigning(debug, DeliverableKind.aab),
        DeliverableSigning.debug,
      );
      final signed = zipWith({
        'META-INF/UPLOAD.RSA': utf8.encode('CN=Atelier Velo'),
      });
      expect(
        detectSigning(signed, DeliverableKind.aab),
        DeliverableSigning.signed,
      );
      expect(
        detectSigning(
          zipWith({
            'a.txt': [1],
          }),
          DeliverableKind.aab,
        ),
        DeliverableSigning.unsigned,
      );
    });

    test('APK signé v2 : bloc de signature', () {
      final apk = Uint8List.fromList([
        ...zipWith({
          'classes.dex': [1, 2],
        }),
        ...ascii.encode('APK Sig Block 42'),
        ...ascii.encode('CN=Android Debug'),
      ]);
      expect(detectSigning(apk, DeliverableKind.apk), DeliverableSigning.debug);
    });

    test(
      'inspection : taille, empreinte SHA-256, fichiers absents ignorés',
      () {
        final dir = Directory.systemTemp.createTempSync('lp_aab_');
        addTearDown(() => dir.deleteSync(recursive: true));
        final path = deliverableCandidates('').first;
        final file = File(p.join(dir.path, path))..createSync(recursive: true);
        final bytes = zipWith({'META-INF/A.RSA': utf8.encode('CN=Moi')});
        file.writeAsBytesSync(bytes);
        final list = inspectDeliverables((
          root: dir.path,
          paths: deliverableCandidates(''),
        ));
        expect(list, hasLength(1));
        expect(
          list.single.path,
          'build/app/outputs/bundle/release/app-release.aab',
        );
        expect(list.single.size, bytes.length);
        expect(list.single.sha256, hasLength(64));
        expect(list.single.signing, DeliverableSigning.signed);
        expect(deliverableCandidates('app').first, startsWith('app/build/'));
      },
    );

    test('tailles lisibles', () {
      expect(formatSize(1536), '1,5 Ko');
      expect(formatSize(3 * 1024 * 1024, locale: 'en'), '3.0 MB');
    });

    test('flutter doctor : sections Android et Java', () {
      const out = '''
[✓] Flutter (Channel stable, 3.47.2)
    • Flutter version 3.47.2
[!] Android toolchain - develop for Android devices (Android SDK version 36.0.0)
    • Android SDK at /home/a/Android/Sdk
    • Java version OpenJDK Runtime Environment (build 21.0.5)
    ✗ Android license status unknown.
[✓] Chrome - develop for the web
    • Chrome at google-chrome
''';
      final lines = androidDoctorLines(out);
      expect(lines.first.status, '!');
      expect(lines.map((l) => l.status), ['!', '•', '•', '✗']);
      expect(lines.any((l) => l.text.contains('Chrome')), isFalse);
      expect(
        doctorJavaVersion(out),
        'OpenJDK Runtime Environment (build 21.0.5)',
      );
    });
  });

  group('Play Store et Fastlane', () {
    test('limites de la fiche', () {
      final l = const PlayListing().copyWith(PlayField.title, 'x' * 31);
      expect(l.overLimit, [PlayField.title]);
      expect(l.missing, [
        PlayField.shortDescription,
        PlayField.fullDescription,
      ]);
      expect(PlayListing.fromJson(l.toJson())[PlayField.title], hasLength(31));
    });

    test('métadonnées supply', () {
      final files = supplyTextFiles({
        'fr-FR': const PlayListing({
          PlayField.title: 'Carnet Vélo',
          PlayField.shortDescription: 'Tes sorties',
          PlayField.fullDescription: 'Long',
          PlayField.changelog: 'Nouveautés',
        }),
        'en-US': const PlayListing(),
      }, versionCode: 15);
      expect(files['metadata/android/fr-FR/title.txt'], 'Carnet Vélo\n');
      expect(files['metadata/android/fr-FR/changelogs/15.txt'], 'Nouveautés\n');
      expect(files.keys.any((k) => k.contains('en-US')), isFalse);
    });

    test('Appfile et Fastfile sans secret, piste interne en brouillon', () {
      expect(
        appfile('fr.atelier.velo'),
        contains('package_name("fr.atelier.velo")'),
      );
      final ff = fastfile(
        aabPath: '../build/app/outputs/bundle/release/app-release.aab',
      );
      expect(ff, contains('track: "internal"'));
      expect(ff, contains('release_status: "draft"'));
      expect(ff, contains('json_key: options[:json_key]'));
      expect(ff, isNot(contains('json_key_data')));
    });

    test('visuel 1024 × 500 et icône 512 sans déformation', () {
      final graphic = img.decodePng(
        featureGraphic(png(1024, 1024), 0xFF3F4BD1),
      )!;
      expect((graphic.width, graphic.height), (1024, 500));
      final icon = img.decodePng(playIcon(png(1024, 600))!)!;
      expect((icon.width, icon.height), (512, 512));
      expect(
        icon.getPixel(256, 10).a,
        0,
        reason: 'bandes transparentes, pas d\'étirement',
      );
      expect(playIcon(png(200, 200)), isNull);
    });

    test('politique Fastlane : flux dédié et forme exacte', () {
      const policy = CommandPolicy();
      const root = '/home/a/velo';
      PolicyDecision eval(CommandSpec s) => policy.evaluate(s, root);
      final send = fastlaneCommand(
        '$root/android',
        'internal',
        '/home/a/cle.json',
      );
      expect(send.display, 'fastlane internal json_key:/home/a/cle.json');
      final d = eval(send);
      expect(d.risk, RiskLevel.sensitive);
      expect(d.issues, [PolicyIssue.storePublication]);
      expect(d.reinforced, isTrue);
      // Tapé dans le terminal : refusé.
      expect(
        eval(
          CommandSpec(
            executable: 'fastlane',
            arguments: send.arguments,
            workingDirectory: root,
          ),
        ).issues,
        [PolicyIssue.publication],
      );
      for (final args in [
        ['supply', 'json_key:/a.json'],
        ['internal', 'json_key:relatif.json'],
        ['internal', r'json_key:/a;rm -rf.json'],
        ['internal'],
        ['run', 'upload_to_play_store'],
      ]) {
        expect(
          eval(
            CommandSpec(
              executable: 'fastlane',
              arguments: args,
              workingDirectory: root,
              purpose: CommandPurpose.deployment,
            ),
          ).allowed,
          isFalse,
          reason: '$args',
        );
      }
      expect(
        eval(fastlaneCommand(root, 'check', '/home/a/cle.json')).risk,
        RiskLevel.local,
      );
      expect(
        eval(
          const CommandSpec(
            executable: 'fastlane',
            arguments: ['--version'],
            workingDirectory: root,
          ),
        ).risk,
        RiskLevel.readOnly,
      );
    });
  });
}
