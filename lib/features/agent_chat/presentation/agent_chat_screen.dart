import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/destinations.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/page_frame.dart';
import '../../checklist/application/checklist_providers.dart';
import '../../commands/application/command_providers.dart';
import '../../demo/demo_providers.dart';
import '../../detection/application/detection_providers.dart';
import '../../llm/application/llm_service.dart';
import '../../llm/domain/prompt_builder.dart';
import '../../llm/presentation/llm_send_dialog.dart';
import '../../projects/application/project_providers.dart';
import '../../settings/application/api_keys_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../application/chat_controller.dart';
import '../domain/chat.dart';

class AgentChatScreen extends ConsumerWidget {
  const AgentChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final demo = ref.watch(demoCatalogProvider);

    return PageFrame(
      icon: Icons.forum,
      title: l10n.agentTitle,
      subtitle: l10n.agentSubtitle,
      children: [
        if (demo == null)
          const _ChatWorkspace()
        else
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                const Align(alignment: Alignment.centerLeft, child: DemoTag()),
                for (final m in demo.chat)
                  _Bubble(fromUser: m.fromUser, text: m.text),
              ],
            ),
          ),
      ],
    );
  }
}

class _ChatWorkspace extends ConsumerStatefulWidget {
  const _ChatWorkspace();

  @override
  ConsumerState<_ChatWorkspace> createState() => _ChatWorkspaceState();
}

class _ChatWorkspaceState extends ConsumerState<_ChatWorkspace> {
  final _input = TextEditingController();
  final _contexts = <ChatContext>{ChatContext.project};

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final question = _input.text.trim();
    if (question.isEmpty) return;
    final settings = ref.read(settingsControllerProvider);
    final provider = settings.llmProvider;
    final ws = ref.read(currentWorkspaceProvider).value;
    final detection = ref.read(currentDetectionProvider).value;
    final checklist = ref.read(currentChecklistProvider).value;
    final last = ref.read(terminalControllerProvider).result;
    final history = ref.read(chatControllerProvider);

    String? project;
    if (_contexts.contains(ChatContext.project) && ws != null) {
      project = projectSummary(
        name: ws.project.name,
        version: ws.activeSession?.version,
        level: ws.activeSession?.currentLevel.label(l10n),
        report: detection?.report,
        targets: detection?.selected ?? const {},
      );
    }
    String? steps;
    if (_contexts.contains(ChatContext.checklist) && checklist != null) {
      steps = checklistSummary(
        checklist.steps,
        isDone: (s) => checklist.progress.isDone(s.id),
        isBlocked: checklist.progress.isBlocked,
      );
    }
    final command = _contexts.contains(ChatContext.lastCommand) && last != null
        ? commandSummary(last)
        : null;

