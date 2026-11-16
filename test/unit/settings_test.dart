import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/domain/explanation_level.dart';
import 'package:launchpilot/features/llm/domain/llm_provider_id.dart';
import 'package:launchpilot/features/settings/application/settings_controller.dart';
import 'package:launchpilot/features/settings/data/settings_repository.dart';
import 'package:launchpilot/features/settings/domain/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('SettingsRepository', () {
    test('retourne les valeurs par défaut sur un stockage vide', () async {
      final repo = SettingsRepository(await prefsWith({}));
      final s = repo.load();
      expect(s, const AppSettings());
      expect(s.themePreference, ThemePreference.dark);
      expect(s.language, AppLanguage.fr);
      expect(s.explanationLevel, ExplanationLevel.beginner);
      expect(s.demoMode, isFalse);
    });

    test('enregistre puis relit toutes les préférences', () async {
      final prefs = await prefsWith({});
      const custom = AppSettings(
        themePreference: ThemePreference.light,
        language: AppLanguage.en,
        explanationLevel: ExplanationLevel.expert,
        llmProvider: LlmProviderId.mistral,
        textSize: TextSizePreference.extraLarge,
        animationsEnabled: false,
        demoMode: true,
        simulationMode: false,
      );
      await SettingsRepository(prefs).save(custom);
      expect(SettingsRepository(prefs).load(), custom);
    });

    test('ignore une valeur inconnue ou corrompue', () async {
      final repo = SettingsRepository(
        await prefsWith({
          SettingsRepository.kTheme: 'violet-fluo',
          SettingsRepository.kLanguage: 'klingon',
          SettingsRepository.kExplanationLevel: 'guided',
        }),
      );
      final s = repo.load();
      expect(s.themePreference, ThemePreference.dark);
      expect(s.language, AppLanguage.fr);
      expect(s.explanationLevel, ExplanationLevel.guided);
    });
  });

  group('SettingsController', () {
    test('met à jour l\'état et persiste immédiatement', () async {
      final prefs = await prefsWith({});
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final controller = container.read(settingsControllerProvider.notifier);

      await controller.setThemePreference(ThemePreference.light);
      await controller.setExplanationLevel(ExplanationLevel.expert);
      await controller.setLlmProvider(LlmProviderId.gemini);
      await controller.setDemoMode(true);

      final state = container.read(settingsControllerProvider);
      expect(state.themePreference, ThemePreference.light);
      expect(state.explanationLevel, ExplanationLevel.expert);
      expect(container.read(demoModeProvider), isTrue);
      expect(prefs.getString(SettingsRepository.kTheme), 'light');
      expect(prefs.getString(SettingsRepository.kLlmProvider), 'gemini');
      expect(prefs.getBool(SettingsRepository.kDemoMode), isTrue);
    });

    test('aucune clé API ne transite par les préférences', () async {
      final prefs = await prefsWith({});
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      await container
          .read(settingsControllerProvider.notifier)
          .setLlmProvider(LlmProviderId.openai);
      for (final key in prefs.getKeys()) {
        expect(key.toLowerCase(), isNot(contains('key')));
        expect(key.toLowerCase(), isNot(contains('secret')));
      }
    });
  });
}
