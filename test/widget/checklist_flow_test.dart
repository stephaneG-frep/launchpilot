import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/database/app_database.dart';
import 'package:launchpilot/core/domain/action_level.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/detection/data/detection_repository.dart';
import 'package:launchpilot/features/detection/domain/detection_report.dart';
import 'package:launchpilot/features/projects/application/project_providers.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';
import 'package:launchpilot/features/settings/data/settings_repository.dart';

import '../support/test_harness.dart';

const root = '/home/testeur/projets/meteo';

/// Projet analysé (exemple Flutter : Android, iOS et Web détectés), avec
/// éventuellement une session active.
Future<(AppDatabase, Map<String, Object>)> setup({
  bool session = true,
  bool analyzed = true,
  Map<String, Object> prefs = const {},
}) async {
  final db = memoryDatabase();
  final projects = ProjectRepository(db, FakePathInspector([root]));
  final id = (await projects.addProject(root)).project.id;
  if (analyzed) {
    await DetectionRepository(
      db,
    ).saveReport(id, analyzeProjectSync('test/fixtures/projects/flutter_app'));
  }
  if (session) await projects.startSession(id, '1.2.0+7');
  return (db, {CurrentProjectController.prefsKey: id, ...prefs});
}

Future<void> go(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(ValueKey('nav-$name')));
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, String key) =>
    scrollAndTap(tester, find.byKey(ValueKey(key)));

Future<void> pumpChecklist(
  WidgetTester tester,
  AppDatabase db,
  Map<String, Object> prefs, {
  FakeCommandRunner? runner,
  Size size = tallScreen,
}) async {
  await pumpLaunchPilot(
    tester,
    size: size,
    database: db,
    prefs: prefs,
    paths: FakePathInspector([root]),
    commandRunner: runner,
  );
  // En fenêtre étroite, la navigation est dans le tiroir.
  final menu = find.byIcon(Icons.menu);
  if (menu.evaluate().isNotEmpty) {
    await tester.tap(menu);
    await tester.pumpAndSettle();
  }
  await go(tester, 'checklist');
}

