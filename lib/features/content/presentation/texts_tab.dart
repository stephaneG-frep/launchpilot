import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/adaptive_grid.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../llm/application/llm_service.dart';
import '../../llm/domain/llm_trial.dart';
import '../../llm/domain/prompt_builder.dart';
import '../../llm/presentation/llm_send_dialog.dart';
import '../../settings/application/api_keys_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_settings.dart';
import '../application/content_providers.dart';
import '../data/content_repository.dart';
import '../domain/store_texts.dart';
import 'content_workspace.dart';

String fieldLabel(AppLocalizations l10n, StoreField f) => switch (f) {
  StoreField.title => l10n.fieldTitle,
  StoreField.subtitle => l10n.fieldSubtitle,
  StoreField.shortDescription => l10n.fieldShortDescription,
  StoreField.longDescription => l10n.fieldLongDescription,
  StoreField.keywords => l10n.fieldKeywords,
  StoreField.promoText => l10n.fieldPromoText,
};

/// Textes de la fiche de store, par langue, avec compteurs, génération
/// optionnelle par l'IA et aperçus.
class TextsTab extends ConsumerStatefulWidget {
  const TextsTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<TextsTab> createState() => _TextsTabState();
}

class _TextsTabState extends ConsumerState<TextsTab> {
  final _texts = <AppLanguage, StoreTexts>{};
  final _pitch = TextEditingController();
  AppLanguage _lang = AppLanguage.fr;
  final _fields = {
    for (final f in StoreField.values) f: TextEditingController(),
  };

