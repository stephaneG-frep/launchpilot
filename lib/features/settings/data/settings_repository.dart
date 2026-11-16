import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/explanation_level.dart';
import '../../../core/domain/hosting.dart';
import '../../llm/domain/llm_provider_id.dart';
import '../domain/app_settings.dart';

/// Lit et écrit les préférences simples dans SharedPreferences.
/// Une valeur inconnue ou corrompue retombe sur la valeur par défaut.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const kTheme = 'lp.theme';
  static const kLanguage = 'lp.language';
  static const kExplanationLevel = 'lp.explanationLevel';
  static const kLlmProvider = 'lp.llmProvider';
  static const kTextSize = 'lp.textSize';
  static const kAnimations = 'lp.animations';
  static const kDemoMode = 'lp.demoMode';
  static const kSimulation = 'lp.simulation';
  static const kPreferredHost = 'lp.preferredHost';
  static const kAnalytics = 'lp.analytics';

  AppSettings load() {
    const defaults = AppSettings();
    return AppSettings(
      themePreference: _enum(
        ThemePreference.values,
        kTheme,
        defaults.themePreference,
      ),
      language: _enum(AppLanguage.values, kLanguage, defaults.language),
      explanationLevel: _enum(
        ExplanationLevel.values,
        kExplanationLevel,
        defaults.explanationLevel,
      ),
      llmProvider: _enum(
        LlmProviderId.values,
        kLlmProvider,
        defaults.llmProvider,
      ),
      textSize: _enum(TextSizePreference.values, kTextSize, defaults.textSize),
      animationsEnabled:
          _prefs.getBool(kAnimations) ?? defaults.animationsEnabled,
      demoMode: _prefs.getBool(kDemoMode) ?? defaults.demoMode,
      simulationMode: _prefs.getBool(kSimulation) ?? defaults.simulationMode,
      preferredHost: HostingProvider.values
          .where((h) => h.name == _prefs.getString(kPreferredHost))
          .firstOrNull,
      analytics: _enum(AnalyticsTool.values, kAnalytics, defaults.analytics),
    );
  }

  Future<void> save(AppSettings settings) async {
    await Future.wait([
      _prefs.setString(kTheme, settings.themePreference.name),
      _prefs.setString(kLanguage, settings.language.name),
      _prefs.setString(kExplanationLevel, settings.explanationLevel.name),
      _prefs.setString(kLlmProvider, settings.llmProvider.name),
      _prefs.setString(kTextSize, settings.textSize.name),
      _prefs.setBool(kAnimations, settings.animationsEnabled),
      _prefs.setBool(kDemoMode, settings.demoMode),
      _prefs.setBool(kSimulation, settings.simulationMode),
      if (settings.preferredHost case final host?)
        _prefs.setString(kPreferredHost, host.name)
      else
        _prefs.remove(kPreferredHost),
      _prefs.setString(kAnalytics, settings.analytics.name),
    ]);
  }

  T _enum<T extends Enum>(List<T> values, String key, T fallback) {
    final raw = _prefs.getString(key);
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return fallback;
  }
}
