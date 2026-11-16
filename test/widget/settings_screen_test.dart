import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/features/llm/domain/llm_provider_id.dart';
import 'package:launchpilot/features/settings/data/api_key_repository.dart';
import 'package:launchpilot/features/settings/data/settings_repository.dart';

import '../support/test_harness.dart';

const fakeKey = 'sk-test-0000000000000000000000000000';

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('nav-settings')));
  await tester.pumpAndSettle();
}

MaterialApp materialApp(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp));

void main() {
  testWidgets('thème : sombre par défaut, passage au clair persistant', (
    tester,
  ) async {
    final prefs = await pumpLaunchPilot(tester, size: tallScreen);
    expect(materialApp(tester).themeMode, ThemeMode.dark);

    await openSettings(tester);
    await scrollAndTap(tester, find.text('Clair'));

    expect(materialApp(tester).themeMode, ThemeMode.light);
    expect(prefs.getString(SettingsRepository.kTheme), 'light');
  });

  testWidgets('langue : bascule immédiate en anglais', (tester) async {
    final prefs = await pumpLaunchPilot(tester, size: tallScreen);
    await openSettings(tester);

    await scrollAndTap(tester, find.text('English'));

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Guidance mode'), findsOneWidget);
    expect(prefs.getString(SettingsRepository.kLanguage), 'en');
  });

  testWidgets('mode d\'accompagnement, taille du texte, animations', (
    tester,
  ) async {
    final prefs = await pumpLaunchPilot(tester, size: tallScreen);
    await openSettings(tester);

    await scrollAndTap(tester, find.byKey(const ValueKey('mode-expert')));
    expect(prefs.getString(SettingsRepository.kExplanationLevel), 'expert');
    expect(materialApp(tester).theme!.visualDensity, VisualDensity.compact);

    await scrollAndTap(tester, find.text('Grande'));
    expect(prefs.getString(SettingsRepository.kTextSize), 'large');

    await scrollAndTap(tester, find.text('Animations'));
    expect(prefs.getBool(SettingsRepository.kAnimations), isFalse);
  });

  testWidgets('fournisseur LLM préféré', (tester) async {
    final prefs = await pumpLaunchPilot(tester, size: tallScreen);
    await openSettings(tester);

    await scrollAndTap(tester, find.byKey(const ValueKey('provider-mistral')));

    expect(prefs.getString(SettingsRepository.kLlmProvider), 'mistral');
    final chip = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('provider-mistral')),
    );
    expect(chip.selected, isTrue);
  });

  group('clés API', () {
    final field = find.byKey(const ValueKey('api-key-field-anthropic'));
    final save = find.byKey(const ValueKey('api-key-save-anthropic'));

    testWidgets('refuse une saisie invalide sans rien écrire', (tester) async {
      final store = InMemorySecretStore();
      await pumpLaunchPilot(tester, size: tallScreen, secretStore: store);
      await openSettings(tester);

      await scrollAndTap(tester, save);
      expect(find.text('Saisis une clé avant d\'enregistrer.'), findsOneWidget);

      await tester.enterText(field, 'sk-court');
      await scrollAndTap(tester, save);
      expect(find.text('Cette clé semble trop courte.'), findsOneWidget);
      expect(store.values, isEmpty);
    });

    testWidgets('enregistre, masque, vide le champ et ne réaffiche jamais', (
      tester,
    ) async {
      final store = InMemorySecretStore();
      final prefs = await pumpLaunchPilot(
        tester,
        size: tallScreen,
        secretStore: store,
      );
      await openSettings(tester);

      final textField = tester.widget<TextField>(field);
      expect(textField.obscureText, isTrue);
      expect(textField.enableSuggestions, isFalse);

      await tester.enterText(field, '  $fakeKey  ');
      await scrollAndTap(tester, save);

      expect(
        store.values[ApiKeyRepository.storageKeyFor(LlmProviderId.anthropic)],
        fakeKey,
      );
      expect(find.text('Clé enregistrée'), findsOneWidget);
      expect(
        find.text('Clé Anthropic Claude enregistrée dans le trousseau.'),
        findsOneWidget,
      );
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
      expect(find.textContaining(fakeKey), findsNothing);
      // Rien dans les préférences ne contient la clé.
      for (final k in prefs.getKeys()) {
        expect(prefs.get(k).toString(), isNot(contains(fakeKey)));
      }
    });

    testWidgets('suppression après confirmation seulement', (tester) async {
      final store = InMemorySecretStore()
        ..values[ApiKeyRepository.storageKeyFor(LlmProviderId.anthropic)] =
            fakeKey;
      await pumpLaunchPilot(tester, size: tallScreen, secretStore: store);
      await openSettings(tester);
      final delete = find.byKey(const ValueKey('api-key-delete-anthropic'));

      await scrollAndTap(tester, delete);
      expect(find.text('Supprimer la clé Anthropic Claude ?'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(store.values, isNotEmpty);

      await scrollAndTap(tester, delete);
      await tester.tap(find.byKey(const ValueKey('api-key-delete-confirm')));
      await tester.pumpAndSettle();

      expect(store.values, isEmpty);
      expect(find.text('Clé Anthropic Claude supprimée.'), findsOneWidget);
      expect(delete, findsNothing);
    });

    testWidgets('trousseau indisponible : message clair, saisie bloquée', (
      tester,
    ) async {
      final store = InMemorySecretStore()..failing = true;
      await pumpLaunchPilot(tester, size: tallScreen, secretStore: store);
      await openSettings(tester);

      expect(
        find.textContaining('trousseau du système est verrouillé ou indisponible'),
        findsWidgets,
      );
      expect(tester.widget<TextField>(field).enabled, isFalse);
    });
  });
}
