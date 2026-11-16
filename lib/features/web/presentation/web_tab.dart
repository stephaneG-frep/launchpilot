import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../changes/application/change_providers.dart';
import '../../commands/domain/command_result.dart';
import '../../commands/domain/command_spec.dart';
import '../../commands/presentation/command_preview_dialog.dart';
import '../../content/presentation/content_workspace.dart';
import '../../settings/application/settings_controller.dart';
import '../application/web_providers.dart';
import '../domain/hosting.dart';
import '../domain/web_audit.dart';
import '../domain/web_build.dart';
import 'audit_texts.dart';

String areaLabel(AppLocalizations l10n, AuditArea a) => switch (a) {
  AuditArea.seo => 'SEO',
  AuditArea.responsive => l10n.auditAreaResponsive,
  AuditArea.pwa => 'PWA',
  AuditArea.accessibility => l10n.auditAreaAccessibility,
  AuditArea.links => l10n.auditAreaLinks,
  AuditArea.https => 'HTTPS',
  AuditArea.forms => l10n.auditAreaForms,
  AuditArea.errors => l10n.auditAreaErrors,
};

/// Icône et couleur d'un statut d'audit.
(IconData, Color) auditStatusStyle(BuildContext context, AuditStatus s) {
  final palette = LaunchPalette.of(context);
  return switch (s) {
    AuditStatus.ok => (Icons.check_circle, palette.statusSucceeded),
    AuditStatus.warning => (Icons.warning_amber, palette.statusWarning),
    AuditStatus.failure => (Icons.error, palette.statusFailed),
    AuditStatus.info => (Icons.info_outline, palette.statusPedagogy),
  };
}

/// Message quand la cible web n'a pas de plan de build exploitable.
String buildGapText(AppLocalizations l10n, WebBuildGap gap) => switch (gap) {
  WebBuildGap.noBuildScript => l10n.webGapNoScript,
  WebBuildGap.serverRendered => l10n.webGapServer,
};

/// Construction, audit statique, aperçu local et Lighthouse.
class WebTab extends ConsumerStatefulWidget {
  const WebTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<WebTab> createState() => _WebTabState();
}

enum _AuditSource { output, sources }

class _WebTabState extends ConsumerState<WebTab> {
  final _output = TextEditingController();
  final _lighthouseUrl = TextEditingController();
  _AuditSource _source = _AuditSource.output;
  WebAudit? _audit;
  bool _auditMissing = false;
  Map<String, int>? _scores;
  bool _scoresUnreadable = false;

  @override
  void initState() {
    super.initState();
    _output.text = ref.read(webBuildPlanProvider)?.outputDir ?? '';
    _lighthouseUrl.text = ref.read(webConfigProvider).siteUrl;
  }

  @override
  void dispose() {
    _output.dispose();
    _lighthouseUrl.dispose();
    super.dispose();
  }

  String get _root => widget.ctx.root;

  bool _outputReady(WebBuildPlan plan) =>
      ref
          .read(projectWriterProvider)
          .readCurrent(_root, widget.ctx.join(plan.outputDir, 'index.html')) !=
      null;

  void _runAudit(WebBuildPlan plan) {
    final reader = ref.read(siteReaderProvider);
    SiteSnapshot? site;
    if (_source == _AuditSource.output) {
      site = reader.read(_root, plan.outputDir);
    } else {
      final indexDir = plan.sourceIndex == null
          ? plan.publicDir
          : _dirOf(plan.sourceIndex!);
      site = reader.read(_root, indexDir);
      // Le dossier public est servi à la racine du site construit.
      if (site != null && plan.publicDir != indexDir) {
        final public = reader.read(_root, plan.publicDir);
        if (public != null) site = site.merge(public);
      }
    }
    setState(() {
      _auditMissing = site == null;
      _audit = site == null ? null : auditSite(site, spa: plan.spa);
    });
  }

