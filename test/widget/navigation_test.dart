import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/app/destinations.dart';
import 'package:launchpilot/core/widgets/later_phase_button.dart';
import 'package:launchpilot/features/settings/data/settings_repository.dart';

import '../support/test_harness.dart';

/// Titre de chaque écran en français.
const titles = {
  AppDestination.home: 'Bienvenue dans LaunchPilot',
  AppDestination.detection: 'Rapport de détection',
  AppDestination.publication: 'Tableau de publication',
  AppDestination.checklist: 'Checklist pédagogique',
  AppDestination.terminal: 'Terminal intégré',
  AppDestination.agent: 'Agent LaunchPilot',
  AppDestination.content: 'Contenus et aperçus',
  AppDestination.reports: 'Rapports et historique',
  AppDestination.settings: 'Paramètres',
  AppDestination.help: 'Aide et lexique',
};

void main() {
  testWidgets('démarre en français sur l\'accueil', (tester) async {
    await pumpLaunchPilot(tester);
    expect(find.text('Bienvenue dans LaunchPilot'), findsOneWidget);
    expect(find.text('Aucun projet pour l\'instant'), findsOneWidget);
    expect(find.text('Mode démo — '), findsNothing);
  });

  testWidgets('la barre latérale mène aux dix écrans', (tester) async {
    await pumpLaunchPilot(tester);
    for (final d in AppDestination.values) {
      await tester.tap(find.byKey(ValueKey('nav-${d.name}')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(Semantics),
          matching: find.text(titles[d]!),
        ),
        findsWidgets,
        reason: d.name,
      );
    }
  });

  testWidgets('fenêtre étroite : navigation par tiroir', (tester) async {
    await pumpLaunchPilot(tester, size: narrowScreen);
    expect(find.byKey(const ValueKey('nav-home')), findsNothing);

    await tester.tap(find.byTooltip('Ouvrir le menu de navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-help')));
    await tester.pumpAndSettle();

    expect(find.text('Aide et lexique'), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
  });

  for (final (lang, menu) in [
    ('fr', 'Ouvrir le menu de navigation'),
    ('en', 'Open navigation menu'),
  ]) {
    testWidgets(
      'aucun débordement : fenêtre étroite, démo, texte très grand ($lang)',
      (tester) async {
        await pumpLaunchPilot(
          tester,
          size: narrowScreen,
          prefs: {
            SettingsRepository.kDemoMode: true,
            SettingsRepository.kTextSize: 'extraLarge',
            SettingsRepository.kLanguage: lang,
          },
        );
        for (final d in AppDestination.values) {
          await tester.tap(find.byTooltip(menu));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(ValueKey('nav-${d.name}')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: d.name);
        }
      },
    );
  }

  testWidgets('largeur intermédiaire : barre compacte à icônes', (
    tester,
  ) async {
    await pumpLaunchPilot(tester, size: const Size(900, 900));
    expect(find.byKey(const ValueKey('nav-home')), findsOneWidget);
    // Les libellés sont dans les infobulles, pas affichés en permanence.
    expect(find.text('Détection'), findsNothing);
  });

  testWidgets('raccourcis Ctrl+chiffre, y compris le pavé numérique', (
    tester,
  ) async {
    await pumpLaunchPilot(tester);

    Future<void> ctrl(
      PhysicalKeyboardKey physical,
      LogicalKeyboardKey logical,
    ) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(logical, physicalKey: physical);
      await tester.sendKeyUpEvent(logical, physicalKey: physical);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
    }

    // En AZERTY, la touche « 2 » produit « é » : seule la position compte.
    // Le simulateur ne connaît pas « é », une autre touche logique suffit.
    await ctrl(PhysicalKeyboardKey.digit2, LogicalKeyboardKey.keyE);
    expect(find.text('Rapport de détection'), findsOneWidget);

    await ctrl(PhysicalKeyboardKey.digit0, LogicalKeyboardKey.digit0);
    expect(find.text('Aide et lexique'), findsOneWidget);

    await ctrl(PhysicalKeyboardKey.numpad9, LogicalKeyboardKey.numpad9);
    expect(find.text('Paramètres'), findsWidgets);
  });

  testWidgets('version complète : plus aucun bouton « phase ultérieure »', (
    tester,
  ) async {
    await pumpLaunchPilot(tester);
    for (final d in AppDestination.values) {
      await tester.tap(find.byKey(ValueKey('nav-${d.name}')));
      await tester.pumpAndSettle();
      expect(find.byType(LaterPhaseButton), findsNothing, reason: d.name);
      expect(
        find.textContaining(RegExp(r'^Phase \d+$')),
        findsNothing,
        reason: d.name,
      );
    }
  });

  testWidgets('écrans vides honnêtes sans mode démo', (tester) async {
    await pumpLaunchPilot(tester);
    final expected = {
      AppDestination.detection: 'Aucun projet ouvert',
      AppDestination.checklist: 'Aucun projet ouvert',
      AppDestination.terminal: 'Aucun projet ouvert',
      AppDestination.agent: 'Aucune clé API pour le fournisseur choisi',
      AppDestination.reports: 'Aucun rapport',
      AppDestination.content: 'Aucun projet ouvert',
    };
    for (final entry in expected.entries) {
      await tester.tap(find.byKey(ValueKey('nav-${entry.key.name}')));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget, reason: entry.key.name);
      expect(find.text('DÉMO'), findsNothing);
    }
  });

  testWidgets('respecte la langue anglaise enregistrée', (tester) async {
    await pumpLaunchPilot(tester, prefs: {SettingsRepository.kLanguage: 'en'});
    expect(find.text('Welcome to LaunchPilot'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
