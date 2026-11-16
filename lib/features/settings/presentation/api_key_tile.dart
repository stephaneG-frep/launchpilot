import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/storage/secret_store.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/badges.dart';
import '../../../l10n/app_localizations.dart';
import '../../llm/domain/llm_provider_id.dart';
import '../../llm/presentation/provider_connection_panel.dart';
import '../application/api_keys_controller.dart';
import '../data/api_key_repository.dart';
import '../../../core/widgets/feedback.dart';

/// Saisie et suppression d'une clé API. La clé saisie est masquée, n'est
/// jamais relue depuis le trousseau et le champ est vidé après enregistrement.
class ApiKeyTile extends ConsumerStatefulWidget {
  const ApiKeyTile({super.key, required this.provider});

  final LlmProviderId provider;

  @override
  ConsumerState<ApiKeyTile> createState() => _ApiKeyTileState();
}

class _ApiKeyTileState extends ConsumerState<ApiKeyTile> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.clear();
    _controller.dispose();
    super.dispose();
  }

  String _issueText(AppLocalizations l10n, ApiKeyIssue issue) =>
      switch (issue) {
        ApiKeyIssue.empty => l10n.apiKeyErrorEmpty,
        ApiKeyIssue.tooShort => l10n.apiKeyErrorTooShort,
        ApiKeyIssue.tooLong => l10n.apiKeyErrorTooLong,
        ApiKeyIssue.invalidCharacters => l10n.apiKeyErrorInvalidChars,
      };

  Future<void> _save() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final issue = ApiKeyValidator.validate(_controller.text);
    if (issue != null) {
      setState(() => _error = _issueText(l10n, issue));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(apiKeysControllerProvider.notifier)
          .save(widget.provider, _controller.text);
      _controller.clear();
      showInfo(messenger, l10n.apiKeySaved(widget.provider.label));
    } on SecretStoreUnavailableException {
      if (mounted) setState(() => _error = l10n.apiKeyStorageError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final label = widget.provider.label;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: Text(l10n.apiKeyDeleteTitle(label)),
        content: Text(l10n.apiKeyDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('api-key-delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(apiKeysControllerProvider.notifier)
          .delete(widget.provider);
      showInfo(messenger, l10n.apiKeyDeleted(label));
    } on SecretStoreUnavailableException {
      if (mounted) setState(() => _error = l10n.apiKeyStorageError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final keys = ref.watch(apiKeysControllerProvider);
    final provider = widget.provider;

    final storageFailed = keys.hasError && !keys.hasValue;
    final stored = keys.value?.hasKey(provider) ?? false;

    final Widget status;
    if (keys.isLoading && !keys.hasValue) {
      status = const SizedBox.square(
        dimension: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (storageFailed) {
      status = Pill(
        label: l10n.statusFailed,
        color: palette.statusFailed,
        icon: Icons.error_outline,
      );
    } else {
      status = Pill(
        label: stored ? l10n.apiKeyStored : l10n.apiKeyMissing,
        color: stored ? palette.statusSucceeded : palette.statusTodo,
        icon: stored ? Icons.lock : Icons.lock_open,
      );
    }

    final error = _error ?? (storageFailed ? l10n.apiKeyStorageError : null);
    final enabled = !_busy && !storageFailed && keys.hasValue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(provider.label, style: theme.textTheme.titleSmall),
              status,
            ],
          ),
          Text(
            l10n.apiKeyWhereToGet(provider.keyConsoleUrl),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: TextField(
                  key: ValueKey('api-key-field-${provider.name}'),
                  controller: _controller,
                  enabled: enabled,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      ApiKeyValidator.maxLength + 64,
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: stored
                        ? l10n.apiKeyFieldReplaceLabel(provider.label)
                        : l10n.apiKeyFieldLabel(provider.label),
                    errorText: error,
                    errorMaxLines: 3,
                    isDense: true,
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: enabled ? (_) => _save() : null,
                ),
              ),
              FilledButton.tonalIcon(
                key: ValueKey('api-key-save-${provider.name}'),
                onPressed: enabled ? _save : null,
                icon: const Icon(Icons.save_outlined),
                label: Text(stored ? l10n.apiKeyReplace : l10n.apiKeySave),
              ),
              if (stored)
                TextButton.icon(
                  key: ValueKey('api-key-delete-${provider.name}'),
                  onPressed: enabled ? _delete : null,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.commonDelete),
                ),
            ],
          ),
          ProviderConnectionPanel(provider: provider, keyStored: stored),
        ],
      ),
    );
  }
}
