import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/page_frame.dart';
import '../../demo/demo_catalog.dart';
import '../../demo/demo_providers.dart';
import 'terminal_workspace.dart';
import '../../../core/widgets/feedback.dart';

enum TerminalFilter { all, stdout, stderr }

class TerminalScreen extends ConsumerWidget {
  const TerminalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final demo = ref.watch(demoCatalogProvider);

    return PageFrame(
      icon: Icons.terminal,
      title: l10n.terminalTitle,
      subtitle: l10n.terminalSubtitle,
      children: [
        if (demo == null) const TerminalWorkspace() else _DemoTerminal(demo),
      ],
    );
  }
}

class _DemoTerminal extends StatefulWidget {
  const _DemoTerminal(this.catalog);

  final DemoCatalog catalog;

  @override
  State<_DemoTerminal> createState() => _DemoTerminalState();
}

class _DemoTerminalState extends State<_DemoTerminal> {
  TerminalFilter _filter = TerminalFilter.all;

  List<DemoTerminalLine> get _visible =>
      widget.catalog.terminalLines.where((line) {
        return switch (_filter) {
          TerminalFilter.all => true,
          TerminalFilter.stdout => line.stream == TerminalStream.stdout,
          TerminalFilter.stderr => line.stream == TerminalStream.stderr,
        };
      }).toList();

  Future<void> _copy() async {
    final text = [
      '\$ ${widget.catalog.terminalCommand}',
      for (final line in _visible) line.text,
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showInfo(ScaffoldMessenger.of(context), context.l10n.terminalCopied);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final catalog = widget.catalog;
    final exitOk = catalog.terminalExitCode == 0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '\$ ${catalog.terminalCommand}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              Pill(
                label: l10n.terminalSimulated,
                color: palette.accentOrange,
                icon: Icons.science_outlined,
              ),
              Pill(
                label: l10n.terminalExitCode(catalog.terminalExitCode),
                color: exitOk ? palette.statusSucceeded : palette.statusFailed,
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<TerminalFilter>(
                segments: [
                  ButtonSegment(
                    value: TerminalFilter.all,
                    label: Text(l10n.terminalFilterAll),
                  ),
                  ButtonSegment(
                    value: TerminalFilter.stdout,
                    label: Text(l10n.terminalFilterStdout),
                  ),
                  ButtonSegment(
                    value: TerminalFilter.stderr,
                    label: Text(l10n.terminalFilterStderr),
                  ),
                ],
                selected: {_filter},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _filter = s.first),
              ),
              OutlinedButton.icon(
                onPressed: _copy,
                icon: const Icon(Icons.copy),
                label: Text(l10n.terminalCopy),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF060914),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.glassBorder),
            ),
            child: SelectableText.rich(
              TextSpan(
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.55,
                  color: Color(0xFFD7DCF0),
                ),
                children: [
                  for (final line in _visible)
                    TextSpan(
                      text: '${line.text}\n',
                      style: line.stream == TerminalStream.stderr
                          ? const TextStyle(color: Color(0xFFFF8A8A))
                          : null,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
