import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/detection/data/detection_repository.dart';
import 'package:launchpilot/features/ios/application/ios_providers.dart';
import 'package:launchpilot/features/ios/domain/ios_project.dart';
import 'package:launchpilot/features/projects/application/project_providers.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../support/test_harness.dart';

Directory copyFixture(String name) {
  final dir = Directory.systemTemp.createTempSync('lp_ios_');
  final src = Directory('test/fixtures/projects/$name');
  for (final f in src.listSync(recursive: true).whereType<File>()) {
    final target = File(p.join(dir.path, p.relative(f.path, from: src.path)));
    target.parent.createSync(recursive: true);
    f.copySync(target.path);
  }
  return dir;
}

Future<void> confirmWrite(WidgetTester tester) async {
  expect(find.text('Aperçu des modifications'), findsOneWidget);
  await tester.tap(find.byKey(const ValueKey('write-confirm')));
  await tester.pumpAndSettle();
  expect(find.text('Modifications écrites.'), findsWidgets);
}

Future<void> reveal(WidgetTester tester, Finder finder) => tester
    .scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);

void main() {
  late Directory dir;
  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> start(
    WidgetTester tester, {
    String fixture = 'flutter_ios',
    String tool = 'ios',
    bool session = false,
  }) async {
    dir = copyFixture(fixture);
    final db = memoryDatabase();
    addTearDown(db.close);
    final projects = ProjectRepository(db, FakePathInspector([dir.path]));
    final id = (await projects.addProject(dir.path)).project.id;
    await DetectionRepository(db).saveReport(id, analyzeProjectSync(dir.path));
    if (session) await projects.startSession(id, '1.4.0');
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      prefs: {CurrentProjectController.prefsKey: id},
      paths: FakePathInspector([dir.path]),
      overrides: [hostIsLinuxProvider.overrideWithValue(true)],
    );
    await tester.tap(find.byKey(const ValueKey('nav-content')));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byKey(ValueKey('tool-$tool')));
  }

  testWidgets('limites Linux et audit', (tester) async {
    await start(tester);
    expect(find.byKey(const ValueKey('ios-limits')), findsOneWidget);
    expect(find.textContaining('il faut Xcode'), findsOneWidget);
    await scrollAndTap(tester, find.byKey(const ValueKey('ios-audit')));
    for (final key in const [
      'ios-check-linuxHost-26',
      'ios-check-exampleBundleId-com.example.carnetPhoto',
      'ios-check-usageMissing-NSCameraUsageDescription',
      'ios-check-usageWeak-NSLocationWhenInUseUsageDescription',
      'ios-check-privacyManifest-',
    ]) {
      await reveal(tester, find.byKey(ValueKey(key)));
    }
  });

  testWidgets('Info.plist : textes d\'accès et chiffrement après aperçu', (
    tester,
  ) async {
    await start(tester);
    await scrollAndTap(tester, find.byKey(const ValueKey('ios-audit')));
    final camera = find.byKey(
      const ValueKey('ios-usage-NSCameraUsageDescription'),
    );
    await reveal(tester, camera);
    expect(
      tester.widget<TextField>(camera).controller!.text,
      startsWith('Carnet Photo utilise l\'appareil photo'),
    );
    await tester.enterText(
      camera,
      'Pour photographier tes souvenirs de voyage.',
    );
    final plist = File(p.join(dir.path, 'ios/Runner/Info.plist'));
    final before = plist.readAsStringSync();
    await scrollAndTap(tester, find.byKey(const ValueKey('ios-plist-write')));
    expect(plist.readAsStringSync(), before, reason: 'rien avant confirmation');
    await confirmWrite(tester);
    final values = plistTopLevel(plist.readAsStringSync());
    expect(
      values['NSCameraUsageDescription'],
      'Pour photographier tes souvenirs de voyage.',
    );
    expect(values['NSMicrophoneUsageDescription'], isNotEmpty);
    expect(values['ITSAppUsesNonExemptEncryption'], isFalse);
    expect(
      (values['NSLocationWhenInUseUsageDescription']! as String).length,
      greaterThan(25),
    );
  });

  testWidgets('manifeste de confidentialité ajouté au projet Xcode', (
    tester,
  ) async {
    await start(tester);
    await scrollAndTap(tester, find.byKey(const ValueKey('ios-privacy-write')));
    await confirmWrite(tester);
    final manifest = File(p.join(dir.path, 'ios/Runner/PrivacyInfo.xcprivacy'));
    expect(
      manifest.readAsStringSync(),
      contains('NSPrivacyCollectedDataTypePreciseLocation'),
    );
    final pbx = File(p.join(dir.path, 'ios/Runner.xcodeproj/project.pbxproj'))
        .readAsStringSync();
    expect('PrivacyInfo.xcprivacy in Resources'.allMatches(pbx), hasLength(2));
    await reveal(
      tester,
      find.byKey(const ValueKey('ios-check-privacyManifestOk-')),
    );
  });

  testWidgets('CI : GitHub Actions puis Codemagic, après aperçu', (
    tester,
  ) async {
    await start(tester);
    final write = find.byKey(const ValueKey('ios-ci-write'));
    await tester.ensureVisible(write);
    expect(
      tester.widget<FilledButton>(write).onPressed,
      isNull,
      reason: 'Team ID manquant',
    );
    await tester.enterText(
      find.byKey(const ValueKey('ios-team')),
      'ab12cd34ef',
    );
    await tester.pumpAndSettle();
    await scrollAndTap(tester, write);
    await confirmWrite(tester);
    final wf = File(p.join(dir.path, '.github/workflows/ios-testflight.yml'))
        .readAsStringSync();
    final y = loadYaml(wf) as YamlMap;
    expect(((y['jobs'] as YamlMap)['ios'] as YamlMap)['runs-on'], 'macos-26');
    expect(wf, contains('DEVELOPMENT_TEAM=AB12CD34EF'));
    expect(
      plistTopLevel(
        File(p.join(dir.path, 'ios/ExportOptions.plist')).readAsStringSync(),
      )['teamID'],
      'AB12CD34EF',
    );

    await tester.tap(find.text('Codemagic'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, write);
    await confirmWrite(tester);
    final cm = loadYaml(
      File(p.join(dir.path, 'codemagic.yaml')).readAsStringSync(),
    ) as YamlMap;
    expect(
      cm['workflows']['ios-testflight']['environment']['ios_signing']['bundle_identifier'],
      'com.example.carnetPhoto',
    );
  });

  testWidgets('App Store : fiche, captures et Fastlane deliver', (
    tester,
  ) async {
    await start(tester, tool: 'appStore', session: true);
    final shot = img.Image(width: 1290, height: 2796);
    File(p.join(dir.path, 'store_assets/screenshots/iphone/1.png'))
      ..createSync(recursive: true)
      ..writeAsBytesSync(img.encodePng(shot));
    await tester.tap(find.byKey(const ValueKey('tool-ios')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tool-appStore')));
    await tester.pumpAndSettle();
    expect(find.text('1 capture iPhone prête'), findsOneWidget);

    final fastlane = find.byKey(const ValueKey('as-fastlane'));
    await tester.ensureVisible(fastlane);
    expect(tester.widget<FilledButton>(fastlane).onPressed, isNull);
    await tester.enterText(
      find.byKey(const ValueKey('as-name')),
      'Carnet Photo',
    );
    await tester.enterText(
      find.byKey(const ValueKey('as-description')),
      'Tes souvenirs géolocalisés.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('as-keywords')),
      'photo,voyage,carnet',
    );
    await tester.enterText(find.byKey(const ValueKey('as-subtitle')), 'x' * 31);
    await tester.pumpAndSettle();
    expect(find.text('31 / 30'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('as-subtitle')),
      'Tes souvenirs',
    );
    await tester.enterText(
      find.byKey(const ValueKey('as-support')),
      'https://photo.example/aide',
    );
    await tester.enterText(
      find.byKey(const ValueKey('as-privacy')),
      'https://photo.example/confidentialite',
    );
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byKey(const ValueKey('as-save')));
    expect(
      find.text('Fiche App Store enregistrée dans la session.'),
      findsOneWidget,
    );

    await scrollAndTap(tester, fastlane);
    await confirmWrite(tester);
    final fl = p.join(dir.path, 'ios/fastlane');
    expect(
      File(p.join(fl, 'Appfile')).readAsStringSync(),
      contains('app_identifier("com.example.carnetPhoto")'),
    );
    expect(
      File(p.join(fl, 'Fastfile')).readAsStringSync(),
      contains('skip_binary_upload: true'),
    );
    expect(
      File(p.join(fl, 'metadata/fr-FR/name.txt')).readAsStringSync(),
      'Carnet Photo\n',
    );
    expect(
      File(p.join(fl, 'metadata/fr-FR/privacy_url.txt')).readAsStringSync(),
      'https://photo.example/confidentialite\n',
    );
    expect(
      File(p.join(fl, 'screenshots/fr-FR/iphone-1.png')).existsSync(),
      isTrue,
    );
  });

  testWidgets('outils iOS masqués sans cible iOS', (tester) async {
    dir = copyFixture('flutter_android');
    final db = memoryDatabase();
    addTearDown(db.close);
    final projects = ProjectRepository(db, FakePathInspector([dir.path]));
    final id = (await projects.addProject(dir.path)).project.id;
    await DetectionRepository(db).saveReport(id, analyzeProjectSync(dir.path));
    await pumpLaunchPilot(
      tester,
      database: db,
      prefs: {CurrentProjectController.prefsKey: id},
      paths: FakePathInspector([dir.path]),
    );
    await tester.tap(find.byKey(const ValueKey('nav-content')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tool-ios')), findsNothing);
    expect(find.byKey(const ValueKey('tool-android')), findsOneWidget);
  });
}