void main() {
  testWidgets('sans session puis sans analyse : états honnêtes', (
    tester,
  ) async {
    final (db, prefs) = await setup(session: false);
    addTearDown(db.close);
    await pumpChecklist(tester, db, prefs);
    expect(find.text('Aucune session en cours pour ce projet'), findsOneWidget);
    expect(find.byKey(const ValueKey('checklist-new-session')), findsOneWidget);

    final (db2, prefs2) = await setup(analyzed: false);
    addTearDown(db2.close);
    await tester.pumpWidget(const SizedBox());
    await pumpChecklist(tester, db2, prefs2);
    expect(find.text('Projet pas encore analysé'), findsOneWidget);
    await tapKey(tester, 'checklist-go-detection');
    expect(find.text('Rapport de détection'), findsOneWidget);
  });

  testWidgets('plan affiché par niveau, prérequis bloquants', (tester) async {
    final (db, prefs) = await setup();
    addTearDown(db.close);
    await pumpChecklist(tester, db, prefs);

    for (final level in ['Analyser', 'Préparer', 'Construire', 'Publier']) {
      expect(find.text(level), findsWidgets);
    }
    expect(find.text('Mettre le projet sous Git'), findsOneWidget);
    expect(find.text('Construire l\'App Bundle'), findsOneWidget);
    expect(
      find.textContaining('Prochaine étape : Mettre le projet sous Git'),
      findsOneWidget,
    );
    expect(find.textContaining('Cibles pas encore validées'), findsOneWidget);

    // La clé de signature attend la protection des fichiers sensibles.
    expect(
      find.text('Termine d\'abord : Protéger les fichiers sensibles'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('step-done-android.keystore')),
      findsNothing,
    );
  });

  testWidgets('étapes manuelles en chaîne et étape pédagogique', (
    tester,
  ) async {
    final (db, prefs) = await setup();
    addTearDown(db.close);
    await pumpChecklist(tester, db, prefs);

    await tapKey(tester, 'step-done-common.git');
    await tapKey(tester, 'step-done-common.secrets');
    expect(
      find.byKey(const ValueKey('step-done-android.keystore')),
      findsOneWidget,
    );

    await tapKey(tester, 'step-done-android.permissions');
    expect(find.text('J\'ai compris'), findsWidgets);
    expect(
      find.byKey(const ValueKey('step-reset-android.permissions')),
      findsOneWidget,
    );
    expect(find.text('Étape pédagogique'), findsWidgets);

    await tapKey(tester, 'step-reset-common.git');
    expect(find.byKey(const ValueKey('step-done-common.git')), findsOneWidget);
  });

  testWidgets('commande : simulée, puis réussie, puis échouée', (tester) async {
    final (db, prefs) = await setup();
    addTearDown(db.close);
    final runner = FakeCommandRunner();
    await pumpChecklist(tester, db, prefs, runner: runner);

    await tapKey(tester, 'step-run-common.flutter.doctor');
    expect(find.text('Aperçu de la commande'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
    await tester.pumpAndSettle();
    expect(
      find.text('Étape réussie.'),
      findsOneWidget,
      reason: 'lecture seule',
    );
    expect(runner.executed, ['flutter doctor -v']);

    // pub get modifie des fichiers générés : simulée par défaut.
    await tapKey(tester, 'step-run-common.flutter.deps');
    await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Commande simulée'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('step-run-common.flutter.deps')),
      findsOneWidget,
    );
    expect(runner.executed, ['flutter doctor -v']);
  });

  testWidgets('commande en échec : statut et accès à la sortie', (
    tester,
  ) async {
    final (db, prefs) = await setup(
      prefs: {SettingsRepository.kSimulation: false},
    );
    addTearDown(db.close);
    final runner = FakeCommandRunner({
      'flutter pub get': (
        exitCode: 1,
        stdout: <String>[],
        stderr: ['Because meteo depends on x…'],
      ),
    });
    await pumpChecklist(tester, db, prefs, runner: runner);

    await tapKey(tester, 'step-run-common.flutter.deps');
    await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
    await tester.pumpAndSettle();
    expect(find.textContaining('La commande a échoué'), findsOneWidget);
    expect(find.text('Échec'), findsWidgets);
    expect(find.text('Voir la sortie'), findsOneWidget);
    // L'analyse dépend des dépendances : toujours bloquée.
    expect(
      find.byKey(const ValueKey('step-run-common.flutter.analyze')),
      findsNothing,
    );
  });

  testWidgets('trois niveaux d\'explication et lexique', (tester) async {
    final (db, prefs) = await setup();
    addTearDown(db.close);
    await pumpChecklist(tester, db, prefs);

    // Débutant : objectif.
    expect(
      find.text('S\'assurer qu\'aucun secret ne sera versionné ni publié.'),
      findsOneWidget,
    );
    await scrollAndTap(tester, find.text('Accompagné'));
    expect(
      find.text('Fichiers sensibles détectés : vérifie qu\'ils sont ignorés.'),
      findsOneWidget,
    );
    await scrollAndTap(tester, find.text('Expert'));
    expect(
      find.textContaining('flutter doctor -v', findRichText: true),
      findsWidgets,
    );

    await scrollAndTap(tester, find.text('Débutant'));
    final expand = find.descendant(
      of: find.ancestor(
        of: find.text('Préparer la clé de signature'),
        matching: find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == 'ChecklistStepCard',
        ),
      ),
      matching: find.byTooltip('Afficher les détails'),
    );
    await scrollAndTap(tester, expand);
    await tapKey(tester, 'glossary-android.keystore-keystore');
    expect(
      find.textContaining('clé de signature Android. Il ne doit jamais'),
      findsOneWidget,
    );
  });

  testWidgets('reprise : statuts et niveau conservés après redémarrage', (
    tester,
  ) async {
    final (db, prefs) = await setup();
    addTearDown(db.close);
    await pumpChecklist(tester, db, prefs);
    await tapKey(tester, 'step-done-common.git');
    await tapKey(tester, 'step-done-android.permissions');

    await tester.pumpWidget(const SizedBox());
    await pumpChecklist(tester, db, prefs);
    expect(find.byKey(const ValueKey('step-reset-common.git')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('step-reset-android.permissions')),
      findsOneWidget,
    );

    final session = await tester.runAsync(
      () => db.select(db.releaseSessions).getSingle(),
    );
    expect(session!.currentLevel, ActionLevel.analyze);
  });

  testWidgets('cible retirée : ses étapes disparaissent', (tester) async {
    final (db, prefs) = await setup();
    addTearDown(db.close);
    await pumpChecklist(tester, db, prefs);
    expect(find.text('Mettre en ligne'), findsOneWidget);

    await go(tester, 'detection');
    await tapKey(tester, 'target-switch-web');
    await go(tester, 'checklist');
    expect(find.text('Mettre en ligne'), findsNothing);
    expect(find.text('Construire l\'App Bundle'), findsOneWidget);
    final selected = await tester.runAsync(
      () =>
          DetectionRepository(db)
              .load(prefs[CurrentProjectController.prefsKey]! as int),
    );
    expect(selected!.selected, isNot(contains(PlatformTarget.web)));
  });

  for (final lang in ['fr', 'en']) {
    testWidgets('aucun débordement en fenêtre étroite ($lang)', (tester) async {
      final (db, prefs) = await setup(
        prefs: {
          SettingsRepository.kTextSize: 'extraLarge',
          SettingsRepository.kLanguage: lang,
        },
      );
      addTearDown(db.close);
      await pumpChecklist(tester, db, prefs, size: narrowScreen);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -30000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
