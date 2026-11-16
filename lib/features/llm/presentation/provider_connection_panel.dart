import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../application/llm_service.dart';
import '../domain/llm_provider_id.dart';
import '../domain/llm_types.dart';
import 'llm_error_text.dart';

/// Choix du modèle et test de connexion d'un fournisseur.
class ProviderConnectionPanel extends ConsumerStatefulWidget {
  const ProviderConnectionPanel({
    super.key,
    required this.provider,
    required this.keyStored,
  });

  final LlmProviderId provider;
  final bool keyStored;

  @override
  ConsumerState<ProviderConnectionPanel> createState() =>
      _ProviderConnectionPanelState();
}

class _ProviderConnectionPanelState
    extends ConsumerState<ProviderConnectionPanel> {
  late final TextEditingController _model;
  CancellationToken? _cancel;
  ConnectionReport? _report;
  LlmException? _error;

  LlmProviderId get _id => widget.provider;

  @override
  void initState() {
    super.initState();
    final current = ref.read(llmModelsProvider)[_id]!;
    _model = TextEditingController(
      text: current == _id.defaultModel ? '' : current,
    );
  }

  @override
  void dispose() {
    _cancel?.cancel();
    _model.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    final cancel = CancellationToken();
    setState(() {
      _cancel = cancel;
      _report = null;
      _error = null;
    });
    try {
      final report = await ref
          .read(llmServiceProvider)
          .testConnection(_id, cancel: cancel);
      if (mounted) setState(() => _report = report);
    } on LlmException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _cancel = null);
    }
  }

  void _chooseModel(String model) {
    _model.text = model;
    ref.read(llmModelsProvider.notifier).setModel(_id, model);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final model = ref.watch(llmModelsProvider)[_id]!;
    final testing = _cancel != null;
    final report = _report;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: TextField(
                key: ValueKey('llm-model-${_id.name}'),
                controller: _model,
                autocorrect: false,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: l10n.llmModelLabel,
                  hintText: _id.defaultModel,
                  helperText: l10n.llmModelDefault(_id.defaultModel),
                  isDense: true,
                ),
                onChanged: (v) =>
                    ref.read(llmModelsProvider.notifier).setModel(_id, v),
              ),
            ),
            if (report != null && report.availableModels.isNotEmpty)
              PopupMenuButton<String>(
                key: ValueKey('llm-choose-model-${_id.name}'),
                tooltip: l10n.llmChooseModel,
                icon: const Icon(Icons.list_alt),
                onSelected: _chooseModel,
                itemBuilder: (_) => [
                  for (final m in report.availableModels)
                    PopupMenuItem(value: m, child: Text(m)),
                ],
              ),
            if (testing)
              TextButton.icon(
                key: ValueKey('llm-test-cancel-${_id.name}'),
                onPressed: () => _cancel?.cancel(),
                icon: const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                label: Text(l10n.llmTestCancel),
              )
            else
              OutlinedButton.icon(
                key: ValueKey('llm-test-${_id.name}'),
                onPressed: widget.keyStored ? _test : null,
                icon: const Icon(Icons.network_check),
                label: Text(l10n.llmTest),
              ),
          ],
        ),
        if (report != null) ...[
          _Line(
            icon: Icons.check_circle,
            color: palette.statusSucceeded,
            text: l10n.llmTestOk(
              report.latency.inMilliseconds,
              report.availableModels.length,
            ),
          ),
          _Line(
            icon: report.availableModels.contains(model)
                ? Icons.check
                : Icons.warning_amber_rounded,
            color: report.availableModels.contains(model)
                ? palette.statusSucceeded
                : palette.statusWarning,
            text: report.availableModels.contains(model)
                ? l10n.llmTestModelOk(model)
                : l10n.llmTestModelMissing(model),
          ),
        ],
        if (_error case final error?)
          Builder(
            builder: (context) {
              final (message, detail) = describeLlmError(l10n, error);
              return _Line(
                icon: Icons.error_outline,
                color: palette.statusFailed,
                text: message,
                detail: detail,
                style: theme.textTheme.bodySmall,
              );
            },
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.icon,
    required this.color,
    required this.text,
    this.detail,
    this.style,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String? detail;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text),
              if (detail != null)
                SelectableText(
                  detail!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
