import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../changes/application/change_providers.dart';
import '../../commands/domain/command_spec.dart';
import '../../commands/presentation/command_preview_dialog.dart';
import '../../llm/application/llm_service.dart';
import '../../llm/domain/llm_trial.dart';
import '../../llm/domain/prompt_builder.dart';
import '../../llm/presentation/llm_send_dialog.dart';
import '../../settings/application/api_keys_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../application/content_providers.dart';
import '../data/changelog_service.dart';
import '../data/content_repository.dart';
import '../domain/changelog.dart';
import '../domain/version.dart';
import 'content_workspace.dart';

enum _Audience { technical, public }

String groupTitle(AppLocalizations l10n, ChangeGroup g) => switch (g) {
  ChangeGroup.breaking => l10n.changelogGroupBreaking,
  ChangeGroup.features => l10n.changelogGroupFeatures,
  ChangeGroup.fixes => l10n.changelogGroupFixes,
  ChangeGroup.performance => l10n.changelogGroupPerformance,
  ChangeGroup.docs => l10n.changelogGroupDocs,
  ChangeGroup.other => l10n.changelogGroupOther,
};

/// Changelog depuis les commits, en version technique ou grand public,
/// éventuellement reformulé par l'IA, puis écrit dans CHANGELOG.md.
class ChangelogTab extends ConsumerStatefulWidget {
  const ChangelogTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<ChangelogTab> createState() => _ChangelogTabState();
}

class _ChangelogTabState extends ConsumerState<ChangelogTab> {
  CommitRange? _range;
  bool _loading = false;
  _Audience _audience = _Audience.public;
  final _technical = TextEditingController();
  final _public = TextEditingController();

  TextEditingController get _current =>
      _audience == _Audience.technical ? _technical : _public;

  @override
  void dispose() {
    _technical.dispose();
    _public.dispose();
    super.dispose();
  }

  /// Version du projet (manifeste), sinon celle de la session.
  String get _version {
    final writer = ref.read(projectWriterProvider);
    for (final pkg in widget.ctx.report?.packages ?? const []) {
      final kind = pkg.manager == 'pub'
          ? VersionFileKind.pubspec
          : VersionFileKind.packageJson;
      final content = writer.readCurrent(widget.ctx.root, pkg.manifest);
      final v = content == null ? null : readVersion(kind, content);
      if (v != null) return SemVer.tryParse(v)?.name ?? v;
    }
    return widget.ctx.ws.activeSession?.version ?? '0.0.0';
  }

  String _heading() {
    final d = DateTime.now();
    final day =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return '$_version — $day';
  }

  Future<void> _read() async {
    final l10n = context.l10n;
    setState(() => _loading = true);
    final range = await ref
        .read(changelogServiceProvider)
        .commits(widget.ctx.root);
    if (!mounted) return;
    String title(ChangeGroup g) => groupTitle(l10n, g);
    setState(() {
      _loading = false;
      _range = range;
      _technical.text = technicalChangelog(
        range.commits,
        title,
        heading: _heading(),
      );
      _public.text = publicChangelog(
        range.commits,
        title,
        heading: _heading(),
        fallback: l10n.changelogPublicFallback,
      );
    });
  }

  Future<void> _rephrase() async {
    final l10n = context.l10n;
    final settings = ref.read(settingsControllerProvider);
    final provider = settings.llmProvider;
    final payload = PromptBuilder.build(
      provider: provider,
      model: ref.read(llmModelsProvider)[provider]!,
      system: LlmTrial.system(l10n.llmTrialLanguage),
      instruction: l10n.changelogAiInstruction(_heading()),
      schemaName: 'launchpilot_changelog',
      schema: const {
        'type': 'object',
        'additionalProperties': false,
        'required': ['technical', 'public'],
        'properties': {
          'technical': {'type': 'string'},
          'public': {'type': 'string'},
        },
      },
      items: [
        ContextItem(
          label: 'Commits',
          content: [for (final c in _range!.commits) '- ${c.subject}']
              .join('\n'),
        ),
      ],
    );
    final result = await showLlmSendDialog(
      context,
      payload: payload,
      resultBuilder: (context, r) => Text('${r.data['public']}'),
    );
    if (result == null || !mounted) return;
    setState(() {
      _technical.text = '${result.data['technical']}';
      _public.text = '${result.data['public']}';
    });
  }

