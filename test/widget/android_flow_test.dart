import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:launchpilot/features/android/application/android_providers.dart';
import 'package:launchpilot/features/android/domain/deliverables.dart';
import 'package:launchpilot/features/content/application/content_providers.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/detection/data/detection_repository.dart';
import 'package:launchpilot/features/projects/application/project_providers.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';
import 'package:launchpilot/features/settings/data/settings_repository.dart';
import 'package:launchpilot/features/web/application/web_providers.dart';
import 'package:launchpilot/features/web/data/web_services.dart';
import 'package:path/path.dart' as p;

import '../support/test_harness.dart';

class FakeTools implements ToolLocator {
  FakeTools(this.installed);
  final Set<String> installed;

  @override
  Future<bool> isInstalled(String executable) async =>
      installed.contains(executable);
}

class FakePicker implements ImagePicker {
  FakePicker(this.image);
  final PickedImage? image;

  @override
  Future<PickedImage?> pickOne() async => image;

  @override
  Future<List<PickedImage>> pickMany() async => [?image];
}

Uint8List png(int w, int h) {
  final image = img.Image(width: w, height: h, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(30, 120, 200, 255));
  return img.encodePng(image);
}

Uint8List aab(String certSubject) {
  final archive = Archive()
    ..addFile(ArchiveFile('base/manifest/AndroidManifest.xml', 3, [1, 2, 3]))
    ..addFile(
      ArchiveFile(
        'META-INF/KEY.RSA',
        certSubject.length,
        utf8.encode(certSubject),
      ),
    );
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

Directory copyFixture(String name) {
  final dir = Directory.systemTemp.createTempSync('lp_android_');
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

  Future<FakeCommandRunner> start(
    WidgetTester tester, {
    String tool = 'android',
    Set<String> tools = const {},
    bool simulation = true,
    bool session = false,
    Map<String, FakeOutput> outputs = const {},
    PickedImage? image,
  }) async {
    dir = copyFixture('flutter_android');
    final db = memoryDatabase();
    addTearDown(db.close);
    final projects = ProjectRepository(db, FakePathInspector([dir.path]));
    final id = (await projects.addProject(dir.path)).project.id;
    await DetectionRepository(db).saveReport(id, analyzeProjectSync(dir.path));
    if (session) await projects.startSession(id, '2.1.0');
    final runner = FakeCommandRunner({...outputs});
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      prefs: {
        CurrentProjectController.prefsKey: id,
        SettingsRepository.kSimulation: simulation,
      },
      paths: FakePathInspector([dir.path]),
      commandRunner: runner,
      overrides: [
        toolLocatorProvider.overrideWithValue(FakeTools(tools)),
        deliverableInspectorProvider.overrideWithValue(
          (job) async => inspectDeliverables(job),
        ),
        imagePickerProvider.overrideWithValue(FakePicker(image)),
      ],
    );
    await tester.tap(find.byKey(const ValueKey('nav-content')));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byKey(ValueKey('tool-$tool')));
    return runner;
  }

  testWidgets('audit : identifiant, API cible, signature, permissions', (
    tester,
  ) async {
    await start(tester);
    expect(
      find.text('Gradle 8.12 · plugin Android 8.9.1 · Kotlin 2.1.0'),
      findsOneWidget,
    );
    await scrollAndTap(tester, find.byKey(const ValueKey('android-audit')));
    expect(find.byKey(const ValueKey('android-audit-summary')), findsOneWidget);
    for (final key in const [
      'android-check-exampleId-com.example.carnet_velo',
      'android-check-targetSdkTooLow-34',
      'android-check-debugSigning-',
      'android-check-permRestricted-ACCESS_BACKGROUND_LOCATION',
      'android-check-permUnexplained-READ_CONTACTS',
    ]) {
      await reveal(tester, find.byKey(ValueKey(key)));
    }
    expect(find.textContaining('Google Play exige l\'API 36'), findsOneWidget);
  });

  testWidgets('environnement : flutter doctor lu en lecture seule', (
    tester,
  ) async {
    final runner = await start(
      tester,
      outputs: {
        'flutter doctor -v': (
          exitCode: 0,
          stdout: [
            '[!] Android toolchain - develop for Android devices',
            '    • Java version OpenJDK Runtime Environment (build 21.0.5)',
            '    ✗ Android license status unknown.',
          ],
          stderr: <String>[],
        ),
      },
    );
    await scrollAndTap(tester, find.byKey(const ValueKey('android-doctor')));
    await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
    await tester.pumpAndSettle();
    expect(runner.executed, contains('flutter doctor -v'));
    expect(find.text('Android license status unknown.'), findsOneWidget);
    expect(
      find.text('Java : OpenJDK Runtime Environment (build 21.0.5)'),
      findsOneWidget,
    );
    expect(find.textContaining('--android-licenses'), findsOneWidget);
  });

  testWidgets('signature release et .gitignore, après aperçu', (tester) async {
    await start(tester);
    expect(find.byKey(const ValueKey('android-keytool')), findsOneWidget);
    final template = tester.widget<SelectableText>(
      find.byKey(const ValueKey('android-key-template')),
    );
    expect(template.data, contains('<mot de passe du keystore>'));

    final gradle = File(p.join(dir.path, 'android/app/build.gradle.kts'));
    final before = gradle.readAsStringSync();
    await scrollAndTap(tester, find.byKey(const ValueKey('android-signing')));
    expect(
      gradle.readAsStringSync(),
      before,
      reason: 'rien avant confirmation',
    );
    await confirmWrite(tester);
    final after = gradle.readAsStringSync();
    expect(after, contains('create("release")'));
    expect(after, contains('signingConfigs.getByName("release")'));

    await scrollAndTap(tester, find.byKey(const ValueKey('android-signing')));
    expect(
      find.text('La signature release est déjà configurée.'),
      findsOneWidget,
    );

    await scrollAndTap(tester, find.byKey(const ValueKey('android-gitignore')));
    await confirmWrite(tester);
    final ignore = File(p.join(dir.path, '.gitignore')).readAsStringSync();
    expect(ignore, contains('/android/key.properties'));
    expect(ignore, contains('\n*.jks\n'));
  });

  testWidgets('build : aperçu de la commande, livrables contrôlés', (
    tester,
  ) async {
    await start(tester);
    await scrollAndTap(tester, find.byKey(const ValueKey('android-build-aab')));
    expect(
      find.textContaining('flutter build appbundle --release'),
      findsWidgets,
    );
    await tester.tap(find.text('Annuler').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-content')));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byKey(const ValueKey('tool-android')));

    File(p.join(dir.path, deliverableCandidates('').first))
      ..createSync(recursive: true)
      ..writeAsBytesSync(aab('CN=Android Debug, O=Android'));
    await scrollAndTap(
      tester,
      find.byKey(const ValueKey('android-deliverables')),
    );
    await reveal(
      tester,
      find.text('Signé avec la clé de débogage : Google Play le refusera.'),
    );
    expect(
      find.textContaining(RegExp(r'SHA-256 [0-9a-f]{64}')),
      findsOneWidget,
    );
  });

  testWidgets('Play Store : fiche, Fastlane écrit, envoi simulé', (
    tester,
  ) async {
    final runner = await start(
      tester,
      tool: 'play',
      tools: {'fastlane'},
      session: true,
      image: PickedImage('icone.png', png(1024, 1024)),
    );
    expect(find.byKey(const ValueKey('play-first-upload')), findsOneWidget);
    final fastlaneBtn = find.byKey(const ValueKey('play-fastlane'));
    await tester.ensureVisible(fastlaneBtn);
    expect(
      tester.widget<FilledButton>(fastlaneBtn).onPressed,
      isNull,
      reason: 'fiche vide',
    );

    await tester.enterText(find.byKey(const ValueKey('play-title')), 'x' * 31);
    await tester.pumpAndSettle();
    expect(find.text('31 / 30'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('play-title')),
      'Carnet Vélo',
    );
    await tester.enterText(
      find.byKey(const ValueKey('play-shortDescription')),
      'Tes sorties à vélo',
    );
    await tester.enterText(
      find.byKey(const ValueKey('play-fullDescription')),
      'Note tes sorties, distances et parcours.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('play-changelog')),
      'Première version',
    );
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byKey(const ValueKey('play-save')));
    expect(
      find.text('Fiche Play Store enregistrée dans la session.'),
      findsOneWidget,
    );

    await scrollAndTap(tester, find.byKey(const ValueKey('play-icon')));
    expect(find.byKey(const ValueKey('play-feature-graphic')), findsOneWidget);
    await scrollAndTap(tester, fastlaneBtn);
    await confirmWrite(tester);
    final fl = p.join(dir.path, 'android/fastlane');
    expect(
      File(p.join(fl, 'Appfile')).readAsStringSync(),
      contains('package_name("com.example.carnet_velo")'),
    );
    expect(
      File(p.join(fl, 'Fastfile')).readAsStringSync(),
      contains('track: "internal"'),
    );
    expect(
      File(p.join(fl, 'metadata/android/fr-FR/title.txt')).readAsStringSync(),
      'Carnet Vélo\n',
    );
    expect(
      File(p.join(fl, 'metadata/android/fr-FR/changelogs/15.txt')).existsSync(),
      isTrue,
    );
    final graphic = img.decodePng(
      File(p.join(fl, 'metadata/android/fr-FR/images/featureGraphic.png'))
          .readAsBytesSync(),
    )!;
    expect((graphic.width, graphic.height), (1024, 500));

    // Envoi : il faut un App Bundle signé et une clé existante.
    final upload = find.byKey(const ValueKey('play-upload'));
    await tester.ensureVisible(upload);
    expect(tester.widget<FilledButton>(upload).onPressed, isNull);
    File(p.join(dir.path, deliverableCandidates('').first))
      ..createSync(recursive: true)
      ..writeAsBytesSync(aab('CN=Carnet Velo'));
    await scrollAndTap(tester, find.byKey(const ValueKey('play-check-aab')));
    expect(find.textContaining('App Bundle signé avec ta clé'), findsOneWidget);
    final keyDir = Directory.systemTemp.createTempSync('lp_key_');
    addTearDown(() => keyDir.deleteSync(recursive: true));
    final key = File(p.join(keyDir.path, 'play.json'))..writeAsStringSync('{}');
    await tester.enterText(
      find.byKey(const ValueKey('play-json-key')),
      key.path,
    );
    await tester.pumpAndSettle();

    await scrollAndTap(tester, upload);
    expect(
      find.text('Récapitulatif : envoi sur la piste interne'),
      findsOneWidget,
    );
    expect(find.textContaining('versionCode : 15'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('deploy-ack')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('deploy-continue')));
    await tester.pumpAndSettle();
    final run = find.byKey(const ValueKey('cmd-preview-run'));
    expect(tester.widget<FilledButton>(run).onPressed, isNull);
    await tester.tap(find.byKey(const ValueKey('cmd-reinforced')));
    await tester.pumpAndSettle();
    await tester.tap(run);
    await tester.pumpAndSettle();
    expect(
      runner.executed.where((c) => c.startsWith('fastlane')),
      isEmpty,
      reason: 'mode simulation',
    );
  });

  testWidgets('hors simulation, l\'envoi confirmé est exécuté', (tester) async {
    final runner = await start(
      tester,
      tool: 'play',
      tools: {'fastlane'},
      simulation: false,
    );
    for (final (path, content) in [
      ('android/fastlane/Fastfile', 'lane'),
      ('android/fastlane/Appfile', 'pkg'),
    ]) {
      File(p.join(dir.path, path))
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
    }
    File(p.join(dir.path, deliverableCandidates('').first))
      ..createSync(recursive: true)
      ..writeAsBytesSync(aab('CN=Carnet Velo'));
    final keyDir = Directory.systemTemp.createTempSync('lp_key_');
    addTearDown(() => keyDir.deleteSync(recursive: true));
    final key = File(p.join(keyDir.path, 'play.json'))..writeAsStringSync('{}');
    // Réaffichage pour prendre en compte le Fastfile créé.
    await tester.tap(find.byKey(const ValueKey('tool-android')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tool-play')));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byKey(const ValueKey('play-check-aab')));
    await tester.enterText(
      find.byKey(const ValueKey('play-json-key')),
      key.path,
    );
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byKey(const ValueKey('play-upload')));
    await tester.tap(find.byKey(const ValueKey('deploy-ack')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('deploy-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cmd-reinforced')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
    await tester.pumpAndSettle();
    expect(runner.executed.where((c) => c.startsWith('fastlane')), [
      'fastlane internal json_key:${key.path}',
    ]);
  });
}
