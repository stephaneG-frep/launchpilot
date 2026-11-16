import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/action_level.dart';
import '../../../core/domain/explanation_level.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/widgets/page_frame.dart';
import '../../demo/demo_providers.dart';
import '../../settings/application/settings_controller.dart';
import 'checklist_step_card.dart';
import 'checklist_workspace.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final demo = ref.watch(demoCatalogProvider);
    final level = ref.watch(
      settingsControllerProvider.select((s) => s.explanationLevel),
    );

    return PageFrame(
      icon: Icons.checklist,
      title: l10n.checklistTitle,
      subtitle: l10n.checklistSubtitle,
      children: [
        ExplanationLevelSelector(level: level),
        if (demo == null)
          const ChecklistWorkspace()
        else
          for (final action in ActionLevel.values) ...[
            SectionTitle(action.label(l10n)),
            for (final step in demo.stepsFor(action))
              ChecklistStepCard(
                key: ValueKey(step.id),
                step: step,
                level: level,
              ),
          ],
      ],
    );
  }
}

/// Sélecteur du mode d'accompagnement, directement relié aux paramètres.
class ExplanationLevelSelector extends ConsumerWidget {
  const ExplanationLevelSelector({super.key, required this.level});

  final ExplanationLevel level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.checklistLevelLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SegmentedButton<ExplanationLevel>(
          segments: [
            for (final l in ExplanationLevel.values)
              ButtonSegment(
                value: l,
                label: Text(l.label(l10n)),
                tooltip: l.description(l10n),
              ),
          ],
          selected: {level},
          showSelectedIcon: false,
          onSelectionChanged: (s) => ref
              .read(settingsControllerProvider.notifier)
              .setExplanationLevel(s.first),
        ),
      ],
    );
  }
}
