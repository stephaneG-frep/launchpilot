import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/features/settings/data/settings_repository.dart';

import '../support/test_harness.dart';

Future<void> go(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(ValueKey('nav-$name')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('activation depuis l\'accueil : bannière et données signalées', (
    tester,
  ) async {
    final prefs = await pumpLaunchPilot(tester, size: tallScreen);

    await scrollAndTap(tester, find.byKey(const ValueKey('home-try-demo')));

    expect(prefs.getBool(SettingsRepository.kDemoMode), isTrue);
    expect(find.textContaining('Données fictives'), findsOneWidget);
    expect(find.text('MétéoPlus (démo)'), findsOneWidget);
    expect(find.text('DÉMO'), findsWidgets);
  });

  testWidgets('quitter le mode démo depuis la bannière', (tester) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      prefs: {SettingsRepository.kDemoMode: true},
    );
    await scrollAndTap(tester, find.text('Quitter le mode démo'));

    expect(find.text('MétéoPlus (démo)'), findsNothing);
    expect(find.text('Aucun projet pour l\'instant'), findsOneWidget);
  });

  testWidgets('la checklist s\'adapte au mode d\'accompagnement', (
    tester,
  ) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      prefs: {SettingsRepository.kDemoMode: true},
    );
    await go(tester, 'checklist');

    // Débutant : objectif visible, vérification sur demande.
    expect(
      find.text('Savoir si des modifications ne sont pas encore validées.'),
      findsOneWidget,
    );
    await scrollAndTap(tester, find.byTooltip('Afficher les détails').first);
    expect(find.text('Explication'), findsOneWidget);
    expect(find.text('Comment vérifier'), findsNothing);
    await scrollAndTap(tester, find.text('Montre-moi comment vérifier'));
    expect(find.text('Comment vérifier'), findsOneWidget);
    expect(
      find.textContaining('# Liste les fichiers modifiés'),
      findsOneWidget,
    );

    // Expert : commande en tête, plus d'explication longue ni d'objectif.
    await scrollAndTap(tester, find.text('Expert'));
    expect(
      find.text('Savoir si des modifications ne sont pas encore validées.'),
      findsNothing,
    );
    expect(find.text('Explication'), findsNothing);
    expect(find.text('Comment vérifier'), findsOneWidget);
    expect(find.textContaining('git status --porcelain'), findsWidgets);
  });

  testWidgets('terminal simulé : filtre stderr et copie', (tester) async {
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      prefs: {SettingsRepository.kDemoMode: true},
    );
    await go(tester, 'terminal');
    expect(find.text('Sortie simulée'), findsOneWidget);
    expect(
      find.textContaining('3 issues found', findRichText: true),
      findsOneWidget,
    );

    await scrollAndTap(tester, find.text('stderr'));
    expect(
      find.textContaining('3 issues found', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('Undefined name', findRichText: true),
      findsOneWidget,
    );

    await scrollAndTap(tester, find.text('Copier la sortie'));
    expect(clipboard, startsWith(r'$ flutter analyze'));
    expect(clipboard, isNot(contains('3 issues found')));
  });

  testWidgets('tableau de publication : quatre niveaux et avertissement', (
    tester,
  ) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      prefs: {SettingsRepository.kDemoMode: true},
    );
    await go(tester, 'publication');

    for (final label in [
      '1. Analyser',
      '2. Préparer',
      '3. Construire',
      '4. Publier',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(
      find.text(
        'La publication n\'est jamais déclenchée automatiquement après un build.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('lexique : recherche fonctionnelle', (tester) async {
    await pumpLaunchPilot(tester, size: tallScreen);
    await go(tester, 'help');

    await tester.enterText(
      find.byKey(const ValueKey('glossary-search')),
      'keystore',
    );
    await tester.pumpAndSettle();
    expect(find.text('Keystore'), findsOneWidget);
    expect(find.text('PWA'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('glossary-search')),
      'zzzz',
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Aucun terme ne correspond à ta recherche.'),
      findsOneWidget,
    );
  });
}