  static String _dirOf(String path) {
    final i = path.lastIndexOf('/');
    return i < 0 ? '' : path.substring(0, i);
  }

  Future<void> _build(WebBuildPlan plan) => previewAndRun(
    context,
    ref,
    CommandSpec(
      executable: plan.executable!,
      arguments: plan.arguments,
      workingDirectory: widget.ctx.join(_root, plan.workingDir),
    ),
  );

  Future<void> _lighthouse() async {
    final url = _lighthouseUrl.text.trim();
    final result = await previewAndRun(
      context,
      ref,
      lighthouseCommand(url, _root),
      openTerminal: false,
    );
    if (result != null && result.status == RunStatus.succeeded) _readScores();
  }

  void _readScores() {
    final raw = ref
        .read(projectWriterProvider)
        .readCurrent(_root, lighthouseReportFile);
    setState(() {
      _scores = raw == null ? null : parseLighthouse(raw);
      _scoresUnreadable = raw != null && _scores == null;
    });
  }

  Future<void> _toggleServer(WebBuildPlan plan) async {
    final server = ref.read(previewServerProvider);
    if (server.url != null) {
      await server.stop();
    } else {
      final url = await server.start(
        widget.ctx.join(_root, plan.outputDir),
        spa: plan.spa,
      );
      _lighthouseUrl.text = url.toString();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final plan = ref.watch(webBuildPlanProvider);
    if (plan == null) return Text(l10n.webNoPlan);
    final lang = ref.watch(
      settingsControllerProvider.select((s) => s.language),
    );
    final ready = _outputReady(plan);
    final server = ref.watch(previewServerProvider);
    final tools = ref.watch(installedToolsProvider).value ?? const {};
    final hasLighthouse = tools.contains('lighthouse');
    final reportExists =
        ref
            .read(projectWriterProvider)
            .readCurrent(_root, lighthouseReportFile) !=
        null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.webBuildTitle, style: theme.textTheme.titleMedium),
              Text(l10n.webFramework(plan.framework)),
              if (plan.hasCommand)
                SelectableText(
                  plan.commandLine,
                  key: const ValueKey('web-command'),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              if (plan.gap case final gap?)
                Text(
                  buildGapText(l10n, gap),
                  style: TextStyle(color: palette.statusWarning),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: TextField(
                  key: const ValueKey('web-output'),
                  controller: _output,
                  style: const TextStyle(fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    labelText: l10n.webOutputDir,
                    helperText: plan.outputGuessed
                        ? l10n.webOutputGuessed
                        : null,
                    isDense: true,
                  ),
                  onSubmitted: (v) => ref
                      .read(webConfigProvider.notifier)
                      .update(
                        ref
                            .read(webConfigProvider)
                            .copyWith(outputDir: v.trim()),
                      ),
                ),
              ),
              Text(
                ready ? l10n.webOutputReady : l10n.webOutputMissing,
                key: const ValueKey('web-output-state'),
                style: TextStyle(
                  color: ready
                      ? palette.statusSucceeded
                      : palette.statusWarning,
                ),
              ),
              if (plan.hasCommand)
                FilledButton.icon(
                  key: const ValueKey('web-build'),
                  onPressed: () => _build(plan),
                  icon: const Icon(Icons.construction),
                  label: Text(l10n.webBuild),
                ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.webAuditTitle, style: theme.textTheme.titleMedium),
              Text(l10n.webAuditHelp),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SegmentedButton<_AuditSource>(
                    segments: [
                      ButtonSegment(
                        value: _AuditSource.output,
                        label: Text(l10n.webAuditOutput),
                      ),
                      ButtonSegment(
                        value: _AuditSource.sources,
                        label: Text(l10n.webAuditSources),
                      ),
                    ],
                    selected: {_source},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) =>
                        setState(() => _source = s.first),
                  ),
                  FilledButton.tonalIcon(
                    key: const ValueKey('web-audit'),
                    onPressed: () => _runAudit(plan),
                    icon: const Icon(Icons.fact_check_outlined),
                    label: Text(l10n.webAuditRun),
                  ),
                ],
              ),
              if (_auditMissing)
                Text(
                  l10n.webAuditNoFolder,
                  style: TextStyle(color: palette.statusWarning),
                ),
              if (_audit case final audit?) ...[
                Text(
                  l10n.webAuditSummary(
                    audit.count(AuditStatus.failure),
                    audit.count(AuditStatus.warning),
                    audit.count(AuditStatus.ok),
                  ),
                  key: const ValueKey('web-audit-summary'),
                  style: theme.textTheme.titleSmall,
                ),
                if (audit.truncated) Text(l10n.webAuditTruncated),
                for (final area in AuditArea.values)
                  if (audit.inArea(area).isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        areaLabel(l10n, area),
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    for (final item in audit.inArea(area))
                      _AuditRow(item: item, text: auditText(item, lang)),
                  ],
                Text(l10n.webAuditLimits, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.webPreviewTitle, style: theme.textTheme.titleMedium),
              Text(l10n.webPreviewHelp),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey('web-serve'),
                    onPressed: ready || server.url != null
                        ? () => _toggleServer(plan)
                        : null,
                    icon: Icon(
                      server.url == null ? Icons.play_arrow : Icons.stop,
                    ),
                    label: Text(
                      server.url == null
                          ? l10n.webServeStart
                          : l10n.webServeStop,
                    ),
                  ),
                  if (server.url case final url?) ...[
                    SelectableText(
                      '$url',
                      key: const ValueKey('web-serve-url'),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    IconButton(
                      tooltip: l10n.commonCopy,
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '$url'));
                        showInfo(
                          ScaffoldMessenger.of(context),
                          l10n.commonCopied,
                        );
                      },
                    ),
                  ],
                ],
              ),
              if (server.url != null) Text(l10n.webPreviewChecks),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text('Lighthouse', style: theme.textTheme.titleMedium),
              if (!hasLighthouse) ...[
                Text(
                  l10n.webLighthouseMissing,
                  key: const ValueKey('web-lighthouse-missing'),
                ),
                const SelectableText(
                  'npm install -g lighthouse',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ] else ...[
                Text(l10n.webLighthouseHelp),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: TextField(
                    key: const ValueKey('web-lighthouse-url'),
                    controller: _lighthouseUrl,
                    decoration: InputDecoration(
                      labelText: l10n.webLighthouseUrl,
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                FilledButton.tonalIcon(
                  key: const ValueKey('web-lighthouse-run'),
                  onPressed:
                      Uri.tryParse(_lighthouseUrl.text.trim())
                              ?.host
                              .isNotEmpty ??
                          false
                      ? _lighthouse
                      : null,
                  icon: const Icon(Icons.speed),
                  label: Text(l10n.webLighthouseRun),
                ),
              ],
              if (reportExists)
                TextButton(
                  key: const ValueKey('web-lighthouse-read'),
                  onPressed: _readScores,
                  child: Text(l10n.webLighthouseRead),
                ),
              if (_scoresUnreadable) Text(l10n.webLighthouseUnreadable),
              if (_scores case final scores?)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final e in scores.entries)
                      _Score(label: e.key, value: e.value),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.item, required this.text});

  final AuditItem item;
  final AuditText text;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = auditStatusStyle(context, item.status);
    final showFix = item.status != AuditStatus.ok;
    return Row(
      key: ValueKey('audit-${item.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text.label),
              if (showFix && text.fix.isNotEmpty)
                Text(text.fix, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final palette = LaunchPalette.of(context);
    final color = value >= 90
        ? palette.statusSucceeded
        : value >= 50
        ? palette.statusWarning
        : palette.statusFailed;
    return Container(
      key: ValueKey('score-$label'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: color),
          ),
          Text(label),
        ],
      ),
    );
  }
}
