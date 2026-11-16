import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../detection/application/detection_providers.dart';
import '../application/project_providers.dart';
import '../domain/project_validation.dart';
import '../../../core/widgets/feedback.dart';

String pathIssueText(AppLocalizations l10n, ProjectPathIssue issue) =>
    switch (issue) {
      ProjectPathIssue.empty => l10n.pathErrorEmpty,
      ProjectPathIssue.notAbsolute => l10n.pathErrorNotAbsolute,
      ProjectPathIssue.notFound => l10n.pathErrorNotFound,
      ProjectPathIssue.alreadyRegistered => l10n.pathErrorAlreadyRegistered,
    };

/// Ajout d'un projet via le sélecteur de dossier natif. Renvoie vrai si un
/// projet a été ajouté (ou rouvert).
Future<bool> pickAndAddProject(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final path = await ref
      .read(folderPickerProvider)
      .pickDirectory(title: l10n.pickerConfirm);
  if (path == null) return false;
  try {
    final r = await ref.read(projectActionsProvider).addAndOpen(path);
    showInfo(
      messenger,
      r.created
          ? l10n.projectAdded(r.project.name)
          : l10n.projectAlreadyKnown(r.project.name),
    );
    return true;
  } on ProjectPathException catch (e) {
    showInfo(messenger, pathIssueText(l10n, e.issue));
    return false;
  }
}

/// Ajout d'un projet en saisissant son chemin (ou via « Parcourir… »).
Future<bool> showAddProjectDialog(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final actions = ref.read(projectActionsProvider);
  final added = await showDialog<({String name, bool created})>(
    context: context,
    builder: (context) => _TextFormDialog(
      icon: Icons.create_new_folder_outlined,
      title: l10n.addProjectTitle,
      note: l10n.addProjectPickerNote,
      fieldKey: const ValueKey('add-project-path'),
      label: l10n.addProjectPathLabel,
      hint: l10n.addProjectPathHint,
      secondLabel: l10n.addProjectNameLabel,
      confirm: l10n.addProjectConfirm,
      monospace: true,
      onBrowse: () => ref
          .read(folderPickerProvider)
          .pickDirectory(title: l10n.pickerConfirm),
      onSubmit: (path, name) async {
        try {
          final r = await actions.addAndOpen(path, name: name);
          return (null, (name: r.project.name, created: r.created));
        } on ProjectPathException catch (e) {
          return (pathIssueText(l10n, e.issue), null);
        }
      },
    ),
  );
  if (added == null) return false;
  showInfo(
    messenger,
    added.created
        ? l10n.projectAdded(added.name)
        : l10n.projectAlreadyKnown(added.name),
  );
  return true;
}

Future<void> showRelocateDialog(
  BuildContext context,
  WidgetRef ref,
  Project project,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final actions = ref.read(projectActionsProvider);
  final done = await showDialog<bool>(
    context: context,
    builder: (context) => _TextFormDialog(
      icon: Icons.drive_file_move_outline,
      title: l10n.relocateTitle(project.name),
      note: l10n.relocateOldPath(project.path),
      fieldKey: const ValueKey('relocate-path'),
      label: l10n.addProjectPathLabel,
      hint: l10n.addProjectPathHint,
      confirm: l10n.relocateConfirm,
      monospace: true,
      onBrowse: () => ref
          .read(folderPickerProvider)
          .pickDirectory(
            initialDirectory: p.dirname(project.path),
            title: l10n.pickerConfirm,
          ),
      onSubmit: (path, _) async {
        try {
          await actions.relocate(project.id, path);
          return (null, true);
        } on ProjectPathException catch (e) {
          return (pathIssueText(l10n, e.issue), null);
        }
      },
    ),
  );
  if (done == true) showInfo(messenger, l10n.projectRelocated);
}

Future<bool> showNewSessionDialog(
  BuildContext context,
  WidgetRef ref,
  Project project,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final actions = ref.read(projectActionsProvider);
  final version = await showDialog<String>(
    context: context,
    builder: (context) => _TextFormDialog(
      icon: Icons.flag_outlined,
      title: l10n.newSessionTitle(project.name),
      note: l10n.newSessionHint,
      fieldKey: const ValueKey('new-session-version'),
      label: l10n.newSessionVersionLabel,
      hint: l10n.newSessionVersionHint,
      confirm: l10n.newSessionConfirm,
      monospace: true,
      onSubmit: (raw, _) async {
        try {
          final s = await actions.startSession(project.id, raw);
          return (null, s.version);
        } on InvalidVersionException catch (e) {
          return (
            e.issue == VersionIssue.empty
                ? l10n.versionErrorEmpty
                : l10n.versionErrorInvalid,
            null,
          );
        } on ActiveSessionExistsException {
          return (l10n.sessionErrorActiveExists, null);
        }
      },
    ),
  );
  if (version == null) return false;
  showInfo(messenger, l10n.sessionStarted(version));
  return true;
}