    final LlmPayload payload;
    try {
      payload = PromptBuilder.build(
        provider: provider,
        model: ref.read(llmModelsProvider)[provider]!,
        system: ChatPrompt.system(l10n.llmTrialLanguage),
        instruction: question,
        schemaName: ChatPrompt.schemaName,
        schema: ChatPrompt.schema,
        items: chatItems(
          history: historySummary(history, you: l10n.agentYou),
          project: project,
          checklist: steps,
          lastCommand: command,
        ),
      );
    } on PayloadTooLargeException {
      showInfo(ScaffoldMessenger.of(context), l10n.chatTooLarge);
      return;
    }
    final result = await showLlmSendDialog(
      context,
      payload: payload,
      resultBuilder: (context, r) => Text('${r.data['answer'] ?? ''}'),
    );
    if (result == null || !mounted) return;
    final chat = ref.read(chatControllerProvider.notifier);
    await chat.add(
      ChatMessage(role: ChatRole.user, text: question, at: DateTime.now()),
    );
    await chat.add(
      ChatMessage(
        role: ChatRole.assistant,
        text: '${result.data['answer'] ?? ''}',
        followUps: [
          for (final f in (result.data['followUps'] as List?) ?? const [])
            if ('$f'.trim().isNotEmpty) '$f',
        ].take(3).toList(),
        model: result.model,
        at: DateTime.now(),
      ),
    );
    if (mounted) setState(_input.clear);
  }

  Future<void> _clear() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chatClearTitle),
        content: Text(l10n.chatClearMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('chat-clear-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(chatControllerProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final provider = ref.watch(
      settingsControllerProvider.select((s) => s.llmProvider),
    );
    final hasKey =
        ref.watch(apiKeysControllerProvider).value?.hasKey(provider) ?? false;
    final ws = ref.watch(currentWorkspaceProvider).value;
    final checklist = ref.watch(currentChecklistProvider).value;
    final last = ref.watch(terminalControllerProvider).result;
    final messages = ref.watch(chatControllerProvider);
    final available = {
      ChatContext.project: ws != null,
      ChatContext.checklist: checklist != null,
      ChatContext.lastCommand: last != null,
    };
    final quick = [
      l10n.chatQuickNext,
      l10n.chatQuickSimpler,
      l10n.chatQuickError,
      l10n.chatQuickRemaining,
    ];

    if (!hasKey) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(l10n.chatNoKeyTitle, style: theme.textTheme.titleMedium),
            Text(l10n.chatNoKeyMessage(provider.label)),
            FilledButton.icon(
              key: const ValueKey('chat-open-settings'),
              onPressed: () => context.go(AppDestination.settings.path),
              icon: const Icon(Icons.key_outlined),
              label: Text(l10n.chatOpenSettings),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: palette.statusPedagogy.withValues(alpha: 0.1),
          ),
          child: Text(l10n.chatSafety, key: const ValueKey('chat-safety')),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              if (messages.isEmpty)
                Text(l10n.chatEmpty, key: const ValueKey('chat-empty'))
              else
                for (final (i, m) in messages.indexed)
                  _Bubble(
                    fromUser: m.role == ChatRole.user,
                    text: m.text,
                    model: m.model,
                    followUps: i == messages.length - 1
                        ? m.followUps
                        : const [],
                    onFollowUp: (f) => setState(() => _input.text = f),
                  ),
              if (messages.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: const ValueKey('chat-clear'),
                    onPressed: _clear,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(l10n.chatClear),
                  ),
                ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.chatContextTitle, style: theme.textTheme.labelLarge),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in ChatContext.values)
                    FilterChip(
                      key: ValueKey('chat-ctx-${c.name}'),
                      label: Text(switch (c) {
                        ChatContext.project => l10n.chatCtxProject,
                        ChatContext.checklist => l10n.chatCtxChecklist,
                        ChatContext.lastCommand => l10n.chatCtxCommand,
                      }),
                      selected: _contexts.contains(c) && available[c]!,
                      onSelected: available[c]!
                          ? (v) => setState(
                              () => v ? _contexts.add(c) : _contexts.remove(c),
                            )
                          : null,
                    ),
                ],
              ),
              Text(l10n.chatContextHelp, style: theme.textTheme.bodySmall),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (i, q) in quick.indexed)
                    ActionChip(
                      key: ValueKey('chat-quick-$i'),
                      label: Text(q),
                      onPressed: () => setState(() => _input.text = q),
                    ),
                ],
              ),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('chat-input'),
                      controller: _input,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: l10n.agentComposerHint,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  FilledButton.icon(
                    key: const ValueKey('chat-send'),
                    onPressed: _input.text.trim().isEmpty ? null : _send,
                    icon: const Icon(Icons.send),
                    label: Text(l10n.agentSend),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.fromUser,
    required this.text,
    this.model,
    this.followUps = const [],
    this.onFollowUp,
  });

  final bool fromUser;
  final String text;
  final String? model;
  final List<String> followUps;
  final void Function(String)? onFollowUp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = LaunchPalette.of(context);
    // Violet : intervention de l'IA, comme le statut pédagogique.
    final color = fromUser ? scheme.primary : palette.statusPedagogy;

    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(
                fromUser ? l10n.agentYou : l10n.agentAssistant,
                style: theme.textTheme.labelMedium?.copyWith(color: color),
              ),
              SelectableText(text),
              if (model != null)
                Text(l10n.chatModel(model!), style: theme.textTheme.bodySmall),
              if (followUps.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final (i, f) in followUps.indexed)
                      ActionChip(
                        key: ValueKey('chat-followup-$i'),
                        label: Text(f),
                        onPressed: () => onFollowUp?.call(f),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
