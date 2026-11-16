import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/destinations.dart';
import '../../../core/database/app_database.dart';
import '../../../core/domain/action_level.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/adaptive_grid.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../checklist/application/checklist_providers.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/data/project_repository.dart';
import '../../projects/domain/project_views.dart';
import '../../git/presentation/protection_card.dart';
import '../../projects/presentation/project_dialogs.dart';
import 'level_cards.dart';

/// Tableau de publication du projet réellement ouvert.
class WorkspaceBoard extends ConsumerWidget {
  const WorkspaceBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final workspace = ref.watch(currentWorkspaceProvider);

    return workspace.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => EmptyState(
        icon: Icons.error_outline,
        title: l10n.homeLoadError,
        message: l10n.settingsLocalDataHint,
      ),
      data: (ws) {
        if (ws == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              EmptyState(
                icon: Icons.rocket_launch_outlined,
                title: l10n.publicationNoProjectTitle,
                message: l10n.publicationNoProjectMessage,
                actions: [
                  FilledButton.icon(
                    onPressed: () => context.go(AppDestination.home.path),
                    icon: const Icon(Icons.home_outlined),
                    label: Text(l10n.publicationGoHome),
                  ),
                ],
              ),
              const LevelOverview(),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            _ProjectHeader(ws),
            ProtectionCard(ws),
            if (ws.activeSession == null) ...[
              EmptyState(
                icon: Icons.flag_outlined,
                title: l10n.publicationNoSessionTitle,
                message: l10n.publicationNoSessionMessage,
                actions: [
                  FilledButton.icon(
                    key: const ValueKey('board-new-session'),
                    onPressed: () =>
                        showNewSessionDialog(context, ref, ws.project),
                    icon: const Icon(Icons.flag_outlined),
                    label: Text(l10n.homeNewSession),
                  ),
                ],
              ),
              const LevelOverview(),
            ] else
              _SessionLevels(ws),
          ],
        );
      },
    );
  }
}

class _ProjectHeader extends ConsumerWidget {
  const _ProjectHeader(this.ws);

  final ProjectWorkspace ws;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final session = ws.activeSession;
    final done = ws.steps
        .where((s) => ProjectRepository.doneStatuses.contains(s.status))
        .length;
    final progress = ws.steps.isEmpty ? 0.0 : done / ws.steps.length;

    return GlassCard(
      accent: theme.colorScheme.primary,
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  session == null
                      ? ws.project.name
                      : '${ws.project.name} · ${session.version}',
                  style: theme.textTheme.titleLarge,
                ),
                SelectableText(
                  ws.project.path,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                if (!ws.folderAvailable)
                  Pill(
                    label: l10n.homeFolderMissing,
                    color: palette.statusWarning,
                    icon: Icons.warning_amber_rounded,
                  ),
                if (session != null) ...[
                  Text(
                    l10n.homeSessionStarted(
                      context.formatDate(session.createdAt),
                    ),
                  ),
                  Text(l10n.homeCurrentLevel(session.currentLevel.label(l10n))),
                  Text(l10n.publicationStepsDone(done, ws.steps.length)),
                  SizedBox(
                    width: 320,
                    child: LinearProgressIndicator(
                      value: progress,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (session != null)
            OutlinedButton.icon(
              key: const ValueKey('board-close-session'),
              onPressed: () => showCloseSessionDialog(context, ref, session),
              icon: const Icon(Icons.flag_circle_outlined),
              label: Text(l10n.closeSession),
            ),
        ],
      ),
    );
  }
}

class _SessionLevels extends ConsumerWidget {
  const _SessionLevels(this.ws);

  final ProjectWorkspace ws;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final session = ws.activeSession!;
    // Construit et synchronise la checklist : les niveaux reflètent le plan.
    final plan = ref.watch(currentPlanProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        if (ws.steps.isEmpty)
          Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.tertiary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  plan.isLoading
                      ? l10n.detectionAnalyzing
                      : l10n.checklistNeedsDetectionMessage,
                ),
              ),
              if (!plan.isLoading)
                TextButton(
                  onPressed: () => context.go(AppDestination.detection.path),
                  child: Text(l10n.checklistGoDetection),
                ),
            ],
          ),
        AdaptiveGrid(
          minItemWidth: 240,
          children: [
            for (final level in ActionLevel.values)
              _LevelCard(
                level: level,
                steps: ws.steps.where((s) => s.level == level).toList(),
                current: level == session.currentLevel,
              ),
          ],
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.steps,
    required this.current,
  });

  final ActionLevel level;
  final List<ChecklistStepRecord> steps;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = level.color(context);
    final done = steps
        .where((s) => ProjectRepository.doneStatuses.contains(s.status))
        .length;

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
            value: steps.isEmpty ? 0 : done / steps.length,
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          Text(
            l10n.publicationStepsDone(done, steps.length),
            style: theme.textTheme.labelMedium,
          ),
          if (steps.isNotEmpty)
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
