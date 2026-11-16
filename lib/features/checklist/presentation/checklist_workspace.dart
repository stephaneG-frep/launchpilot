import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/destinations.dart';
import '../../../core/domain/action_level.dart';
import '../../../core/domain/step_status.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/page_frame.dart';
import '../../commands/domain/command_result.dart';
import '../../commands/domain/command_spec.dart';
import '../../commands/presentation/command_preview_dialog.dart';
import '../../detection/application/detection_providers.dart';
import '../../help/domain/glossary.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/project_views.dart';
import '../../projects/presentation/project_dialogs.dart';
import '../../settings/application/settings_controller.dart';
import '../application/checklist_providers.dart';
import '../domain/checklist_step.dart';
import 'checklist_step_card.dart';

/// Checklist réelle de la session active, construite par les cibles.
class ChecklistWorkspace extends ConsumerWidget {
  const ChecklistWorkspace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ws = ref.watch(currentWorkspaceProvider).value;
    if (ws == null) {
      return EmptyState(
        icon: Icons.checklist,
        title: l10n.publicationNoProjectTitle,
        message: l10n.checklistEmptyMessage,
        actions: [
          FilledButton.icon(
            onPressed: () => context.go(AppDestination.home.path),
            icon: const Icon(Icons.home_outlined),
            label: Text(l10n.publicationGoHome),
          ),
        ],
      );
    }
    if (ws.activeSession == null) {
      return EmptyState(
        icon: Icons.flag_outlined,
        title: l10n.publicationNoSessionTitle,
        message: l10n.publicationNoSessionMessage,
        actions: [
          FilledButton.icon(
            key: const ValueKey('checklist-new-session'),
            onPressed: () => showNewSessionDialog(context, ref, ws.project),
            icon: const Icon(Icons.flag_outlined),
            label: Text(l10n.homeNewSession),
          ),
        ],
      );
    }
    final detection = ref.watch(currentDetectionProvider);
    if (!detection.isLoading && detection.value == null) {
      return EmptyState(
        icon: Icons.radar,
        title: l10n.checklistNeedsDetectionTitle,
        message: l10n.checklistNeedsDetectionMessage,
        actions: [
          FilledButton.icon(
            key: const ValueKey('checklist-go-detection'),
            onPressed: () => context.go(AppDestination.detection.path),
            icon: const Icon(Icons.radar),
            label: Text(l10n.checklistGoDetection),
          ),
        ],
      );
    }

    final checklist = ref.watch(currentChecklistProvider);
    final view = checklist.value;
    if (view == null) {
      return checklist.hasError
          ? Text('${checklist.error}')
          : const LinearProgressIndicator();
    }

