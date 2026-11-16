import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/launch_palette.dart';

/// Carte légèrement translucide, base visuelle de LaunchPilot.
/// Utilise un [Material] pour que les effets d'encre des enfants restent visibles.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.accent,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Couleur de bordure et de reflet, pour mettre une carte en avant.
  final Color? accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = LaunchPalette.of(context);
    final radius = BorderRadius.circular(AppTheme.radius);
    final highlight = (accent ?? Colors.white).withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.06 : 0.25,
    );

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [highlight, Colors.transparent],
          stops: const [0, 0.55],
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap != null) {
      content = InkWell(onTap: onTap, child: content);
    }

    return Material(
      color: palette.glassFill,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: accent?.withValues(alpha: 0.5) ?? palette.glassBorder,
        ),
      ),
      child: content,
    );
  }
}
