import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/destinations.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/adaptive_grid.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/page_frame.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/project_views.dart';
import '../../projects/presentation/project_dialogs.dart';

enum _ProjectFilter { all, favorites }

/// Sections « Reprendre une session » et « Projets récents » alimentées par
/// la base locale.
class LocalProjectsSections extends ConsumerStatefulWidget {
  const LocalProjectsSections({super.key});

  @override
  ConsumerState<LocalProjectsSections> createState() =>
      _LocalProjectsSectionsState();
}

class _LocalProjectsSectionsState extends ConsumerState<LocalProjectsSections> {
  _ProjectFilter _filter = _ProjectFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final overviews = ref.watch(projectOverviewsProvider);

    return overviews.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => EmptyState(
        icon: Icons.error_outline,
        title: l10n.homeLoadError,
        message: l10n.settingsLocalDataHint,
      ),
      data: (all) {
        final active = all.where((o) => o.activeSession != null).toList()
          ..sort(
            (a, b) => b.activeSession!.updatedAt.compareTo(
              a.activeSession!.updatedAt,
            ),
          );
        final shown = _filter == _ProjectFilter.all
            ? all
            : all.where((o) => o.project.favorite).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            SectionTitle(l10n.homeResumeTitle),
            if (active.isEmpty)
              EmptyState(
                icon: Icons.history,
                title: l10n.homeResumeEmptyTitle,
                message: l10n.homeResumeEmptyMessage,
              )
            else
              AdaptiveGrid(
                minItemWidth: 320,
                maxColumns: 2,
                children: [for (final o in active) _ResumeCard(o)],
              ),
            SectionTitle(
              l10n.homeRecentTitle,
              trailing: all.isEmpty
                  ? null
                  : SegmentedButton<_ProjectFilter>(
                      segments: [
                        ButtonSegment(
                          value: _ProjectFilter.all,
                          label: Text(l10n.homeFilterAll),
                        ),
                        ButtonSegment(
                          value: _ProjectFilter.favorites,
                          icon: const Icon(Icons.star_outline),
                          label: Text(l10n.homeFilterFavorites),
                        ),
                      ],
                      selected: {_filter},
                      showSelectedIcon: false,
                      onSelectionChanged: (s) =>
                          setState(() => _filter = s.first),
                    ),
            ),
            if (all.isEmpty)
              EmptyState(
                icon: Icons.folder_open,
                title: l10n.homeRecentEmptyTitle,
                message: l10n.homeRecentEmptyMessage,
              )
            else if (shown.isEmpty)
              Text(l10n.homeFavoritesEmpty)
            else
              AdaptiveGrid(
                minItemWidth: 300,
                maxColumns: 3,
                children: [
                  for (final o in shown)
                    _ProjectTile(o, key: ValueKey('project-${o.project.id}')),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _ResumeCard extends ConsumerWidget {
  const _ResumeCard(this.overview);

  final ProjectOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final session = overview.activeSession!;
    final percent = (overview.progress * 100).round();

    return GlassCard(
      accent: theme.colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            '${overview.project.name} · ${session.version}',
            style: theme.textTheme.titleMedium,
          ),
          Text(l10n.homeResumeSince(context.formatDate(session.updatedAt))),
          Text(l10n.homeCurrentLevel(session.currentLevel.label(l10n))),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: overview.progress,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(l10n.percentValue(percent)),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: ValueKey('resume-${session.id}'),
              onPressed: () async {
                final router = GoRouter.of(context);
                await ref.read(projectActionsProvider).resumeSession(session);
                router.go(AppDestination.publication.path);
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.homeResumeAction),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MenuAction { newSession, relocate, remove }

class _ProjectTile extends ConsumerWidget {
  const _ProjectTile(this.overview, {super.key});

  final ProjectOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = LaunchPalette.of(context);
    final project = overview.project;
    final session = overview.activeSession;
    final actions = ref.read(projectActionsProvider);

    Future<void> open() async {
      final router = GoRouter.of(context);
      await actions.open(project.id);
      router.go(AppDestination.publication.path);
    }

    return GlassCard(
      accent: overview.folderAvailable ? null : palette.statusWarning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                key: ValueKey('favorite-${project.id}'),
                tooltip: project.favorite
                    ? l10n.homeRemoveFavorite
                    : l10n.homeAddFavorite,
                isSelected: project.favorite,
                onPressed: () =>
                    actions.setFavorite(project.id, !project.favorite),
                icon: const Icon(Icons.star_outline),
                selectedIcon: Icon(Icons.star, color: palette.accentOrange),
              ),
              PopupMenuButton<_MenuAction>(
                key: ValueKey('project-menu-${project.id}'),
                tooltip: l10n.homeProjectMenu,
                onSelected: (action) => switch (action) {
                  _MenuAction.newSession => showNewSessionDialog(
                    context,
                    ref,
                    project,
                  ),
                  _MenuAction.relocate => showRelocateDialog(
                    context,
                    ref,
                    project,
                  ),
                  _MenuAction.remove => showRemoveProjectDialog(
                    context,
                    ref,
                    project,
                  ),
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _MenuAction.newSession,
                    enabled: session == null,
                    child: Text(l10n.homeNewSession),
                  ),
                  PopupMenuItem(
                    value: _MenuAction.relocate,
                    child: Text(l10n.homeRelocate),
                  ),
                  PopupMenuItem(
                    value: _MenuAction.remove,
                    child: Text(l10n.homeRemove),
                  ),
                ],
              ),
            ],
          ),
          SelectableText(
            project.path,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 2,
          ),
          if (!overview.folderAvailable) ...[
            Pill(
              label: l10n.homeFolderMissing,
              color: palette.statusWarning,
              icon: Icons.warning_amber_rounded,
            ),
            Text(l10n.homeFolderMissingHint, style: theme.textTheme.bodySmall),
          ],
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in project.technologies)
                Pill(label: t, color: scheme.secondary),
              if (session != null)
                Pill(
                  label: l10n.homeSessionActive(session.version),
                  color: palette.statusRunning,
                  icon: Icons.play_circle_outline,
                ),
            ],
          ),
          Text(
            l10n.homeLastOpened(context.formatDate(project.lastOpenedAt)),
            style: theme.textTheme.bodySmall,
          ),
          if (session != null)
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: overview.progress,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  l10n.percentValue((overview.progress * 100).round()),
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (overview.folderAvailable)
                OutlinedButton.icon(
                  key: ValueKey('open-${project.id}'),
                  onPressed: open,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.homeOpen),
                )
              else
                FilledButton.tonalIcon(
                  key: ValueKey('relocate-${project.id}'),
                  onPressed: () => showRelocateDialog(context, ref, project),
                  icon: const Icon(Icons.drive_file_move_outline),
                  label: Text(l10n.homeRelocate),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
