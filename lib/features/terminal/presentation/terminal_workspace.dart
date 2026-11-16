import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/destinations.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/page_frame.dart';
import '../../commands/application/command_providers.dart';
import '../../commands/data/command_log_repository.dart';
import '../../commands/domain/command_line.dart';
import '../../commands/domain/command_result.dart';
import '../../commands/domain/command_spec.dart';
import '../../commands/domain/suggested_commands.dart';
import '../../commands/presentation/command_labels.dart';
import '../../commands/presentation/command_preview_dialog.dart';
import '../../detection/application/detection_providers.dart';
import '../../projects/application/project_providers.dart';
import '../../settings/application/settings_controller.dart';

enum _Filter { all, stdout, stderr }

/// Terminal intégré du projet ouvert : commandes proposées ou saisies,
/// toujours prévisualisées, sortie en direct et historique masqué.
class TerminalWorkspace extends ConsumerWidget {
  const TerminalWorkspace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ws = ref.watch(currentWorkspaceProvider).value;
    if (ws == null) {
      return EmptyState(
        icon: Icons.terminal,
        title: l10n.publicationNoProjectTitle,
        message: l10n.terminalEmptyMessage,
        actions: [
          FilledButton.icon(
            onPressed: () => context.go(AppDestination.home.path),
            icon: const Icon(Icons.home_outlined),
            label: Text(l10n.publicationGoHome),
          ),
        ],
      );
    }
    final detection = ref.watch(currentDetectionProvider).value;
    final suggestions = suggestedCommands(
      root: ws.project.path,
      report: detection?.report,
      selectedTargets: detection?.selected ?? const {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: [
        const _SimulationBanner(),
        SectionTitle(l10n.terminalQuick),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in suggestions)
              ActionChip(
                key: ValueKey('quick-${s.display}'),
                avatar: Icon(
                  ref
                      .read(commandRunnerProvider)
                      .policy
                      .evaluate(s, ws.project.path)
                      .risk
                      .icon,
                  size: 16,
                ),
                label: Text(
                  s.display,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                onPressed: () =>
                    previewAndRun(context, ref, s, openTerminal: false),
              ),
          ],
        ),
        _CustomCommand(root: ws.project.path),
        const _RunPanel(),
        SectionTitle(l10n.terminalHistory),
        const _History(),
      ],
    );
  }
}

class _SimulationBanner extends ConsumerWidget {
  const _SimulationBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = LaunchPalette.of(context);
    final on = ref.watch(
      settingsControllerProvider.select((s) => s.simulationMode),
    );
    final color = on ? palette.statusPedagogy : palette.statusWarning;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(on ? Icons.science_outlined : Icons.bolt, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              on ? l10n.terminalSimulationOn : l10n.terminalSimulationOff,
            ),
          ),
          Tooltip(
            message: l10n.terminalSimulationToggle,
            child: Switch(
              key: const ValueKey('terminal-simulation'),
              value: on,
              onChanged: ref
                  .read(settingsControllerProvider.notifier)
                  .setSimulationMode,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomCommand extends ConsumerStatefulWidget {
  const _CustomCommand({required this.root});

  final String root;

  @override
  ConsumerState<_CustomCommand> createState() => _CustomCommandState();
}

class _CustomCommandState extends ConsumerState<_CustomCommand> {
  final _controller = TextEditingController();
  String? _error;
  bool _shellNote = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _preview() {
    final tokens = splitCommandLine(_controller.text.trim());
    if (tokens == null) {
      setState(() => _error = context.l10n.cmdParseError);
      return;
    }
    if (tokens.isEmpty) return;
    setState(() {
      _error = null;
      _shellNote = containsShellOperators(tokens);
    });
    previewAndRun(
      context,
      ref,
      CommandSpec(
        executable: tokens.first,
        arguments: tokens.skip(1).toList(),
        workingDirectory: widget.root,
      ),
      openTerminal: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          l10n.terminalCustom,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('terminal-custom'),
                controller: _controller,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  prefixText: r'$ ',
                  hintText: l10n.terminalCustomHint,
                  errorText: _error,
                  isDense: true,
                ),
                onSubmitted: (_) => _preview(),
              ),
            ),
            FilledButton.tonalIcon(
              key: const ValueKey('terminal-custom-preview'),
              onPressed: _preview,
              icon: const Icon(Icons.preview_outlined),
              label: Text(l10n.terminalPreview),
            ),
          ],
        ),
        if (_shellNote)
          Text(
            l10n.cmdNoShellNote,
            style: TextStyle(color: LaunchPalette.of(context).statusWarning),
          ),
      ],
    );
  }
}

class _RunPanel extends ConsumerStatefulWidget {
  const _RunPanel();

  @override
  ConsumerState<_RunPanel> createState() => _RunPanelState();
}

