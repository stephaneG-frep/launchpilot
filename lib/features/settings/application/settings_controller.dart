import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/explanation_level.dart';
import '../../../core/domain/hosting.dart';
import '../../llm/domain/llm_provider_id.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

/// Surchargé dans `main()` (et dans les tests) avec une instance chargée.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider non surchargé'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

final demoModeProvider = Provider<bool>(
  (ref) => ref.watch(settingsControllerProvider.select((s) => s.demoMode)),
);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> setThemePreference(ThemePreference value) =>
      _update(state.copyWith(themePreference: value));

  Future<void> setLanguage(AppLanguage value) =>
      _update(state.copyWith(language: value));

  Future<void> setExplanationLevel(ExplanationLevel value) =>
      _update(state.copyWith(explanationLevel: value));

  Future<void> setLlmProvider(LlmProviderId value) =>
      _update(state.copyWith(llmProvider: value));

  Future<void> setTextSize(TextSizePreference value) =>
      _update(state.copyWith(textSize: value));

  Future<void> setAnimationsEnabled(bool value) =>
      _update(state.copyWith(animationsEnabled: value));

  Future<void> setDemoMode(bool value) =>
      _update(state.copyWith(demoMode: value));

  Future<void> setSimulationMode(bool value) =>
      _update(state.copyWith(simulationMode: value));

  Future<void> setPreferredHost(HostingProvider? value) => _update(
    state.copyWith(preferredHost: value, clearPreferredHost: value == null),
  );

  Future<void> setAnalytics(AnalyticsTool value) =>
      _update(state.copyWith(analytics: value));

  Future<void> _update(AppSettings next) async {
    if (next == state) return;
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }
}