  int? get _sessionId => widget.ctx.ws.activeSession?.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pitch.dispose();
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final id = _sessionId;
    if (id == null) return;
    final saved = await ref
        .read(contentRepositoryProvider)
        .latestJson(id, ContentRepository.storeTextsKey);
    if (saved is! Map || !mounted) return;
    setState(() {
      _pitch.text = '${saved['pitch'] ?? ''}';
      for (final lang in AppLanguage.values) {
        final t = saved[lang.name];
        if (t is Map) _texts[lang] = StoreTexts.fromJson(t.cast());
      }
      _fillFields();
    });
  }

  StoreTexts get _current =>
      StoreTexts({for (final e in _fields.entries) e.key: e.value.text});

  void _fillFields() {
    final t = _texts[_lang] ?? const StoreTexts();
    for (final e in _fields.entries) {
      e.value.text = t[e.key];
    }
  }

  void _switch(AppLanguage lang) => setState(() {
    _texts[_lang] = _current;
    _lang = lang;
    _fillFields();
  });

  Future<void> _generate() async {
    final l10n = context.l10n;
    final provider = ref.read(settingsControllerProvider).llmProvider;
    final r = widget.ctx.report;
    final language = _lang == AppLanguage.fr ? 'français' : 'English';
    final payload = PromptBuilder.build(
      provider: provider,
      model: ref.read(llmModelsProvider)[provider]!,
      system: LlmTrial.system(l10n.llmTrialLanguage),
      instruction: l10n.textsAiInstruction(
        widget.ctx.ws.project.name,
        language,
        _pitch.text.trim(),
      ),
      schemaName: 'launchpilot_store_texts',
      schema: StoreTexts.schema,
      items: [
        if (r != null)
          ContextItem(
            label: 'Contexte',
            content: [
              'Technologies : ${r.technologies.map((t) => t.label).join(', ')}',
              'Services : ${r.services.map((s) => s.label).join(', ')}',
            ].join('\n'),
          ),
      ],
    );
    final result = await showLlmSendDialog(
      context,
      payload: payload,
      resultBuilder: (context, res) => Text('${res.data['title']}'),
    );
    if (result == null || !mounted) return;
    setState(() {
      for (final f in StoreField.values) {
        _fields[f]!.text = '${result.data[f.name] ?? ''}';
      }
    });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    _texts[_lang] = _current;
    await ref.read(contentRepositoryProvider).saveJson(
      _sessionId!,
      ContentRepository.storeTextsKey,
      {
        'pitch': _pitch.text,
        for (final e in _texts.entries) e.key.name: e.value.toJson(),
      },
    );
    if (mounted) showInfo(ScaffoldMessenger.of(context), l10n.textsSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final current = _current;
    final hasKey =
        ref
            .watch(apiKeysControllerProvider)
            .value
            ?.hasKey(ref.watch(settingsControllerProvider).llmProvider) ??
        false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              if (_sessionId == null)
                Text(
                  l10n.contentNeedsSession,
                  style: TextStyle(color: palette.statusWarning),
                ),
              Text(l10n.textsLanguage, style: theme.textTheme.labelLarge),
              SegmentedButton<AppLanguage>(
                segments: [
                  ButtonSegment(
                    value: AppLanguage.fr,
                    label: Text(l10n.languageFrench),
                  ),
                  ButtonSegment(
                    value: AppLanguage.en,
                    label: Text(l10n.languageEnglish),
                  ),
                ],
                selected: {_lang},
                showSelectedIcon: false,
                onSelectionChanged: (s) => _switch(s.first),
              ),
              TextField(
                key: const ValueKey('texts-pitch'),
                controller: _pitch,
                decoration: InputDecoration(
                  labelText: l10n.textsPitch,
                  hintText: l10n.textsPitchHint,
                ),
                onChanged: (_) => setState(() {}),
              ),
              OutlinedButton.icon(
                key: const ValueKey('texts-ai'),
                onPressed: hasKey && _pitch.text.trim().isNotEmpty
                    ? _generate
                    : null,
                icon: const Icon(Icons.auto_awesome),
                label: Text(l10n.textsAi),
              ),
              for (final f in StoreField.values)
                TextField(
                  key: ValueKey('texts-${f.name}'),
                  controller: _fields[f],
                  minLines: f == StoreField.longDescription ? 5 : 1,
                  maxLines: f == StoreField.longDescription ? 12 : 3,
                  decoration: InputDecoration(
                    labelText: fieldLabel(l10n, f),
                    counterText: l10n.textsCounter(
                      visibleLength(_fields[f]!.text),
                      f.limit,
                    ),
                    counterStyle: TextStyle(
                      color: visibleLength(_fields[f]!.text) > f.limit
                          ? palette.statusFailed
                          : null,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              if (current.overLimit.isNotEmpty)
                Text(
                  l10n.textsOverLimit,
                  style: TextStyle(color: palette.statusFailed),
                ),
              FilledButton.icon(
                key: const ValueKey('texts-save'),
                onPressed: _sessionId == null ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.textsSave),
              ),
              Text(l10n.textsNote, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        AdaptiveGrid(
          minItemWidth: 300,
          maxColumns: 2,
          children: [
            _Preview(
              title: l10n.textsPreviewStore,
              name: current[StoreField.title].isEmpty
                  ? widget.ctx.ws.project.name
                  : current[StoreField.title],
              subtitle: current[StoreField.subtitle],
              body: current[StoreField.shortDescription],
            ),
            _Preview(
              title: l10n.textsPreviewSocial,
              name: current[StoreField.title].isEmpty
                  ? widget.ctx.ws.project.name
                  : current[StoreField.title],
              subtitle: '',
              body: current[StoreField.shortDescription],
              social: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.title,
    required this.name,
    required this.subtitle,
    required this.body,
    this.social = false,
  });

  final String title;
  final String name;
  final String subtitle;
  final String body;
  final bool social;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: social
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [scheme.primary, scheme.tertiary],
                          ),
                        ),
                      ),
                      Text(
                        name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                      ),
                      Text(body, maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [scheme.secondary, scheme.primary],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(name, style: theme.textTheme.titleMedium),
                            if (subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                style: TextStyle(color: scheme.secondary),
                              ),
                            Text(
                              body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
