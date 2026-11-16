import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/destinations.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/adaptive_grid.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/page_frame.dart';
import '../../demo/demo_catalog.dart';
import '../../demo/demo_providers.dart';
import '../../projects/presentation/project_dialogs.dart';
import '../../publication/presentation/level_cards.dart';
import '../../settings/application/settings_controller.dart';
import 'local_projects_sections.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final demo = ref.watch(demoCatalogProvider);

    return PageFrame(
      icon: Icons.home,
      title: l10n.homeTitle,
      subtitle: l10n.homeSubtitle,
      children: [
        _OpenProjectCard(demoActive: demo != null),
        if (demo == null)
          const LocalProjectsSections()
        else ...[
          SectionTitle(l10n.homeResumeTitle),
          _SessionCard(demo.session),
          SectionTitle(l10n.homeRecentTitle),
          AdaptiveGrid(
            minItemWidth: 300,
            maxColumns: 3,
            children: [for (final p in demo.projects) _ProjectCard(p)],
          ),
        ],
        SectionTitle(l10n.homeHowTitle),
        const LevelOverview(),
      ],
    );
  }
}

class _OpenProjectCard extends ConsumerWidget {
  const _OpenProjectCard({required this.demoActive});

  final bool demoActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GlassCard(
      accent: scheme.secondary,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.folder_special_outlined,
                size: 36,
                color: scheme.secondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      l10n.homeOpenProject,
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      l10n.homeOpenProjectHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // En mode démo, rien de réel n'est enregistré.
              if (!demoActive) ...[
                FilledButton.icon(
                  key: const ValueKey('home-pick-folder'),
                  onPressed: () async {
                    final router = GoRouter.of(context);
                    if (await pickAndAddProject(context, ref)) {
                      router.go(AppDestination.detection.path);
                    }
                  },
                  icon: const Icon(Icons.folder_open),
                  label: Text(l10n.homeChooseFolder),
                ),
                OutlinedButton.icon(
                  key: const ValueKey('home-add-project'),
                  onPressed: () async {
                    final router = GoRouter.of(context);
                    if (await showAddProjectDialog(context, ref)) {
                      router.go(AppDestination.detection.path);
                    }
                  },
                  icon: const Icon(Icons.keyboard_outlined),
                  label: Text(l10n.homeEnterPath),
                ),
              ],
              if (!demoActive)
                Tooltip(
                  message: l10n.homeDemoHint,
                  child: OutlinedButton.icon(
                    key: const ValueKey('home-try-demo'),
                    onPressed: () => ref
                        .read(settingsControllerProvider.notifier)
                        .setDemoMode(true),
                    icon: const Icon(Icons.science_outlined),
                    label: Text(l10n.homeTryDemo),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard(this.session);

  final DemoSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final percent = (session.progress * 100).round();

    return GlassCard(
      accent: theme.colorScheme.primary,
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${session.projectName} · ${session.version}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const DemoTag(),
                  ],
                ),
                Text(
                  l10n.homeSessionStarted(
                    context.formatDate(session.startedAt),
                  ),
                ),
                Text(l10n.homeCurrentLevel(session.currentLevel.label(l10n))),
                SizedBox(
                  width: 320,
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: session.progress,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Text(l10n.percentValue(percent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => context.go(AppDestination.publication.path),
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.homeResumeAction),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard(this.project);

  final DemoProject project;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = LaunchPalette.of(context);
    final percent = (project.progress * 100).round();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
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
              if (project.favorite)
                Tooltip(
                  message: l10n.homeFavorite,
                  child: Icon(
                    Icons.star,
                    color: palette.accentOrange,
                    size: 20,
                  ),
                ),
            ],
          ),
          Text(
            project.path,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: scheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              const DemoTag(),
              for (final t in project.technologies)
                Pill(label: t, color: scheme.secondary),
              Pill(label: project.version, color: scheme.primary),
            ],
          ),
          Text(
            l10n.homeLastOpened(context.formatDate(project.lastOpened)),
            style: theme.textTheme.bodySmall,
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: project.progress,
                  borderRadius: BorderRadius.circular(4),
                  color: project.progress >= 1 ? palette.statusSucceeded : null,
                ),
              ),
              Text(
                l10n.percentValue(percent),
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
