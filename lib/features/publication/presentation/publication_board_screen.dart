import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/action_level.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/adaptive_grid.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/page_frame.dart';
import '../../demo/demo_catalog.dart';
import '../../demo/demo_providers.dart';
import 'level_cards.dart';
import 'workspace_board.dart';

class PublicationBoardScreen extends ConsumerWidget {
  const PublicationBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final demo = ref.watch(demoCatalogProvider);

    return PageFrame(
      icon: Icons.rocket_launch,
      title: l10n.publicationTitle,
      subtitle: l10n.publicationSubtitle,
      children: [
        const _NeverAutoNotice(),
        if (demo == null)
          const WorkspaceBoard()
        else ...[
          _GlobalProgress(demo),
          AdaptiveGrid(
            minItemWidth: 240,
            children: [
              for (final level in ActionLevel.values)
                _LevelProgressCard(
                  catalog: demo,
                  level: level,
                  current: level == demo.session.currentLevel,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NeverAutoNotice extends StatelessWidget {
  const _NeverAutoNotice();

  @override
  Widget build(BuildContext context) {
    final palette = LaunchPalette.of(context);
    return Row(
      children: [
        Icon(
          Icons.verified_user_outlined,
          color: palette.statusWarning,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(context.l10n.publicationNeverAuto)),
      ],
    );
  }
}

class _GlobalProgress extends StatelessWidget {
  const _GlobalProgress(this.catalog);

  final DemoCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final done = catalog.steps.where(DemoCatalog.isDone).length;
    final percent = (catalog.globalProgress * 100).round();

    return GlassCard(
      accent: theme.colorScheme.primary,
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: catalog.globalProgress,
                  strokeWidth: 7,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                Center(
                  child: Text(
                    l10n.percentValue(percent),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.publicationGlobalProgress,
                      style: theme.textTheme.titleMedium,
                    ),
                    const DemoTag(),
                  ],
                ),
                Text(
                  '${catalog.session.projectName} · ${catalog.session.version}',
                ),
                Text(l10n.publicationStepsDone(done, catalog.steps.length)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelProgressCard extends StatelessWidget {
  const _LevelProgressCard({
    required this.catalog,
    required this.level,
    required this.current,
  });

  final DemoCatalog catalog;
  final ActionLevel level;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final steps = catalog.stepsFor(level);
    final done = steps.where(DemoCatalog.isDone).length;
    final color = level.color(context);

    return GlassCard(
      accent: current ? color : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            children: [
              Icon(level.icon, color: color),
              const SizedBox(width: 10),
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          LinearProgressIndicator(
            value: catalog.progressFor(level),
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          Text(
            l10n.publicationStepsDone(done, steps.length),
            style: theme.textTheme.labelMedium,
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final s in steps) StatusPill(s.status)],
          ),
        ],
      ),
    );
  }
}
