import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:launchpilot/core/database/app_database.dart';
import 'package:launchpilot/features/content/application/content_providers.dart';
import 'package:launchpilot/features/content/domain/icons.dart';
import 'package:launchpilot/features/content/presentation/screenshot_framer.dart';
import 'package:launchpilot/features/content/presentation/screenshots_tab.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/detection/data/detection_repository.dart';
import 'package:launchpilot/features/projects/application/project_providers.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';
import 'package:path/path.dart' as p;

import '../support/test_harness.dart';

Uint8List png(int w, int h) {
  final image = img.Image(width: w, height: h, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(40, 120, 220, 255));
  return img.encodePng(image);
}

class FakeImagePicker implements ImagePicker {
  FakeImagePicker(this.images);
  final List<PickedImage> images;

  @override
  Future<PickedImage?> pickOne() async => images.firstOrNull;

  @override
  Future<List<PickedImage>> pickMany() async => images;
}

/// Cadre neutre : le rendu dart:ui ne progresse pas en temps simulé.
class IdentityFramer implements ScreenshotFramer {
  @override
  Future<Uint8List> frame(
    Uint8List png, {
    required FrameStyle style,
    required ExportFormat format,
    String caption = '',
  }) async => png;
}

/// Copie du projet d'exemple Flutter dans un dossier réel, avec un dépôt Git.
Directory copyFixture() {
  final dir = Directory.systemTemp.createTempSync('lp_content_');
  final src = Directory('test/fixtures/projects/flutter_app');
  for (final f in src.listSync(recursive: true).whereType<File>()) {
    final target = File(p.join(dir.path, p.relative(f.path, from: src.path)));
    target.parent.createSync(recursive: true);
    f.copySync(target.path);
  }
  Process.runSync('git', ['init', '-q'], workingDirectory: dir.path);
  return dir;
}

Future<(AppDatabase, Map<String, Object>)> open(
  String path, {
  String? version,
}) async {
  final db = memoryDatabase();
  final projects = ProjectRepository(db, FakePathInspector([path]));
  final id = (await projects.addProject(path)).project.id;
  await DetectionRepository(db).saveReport(id, analyzeProjectSync(path));
  if (version != null) await projects.startSession(id, version);
  return (db, <String, Object>{CurrentProjectController.prefsKey: id});
}

Future<void> confirmWrite(WidgetTester tester) async {
  expect(find.text('Aperçu des modifications'), findsOneWidget);
  await tester.tap(find.byKey(const ValueKey('write-confirm')));
  await tester.pumpAndSettle();
  expect(find.text('Modifications écrites.'), findsWidgets);
}

