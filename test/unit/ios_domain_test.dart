import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/domain/audit_status.dart';
import 'package:launchpilot/features/content/domain/legal.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/ios/data/ios_reader.dart';
import 'package:launchpilot/features/ios/domain/app_store.dart';
import 'package:launchpilot/features/ios/domain/ios_audit.dart';
import 'package:launchpilot/features/ios/domain/ios_edits.dart';
import 'package:launchpilot/features/ios/domain/ios_project.dart';
import 'package:yaml/yaml.dart';

const root = 'test/fixtures/projects/flutter_ios';

String fixture(String path) => File('$root/$path').readAsStringSync();

void main() {
  group('lecture du projet iOS', () {
    test('Info.plist : clés de premier niveau seulement', () {
      final plist = plistTopLevel(fixture('ios/Runner/Info.plist'));
      expect(plist['CFBundleDisplayName'], 'Carnet Photo');
      expect(plist['NSLocationWhenInUseUsageDescription'], 'Localisation');
      expect(plist['LSRequiresIPhoneOS'], isTrue);
      // Clés imbriquées (scènes) ignorées.
      expect(plist.containsKey('UISceneConfigurationName'), isFalse);
      expect(
        plistTopLevel(
          '<plist><dict><key>A</key><string>x &amp; y</string></dict></plist>',
        )['A'],
        'x & y',
      );
    });

    test('pbxproj : identifiant de la cible Runner, cible, signature', () {
      final info = parsePbxproj(
        fixture('ios/Runner.xcodeproj/project.pbxproj'),
      );
      expect(info.bundleId, 'com.example.carnetPhoto');
      expect(info.deploymentTarget, '15.0');
      expect(info.developmentTeam, isNull);
      expect(info.automaticSigning, isTrue);
      expect(info.privacyManifest, isFalse);
    });

    test('lecteur : icône App Store sans alpha, pas de CocoaPods', () {
      final p = const IosReader().read(root, analyzeProjectSync(root))!;
      expect(p.iosDir, 'ios');
      expect(p.marketingIcon, (present: true, alpha: false));
      expect(p.usesCocoaPods, isFalse);
      expect(p.privacyManifestFile, isFalse);
    });
  });

  group('audit iOS', () {
    final project = const IosReader().read(root, analyzeProjectSync(root))!;

    test('défauts repérés et limite Linux annoncée', () {
      final checks = auditIos(
        project,
        linuxHost: true,
        dependencies: const {'camera', 'geolocator', 'shared_preferences'},
      );
      IosCheck c(String id, [String? v]) => checks.firstWhere(
        (x) => x.id == id && (v == null || x.values.first == v),
      );
      expect(c('linuxHost').values, ['$requiredXcode']);
      expect(c('exampleBundleId').status, AuditStatus.failure);
      expect(
        c('usageMissing', 'NSCameraUsageDescription').values.last,
        'camera',
      );
      expect(
        c('usageMissing', 'NSMicrophoneUsageDescription').status,
        AuditStatus.failure,
      );
      expect(
        c('usageWeak', 'NSLocationWhenInUseUsageDescription').status,
        AuditStatus.warning,
      );
      expect(c('privacyManifest').status, AuditStatus.warning);
      expect(c('encryption').status, AuditStatus.info);
      expect(c('noTeam').status, AuditStatus.warning);
      expect(c('marketingIcon').status, AuditStatus.ok);
      expect(c('versionFromPubspec').status, AuditStatus.ok);
    });

    test('projet prêt', () {
      const ready = IosProject(
        iosDir: 'ios',
        infoPlistPath: 'x',
        pbxprojPath: 'y',
        plist: {
          'CFBundleDisplayName': 'Carnet Photo',
          'CFBundleShortVersionString': r'$(FLUTTER_BUILD_NAME)',
          'NSCameraUsageDescription':
              'Carnet Photo utilise l\'appareil photo pour tes photos.',
          'ITSAppUsesNonExemptEncryption': false,
        },
        bundleId: 'fr.atelier.photo',
        developmentTeam: 'AB12CD34EF',
        automaticSigning: true,
        privacyManifestFile: true,
        privacyManifestInProject: true,
        marketingIcon: (present: true, alpha: false),
      );
      final checks = auditIos(
        ready,
        linuxHost: true,
        dependencies: const {'mobile_scanner'},
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

    test('manifeste présent mais absent du projet Xcode, icône avec alpha', () {
      const a = IosProject(
        iosDir: 'ios',
        infoPlistPath: 'x',
        pbxprojPath: 'y',
        privacyManifestFile: true,
        marketingIcon: (present: true, alpha: true),
      );
      final ids = auditIos(a, linuxHost: false).map((c) => c.id);
      expect(
        ids,
        containsAll([
          'macHost',
          'privacyManifestNotInProject',
          'marketingIconAlpha',
        ]),
      );
    });

    test('textes trop vagues', () {
      expect(weakUsageText('Localisation'), isTrue);
      expect(weakUsageText('Nécessaire'), isTrue);
      expect(
        weakUsageText('Pour situer tes photos sur la carte du carnet.'),
        isFalse,
      );
    });
  });

  group('modifications iOS', () {
    test('Info.plist : ajout et remplacement, le reste intact', () {
      final source = fixture('ios/Runner/Info.plist');
      var out = setPlistValue(
        source,
        'NSCameraUsageDescription',
        'Photos <du> carnet & souvenirs',
      )!;
      out = setPlistValue(
        out,
        'NSLocationWhenInUseUsageDescription',
        'Pour situer tes photos sur la carte.',
      )!;
      out = setPlistValue(out, 'ITSAppUsesNonExemptEncryption', false)!;
      final plist = plistTopLevel(out);
      expect(
        plist['NSCameraUsageDescription'],
        'Photos <du> carnet & souvenirs',
      );
      expect(
        out,
        contains('<string>Photos &lt;du&gt; carnet &amp; souvenirs</string>'),
      );
      expect(
        plist['NSLocationWhenInUseUsageDescription'],
        'Pour situer tes photos sur la carte.',
      );
      expect(
        'NSLocationWhenInUseUsageDescription'.allMatches(out),
        hasLength(1),
      );
      expect(plist['ITSAppUsesNonExemptEncryption'], isFalse);
      expect(
        out,
        contains('\t<key>NSCameraUsageDescription</key>\n\t<string>'),
      );
      expect(out, endsWith('</dict>\n</plist>\n'));
      expect(out.contains('UISceneConfigurations'), isTrue);
      // Toujours bien formé : la structure imbriquée est inchangée.
      expect(
        '<dict>'.allMatches(out).length,
        '<dict>'.allMatches(source).length,
      );
      expect(setPlistValue('pas un plist', 'A', 'b'), isNull);
    });

    test('manifeste de confidentialité depuis le questionnaire', () {
      final xml = privacyManifest(
        const LegalAnswers(data: {DataCategory.location, DataCategory.usage}),
      );
      expect(
        xml,
        contains('<string>NSPrivacyCollectedDataTypePreciseLocation</string>'),
      );
      expect(xml, contains('NSPrivacyCollectedDataTypePurposeAnalytics'));
      expect(xml, contains('<key>NSPrivacyTracking</key>\n\t<false/>'));
      expect('<dict>'.allMatches(xml).length, '</dict>'.allMatches(xml).length);
      expect(plistTopLevel(xml)['NSPrivacyTracking'], isFalse);
    });

    test('ajout du manifeste au projet Xcode, comme Xcode', () {
      final source = fixture('ios/Runner.xcodeproj/project.pbxproj');
      final edit = addPrivacyManifestToProject(source);
      expect(edit.outcome, PbxEditOutcome.changed);
      final out = edit.content!;
      final refs = RegExp(
        r'([0-9A-F]{24}) /\* PrivacyInfo\.xcprivacy \*/ = \{isa = PBXFileReference',
      ).firstMatch(out)!;
      final fileRef = refs.group(1)!;
      final build = RegExp(
        r'([0-9A-F]{24}) /\* PrivacyInfo\.xcprivacy in Resources \*/ = \{isa = PBXBuildFile; fileRef = (\w+)',
      ).firstMatch(out)!;
      expect(build.group(2), fileRef);
      expect(source.contains(fileRef), isFalse);
      expect(source.contains(build.group(1)!), isFalse);
      // Dans le groupe Runner et la phase de ressources de Runner (pas des tests).
      final group = RegExp(
        r'/\* Runner \*/ = \{\s*isa = PBXGroup;\s*children = \(([^)]*)\)',
      ).firstMatch(out)!;
      expect(group.group(1), contains('$fileRef /* PrivacyInfo.xcprivacy */'));
      final phases = RegExp(r'isa = PBXResourcesBuildPhase;[^}]*')
          .allMatches(out)
          .map((m) => m.group(0)!)
          .toList();
      expect(phases.where((p) => p.contains('PrivacyInfo')), hasLength(1));
      expect(
        phases.firstWhere((p) => p.contains('PrivacyInfo')),
        contains('Assets.xcassets'),
      );
      expect(out.length - source.length, greaterThan(100));
      expect(parsePbxproj(out).privacyManifest, isTrue);
      expect(
        addPrivacyManifestToProject(out).outcome,
        PbxEditOutcome.alreadyPresent,
      );
      expect(
        addPrivacyManifestToProject('// projet').outcome,
        PbxEditOutcome.unrecognized,
      );
    });

    test('textes d\'accès suggérés', () {
      expect(
        suggestedUsageText('NSCameraUsageDescription', 'Carnet', fr: true),
        startsWith('Carnet utilise l\'appareil photo'),
      );
      expect(
        weakUsageText(
          suggestedUsageText('NSContactsUsageDescription', 'A', fr: false),
        ),
        isFalse,
      );
    });
  });

  group('App Store, Fastlane et CI', () {
    const config = IosConfig(
      teamId: 'AB12CD34EF',
      appleAppId: '6740000000',
      supportUrl: 'https://photo.example/aide',
      privacyUrl: 'https://photo.example/confidentialite',
      copyright: '2026 Atelier Photo',
    );

    test('fiche : limites et fichiers deliver', () {
      final l = AppStoreListing({AppStoreField.keywords: 'k' * 101});
      expect(l.overLimit, [AppStoreField.keywords]);
      expect(l.missing, [AppStoreField.name, AppStoreField.description]);
      final files = deliverTextFiles({
        'fr-FR': const AppStoreListing({
          AppStoreField.name: 'Carnet Photo',
          AppStoreField.subtitle: 'Tes souvenirs',
          AppStoreField.description: 'Description',
          AppStoreField.keywords: 'photo,carnet',
        }),
        'en-US': const AppStoreListing(),
      }, config);
      expect(files['metadata/fr-FR/name.txt'], 'Carnet Photo\n');
      expect(
        files['metadata/fr-FR/privacy_url.txt'],
        'https://photo.example/confidentialite\n',
      );
      expect(files['metadata/copyright.txt'], '2026 Atelier Photo\n');
      expect(files.keys.any((k) => k.contains('en-US')), isFalse);
      expect(files.containsKey('metadata/fr-FR/promotional_text.txt'), isFalse);
    });

    test('Appfile, Fastfile et ExportOptions sans secret', () {
      expect(
        iosAppfile('fr.a.b', 'AB12CD34EF'),
        contains('team_id("AB12CD34EF")'),
      );
      final ff = iosFastfile();
      expect(ff, contains('ENV["ASC_KEY_P8_BASE64"]'));
      expect(ff, contains('skip_binary_upload: true'));
      expect(ff, contains('submit_for_review: false'));
      final export = exportOptionsPlist('AB12CD34EF');
      final plist = plistTopLevel(export);
      expect(plist['method'], 'app-store-connect');
      expect(plist['teamID'], 'AB12CD34EF');
      expect(plist['signingStyle'], 'automatic');
    });

    test(
      'workflow GitHub : YAML valide, macOS, manuel, aucun secret en clair',
      () {
        final wf = githubIosWorkflow(iosDir: 'ios', teamId: 'AB12CD34EF');
        final y = loadYaml(wf) as YamlMap;
        expect((y['on'] as YamlMap).keys, ['workflow_dispatch']);
        final job = (y['jobs'] as YamlMap)['ios'] as YamlMap;
        expect(job['runs-on'], 'macos-26');
        final steps = (job['steps'] as YamlList).cast<YamlMap>();
        final archive =
            steps.firstWhere(
                  (s) => s['name'] == 'Archive signée (signature automatique)',
                )['run']
                as String;
        expect(archive, contains('-workspace ios/Runner.xcworkspace'));
        expect(archive, contains('DEVELOPMENT_TEAM=AB12CD34EF'));
        expect(archive, contains('-allowProvisioningUpdates'));
        expect(wf, contains(r'${{ secrets.ASC_KEY_P8_BASE64 }}'));
        expect(wf, isNot(contains('git push')));
        expect(steps.last['if'], 'always()');
        // Projet Flutter dans un sous-dossier.
        final sub = loadYaml(
          githubIosWorkflow(iosDir: 'app/ios', teamId: 'X'),
        ) as YamlMap;
        expect(
          (((sub['jobs'] as YamlMap)['ios'] as YamlMap)['defaults']
              as YamlMap)['run']['working-directory'],
          'app',
        );
      },
    );

    test('codemagic.yaml : YAML valide, signature et TestFlight', () {
      final y = loadYaml(
        codemagicYaml(bundleId: 'fr.a.b', appleAppId: '6740000000', pubDir: ''),
      ) as YamlMap;
      final wf = (y['workflows'] as YamlMap)['ios-testflight'] as YamlMap;
      expect(
        wf['environment']['ios_signing']['distribution_type'],
        'app_store',
      );
      expect(wf['environment']['ios_signing']['bundle_identifier'], 'fr.a.b');
      expect(wf['environment']['vars']['APP_STORE_APPLE_ID'], 6740000000);
      expect(
        wf['publishing']['app_store_connect']['submit_to_testflight'],
        isTrue,
      );
      expect(
        wf['publishing']['app_store_connect']['submit_to_app_store'],
        isFalse,
      );
      final scripts = (wf['scripts'] as YamlList).cast<YamlMap>();
      expect(scripts.first['script'], 'xcode-project use-profiles');
      expect(
        scripts.last['script'],
        contains('--export-options-plist=/Users/builder/export_options.plist'),
      );
    });

    test('validations', () {
      expect(config.teamValid, isTrue);
      expect(const IosConfig(teamId: 'abc').teamValid, isFalse);
      expect(config.appleAppIdValid, isTrue);
      expect(IosConfig.fromJson(config.toJson()), config);
    });
  });
}
