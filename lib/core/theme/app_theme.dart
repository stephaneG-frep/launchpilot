import 'package:flutter/material.dart';

import 'launch_palette.dart';

abstract final class AppTheme {
  static const radius = 18.0;

  /// [dense] est activé en mode Expert pour une interface plus compacte.
  static ThemeData build({required Brightness brightness, bool dense = false}) {
    final isDark = brightness == Brightness.dark;
    final palette = isDark ? LaunchPalette.dark : LaunchPalette.light;

    final scheme =
        ColorScheme.fromSeed(
          seedColor: BrandColors.indigo,
          brightness: brightness,
        ).copyWith(
          primary: isDark ? const Color(0xFF8C98FF) : BrandColors.indigoDeep,
          onPrimary: isDark ? BrandColors.midnight : Colors.white,
          primaryContainer: isDark
              ? const Color(0xFF2A3380)
              : const Color(0xFFDDE1FF),
          onPrimaryContainer: isDark
              ? const Color(0xFFE0E3FF)
              : const Color(0xFF111A6B),
          secondary: isDark ? BrandColors.turquoise : BrandColors.turquoiseDeep,
          onSecondary: isDark ? const Color(0xFF042F2A) : Colors.white,
          tertiary: isDark ? const Color(0xFFC4B5FD) : BrandColors.violetDeep,
          onTertiary: isDark ? const Color(0xFF2E1065) : Colors.white,
          error: isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
          surface: isDark ? const Color(0xFF0F1530) : const Color(0xFFF6F7FD),
          onSurface: isDark ? const Color(0xFFE6E9F5) : const Color(0xFF141833),
          onSurfaceVariant: isDark
              ? const Color(0xFFAEB5D6)
              : const Color(0xFF4A5070),
          surfaceContainerLowest: isDark
              ? BrandColors.midnightDeep
              : Colors.white,
          surfaceContainerLow: isDark
              ? const Color(0xFF141B3B)
              : const Color(0xFFEEF0FA),
          surfaceContainer: isDark
              ? const Color(0xFF182044)
              : const Color(0xFFE8EBF8),
          surfaceContainerHigh: isDark
              ? const Color(0xFF1E2750)
              : const Color(0xFFE1E5F5),
          surfaceContainerHighest: isDark
              ? const Color(0xFF253060)
              : const Color(0xFFD9DEF2),
          outline: isDark ? const Color(0xFF5A6499) : const Color(0xFF7A80A6),
          outlineVariant: isDark
              ? const Color(0xFF2A3363)
              : const Color(0xFFCBD0E6),
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [palette],
    );

    final text = base.textTheme;
    return base.copyWith(
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(color: scheme.onInverseSurface, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
