import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../projects/application/project_providers.dart';
import '../../../core/widgets/feedback.dart';

/// Emplacement, volume et effacement contrôlé de la base locale.
class LocalDataContent extends ConsumerWidget {
  const LocalDataContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final location = ref.watch(databaseLocationProvider);
    final stats = ref.watch(localDataStatsProvider).value;

    Widget stat(String label, int? value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value?.toString() ?? '…', style: theme.textTheme.headlineSmall),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 14,
      children: [
        Text(l10n.settingsLocalDataHint),
        if (location != null)
          SelectableText(
            l10n.settingsLocalDataLocation(location),
            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        Wrap(
          spacing: 32,
          runSpacing: 12,
          children: [
            stat(l10n.statProjects, stats?.projects),
            stat(l10n.statSessions, stats?.sessions),
            stat(l10n.statSteps, stats?.steps),
          ],
        ),
        OutlinedButton.icon(
          key: const ValueKey('clear-local-data'),
          style: OutlinedButton.styleFrom(
            foregroundColor: LaunchPalette.of(context).statusFailed,
          ),
          onPressed: stats == null || stats.isEmpty
              ? null
              : () => _confirmClear(context, ref),
          icon: const Icon(Icons.delete_forever_outlined),
          label: Text(l10n.settingsClearData),
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ClearDataDialog(),
    );
    if (confirmed != true) return;
    await ref.read(projectActionsProvider).clearAllLocalData();
    showInfo(messenger, l10n.clearDataDone);
  }
}

/// Confirmation renforcée : le mot demandé doit être saisi.
class _ClearDataDialog extends StatefulWidget {
  const _ClearDataDialog();

  @override
  State<_ClearDataDialog> createState() => _ClearDataDialogState();
}

class _ClearDataDialogState extends State<_ClearDataDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final word = l10n.clearDataWord;
    final matches = _controller.text.trim() == word;
    return AlertDialog(
      icon: Icon(
        Icons.delete_forever_outlined,
        color: LaunchPalette.of(context).statusFailed,
      ),
      title: Text(l10n.clearDataTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(l10n.clearDataMessage),
            TextField(
              key: const ValueKey('clear-data-word'),
              controller: _controller,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.clearDataTypeWord(word),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('clear-data-confirm'),
          style: FilledButton.styleFrom(
            backgroundColor: LaunchPalette.of(context).statusFailed,
          ),
          onPressed: matches ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.clearDataConfirm),
        ),
      ],
    );
  }
}
