import 'package:flutter/material.dart';

import '../domain/step_status.dart';

/// Couleurs de marque, communes aux deux thèmes.
abstract final class BrandColors {
  static const midnight = Color(0xFF0B1026);
  static const midnightDeep = Color(0xFF070B1C);
  static const indigo = Color(0xFF6D7CFF);
  static const indigoDeep = Color(0xFF3F4BD1);
  static const turquoise = Color(0xFF2DD4BF);
  static const turquoiseDeep = Color(0xFF0F766E);
  static const violet = Color(0xFFA78BFA);
  static const violetDeep = Color(0xFF7C3AED);
  static const orange = Color(0xFFFB923C);
  static const orangeDeep = Color(0xFFC2410C);
}

/// Couleurs propres à LaunchPilot qui n'existent pas dans [ColorScheme] :
/// statuts d'étapes, surfaces translucides et fond dégradé.
@immutable
class LaunchPalette extends ThemeExtension<LaunchPalette> {
  const LaunchPalette({
    required this.statusTodo,
    required this.statusRunning,
    required this.statusSucceeded,
    required this.statusFailed,
    required this.statusWarning,
    required this.statusPedagogy,
    required this.glassFill,
    required this.glassBorder,
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.glowTurquoise,
    required this.glowViolet,
    required this.accentOrange,
  });

  final Color statusTodo;
  final Color statusRunning;
  final Color statusSucceeded;
  final Color statusFailed;
  final Color statusWarning;
  final Color statusPedagogy;
  final Color glassFill;
  final Color glassBorder;
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color glowTurquoise;
  final Color glowViolet;
  final Color accentOrange;

  static const dark = LaunchPalette(
    statusTodo: Color(0xFF94A3B8),
    statusRunning: Color(0xFF60A5FA),
    statusSucceeded: Color(0xFF4ADE80),
    statusFailed: Color(0xFFF87171),
    statusWarning: BrandColors.orange,
    statusPedagogy: Color(0xFFC4B5FD),
    glassFill: Color(0xB8141B3D),
    glassBorder: Color(0x1FFFFFFF),
    backgroundTop: Color(0xFF0E1433),
    backgroundBottom: BrandColors.midnightDeep,
    glowTurquoise: Color(0x262DD4BF),
    glowViolet: Color(0x2EA78BFA),
    accentOrange: BrandColors.orange,
  );

  static const light = LaunchPalette(
    statusTodo: Color(0xFF526073),
    statusRunning: Color(0xFF2563EB),
    statusSucceeded: Color(0xFF166534),
    statusFailed: Color(0xFFB91C1C),
    statusWarning: BrandColors.orangeDeep,
    statusPedagogy: BrandColors.violetDeep,
    glassFill: Color(0xD9FFFFFF),
    glassBorder: Color(0x1F1E2A6B),
    backgroundTop: Color(0xFFEFF2FF),
    backgroundBottom: Color(0xFFF8F9FD),
    glowTurquoise: Color(0x1F0F766E),
    glowViolet: Color(0x1F7C3AED),
    accentOrange: BrandColors.orangeDeep,
  );

  static LaunchPalette of(BuildContext context) =>
      Theme.of(context).extension<LaunchPalette>()!;

  Color statusColor(StepStatus status) => switch (status) {
    StepStatus.todo => statusTodo,
    StepStatus.running => statusRunning,
    StepStatus.succeeded => statusSucceeded,
    StepStatus.failed => statusFailed,
    StepStatus.needsValidation => statusWarning,
    StepStatus.pedagogical => statusPedagogy,
  };

  @override
  LaunchPalette copyWith({
    Color? statusTodo,
    Color? statusRunning,
    Color? statusSucceeded,
    Color? statusFailed,
    Color? statusWarning,
    Color? statusPedagogy,
    Color? glassFill,
    Color? glassBorder,
    Color? backgroundTop,
    Color? backgroundBottom,
    Color? glowTurquoise,
    Color? glowViolet,
    Color? accentOrange,
  }) {
    return LaunchPalette(
      statusTodo: statusTodo ?? this.statusTodo,
      statusRunning: statusRunning ?? this.statusRunning,
      statusSucceeded: statusSucceeded ?? this.statusSucceeded,
      statusFailed: statusFailed ?? this.statusFailed,
      statusWarning: statusWarning ?? this.statusWarning,
      statusPedagogy: statusPedagogy ?? this.statusPedagogy,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      glowTurquoise: glowTurquoise ?? this.glowTurquoise,
      glowViolet: glowViolet ?? this.glowViolet,
      accentOrange: accentOrange ?? this.accentOrange,
    );
  }

  @override
  LaunchPalette lerp(LaunchPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return LaunchPalette(
      statusTodo: mix(statusTodo, other.statusTodo),
      statusRunning: mix(statusRunning, other.statusRunning),
      statusSucceeded: mix(statusSucceeded, other.statusSucceeded),
      statusFailed: mix(statusFailed, other.statusFailed),
      statusWarning: mix(statusWarning, other.statusWarning),
      statusPedagogy: mix(statusPedagogy, other.statusPedagogy),
      glassFill: mix(glassFill, other.glassFill),
      glassBorder: mix(glassBorder, other.glassBorder),
      backgroundTop: mix(backgroundTop, other.backgroundTop),
      backgroundBottom: mix(backgroundBottom, other.backgroundBottom),
      glowTurquoise: mix(glowTurquoise, other.glowTurquoise),
      glowViolet: mix(glowViolet, other.glowViolet),
      accentOrange: mix(accentOrange, other.accentOrange),
    );
  }
}
