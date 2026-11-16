import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/domain/explanation_level.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/application/settings_controller.dart';
import '../features/settings/domain/app_settings.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

class LaunchPilotApp extends ConsumerWidget {
  const LaunchPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final router = ref.watch(routerProvider);
    final dense = settings.explanationLevel == ExplanationLevel.expert;

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(brightness: Brightness.light, dense: dense),
      darkTheme: AppTheme.build(brightness: Brightness.dark, dense: dense),
      themeMode: switch (settings.themePreference) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.dark => ThemeMode.dark,
        ThemePreference.light => ThemeMode.light,
      },
      themeAnimationDuration: settings.animationsEnabled
          ? const Duration(milliseconds: 200)
          : Duration.zero,
      locale: settings.language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      // Taille du texte et animations s'appliquent à toute l'application.
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final systemScale = media.textScaler.scale(1);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(
              systemScale * settings.textSize.scale,
            ),
            disableAnimations:
                media.disableAnimations || !settings.animationsEnabled,
          ),
          child: child!,
        );
      },
    );
  }
}
