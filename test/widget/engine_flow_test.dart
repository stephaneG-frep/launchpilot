import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/database/app_database.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/detection/data/detection_repository.dart';
import 'package:launchpilot/features/git/data/git_service.dart';
import 'package:launchpilot/features/projects/application/project_providers.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';
import 'package:launchpilot/features/settings/data/settings_repository.dart';
import 'package:path/path.dart' as p;

import '../support/test_harness.dart';

const root = '/home/testeur/projets/meteo';
final gitStatusCommand = 'git ${GitService.statusArguments.join(' ')}';

/// Base avec un projet ouvert (et analysé à partir du projet d'exemple
/// Flutter), prête à être donnée au harnais.
Future<(AppDatabase, Map<String, Object>, int)> openedProject(
  String path, {
  String? version,
}) async {
  final db = memoryDatabase();
  final projects = ProjectRepository(db, FakePathInspector([path]));
  final id = (await projects.addProject(path)).project.id;
  await DetectionRepository(db)
      .saveReport(id, analyzeProjectSync('test/fixtures/projects/flutter_app'));
  if (version != null) await projects.startSession(id, version);
  return (db, <String, Object>{CurrentProjectController.prefsKey: id}, id);
}

Future<void> go(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(ValueKey('nav-$name')));
  await tester.pumpAndSettle();
}

Future<void> runQuick(WidgetTester tester, String display) async {
  await scrollAndTap(tester, find.byKey(ValueKey('quick-$display')));
}

