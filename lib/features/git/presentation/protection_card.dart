import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../changes/application/change_providers.dart';
import '../../changes/data/project_writer.dart';
import '../../changes/presentation/change_preview_dialog.dart';
import '../../commands/domain/command_spec.dart';
import '../../commands/presentation/command_preview_dialog.dart';
import '../../projects/domain/project_views.dart';
import '../application/git_providers.dart';
import '../domain/git_status.dart';
import '../domain/gitignore_advisor.dart';

/// Protection du projet : état Git en direct, branche de version, fichiers
/// sensibles à ignorer et modifications de LaunchPilot restaurables.
class ProtectionCard extends ConsumerWidget {
  const ProtectionCard(this.ws, {super.key});

  final ProjectWorkspace ws;

  void _refresh(WidgetRef ref) {
    ref.invalidate(gitStatusProvider);
    ref.invalidate(gitignoreProposalProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final status = ref.watch(gitStatusProvider);
    final proposal = ref.watch(gitignoreProposalProvider).value ?? const [];
    final changes = ref.watch(currentFileChangesProvider).value ?? const [];
    final git = status.value;
    final session = ws.activeSession;

    return GlassCard(
      accent: palette.statusPedagogy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: palette.statusPedagogy),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.protectionTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                key: const ValueKey('protection-refresh'),
                tooltip: l10n.protectionRefresh,
                onPressed: () => _refresh(ref),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (status.isLoading && git == null)
            const LinearProgressIndicator()
          else if (git == null || !git.isRepo)
            Text(l10n.protectionNoGit)
          else ...[
            Text(
              git.branch == null
                  ? l10n.protectionDetached
                  : l10n.protectionOnBranch(git.branch!),
            ),
            Row(
              children: [
                Icon(
                  git.clean ? Icons.check_circle_outline : Icons.edit_note,
                  size: 18,
                  color: git.clean
                      ? palette.statusSucceeded
                      : palette.statusWarning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    git.clean
                        ? l10n.protectionClean
                        : l10n.protectionDirty(git.changes.length),
                  ),
                ),
              ],
            ),
            if (!git.clean) ...[
              Text(l10n.protectionDirtyHint, style: theme.textTheme.bodySmall),
              for (final c in git.changes.take(8))
                Text(
                  '${c.index}${c.worktree} ${c.path}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              if (git.changes.length > 8)
                Text('…', style: theme.textTheme.bodySmall),
            ],
            if (session != null &&
                git.branch != releaseBranchName(session.version))
              OutlinedButton.icon(
                key: const ValueKey('protection-branch'),
                onPressed: () async {
                  final r = await previewAndRun(
                    context,
                    ref,
                    CommandSpec(
                      executable: 'git',
                      arguments: [
                        'switch',
                        '-c',
                        releaseBranchName(session.version),
                      ],
                      workingDirectory: ws.project.path,
                    ),
                    openTerminal: false,
                  );
                  if (r != null) _refresh(ref);
                },
                icon: const Icon(Icons.call_split),
                label: Text(
                  l10n.protectionCreateBranch(
                    releaseBranchName(session.version),
                  ),
                ),
              ),
          ],
          if (proposal.isNotEmpty) ...[
            const Divider(),
            Text(
              l10n.protectionGitignoreTitle,
              style: theme.textTheme.titleSmall,
            ),
            Text(l10n.protectionGitignoreHint(proposal.join(', '))),
            FilledButton.tonalIcon(
              key: const ValueKey('protection-gitignore'),
              onPressed: () async {
                final writer = ref.read(projectWriterProvider);
                final current = writer.readCurrent(
                  ws.project.path,
                  '.gitignore',
                );
                final set = await writer.plan(
                  ws.project.path,
                  l10n.protectionGitignoreLabel,
                  {'.gitignore': gitignoreWithEntries(current, proposal)},
                );
                if (!context.mounted) return;
                if (await showChangePreview(context, ref, set, git: git)) {
                  _refresh(ref);
                }
              },
              icon: const Icon(Icons.shield),
              label: Text(l10n.protectionGitignoreAction),
            ),
          ],
          const Divider(),
          Text(l10n.protectionChanges, style: theme.textTheme.titleSmall),
          if (changes.isEmpty)
            Text(l10n.protectionChangesEmpty)
          else
            for (final c in changes)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${c.path} · ${c.existedBefore ? l10n.changeModified : l10n.changeCreated}',
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                        Text(
                          c.restoredAt == null
                              ? '${c.label} · ${context.formatDate(c.appliedAt)}'
                              : l10n.protectionRestored(
                                  context.formatDate(c.restoredAt!),
                                ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (c.restoredAt == null)
                    TextButton.icon(
                      key: ValueKey('restore-${c.id}'),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final outcome = await ref
                            .read(projectWriterProvider)
                            .restore(ws.project.path, c.id);
                        showInfo(messenger, switch (outcome) {
                          RestoreOutcome.restored ||
                          RestoreOutcome.alreadyRestored => l10n.restoreDone,
                          RestoreOutcome.conflict => l10n.restoreConflict,
                          RestoreOutcome.backupMissing =>
                            l10n.restoreBackupMissing,
                        });
                        _refresh(ref);
                      },
                      icon: const Icon(Icons.restore),
                      label: Text(l10n.protectionRestore),
                    ),
                ],
              ),
        ],
      ),
    );
  }
}