void main() {
  late Directory dir;
  setUp(() => dir = copyFixture());
  tearDown(() => dir.deleteSync(recursive: true));

  Future<AppDatabase> start(
    WidgetTester tester, {
    String? version,
    FakeCommandRunner? runner,
    List<PickedImage> images = const [],
    String tool = 'version',
  }) async {
    final (db, prefs) = await open(dir.path, version: version);
    addTearDown(db.close);
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      prefs: prefs,
      paths: FakePathInspector([dir.path]),
      commandRunner: runner,
      overrides: [
        imagePickerProvider.overrideWithValue(FakeImagePicker(images)),
        iconGeneratorProvider.overrideWithValue((job) async => runIconJob(job)),
        screenshotFramerProvider.overrideWithValue(IdentityFramer()),
      ],
    );
    await tester.tap(find.byKey(const ValueKey('nav-content')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('tool-$tool')));
    await tester.pumpAndSettle();
    return db;
  }

  testWidgets('version : seule la ligne version change, après aperçu', (
    tester,
  ) async {
    await start(tester);
    final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
    final before = pubspec.readAsStringSync();

    expect(find.text('1.2.0+7 → 1.2.1+8'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('bump-pubspec.yaml')));
    await tester.tap(find.text('Mineure'));
    await tester.pumpAndSettle();
    expect(find.text('1.2.0+7 → 1.3.0+8'), findsOneWidget);

    await scrollAndTap(
      tester,
      find.byKey(const ValueKey('version-write-pubspec.yaml')),
    );
    expect(pubspec.readAsStringSync(), before, reason: 'aperçu seulement');
    await confirmWrite(tester);
    expect(
      pubspec.readAsStringSync(),
      before.replaceFirst('version: 1.2.0+7', 'version: 1.3.0+8'),
    );
  });

  testWidgets('version personnalisée invalide refusée', (tester) async {
    await start(tester);
    await tester.enterText(
      find.byKey(const ValueKey('version-custom-pubspec.yaml')),
      'deux',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Version invalide'), findsWidgets);
  });

  testWidgets('changelog depuis les commits, écrit puis tag confirmé', (
    tester,
  ) async {
    final runner = FakeCommandRunner({
      'git describe --tags --abbrev=0': (
        exitCode: 0,
        stdout: ['v1.1.0'],
        stderr: <String>[],
      ),
      'git log v1.1.0..HEAD --no-merges --pretty=format:%h%x1f%s%x1f%an': (
        exitCode: 0,
        stdout: [
          'a1\u001ffeat(meteo): prévisions sur 7 jours\u001fAlex',
          'b2\u001ffix: plantage hors ligne\u001fAlex',
          'c3\u001fchore: mise à jour des dépendances\u001fAlex',
        ],
        stderr: <String>[],
      ),
    });
    await start(tester, runner: runner, tool: 'changelog');
    await scrollAndTap(tester, find.byKey(const ValueKey('changelog-read')));
    expect(runner.executed.last, startsWith('git log v1.1.0..HEAD'));

    final text = tester
        .widget<TextField>(find.byKey(const ValueKey('changelog-text')))
        .controller!
        .text;
    expect(text, contains('Prévisions sur 7 jours'));
    expect(text, contains('Plantage hors ligne'));
    expect(text, isNot(contains('dépendances')), reason: 'version publique');

    await scrollAndTap(tester, find.byKey(const ValueKey('changelog-write')));
    await confirmWrite(tester);
    final changelog = File(p.join(dir.path, 'CHANGELOG.md'));
    expect(changelog.readAsStringSync(), contains('## 1.2.0'));
    expect(changelog.readAsStringSync(), contains('Prévisions sur 7 jours'));

    await scrollAndTap(tester, find.byKey(const ValueKey('changelog-tag')));
    final run = find.byKey(const ValueKey('cmd-preview-run'));
    expect(tester.widget<FilledButton>(run).onPressed, isNull);
    await tester.tap(find.byKey(const ValueKey('cmd-reinforced')));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(run).onPressed, isNotNull);
    expect(runner.executed, isNot(contains('git tag v1.2.0')));
  });

  testWidgets('icônes générées pour chaque plateforme, sans déformation', (
    tester,
  ) async {
    await start(
      tester,
      tool: 'icons',
      images: [PickedImage('logo.png', png(1024, 1024))],
    );
    await scrollAndTap(tester, find.byKey(const ValueKey('icons-pick')));
    await scrollAndTap(tester, find.byKey(const ValueKey('icons-generate')));
    await scrollAndTap(tester, find.byKey(const ValueKey('icons-write')));
    await confirmWrite(tester);

    final hdpi = File(
      p.join(dir.path, 'android/app/src/main/res/mipmap-hdpi/ic_launcher.png'),
    );
    expect(img.decodePng(hdpi.readAsBytesSync())!.width, 72);
    final xxxhdpi = File(
      p.join(
        dir.path,
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
      ),
    );
    expect(img.decodePng(xxxhdpi.readAsBytesSync())!.height, 192);
    expect(File(p.join(dir.path, 'web/icons/Icon-512.png')).existsSync(), true);
    expect(
      File(
        p.join(
          dir.path,
          'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
        ),
      ).existsSync(),
      isTrue,
    );
  });

  testWidgets('icône trop petite : génération impossible', (tester) async {
    await start(
      tester,
      tool: 'icons',
      images: [PickedImage('mini.png', png(200, 200))],
    );
    await scrollAndTap(tester, find.byKey(const ValueKey('icons-pick')));
    expect(find.byKey(const ValueKey('icons-generate')), findsNothing);
  });

  testWidgets('captures : dimensions vérifiées, zone masquée, export', (
    tester,
  ) async {
    await start(
      tester,
      tool: 'screenshots',
      images: [PickedImage('accueil.png', png(1080, 1920))],
    );
    await scrollAndTap(tester, find.byKey(const ValueKey('shots-import')));
    expect(find.text('accueil.png · 1080 × 1920'), findsOneWidget);

    await scrollAndTap(tester, find.byKey(const ValueKey('shot-mask-0')));
    final canvas = find.byKey(const ValueKey('mask-canvas'));
    final box = tester.getRect(canvas);
    await tester.dragFrom(
      box.topLeft + const Offset(5, 5),
      Offset(box.width / 2, box.height / 4),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mask-apply')));
    await tester.pumpAndSettle();
    expect(find.text('1 zone masquée'), findsOneWidget);

    await scrollAndTap(tester, find.byKey(const ValueKey('shots-export')));
    await confirmWrite(tester);
    final out = img.decodePng(
      File(p.join(dir.path, 'store_assets/screenshots/play/1.png'))
          .readAsBytesSync(),
    )!;
    // Le coin masqué est opaque et sombre, le reste intact.
    final masked = out.getPixel(20, 20);
    expect(masked.b, lessThan(100));
    final clear = out.getPixel(1000, 1800);
    expect(clear.b, 220);
  });

  testWidgets('textes : compteurs, limites, enregistrement dans la session', (
    tester,
  ) async {
    final db = await start(tester, version: '1.2.0', tool: 'texts');
    await tester.enterText(
      find.byKey(const ValueKey('texts-title')),
      'Météo Express : la météo la plus rapide',
    );
    await tester.pumpAndSettle();
    expect(find.text('39 / 30'), findsOneWidget);
    expect(
      find.text('Certains champs dépassent la limite des stores.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('texts-title')),
      'Météo Express',
    );
    await tester.pumpAndSettle();
    expect(find.text('13 / 30'), findsOneWidget);
    // Aperçu de la fiche mis à jour en direct.
    expect(find.text('Météo Express'), findsWidgets);
    expect(
      tester
          .widget<OutlinedButton>(
            find.ancestor(
              of: find.text('Générer avec l\'IA'),
              matching: find.byWidgetPredicate((w) => w is OutlinedButton),
            ),
          )
          .onPressed,
      isNull,
      reason: 'sans clé API',
    );

    await scrollAndTap(tester, find.byKey(const ValueKey('texts-save')));
    expect(find.text('Textes enregistrés dans la session.'), findsOneWidget);
    final rows = await db.select(db.sessionEntries).get();
    expect(rows.single.content, contains('Météo Express'));
  });

  testWidgets('juridique : avertissement, préremplissage, modèles écrits', (
    tester,
  ) async {
    await start(tester, tool: 'legal');
    expect(find.byKey(const ValueKey('legal-disclaimer')), findsOneWidget);
    expect(find.textContaining('ne garantissent pas'), findsOneWidget);
    expect(
      find.text('Préremplies d\'après la détection : vérifie-les.'),
      findsOneWidget,
    );
    // Publicité détectée dans le projet d'exemple.
    final ad = tester.widget<FilterChip>(
      find.byKey(const ValueKey('legal-data-advertisingId')),
    );
    expect(ad.selected, isTrue);

    await tester.enterText(
      find.byKey(const ValueKey('legal-publisherName')),
      'Alex Martin',
    );
    await tester.enterText(
      find.byKey(const ValueKey('legal-email')),
      'contact@exemple.fr',
    );
    await scrollAndTap(tester, find.byKey(const ValueKey('legal-generate')));
    await scrollAndTap(tester, find.byKey(const ValueKey('legal-write')));
    await confirmWrite(tester);

    final policy = File(
      p.join(dir.path, 'legal/politique-de-confidentialite.md'),
    ).readAsStringSync();
    expect(policy, contains('Alex Martin'));
    expect(policy, contains('contact@exemple.fr'));
    expect(policy, contains('ne garantit pas la conformité juridique'));
    expect(
      File(p.join(dir.path, 'legal/mentions-legales.md')).existsSync(),
      isTrue,
    );
  });

  testWidgets('la checklist ouvre l\'outil correspondant', (tester) async {
    final (db, prefs) = await open(dir.path, version: '1.2.0');
    addTearDown(db.close);
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      prefs: prefs,
      paths: FakePathInspector([dir.path]),
    );
    await tester.tap(find.byKey(const ValueKey('nav-checklist')));
    await tester.pumpAndSettle();
    final tool = find.byKey(const ValueKey('step-tool-common.legal'));
    if (tool.evaluate().isEmpty) {
      await scrollAndTap(tester, find.text('Préparer les documents légaux'));
    }
    await scrollAndTap(tester, tool);
    expect(find.byKey(const ValueKey('legal-disclaimer')), findsOneWidget);
  });
}