void main() {
  testWidgets('aperçu puis exécution d\'une commande en lecture seule', (
    tester,
  ) async {
    final (db, prefs, _) = await openedProject(root);
    addTearDown(db.close);
    final runner = FakeCommandRunner({
      'flutter doctor -v': (
        exitCode: 0,
        stdout: ['[✓] Flutter (Channel stable)', 'No issues found!'],
        stderr: <String>[],
      ),
    });
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      prefs: prefs,
      paths: FakePathInspector([root]),
      commandRunner: runner,
    );
    await go(tester, 'terminal');
    expect(find.textContaining('Mode simulation actif'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('quick-flutter build appbundle --release')),
      findsOneWidget,
      reason: 'Android est une cible retenue',
    );

    expect(
      find.byKey(const ValueKey('quick-git status')),
      findsNothing,
      reason: 'pas de dépôt Git dans ce projet',
    );
    await runQuick(tester, 'flutter doctor -v');
    expect(find.text('Aperçu de la commande'), findsOneWidget);
    expect(find.text('Lecture seule'), findsOneWidget);
    expect(runner.executed, isEmpty, reason: 'rien avant la confirmation');

    await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
    await tester.pumpAndSettle();

    expect(runner.executed, ['flutter doctor -v']);
    expect(find.text('Réussie'), findsWidgets);
    expect(find.text('No issues found!'), findsOneWidget);
    expect(find.byKey(const ValueKey('history-1')), findsOneWidget);
  });

  testWidgets('mode simulation : prévisualisée, jamais lancée', (tester) async {
    final (db, prefs, _) = await openedProject(root);
    addTearDown(db.close);
    final runner = FakeCommandRunner();
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      prefs: prefs,
      paths: FakePathInspector([root]),
      commandRunner: runner,
    );
    await go(tester, 'terminal');

    await runQuick(tester, 'flutter pub get');
    expect(find.text('Fichiers générés'), findsOneWidget);
    expect(find.textContaining('seulement prévisualisée'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
    await tester.pumpAndSettle();

    expect(find.text('Simulée'), findsWidgets);
    expect(runner.executed, isEmpty);
  });

  testWidgets('simulation désactivée : la commande confirmée s\'exécute', (
    tester,
  ) async {
    final (db, prefs, _) = await openedProject(root);
    addTearDown(db.close);
    final runner = FakeCommandRunner();
    final shared = await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      prefs: prefs,
      paths: FakePathInspector([root]),
      commandRunner: runner,
    );
    await go(tester, 'terminal');
    await scrollAndTap(
      tester,
      find.byKey(const ValueKey('terminal-simulation')),
    );
    expect(shared.getBool(SettingsRepository.kSimulation), isFalse);

    await runQuick(tester, 'flutter test');
    await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
    await tester.pumpAndSettle();
    expect(runner.executed, ['flutter test']);
  });

  testWidgets(
    'commande interdite : raison affichée, aucun bouton d\'exécution',
    (tester) async {
      final (db, prefs, _) = await openedProject(root);
      addTearDown(db.close);
      final runner = FakeCommandRunner();
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        database: db,
        prefs: prefs,
        paths: FakePathInspector([root]),
        commandRunner: runner,
      );
      await go(tester, 'terminal');

      await tester.enterText(
        find.byKey(const ValueKey('terminal-custom')),
        'git push origin main',
      );
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('terminal-custom-preview')),
      );
      expect(find.text('Interdite'), findsOneWidget);
      expect(
        find.text('L\'envoi vers un dépôt distant (push) est interdit ici.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('cmd-preview-run')), findsNothing);
      await tester.tap(find.text('Fermer'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('terminal-custom')),
        'bash -c "rm -rf /"',
      );
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('terminal-custom-preview')),
      );
      expect(find.textContaining('Les shells sont interdits'), findsOneWidget);
      await tester.tap(find.text('Fermer'));
      await tester.pumpAndSettle();
      expect(runner.executed, isEmpty);

      await tester.enterText(
        find.byKey(const ValueKey('terminal-custom')),
        'git log "oups',
      );
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('terminal-custom-preview')),
      );
      expect(find.text('Guillemet non fermé.'), findsOneWidget);
    },
  );

  testWidgets('création de tag : confirmation renforcée', (tester) async {
    final (db, prefs, _) = await openedProject(root);
    addTearDown(db.close);
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      prefs: prefs,
      paths: FakePathInspector([root]),
    );
    await go(tester, 'terminal');
    await tester.enterText(
      find.byKey(const ValueKey('terminal-custom')),
      'git tag v1.2.0',
    );
    await scrollAndTap(
      tester,
      find.byKey(const ValueKey('terminal-custom-preview')),
    );
    final run = find.byKey(const ValueKey('cmd-preview-run'));
    expect(tester.widget<FilledButton>(run).onPressed, isNull);
    await tester.tap(find.byKey(const ValueKey('cmd-reinforced')));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(run).onPressed, isNotNull);
  });

  testWidgets('arrêt d\'une commande en cours', (tester) async {
    final (db, prefs, _) = await openedProject(root);
    addTearDown(db.close);
    final runner = FakeCommandRunner()..hangingCommand = 'flutter analyze';
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      prefs: prefs,
      paths: FakePathInspector([root]),
      commandRunner: runner,
    );
    await go(tester, 'terminal');
    await runQuick(tester, 'flutter analyze');
    await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
    await tester.pump();
    expect(find.text('en cours…'), findsOneWidget);

    await scrollAndTap(tester, find.byKey(const ValueKey('terminal-stop')));
    expect(find.text('Annulée'), findsWidgets);
  });

  testWidgets('le journal ne garde aucun secret', (tester) async {
    final (db, prefs, id) = await openedProject(root);
    addTearDown(db.close);
    final runner = FakeCommandRunner({
      'flutter analyze': (
        exitCode: 0,
        stdout: ['abc123 ajoute token=abcdef1234567890'],
        stderr: <String>[],
      ),
    });
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      prefs: prefs,
      paths: FakePathInspector([root]),
      commandRunner: runner,
    );
    await go(tester, 'terminal');
    await runQuick(tester, 'flutter analyze');
    await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
    await tester.pumpAndSettle();

    final log = await tester.runAsync(
      () => db.select(db.commandLogs).getSingle(),
    );
    expect(log!.projectId, id);
    expect(log.output, isNot(contains('abcdef1234567890')));
    expect(log.output, contains('[SECRET MASQUÉ]'));
  });

  group('protection du projet (dossier réel)', () {
    late Directory dir;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('lp_protect_');
      File(p.join(dir.path, '.gitignore')).writeAsStringSync('build/\n');
    });
    tearDown(() => dir.deleteSync(recursive: true));

    FakeCommandRunner gitRunner() => FakeCommandRunner({
      'git rev-parse --is-inside-work-tree': (
        exitCode: 0,
        stdout: ['true'],
        stderr: <String>[],
      ),
      gitStatusCommand: (
        exitCode: 0,
        stdout: ['## main\u0000 M lib/main.dart\u0000?? notes.md\u0000'],
        stderr: <String>[],
      ),
      'git check-ignore android/key.properties': (
        exitCode: 1,
        stdout: <String>[],
        stderr: <String>[],
      ),
    });

    testWidgets('état Git, .gitignore avec aperçu, puis restauration', (
      tester,
    ) async {
      final (db, prefs, _) = await openedProject(dir.path);
      addTearDown(db.close);
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        database: db,
        prefs: prefs,
        paths: FakePathInspector([dir.path]),
        commandRunner: gitRunner(),
      );
      await go(tester, 'publication');

      expect(find.text('Tu travailles sur la branche main.'), findsOneWidget);
      expect(find.text('2 modifications non validées'), findsOneWidget);
      expect(find.text(' M lib/main.dart'), findsOneWidget);
      expect(
        find.text(
          'Ils pourraient être versionnés par erreur : android/key.properties',
        ),
        findsOneWidget,
      );

      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('protection-gitignore')),
      );
      expect(find.text('Aperçu des modifications'), findsOneWidget);
      expect(
        find.textContaining('+ /android/key.properties', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('2 modifications non validées.'),
        findsOneWidget,
      );
      expect(
        File(p.join(dir.path, '.gitignore')).readAsStringSync(),
        'build/\n',
        reason: 'rien n\'est écrit avant la confirmation',
      );

      await tester.tap(find.byKey(const ValueKey('write-confirm')));
      await tester.pumpAndSettle();
      expect(find.text('Modifications écrites.'), findsOneWidget);
      expect(
        File(p.join(dir.path, '.gitignore')).readAsStringSync(),
        contains('/android/key.properties'),
      );
      expect(find.text('.gitignore · modifié'), findsOneWidget);

      await scrollAndTap(tester, find.byKey(const ValueKey('restore-1')));
      expect(find.text('Fichier restauré.'), findsOneWidget);
      expect(
        File(p.join(dir.path, '.gitignore')).readAsStringSync(),
        'build/\n',
      );
      expect(find.textContaining('Restauré le'), findsOneWidget);
    });

    testWidgets('restauration refusée si le fichier a été retouché', (
      tester,
    ) async {
      final (db, prefs, _) = await openedProject(dir.path);
      addTearDown(db.close);
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        database: db,
        prefs: prefs,
        paths: FakePathInspector([dir.path]),
        commandRunner: gitRunner(),
      );
      await go(tester, 'publication');
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('protection-gitignore')),
      );
      await tester.tap(find.byKey(const ValueKey('write-confirm')));
      await tester.pumpAndSettle();

      final gitignore = File(p.join(dir.path, '.gitignore'));
      gitignore.writeAsStringSync('${gitignore.readAsStringSync()}mon-ajout\n');
      await scrollAndTap(tester, find.byKey(const ValueKey('restore-1')));
      expect(find.textContaining('Restauration refusée'), findsOneWidget);
      expect(gitignore.readAsStringSync(), endsWith('mon-ajout\n'));
    });

    testWidgets('branche de version proposée et prévisualisée', (tester) async {
      final (db, prefs, _) = await openedProject(dir.path, version: '1.2.0+7');
      addTearDown(db.close);
      final runner = gitRunner();
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        database: db,
        prefs: prefs,
        paths: FakePathInspector([dir.path]),
        commandRunner: runner,
      );
      await go(tester, 'publication');
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('protection-branch')),
      );
      expect(
        find.textContaining('git switch -c launchpilot/release-1.2.0-7'),
        findsOneWidget,
      );
      expect(find.text('Modifie le projet'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
      await tester.pumpAndSettle();
      expect(
        runner.executed.where((c) => c.startsWith('git switch')),
        isEmpty,
        reason: 'mode simulation',
      );
    });
  });
}