class _RunPanelState extends ConsumerState<_RunPanel> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(terminalControllerProvider);
    final spec = state.spec;
    if (spec == null) return const SizedBox.shrink();
    final result = state.result;
    final lines = state.lines
        .where(
          (l) => switch (_filter) {
            _Filter.all => true,
            _Filter.stdout => l.stream == OutputStream.stdout,
            _Filter.stderr => l.stream == OutputStream.stderr,
          },
        )
        .toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SelectableText(
                '\$ ${spec.display}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              if (state.decision case final d?)
                Pill(
                  label: d.risk.label(l10n),
                  color: d.risk.color(context),
                  icon: d.risk.icon,
                ),
              if (state.running)
                Pill(
                  label: l10n.statusRunning,
                  color: LaunchPalette.of(context).statusRunning,
                  icon: Icons.autorenew,
                ),
              if (result != null)
                Pill(
                  key: const ValueKey('run-status'),
                  label: result.status.label(l10n),
                  color: result.status.color(context),
                ),
              if (result?.exitCode case final code?)
                Text(l10n.terminalExitCode(code)),
              if (result != null && result.duration > Duration.zero)
                Text(
                  l10n.terminalDuration(
                    (result.duration.inMilliseconds / 1000).toStringAsFixed(1),
                  ),
                ),
            ],
          ),
          if (result?.status == RunStatus.startFailed)
            Text(l10n.terminalStartFailed(spec.executable)),
          if (result?.status == RunStatus.simulated)
            Text(l10n.cmdSimulationNote),
          if (result?.status == RunStatus.blocked)
            for (final issue in result!.decision.issues) Text(issue.text(l10n)),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<_Filter>(
                segments: [
                  ButtonSegment(
                    value: _Filter.all,
                    label: Text(l10n.terminalFilterAll),
                  ),
                  ButtonSegment(
                    value: _Filter.stdout,
                    label: Text(l10n.terminalFilterStdout),
                  ),
                  ButtonSegment(
                    value: _Filter.stderr,
                    label: Text(l10n.terminalFilterStderr),
                  ),
                ],
                selected: {_filter},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _filter = s.first),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await Clipboard.setData(
                    ClipboardData(
                      text: [
                        '\$ ${spec.display}',
                        ...lines.map((l) => l.text),
                      ].join('\n'),
                    ),
                  );
                  showInfo(messenger, l10n.terminalCopied);
                },
                icon: const Icon(Icons.copy),
                label: Text(l10n.terminalCopy),
              ),
              if (state.running)
                FilledButton.icon(
                  key: const ValueKey('terminal-stop'),
                  style: FilledButton.styleFrom(
                    backgroundColor: LaunchPalette.of(context).statusFailed,
                  ),
                  onPressed: ref
                      .read(terminalControllerProvider.notifier)
                      .cancel,
                  icon: const Icon(Icons.stop),
                  label: Text(l10n.terminalStop),
                ),
            ],
          ),
          if (result?.truncated ?? false) Text(l10n.terminalTruncated),
          OutputView(lines),
        ],
      ),
    );
  }
}

/// Zone de sortie à défilement indépendant, stderr en rouge.
class OutputView extends StatelessWidget {
  const OutputView(this.lines, {super.key});

  final List<OutputLine> lines;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      height: 1.45,
      color: Color(0xFFD7DCF0),
    );
    return Container(
      height: 320,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF060914),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LaunchPalette.of(context).glassBorder),
      ),
      child: lines.isEmpty
          ? Text(context.l10n.terminalNoOutput, style: style)
          : SelectionArea(
              child: ListView.builder(
                key: const ValueKey('terminal-output'),
                itemCount: lines.length,
                itemBuilder: (context, i) => Text(
                  lines[i].text,
                  style: lines[i].stream == OutputStream.stderr
                      ? style.copyWith(color: const Color(0xFFFF8A8A))
                      : style,
                ),
              ),
            ),
    );
  }
}

class _History extends ConsumerWidget {
  const _History();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final entries = ref.watch(currentCommandLogProvider).value ?? const [];
    if (entries.isEmpty) return Text(l10n.terminalHistoryEmpty);
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (final e in entries)
            ListTile(
              key: ValueKey('history-${e.id}'),
              dense: true,
              title: Text(
                [e.executable, ...e.arguments].join(' '),
                style: const TextStyle(fontFamily: 'monospace'),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(context.formatDate(e.startedAt)),
              trailing: _statusPill(context, e),
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    [e.executable, ...e.arguments].join(' '),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  content: SizedBox(
                    width: 640,
                    child: OutputView(CommandLogRepository.outputOf(e)),
                  ),
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
    );
  }

  Widget _statusPill(BuildContext context, CommandLogEntry e) {
    final status = RunStatus.values.asNameMap()[e.status];
    if (status == null) return const SizedBox.shrink();
    return Pill(
      label: status.label(context.l10n),
      color: status.color(context),
    );
  }
}
