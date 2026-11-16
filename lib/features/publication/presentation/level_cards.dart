import 'package:flutter/material.dart';

import '../../../core/domain/action_level.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/adaptive_grid.dart';
import '../../../core/widgets/glass_card.dart';

extension ActionLevelVisuals on ActionLevel {
  IconData get icon => switch (this) {
    ActionLevel.analyze => Icons.search,
    ActionLevel.prepare => Icons.edit_note,
    ActionLevel.build => Icons.construction,
    ActionLevel.publish => Icons.rocket_launch,
  };

  Color color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (this) {
      ActionLevel.analyze => scheme.secondary,
      ActionLevel.prepare => scheme.primary,
      ActionLevel.build => scheme.tertiary,
      ActionLevel.publish => LaunchPalette.of(context).accentOrange,
    };
  }
}

/// Présentation pédagogique des quatre niveaux, sans données de projet.
class LevelOverview extends StatelessWidget {
  const LevelOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AdaptiveGrid(
      minItemWidth: 230,
      children: [
        for (final level in ActionLevel.values)
          GlassCard(
            accent: level.color(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: level
                          .color(context)
                          .withValues(alpha: 0.18),
                      child: Icon(
                        level.icon,
                        color: level.color(context),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${level.index + 1}. ${level.label(l10n)}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                Text(
                  level.description(l10n),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