  Future<void> _write() async {
    final l10n = context.l10n;
    final writer = ref.read(projectWriterProvider);
    final current = writer.readCurrent(widget.ctx.root, 'CHANGELOG.md');
    final set = await writer.plan(widget.ctx.root, 'CHANGELOG.md', {
      'CHANGELOG.md': prependChangelog(
        current,
        _current.text,
        title: 'Changelog',
      ),
    });
    if (!mounted) return;
    if (!await previewAndWrite(context, ref, set)) return;
    final session = widget.ctx.ws.activeSession;
    if (session != null) {
      await ref.read(contentRepositoryProvider).saveJson(
        session.id,
        ContentRepository.changelogKey(_version),
        {'technical': _technical.text, 'public': _public.text},
      );
    }
    if (mounted) showInfo(ScaffoldMessenger.of(context), l10n.writeDone);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = LaunchPalette.of(context);
    final hasGit = widget.ctx.report?.git.present ?? true;
    final range = _range;
    final hasKey =
        ref
            .watch(apiKeysControllerProvider)
            .value
            ?.hasKey(ref.watch(settingsControllerProvider).llmProvider) ??
        false;
    final tag = 'v$_version';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          if (!hasGit)
            Text(l10n.changelogNoGit)
          else
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  key: const ValueKey('changelog-read'),
                  onPressed: _loading ? null : _read,
                  icon: const Icon(Icons.history),
                  label: Text(l10n.changelogRead),
                ),
                if (range != null)
                  Text(
                    range.sinceTag == null
                        ? l10n.changelogLimited(range.commits.length)
                        : l10n.changelogSinceTag(
                            range.commits.length,
                            range.sinceTag!,
                          ),
                  ),
              ],
            ),
          if (range != null && range.commits.isEmpty) Text(l10n.changelogEmpty),
          SegmentedButton<_Audience>(
            segments: [
              ButtonSegment(
                value: _Audience.public,
                label: Text(l10n.changelogPublic),
              ),
              ButtonSegment(
                value: _Audience.technical,
                label: Text(l10n.changelogTechnical),
              ),
            ],
            selected: {_audience},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _audience = s.first),
          ),
          TextField(
            key: const ValueKey('changelog-text'),
            controller: _current,
            minLines: 8,
            maxLines: 18,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(hintText: '## ${_heading()}'),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (range != null && range.commits.isNotEmpty)
                OutlinedButton.icon(
                  key: const ValueKey('changelog-ai'),
                  onPressed: hasKey ? _rephrase : null,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.changelogAi),
                ),
              FilledButton.icon(
                key: const ValueKey('changelog-write'),
                onPressed: () {
                  if (_current.text.trim().isNotEmpty) _write();
                },
                icon: const Icon(Icons.difference_outlined),
                label: Text(l10n.changelogWrite),
              ),
              if (hasGit)
                OutlinedButton.icon(
                  key: const ValueKey('changelog-tag'),
                  onPressed: () => previewAndRun(
                    context,
                    ref,
                    CommandSpec(
                      executable: 'git',
                      arguments: ['tag', tag],
                      workingDirectory: widget.ctx.root,
                    ),
                    openTerminal: false,
                  ),
                  icon: const Icon(Icons.sell_outlined),
                  label: Text(l10n.changelogTag(tag)),
                ),
            ],
          ),
          if (hasGit)
            Text(
              l10n.changelogTagNote,
              style: TextStyle(color: palette.statusPedagogy),
            ),
        ],
      ),
    );
  }
}
