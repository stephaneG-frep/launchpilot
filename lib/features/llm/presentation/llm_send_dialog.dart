import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/explanation_level.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../settings/application/settings_controller.dart';
import '../application/llm_service.dart';
import '../domain/llm_types.dart';
import '../domain/prompt_builder.dart';
import 'llm_error_text.dart';

/// Affiche l'aperçu de [payload], demande une confirmation propre à cet
/// envoi, puis exécute la requête avec possibilité d'annuler.
Future<LlmResult?> showLlmSendDialog(
  BuildContext context, {
  required LlmPayload payload,
  required Widget Function(BuildContext, LlmResult) resultBuilder,
}) => showDialog<LlmResult>(
  context: context,
  barrierDismissible: false,
  builder: (_) => LlmSendDialog(payload: payload, resultBuilder: resultBuilder),
);

enum _Stage { preview, sending, done, failed }

class LlmSendDialog extends ConsumerStatefulWidget {
  const LlmSendDialog({
    super.key,
    required this.payload,
    required this.resultBuilder,
  });

  final LlmPayload payload;
  final Widget Function(BuildContext, LlmResult) resultBuilder;

  @override
  ConsumerState<LlmSendDialog> createState() => _LlmSendDialogState();
}

class _LlmSendDialogState extends ConsumerState<LlmSendDialog> {
  _Stage _stage = _Stage.preview;
  late bool _showPreview;
  CancellationToken? _cancel;
  LlmResult? _result;
  (String, String?)? _error;

  @override
  void initState() {
    super.initState();
    // En mode Débutant, l'aperçu de ce qui sera transmis est déplié d'office.
    _showPreview =
        ref.read(settingsControllerProvider).explanationLevel ==
        ExplanationLevel.beginner;
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final service = ref.read(llmServiceProvider);
    // La confirmation est créée ici, au clic, pour ce contenu exact.
    final consent = service.grantConsent(widget.payload);
    final cancel = CancellationToken();
    setState(() {
      _stage = _Stage.sending;
      _cancel = cancel;
    });
    try {
      final result = await service.send(
        widget.payload,
        consent,
        cancel: cancel,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _stage = _Stage.done;
      });
    } on LlmException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = describeLlmError(l10n, e);
        _stage = _Stage.failed;
      });
    } on ConsentException {
      if (!mounted) return;
      setState(() {
        _error = (l10n.llmErrConsent, null);
        _stage = _Stage.failed;
      });
    } finally {
      _cancel = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = widget.payload;
    final label = p.provider.label;

    return AlertDialog(
      icon: const Icon(Icons.auto_awesome_outlined),
      title: Text(switch (_stage) {
        _Stage.preview || _Stage.sending => l10n.sendTitle(label),
        _Stage.done => l10n.sendDoneTitle,
        _Stage.failed => l10n.sendFailedTitle,
      }),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, minWidth: 280),
        child: SingleChildScrollView(
          child: switch (_stage) {
            _Stage.preview => _preview(context),
            _Stage.sending => Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                const LinearProgressIndicator(),
                Text(l10n.sendInProgress),
              ],
            ),
            _Stage.done => _done(context),
            _Stage.failed => _failed(context),
          },
        ),
      ),
      actions: switch (_stage) {
        _Stage.preview => [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton.icon(
            key: const ValueKey('llm-send-confirm'),
            onPressed: _send,
            icon: const Icon(Icons.send),
            label: Text(l10n.sendConfirm),
          ),
        ],
        _Stage.sending => [
          TextButton.icon(
            key: const ValueKey('llm-send-cancel'),
            onPressed: () => _cancel?.cancel(),
            icon: const Icon(Icons.stop),
            label: Text(l10n.sendCancelRequest),
          ),
        ],
        _Stage.done || _Stage.failed => [
          FilledButton(
            key: const ValueKey('llm-send-close'),
            onPressed: () => Navigator.of(context).pop(_result),
            child: Text(l10n.commonClose),
          ),
        ],
      },
    );
  }

  Widget _preview(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final p = widget.payload;
    final mono = theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace');

    Widget block(String label, String text) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: SelectableText(text, style: mono),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(l10n.sendModel(p.model)),
        Text(l10n.sendSize(p.approxInputTokens)),
        Row(
          children: [
            Icon(
              Icons.shield_outlined,
              size: 18,
              color: p.redactionCount == 0
                  ? palette.statusSucceeded
                  : palette.statusWarning,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.sendRedactions(p.redactionCount))),
          ],
        ),
        if (p.excludedFiles.isNotEmpty)
          Text(l10n.sendExcluded(p.excludedFiles.join(', '))),
        Text(
          p.includesProjectData ? l10n.sendProjectData : l10n.sendNoProjectData,
          style: p.includesProjectData
              ? TextStyle(color: palette.statusWarning)
              : null,
        ),
        TextButton.icon(
          key: const ValueKey('llm-send-toggle-preview'),
          onPressed: () => setState(() => _showPreview = !_showPreview),
          icon: Icon(_showPreview ? Icons.visibility_off : Icons.visibility),
          label: Text(
            _showPreview ? l10n.sendHidePreview : l10n.sendShowPreview,
          ),
        ),
        if (_showPreview) ...[
          block(l10n.sendSystemLabel, p.system),
          block(l10n.sendUserLabel, p.userContent),
        ],
        Text(
          l10n.sendConsentNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _done(BuildContext context) {
    final l10n = context.l10n;
    final r = _result!;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        widget.resultBuilder(context, r),
        const Divider(),
        Text(l10n.sendServedBy(r.model), style: theme.textTheme.bodySmall),
        if (r.usage case final usage?)
          Text(
            l10n.sendUsage(
              usage.inputTokens,
              usage.outputTokens,
              (r.elapsed.inMilliseconds / 1000).toStringAsFixed(1),
            ),
            style: theme.textTheme.bodySmall,
          ),
      ],
    );
  }

  Widget _failed(BuildContext context) {
    final (message, detail) = _error!;
    final palette = LaunchPalette.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.error_outline, color: palette.statusFailed),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(message),
              if (detail != null)
                SelectableText(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
