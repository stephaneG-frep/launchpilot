import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/widgets/badges.dart';
import '../../settings/application/api_keys_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../application/llm_service.dart';
import '../domain/llm_trial.dart';
import '../domain/prompt_builder.dart';
import 'llm_send_dialog.dart';

/// Essai de génération structurée avec le fournisseur préféré.
class LlmTrialCard extends ConsumerWidget {
  const LlmTrialCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final provider = ref.watch(
      settingsControllerProvider.select((s) => s.llmProvider),
    );
    final hasKey =
        ref.watch(apiKeysControllerProvider).value?.hasKey(provider) ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(l10n.llmTrialTitle, style: theme.textTheme.titleMedium),
        Text(l10n.llmTrialHint),
        if (!hasKey) Text(l10n.llmTrialNeedsKey(provider.label)),
        FilledButton.tonalIcon(
          key: const ValueKey('llm-trial'),
          onPressed: hasKey
              ? () {
                  final model = ref.read(llmModelsProvider)[provider]!;
                  final payload = PromptBuilder.build(
                    provider: provider,
                    model: model,
                    system: LlmTrial.system(l10n.llmTrialLanguage),
                    instruction: l10n.llmTrialPrompt,
                    schemaName: LlmTrial.schemaName,
                    schema: LlmTrial.schema,
                  );
                  showLlmSendDialog(
                    context,
                    payload: payload,
                    resultBuilder: (context, result) =>
                        _TrialResult(result.data),
                  );
                }
              : null,
          icon: const Icon(Icons.auto_awesome),
          label: Text('${l10n.llmTrialButton} · ${provider.label}'),
        ),
      ],
    );
  }
}

class _TrialResult extends StatelessWidget {
  const _TrialResult(this.data);

  final Map<String, Object?> data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final terms = (data['terms'] as List?)?.cast<String>() ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(l10n.llmTrialAnswer, style: theme.textTheme.labelLarge),
        SelectableText('${data['answer']}'),
        if (terms.isNotEmpty) ...[
          Text(l10n.llmTrialTerms, style: theme.textTheme.labelLarge),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in terms)
                Pill(label: t, color: theme.colorScheme.tertiary),
            ],
          ),
        ],
      ],
    );
  }
}
