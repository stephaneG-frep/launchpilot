import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/feedback.dart';
import '../../git/domain/git_status.dart';
import '../../projects/application/project_providers.dart';
import '../application/change_providers.dart';
import '../data/project_writer.dart';
import '../domain/change_set.dart';
import '../domain/line_diff.dart';

/// Montre le diff de chaque fichier puis, après confirmation, écrit avec
/// sauvegarde. Renvoie vrai si les fichiers ont été écrits.
Future<bool> showChangePreview(
  BuildContext context,
  WidgetRef ref,
  ChangeSet set, {
  GitStatus? git,
}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final ws = ref.read(currentWorkspaceProvider).value;
  if (ws == null) return false;
  final confirmed =
      await showDialog<bool>(
        context: context,
        builder: (_) => _ChangePreviewDialog(set: set, git: git),
      ) ??
      false;
  if (!confirmed) return false;

  final writer = ref.read(projectWriterProvider);
  try {
    await writer.apply(
      ws.project.id,
      ws.project.path,
      set,
      writer.approve(set),
    );
    showInfo(messenger, l10n.writeDone);
    return true;
  } on WriteException catch (e) {
    showInfo(
      messenger,
      e.issue == WriteIssue.changedSincePreview
          ? l10n.writeChangedSincePreview
          : l10n.writeRefused(e.path ?? ''),
    );
    return false;
  }
}

class _ChangePreviewDialog extends StatelessWidget {
  const _ChangePreviewDialog({required this.set, this.git});

  final ChangeSet set;
  final GitStatus? git;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final dirty = git != null && git!.isRepo && !git!.clean;

    return AlertDialog(
      icon: const Icon(Icons.difference_outlined),
      title: Text(l10n.writePreviewTitle),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(set.label, style: theme.textTheme.titleSmall),
              if (dirty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: palette.statusWarning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(l10n.writeDirtyWarning(git!.changes.length)),
                    ),
                  ],
                ),
              for (final f in set.files.where((f) => f.changes)) _FileDiff(f),
              Text(
                l10n.writeBackupNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton.icon(
          key: const ValueKey('write-confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.save_outlined),
          label: Text(l10n.writeConfirm),
        ),
      ],
    );
  }
}

class _FileDiff extends StatelessWidget {
  const _FileDiff(this.change);

  final PlannedFileChange change;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = LaunchPalette.of(context);
    final hunks = change.diff;
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.4);

    if (!change.isText) return _BinaryPreview(change);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          change.creates
              ? '${change.path} · ${l10n.writeFileNew}'
              : change.path,
          style: mono.copyWith(fontWeight: FontWeight.w700),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF060914),
            borderRadius: BorderRadius.circular(10),
          ),
          child: hunks == null
              ? Text(
                  l10n.writeTooBig,
                  style: mono.copyWith(color: Colors.white70),
                )
              : SelectableText.rich(
                  key: ValueKey('diff-${change.path}'),
                  TextSpan(
                    style: mono.copyWith(color: const Color(0xFFD7DCF0)),
                    children: [
                      for (final h in hunks) ...[
                        TextSpan(
                          text: '${h.header}\n',
                          style: TextStyle(color: palette.statusPedagogy),
                        ),
                        for (final l in h.lines)
                          TextSpan(
                            text: switch (l.op) {
                              DiffOp.same => '  ${l.text}\n',
                              DiffOp.added => '+ ${l.text}\n',
                              DiffOp.removed => '- ${l.text}\n',
                            },
                            style: switch (l.op) {
                              DiffOp.same => null,
                              DiffOp.added => const TextStyle(
                                color: Color(0xFF7EE787),
                              ),
                              DiffOp.removed => const TextStyle(
                                color: Color(0xFFFF8A8A),
                              ),
                            },
                          ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

/// Aperçu d'un fichier binaire : vignettes avant/après pour une image,
/// sinon sa taille.
class _BinaryPreview extends StatelessWidget {
  const _BinaryPreview(this.change);

  final PlannedFileChange change;

  static bool _isImage(String path) =>
      RegExp(r'\.(png|jpe?g|webp|gif)$', caseSensitive: false).hasMatch(path);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 13);
    Widget thumb(String label, List<int>? bytes) => Column(
      spacing: 4,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: bytes == null
              ? const Icon(Icons.add, size: 20)
              : Image.memory(
                  Uint8List.fromList(bytes),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                ),
        ),
      ],
    );

    return Row(
      spacing: 12,
      children: [
        if (_isImage(change.path)) ...[
          thumb(l10n.writeImageBefore, change.beforeBytes),
          const Icon(Icons.arrow_forward, size: 18),
          thumb(l10n.writeImageAfter, change.afterBytes),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                change.creates
                    ? '${change.path} · ${l10n.writeFileNew}'
                    : change.path,
                style: mono.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                l10n.writeBinary(change.afterBytes.length),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
