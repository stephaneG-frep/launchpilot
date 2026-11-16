import 'package:flutter/material.dart';

import '../../../core/domain/explanation_level.dart';
import '../../../core/domain/step_status.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/glass_card.dart';
import '../../help/domain/glossary.dart';
import '../domain/checklist_step.dart';

/// Carte d'étape dont le contenu dépend du mode d'accompagnement :
/// - Débutant : tout est expliqué, vérification sur demande ;
/// - Accompagné : l'essentiel, sans l'explication longue ;
/// - Expert : commande visible en tête, détails techniques seulement.
class ChecklistStepCard extends StatefulWidget {
  const ChecklistStepCard({
    super.key,
    required this.step,
    required this.level,
    this.actions = const [],
    this.blockedBy = const [],
    this.glossary = const [],
  });

  final ChecklistStep step;
  final ExplanationLevel level;

  /// Boutons d'action (exécuter, marquer comme fait…), toujours visibles.
  final List<Widget> actions;

  /// Titres des prérequis non terminés.
  final List<String> blockedBy;

  /// Termes du lexique cités par l'étape, déjà résolus dans la langue.
  final List<GlossaryEntry> glossary;

  @override
  State<ChecklistStepCard> createState() => _ChecklistStepCardState();
}

class _ChecklistStepCardState extends State<ChecklistStepCard> {
  bool _expanded = false;
  bool _showVerification = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final level = widget.level;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final statusColor = palette.statusColor(step.status);
    final animate = !MediaQuery.disableAnimationsOf(context);

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 40,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(step.title, style: theme.textTheme.titleMedium),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  StatusPill(step.status),
                  Pill(
                    label: switch (step.kind) {
                      StepKind.command => l10n.kindCommand,
                      StepKind.manual => l10n.kindManual,
                      StepKind.pedagogical => l10n.kindPedagogical,
                    },
                    color: theme.colorScheme.secondary,
                    icon: switch (step.kind) {
                      StepKind.command => Icons.terminal,
                      StepKind.manual => Icons.fact_check_outlined,
                      StepKind.pedagogical => Icons.school_outlined,
                    },
                  ),
                  if (widget.blockedBy.isNotEmpty)
                    Pill(
                      label: l10n.checklistBlocked,
                      color: palette.statusTodo,
                      icon: Icons.lock_clock_outlined,
                    ),
                  if (step.laterPhase case final phase?) PhasePill(phase),
                  if (step.requiresConfirmation)
                    Pill(
                      label: l10n.checklistRequiresConfirmation,
                      color: palette.statusWarning,
                      icon: Icons.lock_outline,
                    ),
                  if (!step.isReversible)
                    Pill(
                      label: l10n.checklistIrreversible,
                      color: palette.statusFailed,
                      icon: Icons.block,
                    ),
                ],
              ),
              if (level == ExplanationLevel.beginner)
                Text(step.objective, style: theme.textTheme.bodyMedium)
              else if (level == ExplanationLevel.guided)
                Text(
                  step.summary ?? step.objective,
                  style: theme.textTheme.bodyMedium,
                )
              else if (step.commands.isNotEmpty)
                _CommandBlock(step: step, showComments: false),
              if (widget.blockedBy.isNotEmpty)
                Text(
                  l10n.checklistBlockedBy(widget.blockedBy.join(', ')),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (widget.actions.isNotEmpty)
                Wrap(spacing: 8, runSpacing: 8, children: widget.actions),
            ],
          ),
        ),
        IconButton(
          tooltip: _expanded
              ? l10n.checklistHideDetails
              : l10n.checklistShowDetails,
          onPressed: () => setState(() => _expanded = !_expanded),
          icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
        ),
      ],
    );

    return GlassCard(
      // Les étapes bloquantes ou en attente de validation ressortent.
      accent:
          step.status == StepStatus.failed ||
              step.status == StepStatus.needsValidation
          ? statusColor
          : null,
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      child: AnimatedSize(
        duration: animate ? const Duration(milliseconds: 180) : Duration.zero,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            if (_expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 8, 0),
                child: _details(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _details(BuildContext context) {
    final step = widget.step;
    final level = widget.level;
    final l10n = context.l10n;
    final beginner = level == ExplanationLevel.beginner;
    final expert = level == ExplanationLevel.expert;

    final verification = _Field(
      l10n.checklistVerification,
      Text(step.verificationMethod),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 14,
      children: [
        if (step.laterPhase case final phase?)
          Text(
            l10n.checklistLaterPhase(phase),
            style: TextStyle(color: LaunchPalette.of(context).statusPedagogy),
          ),
        if (beginner) ...[
          _Field(l10n.checklistExplanation, Text(step.explanation)),
          _Field(l10n.checklistWhy, Text(step.whyRequired)),
        ] else if (level == ExplanationLevel.guided)
          _Field(l10n.checklistExplanation, Text(step.explanation)),
        if (step.affectedFiles.isNotEmpty)
          _Field(
            l10n.checklistFiles,
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final f in step.affectedFiles)
                  Pill(
                    label: f,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              ],
            ),
          ),
        if (step.commands.isNotEmpty && !expert)
          _Field(
            l10n.checklistCommands,
            _CommandBlock(step: step, showComments: beginner),
          ),
        if (!expert) _Field(l10n.checklistExpected, Text(step.expectedResult)),
        if (step.risks.isNotEmpty)
          _Field(
            l10n.checklistRisks,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final r in step.risks) Text('• $r')],
            ),
          ),
        // En mode Débutant, la vérification s'affiche sur demande.
        if (!beginner || _showVerification) verification,
        _Field(
          l10n.checklistRollback,
          Text(step.rollbackMethod ?? l10n.checklistNoRollback),
        ),
        if (widget.glossary.isNotEmpty)
          _Field(
            l10n.checklistGlossary,
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final g in widget.glossary)
                  ActionChip(
                    key: ValueKey('glossary-${step.id}-${g.id}'),
                    avatar: const Icon(Icons.menu_book_outlined, size: 16),
                    label: Text(g.term),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        icon: const Icon(Icons.menu_book_outlined),
                        title: Text(g.term),
                        content: Text(g.definition),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.commonClose),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (beginner)
          OutlinedButton.icon(
            onPressed: () =>
                setState(() => _showVerification = !_showVerification),
            icon: const Icon(Icons.visibility_outlined),
            label: Text(
              _showVerification
                  ? l10n.checklistHideVerify
                  : l10n.checklistShowVerify,
            ),
          ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.child);

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        child,
      ],
    );
  }
}

/// Aperçu en lecture seule des commandes d'une étape.
class _CommandBlock extends StatelessWidget {
  const _CommandBlock({required this.step, required this.showComments});

  final ChecklistStep step;
  final bool showComments;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5);
    final lines = <TextSpan>[];
    for (final c in step.commands) {
      if (showComments && c.comment != null) {
        lines.add(
          TextSpan(
            text: '# ${c.comment}\n',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        );
      }
      lines.add(
        TextSpan(
          children: [
            TextSpan(
              text: r'$ ',
              style: TextStyle(color: scheme.secondary),
            ),
            TextSpan(text: '${c.display}\n'),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: SelectableText.rich(
        TextSpan(
          style: mono.copyWith(color: scheme.onSurface),
          children: lines,
        ),
        maxLines: null,
      ),
    );
  }
}
