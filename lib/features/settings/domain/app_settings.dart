import 'package:flutter/widgets.dart';

import '../../../core/domain/explanation_level.dart';
import '../../../core/domain/hosting.dart';
import '../../llm/domain/llm_provider_id.dart';

enum ThemePreference { system, dark, light }

enum AppLanguage {
  fr,
  en;

  Locale get locale => Locale(name);
}

enum TextSizePreference {
  normal(1.0),
  large(1.15),
  extraLarge(1.3);

  const TextSizePreference(this.scale);
  final double scale;
}

/// Préférences simples de l'application. Aucune donnée sensible ici :
/// les clés API vivent uniquement dans le trousseau du système.
@immutable
class AppSettings {
  const AppSettings({
    this.themePreference = ThemePreference.dark,
    this.language = AppLanguage.fr,
    this.explanationLevel = ExplanationLevel.beginner,
    this.llmProvider = LlmProviderId.anthropic,
    this.textSize = TextSizePreference.normal,
    this.animationsEnabled = true,
    this.demoMode = false,
    this.simulationMode = true,
    this.preferredHost,
    this.analytics = AnalyticsTool.none,
  });

  final ThemePreference themePreference;
  final AppLanguage language;
  final ExplanationLevel explanationLevel;
  final LlmProviderId llmProvider;
  final TextSizePreference textSize;
  final bool animationsEnabled;
  final bool demoMode;

  /// Seules les commandes en lecture seule s'exécutent ; les autres sont
  /// prévisualisées. Activé par défaut.
  final bool simulationMode;

  /// Hébergeur proposé en premier pour les sites web (aucun par défaut).
  final HostingProvider? preferredHost;

  /// Outil de statistiques proposé pour les sites web.
  final AnalyticsTool analytics;

  AppSettings copyWith({
    ThemePreference? themePreference,
    AppLanguage? language,
    ExplanationLevel? explanationLevel,
    LlmProviderId? llmProvider,
    TextSizePreference? textSize,
    bool? animationsEnabled,
    bool? demoMode,
    bool? simulationMode,
    HostingProvider? preferredHost,
    bool clearPreferredHost = false,
    AnalyticsTool? analytics,
  }) {
    return AppSettings(
      themePreference: themePreference ?? this.themePreference,
      language: language ?? this.language,
      explanationLevel: explanationLevel ?? this.explanationLevel,
      llmProvider: llmProvider ?? this.llmProvider,
      textSize: textSize ?? this.textSize,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      demoMode: demoMode ?? this.demoMode,
      simulationMode: simulationMode ?? this.simulationMode,
      preferredHost: clearPreferredHost
          ? null
          : preferredHost ?? this.preferredHost,
      analytics: analytics ?? this.analytics,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themePreference == themePreference &&
      other.language == language &&
      other.explanationLevel == explanationLevel &&
      other.llmProvider == llmProvider &&
      other.textSize == textSize &&
      other.animationsEnabled == animationsEnabled &&
      other.demoMode == demoMode &&
      other.simulationMode == simulationMode &&
      other.preferredHost == preferredHost &&
      other.analytics == analytics;

  @override
  int get hashCode => Object.hash(
    themePreference,
    language,
    explanationLevel,
    llmProvider,
    textSize,
    animationsEnabled,
    demoMode,
    simulationMode,
    preferredHost,
    analytics,
  );
}
