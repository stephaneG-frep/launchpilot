import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/database/app_database.dart';
import 'package:launchpilot/features/projects/application/project_providers.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';
import 'package:launchpilot/features/settings/data/settings_repository.dart';

import '../support/test_harness.dart';

const meteo = '/home/testeur/projets/meteo';
const site = '/home/testeur/projets/site';

Future<void> go(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(ValueKey('nav-$name')));
  await tester.pumpAndSettle();
}

Future<void> addProject(WidgetTester tester, String path) async {
  await go(tester, 'home');
  await scrollAndTap(tester, find.byKey(const ValueKey('home-add-project')));
  await tester.enterText(find.byKey(const ValueKey('add-project-path')), path);
  await tester.tap(find.byKey(const ValueKey('dialog-confirm')));
  await tester.pumpAndSettle();
}

Future<void> startSession(WidgetTester tester, String version) async {
  await go(tester, 'publication');
  await scrollAndTap(tester, find.byKey(const ValueKey('board-new-session')));
  await tester.enterText(
    find.byKey(const ValueKey('new-session-version')),
    version,
  );
  await tester.tap(find.byKey(const ValueKey('dialog-confirm')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ajout d\'un projet : erreurs claires puis ouverture', (
    tester,
  ) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      paths: FakePathInspector([meteo]),
    );
    expect(find.text('Aucun projet pour l\'instant'), findsOneWidget);

    await scrollAndTap(tester, find.byKey(const ValueKey('home-add-project')));
    final field = find.byKey(const ValueKey('add-project-path'));
    final confirm = find.byKey(const ValueKey('dialog-confirm'));

    await tester.enterText(field, 'projets/meteo');
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(
      find.text('Indique un chemin complet, commençant par / ou ~.'),
      findsOneWidget,
    );

    await tester.enterText(field, '~/projets/inconnu');
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(
      find.text('Ce dossier n\'existe pas ou n\'est pas accessible.'),
      findsOneWidget,
    );

    await tester.enterText(field, '~/projets/meteo');
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(find.text('Projet « meteo » ajouté.'), findsOneWidget);
    // Redirigé vers la détection : l'analyse attend l'accord de l'utilisateur.
    expect(find.text('Rapport de détection'), findsOneWidget);
    expect(find.text('meteo'), findsOneWidget);
    expect(find.text('Ce projet n\'a pas encore été analysé.'), findsOneWidget);

    await go(tester, 'publication');
    expect(find.text('Aucune session en cours pour ce projet'), findsOneWidget);

    await go(tester, 'home');
    expect(find.text(meteo), findsOneWidget);
  });

  testWidgets('session : validation, reprise et survie au redémarrage', (
    tester,
  ) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final paths = FakePathInspector([meteo]);
    final prefs = await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      paths: paths,
    );
    await addProject(tester, meteo);

    await startSession(tester, 'version finale');
    expect(find.textContaining('sans espace'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('new-session-version')),
      '1.3.0+14',
    );
    await tester.tap(find.byKey(const ValueKey('dialog-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Session 1.3.0+14 démarrée.'), findsOneWidget);
    expect(find.text('meteo · 1.3.0+14'), findsOneWidget);
    expect(
      find.textContaining('rapport de détection et des cibles'),
      findsOneWidget,
    );

    // Redémarrage : l'arbre est démonté, puis relancé avec les mêmes
    // données et préférences.
    await tester.pumpWidget(const SizedBox());
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      paths: paths,
      prefs: {for (final k in prefs.getKeys()) k: prefs.get(k)!},
    );
    expect(find.text('meteo · 1.3.0+14'), findsOneWidget);
    expect(find.text('Reprendre'), findsOneWidget);

    await go(tester, 'publication');
    expect(find.text('meteo · 1.3.0+14'), findsOneWidget);
    expect(prefs.getInt(CurrentProjectController.prefsKey), isNotNull);
  });

  testWidgets('clore une session après confirmation', (tester) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      paths: FakePathInspector([meteo]),
    );
    await addProject(tester, meteo);
    await startSession(tester, '2.0.0');

    await scrollAndTap(
      tester,
      find.byKey(const ValueKey('board-close-session')),
    );
    expect(find.text('Clore la session 2.0.0 ?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('close-session-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Session close.'), findsOneWidget);
    expect(find.text('Aucune session en cours pour ce projet'), findsOneWidget);
    await go(tester, 'home');
    expect(find.text('Aucune session en cours'), findsOneWidget);
  });

  testWidgets('favoris et filtre', (tester) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      paths: FakePathInspector([meteo, site]),
    );
    await addProject(tester, meteo);
    await addProject(tester, site);
    await go(tester, 'home');

    await tester.tap(find.byTooltip('Ajouter aux favoris').last);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Retirer des favoris'), findsOneWidget);

    await scrollAndTap(tester, find.text('Favoris'));
    expect(find.text(meteo), findsOneWidget);
    expect(find.text(site), findsNothing);
  });

  testWidgets('dossier déplacé : signalé puis relocalisé', (tester) async {
    final paths = FakePathInspector([meteo]);
    final db = memoryDatabase();
    addTearDown(db.close);
    await db
        .into(db.projects)
        .insert(
          ProjectsCompanion.insert(
            name: 'meteo',
            path: '/home/testeur/ancien/meteo',
            createdAt: DateTime(2026),
            lastOpenedAt: DateTime(2026),
          ),
        );
    await pumpLaunchPilot(tester, size: tallScreen, database: db, paths: paths);

    expect(find.text('Dossier introuvable'), findsOneWidget);
    await scrollAndTap(tester, find.byKey(const ValueKey('relocate-1')));
    await tester.enterText(find.byKey(const ValueKey('relocate-path')), meteo);
    await tester.tap(find.byKey(const ValueKey('dialog-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Nouveau chemin enregistré.'), findsOneWidget);
    expect(find.text('Dossier introuvable'), findsNothing);
    expect(find.text(meteo), findsOneWidget);
  });

  testWidgets('retrait d\'un projet : impact annoncé, confirmation', (
    tester,
  ) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      paths: FakePathInspector([meteo]),
    );
    await addProject(tester, meteo);
    await startSession(tester, '1.0.0');
    await go(tester, 'home');

    await scrollAndTap(tester, find.byTooltip('Actions du projet'));
    await tester.tap(find.text('Retirer de la liste').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('1 session et aucune étape'), findsOneWidget);
    expect(find.textContaining('ne sont pas touchés'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.text(meteo), findsOneWidget);

    await scrollAndTap(tester, find.byTooltip('Actions du projet'));
    await tester.tap(find.text('Retirer de la liste').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('remove-project-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Projet retiré de la liste.'), findsOneWidget);
    expect(find.text('Aucun projet pour l\'instant'), findsOneWidget);
    await go(tester, 'publication');
    expect(find.text('Aucun projet ouvert'), findsOneWidget);
  });

  testWidgets('effacement des données locales : mot de confirmation exigé', (
    tester,
  ) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      paths: FakePathInspector([meteo, site]),
    );
    await addProject(tester, meteo);
    await addProject(tester, site);
    await go(tester, 'settings');

    expect(find.textContaining('/tmp/test.sqlite'), findsOneWidget);
    await scrollAndTap(tester, find.byKey(const ValueKey('clear-local-data')));
    final confirm = find.byKey(const ValueKey('clear-data-confirm'));
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('clear-data-word')),
      'effacer',
    );
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('clear-data-word')),
      'EFFACER',
    );
    await tester.pumpAndSettle();
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(find.text('Données locales effacées.'), findsOneWidget);
    final clear = find.byKey(const ValueKey('clear-local-data'));
    expect(tester.widget<OutlinedButton>(clear).onPressed, isNull);
    await go(tester, 'home');
    expect(find.text('Aucun projet pour l\'instant'), findsOneWidget);
  });

  for (final lang in ['fr', 'en']) {
    testWidgets('aucun débordement en fenêtre étroite ($lang)', (tester) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final repo = ProjectRepository(db, FakePathInspector([meteo]));
      final added = await repo.addProject(
        meteo,
        name: 'Un nom de projet assez long pour déborder',
      );
      await repo.startSession(added.project.id, '10.20.30+400');
      await db
          .into(db.projects)
          .insert(
            ProjectsCompanion.insert(
              name: 'disparu',
              path: '/home/testeur/un/chemin/tres/long/qui/a/disparu/du/disque',
              createdAt: DateTime(2026),
              lastOpenedAt: DateTime(2026),
            ),
          );
      await pumpLaunchPilot(
        tester,
        size: narrowScreen,
        database: db,
        paths: FakePathInspector([meteo]),
        prefs: {
          SettingsRepository.kTextSize: 'extraLarge',
          SettingsRepository.kLanguage: lang,
          CurrentProjectController.prefsKey: added.project.id,
        },
      );
      final menu = lang == 'fr'
          ? 'Ouvrir le menu de navigation'
          : 'Open navigation menu';
      for (final screen in ['home', 'publication', 'settings']) {
        await tester.tap(find.byTooltip(menu));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey('nav-$screen')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: screen);
      }
    });
  }

  testWidgets('le mode démo ne touche pas aux données réelles', (tester) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      paths: FakePathInspector([meteo]),
    );
    await addProject(tester, meteo);
    await go(tester, 'home');

    await scrollAndTap(tester, find.byKey(const ValueKey('home-try-demo')));
    expect(find.text(meteo), findsNothing);
    expect(find.byKey(const ValueKey('home-add-project')), findsNothing);

    await scrollAndTap(tester, find.text('Quitter le mode démo'));
    expect(find.text(meteo), findsOneWidget);
  });
}