Future<void> showRemoveProjectDialog(
  BuildContext context,
  WidgetRef ref,
  Project project,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final impact = await ref
      .read(projectRepositoryProvider)
      .deletionImpact(project.id);
  if (!context.mounted) return;
  final confirmed = await _confirm(
    context,
    icon: Icons.playlist_remove,
    title: l10n.removeProjectTitle(project.name),
    message: l10n.removeProjectMessage(impact.sessions, impact.steps),
    confirm: l10n.removeProjectConfirm,
    confirmKey: const ValueKey('remove-project-confirm'),
  );
  if (!confirmed) return;
  await ref.read(projectActionsProvider).remove(project.id);
  showInfo(messenger, l10n.projectRemoved);
}

Future<void> showCloseSessionDialog(
  BuildContext context,
  WidgetRef ref,
  ReleaseSession session,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await _confirm(
    context,
    icon: Icons.flag_circle_outlined,
    title: l10n.closeSessionTitle(session.version),
    message: l10n.closeSessionMessage,
    confirm: l10n.closeSessionConfirm,
    confirmKey: const ValueKey('close-session-confirm'),
  );
  if (!confirmed) return;
  await ref.read(projectActionsProvider).completeSession(session.id);
  showInfo(messenger, l10n.sessionClosed);
}

Future<bool> _confirm(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String confirm,
  required Key confirmKey,
}) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(icon),
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Text(message),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: confirmKey,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Résultat d'une soumission : message d'erreur, ou valeur de retour.
typedef _Submit<T> = Future<(String?, T?)> Function(
  String value,
  String? second,
);

/// Dialogue à un ou deux champs dont la validation est faite à l'envoi.
class _TextFormDialog<T> extends StatefulWidget {
  const _TextFormDialog({
    required this.icon,
    required this.title,
    required this.note,
    required this.fieldKey,
    required this.label,
    required this.hint,
    required this.confirm,
    required this.onSubmit,
    this.secondLabel,
    this.monospace = false,
    this.onBrowse,
  });

  final IconData icon;
  final String title;
  final String note;
  final Key fieldKey;
  final String label;
  final String hint;
  final String? secondLabel;
  final String confirm;
  final bool monospace;
  final _Submit<T> onSubmit;

  /// Ouvre le sélecteur de dossier natif pour remplir le champ.
  final Future<String?> Function()? onBrowse;

  @override
  State<_TextFormDialog<T>> createState() => _TextFormDialogState<T>();
}

class _TextFormDialogState<T> extends State<_TextFormDialog<T>> {
  final _value = TextEditingController();
  final _second = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _value.dispose();
    _second.dispose();
    super.dispose();
  }

  Future<void> _browse() async {
    final path = await widget.onBrowse!();
    if (path == null || !mounted) return;
    setState(() {
      _value.text = path;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final (error, result) = await widget.onSubmit(
      _value.text,
      widget.secondLabel == null ? null : _second.text,
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(result);
    } else {
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AlertDialog(
      icon: Icon(widget.icon),
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, minWidth: 280),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 14,
            children: [
              Text(
                widget.note,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextField(
                key: widget.fieldKey,
                controller: _value,
                autofocus: true,
                autocorrect: false,
                enableSuggestions: false,
                style: widget.monospace
                    ? const TextStyle(fontFamily: 'monospace')
                    : null,
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hint,
                  errorText: _error,
                  errorMaxLines: 3,
                  suffixIcon: widget.onBrowse == null
                      ? null
                      : IconButton(
                          key: const ValueKey('dialog-browse'),
                          tooltip: l10n.addProjectBrowse,
                          icon: const Icon(Icons.folder_open),
                          onPressed: _browse,
                        ),
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _submit(),
              ),
              if (widget.secondLabel != null)
                TextField(
                  key: const ValueKey('dialog-second-field'),
                  controller: _second,
                  maxLength: 120,
                  decoration: InputDecoration(labelText: widget.secondLabel),
                  onSubmitted: (_) => _submit(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('dialog-confirm'),
          onPressed: _busy ? null : _submit,
          child: Text(widget.confirm),
        ),
      ],
    );
  }
}
