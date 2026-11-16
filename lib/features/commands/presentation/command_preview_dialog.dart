import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/destinations.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/badges.dart';
import '../../projects/application/project_providers.dart';
import '../../settings/application/settings_controller.dart';
import '../application/command_providers.dart';
import '../domain/command_result.dart';
import '../domain/command_spec.dart';
import 'command_labels.dart';

/// Aperçu obligatoire avant toute exécution. Renvoie vrai si l'utilisateur
/// a confirmé (jamais pour une commande interdite).
Future<bool> showCommandPreview(
  BuildContext context,
  CommandSpec spec,
  PolicyDecision decision, {
  required bool simulation,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => _CommandPreviewDialog(
        spec: spec,
        decision: decision,
        simulation: simulation,
      ),
    ) ??
    false;

/// Parcours complet : aperçu, confirmation à usage unique, exécution dans
/// le terminal intégré (affiché automatiquement).
Future<CommandResult?> previewAndRun(
  BuildContext context,
  WidgetRef ref,
  CommandSpec spec, {
  bool openTerminal = true,
}) async {
  final ws = ref.read(currentWorkspaceProvider).value;
  if (ws == null) return null;
  final runner = ref.read(commandRunnerProvider);
  final decision = runner.policy.evaluate(spec, ws.project.path);
  final simulation = ref.read(settingsControllerProvider).simulationMode;
  final router = GoRouter.of(context);
  final confirmed = await showCommandPreview(
    context,
    spec,
    decision,
    simulation: simulation,
  );
  if (!confirmed) return null;
  // La confirmation est créée au clic, pour cette commande exacte.
  final approval = decision.risk == RiskLevel.readOnly
      ? null
      : runner.approve(spec);
  if (openTerminal) router.go(AppDestination.terminal.path);
  return ref
      .read(terminalControllerProvider.notifier)
      .run(
        projectId: ws.project.id,
        projectRoot: ws.project.path,
        spec: spec,
        approval: approval,
      );
}

class _CommandPreviewDialog extends StatefulWidget {
  const _CommandPreviewDialog({
    required this.spec,
    required this.decision,
    required this.simulation,
  });

  final CommandSpec spec;
  final PolicyDecision decision;
  final bool simulation;

  @override
  State<_CommandPreviewDialog> createState() => _CommandPreviewDialogState();
}

class _CommandPreviewDialogState extends State<_CommandPreviewDialog> {
  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final d = widget.decision;
    final risk = d.risk;
    final willSimulate = widget.simulation && risk != RiskLevel.readOnly;
    final canRun = d.allowed && (!d.reinforced || _acknowledged);

    return AlertDialog(
      icon: Icon(risk.icon, color: risk.color(context)),
      title: Text(l10n.cmdPreviewTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, minWidth: 280),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF060914),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  '\$ ${widget.spec.display}',
                  key: const ValueKey('cmd-preview-command'),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFFD7DCF0),
                  ),
                ),
              ),
              Text(
                l10n.cmdWorkingDir(widget.spec.workingDirectory),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              Pill(
                label: risk.label(l10n),
                color: risk.color(context),
                icon: risk.icon,
              ),
              Text(risk.description(l10n)),
              for (final issue in d.issues)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      d.allowed ? Icons.info_outline : Icons.block,
                      size: 18,
                      color: d.allowed
                          ? palette.statusWarning
                          : palette.statusFailed,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(issue.text(l10n))),
                  ],
                ),
              if (willSimulate && d.allowed)
                Text(
                  l10n.cmdSimulationNote,
                  style: TextStyle(color: palette.statusPedagogy),
                ),
              if (d.reinforced)
                CheckboxListTile(
                  key: const ValueKey('cmd-reinforced'),
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  onChanged: (v) => setState(() => _acknowledged = v ?? false),
                  title: Text(l10n.cmdConfirmReinforced),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(d.allowed ? l10n.commonCancel : l10n.commonClose),
        ),
        if (d.allowed)
          FilledButton.icon(
            key: const ValueKey('cmd-preview-run'),
            onPressed: canRun ? () => Navigator.of(context).pop(true) : null,
            icon: Icon(
              willSimulate ? Icons.science_outlined : Icons.play_arrow,
            ),
            label: Text(willSimulate ? l10n.cmdSimulate : l10n.cmdRun),
          ),
      ],
    );
  }
}