    final level = ref.watch(
      settingsControllerProvider.select((s) => s.explanationLevel),
    );
    final language = ref.watch(
      settingsControllerProvider.select((s) => s.language),
    );
    final glossary = Glossary.forLanguage(language);
    final steps = view.steps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        _ProgressHeader(
          view: view,
          reviewed: detection.value?.reviewed ?? false,
        ),
        for (final action in ActionLevel.values)
          if (steps.any((s) => s.level == action)) ...[
            SectionTitle(action.label(l10n)),
            for (final step in steps.where((s) => s.level == action))
              ChecklistStepCard(
                key: ValueKey(step.id),
                step: step,
                level: level,
                blockedBy: [
                  for (final b in view.progress.blockers(step))
                    if (!view.progress.isDone(step.id)) b.title,
                ],
                glossary: [
                  for (final id in step.glossary) ?Glossary.byId(glossary, id),
                ],
                actions: _actions(context, ref, ws, view, step),
              ),
          ],
      ],
    );
  }

  List<Widget> _actions(
    BuildContext context,
    WidgetRef ref,
    ProjectWorkspace ws,
    ChecklistView view,
    ChecklistStep step,
  ) {
    final l10n = context.l10n;
    final actions = ref.read(checklistActionsProvider);
    final done = view.progress.isDone(step.id);
    if (done) {
      return [
        TextButton.icon(
          key: ValueKey('step-reset-${step.id}'),
          onPressed: () => actions.setStatus(view, step, StepStatus.todo),
          icon: const Icon(Icons.replay),
          label: Text(l10n.checklistReset),
        ),
      ];
    }
    if (view.progress.isBlocked(step)) return const [];

    return switch (step.kind) {
      StepKind.command => [
        FilledButton.icon(
          key: ValueKey('step-run-${step.id}'),
          onPressed: () => _run(context, ref, ws, view, step),
          icon: const Icon(Icons.play_arrow),
          label: Text(l10n.checklistRun),
        ),
        if (step.status == StepStatus.failed)
          OutlinedButton.icon(
            onPressed: () => context.go(AppDestination.terminal.path),
            icon: const Icon(Icons.terminal),
            label: Text(l10n.checklistOpenTerminal),
          ),
      ],
      StepKind.manual || StepKind.pedagogical => [
        if (step.toolTab case final tab?)
          FilledButton.icon(
            key: ValueKey('step-tool-${step.id}'),
            onPressed: () =>
                context.go('${AppDestination.content.path}?tab=$tab'),
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.checklistOpenTool),
          ),
        FilledButton.tonalIcon(
          key: ValueKey('step-done-${step.id}'),
          onPressed: () => actions.setStatus(
            view,
            step,
            ChecklistActions.completionFor(step),
          ),
          icon: Icon(
            step.kind == StepKind.pedagogical
                ? Icons.lightbulb_outline
                : Icons.check,
          ),
          label: Text(
            step.kind == StepKind.pedagogical
                ? l10n.checklistUnderstood
                : l10n.checklistDone,
          ),
        ),
      ],
    };
  }

  /// Exécute les commandes de l'étape une à une, chacune avec son aperçu.
  /// La première qui n'aboutit pas arrête la suite.
  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    ProjectWorkspace ws,
    ChecklistView view,
    ChecklistStep step,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(checklistActionsProvider);
    for (final c in step.commands) {
      final result = await previewAndRun(
        context,
        ref,
        CommandSpec(
          executable: c.executable,
          arguments: c.arguments,
          workingDirectory: c.workingDirectory ?? ws.project.path,
        ),
        openTerminal: false,
      );
      if (result == null) return;
      final status = ChecklistActions.statusFor(result.status);
      if (status == null) {
        if (result.status == RunStatus.simulated) {
          showInfo(messenger, l10n.checklistSimulated);
        }
        return;
      }
      if (status != StepStatus.succeeded) {
        await actions.setStatus(view, step, status);
        showInfo(messenger, l10n.checklistRunFailed);
        return;
      }
      if (!context.mounted) return;
    }
    await actions.setStatus(view, step, StepStatus.succeeded);
    showInfo(messenger, l10n.checklistRunOk);
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.view, required this.reviewed});

  final ChecklistView view;
  final bool reviewed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final progress = view.progress;
    final next = progress.next;
    final targets = view.plan.steps
        .map((s) => s.targetId)
        .where((t) => t != 'common')
        .toSet();

    return GlassCard(
      accent: theme.colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  key: const ValueKey('checklist-progress'),
                  value: progress.ratio,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                l10n.publicationStepsDone(progress.done, progress.steps.length),
              ),
            ],
          ),
          Text(l10n.homeCurrentLevel(progress.currentLevel.label(l10n))),
          Text(
            next == null
                ? l10n.checklistAllDone
                : l10n.checklistNext(next.title),
            style: theme.textTheme.titleSmall,
          ),
          if (targets.isNotEmpty)
            Text(l10n.checklistActiveTargets(targets.join(', '))),
          if (!reviewed)
            Row(
              children: [
                Icon(
                  Icons.pending_outlined,
                  color: palette.statusWarning,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.checklistTargetsNotReviewed)),
                TextButton(
                  onPressed: () => context.go(AppDestination.detection.path),
                  child: Text(l10n.detectionValidateTargets),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
