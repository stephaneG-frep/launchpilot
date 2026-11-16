import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/audit_status.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/page_frame.dart';
import '../../demo/demo_catalog.dart';
import '../../demo/demo_providers.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/project_enums.dart';
import '../../settings/application/settings_controller.dart';
import '../application/report_builder.dart';
import '../domain/report.dart';

/// Choix de l'emplacement du rapport, remplaçable dans les tests.
abstract interface class ReportSaver {
  Future<String?> pickPath(String suggestedName);
}

class NativeReportSaver implements ReportSaver {
  const NativeReportSaver();

  @override
  Future<String?> pickPath(String suggestedName) async {
    final location = await fs.getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: const [
        fs.XTypeGroup(label: 'HTML', extensions: ['html']),
      ],
    );
    return location?.path;
  }
}

final reportSaverProvider = Provider<ReportSaver>(
  (ref) => const NativeReportSaver(),
);

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final demo = ref.watch(demoCatalogProvider);

    return PageFrame(
      icon: Icons.description,
      title: l10n.reportsTitle,
      subtitle: l10n.reportsSubtitle,
      children: demo == null
          ? const [_History()]
          : [for (final r in demo.reports) _DemoReportTile(r)],
    );
  }
}

class _History extends ConsumerStatefulWidget {
  const _History();

  @override
  ConsumerState<_History> createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<_History> {
  int? _selected;
  ReportData? _data;
  bool _building = false;
  String? _savedPath;
  List<String> _exports = const [];

  Future<void> _open(int sessionId) async {
    final l10n = context.l10n;
    setState(() {
      _selected = sessionId;
      _building = true;
      _data = null;
      _savedPath = null;
    });
    final language = ref.read(settingsControllerProvider).language;
    final data = await ref
        .read(reportBuilderProvider)
        .build(sessionId, language, l10n);
    final entries = await ref
        .read(projectRepositoryProvider)
        .entriesOf(sessionId);
    if (!mounted || _selected != sessionId) return;
    setState(() {
      _data = data;
      _building = false;
      _exports = [
        for (final e in entries.reversed)
          if (e.kind == SessionEntryKind.report)
            '${(jsonDecode(e.content) as Map)['path']}',
      ];
    });
  }

  Future<void> _export(ReportData data) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    var path = await ref
        .read(reportSaverProvider)
        .pickPath(
          reportFileName(
            data.projectName,
            data.sessionVersion,
            data.generatedAt,
          ),
        );
    if (path == null) return;
    if (!path.toLowerCase().endsWith('.html')) path = '$path.html';
    try {
      File(path).writeAsStringSync(renderReportHtml(data));
    } on FileSystemException {
      showInfo(messenger, l10n.reportWriteFailed);
      return;
    }
    await ref
        .read(projectRepositoryProvider)
        .addEntry(
          _selected!,
          SessionEntryKind.report,
          'report.html',
          jsonEncode({
            'path': path,
            'generatedAt': data.generatedAt.toIso8601String(),
          }),
        );
    ref.invalidate(sessionHistoryProvider);
    if (!mounted) return;
    setState(() {
      _savedPath = path;
      _exports = [path!, ..._exports];
    });
    showInfo(messenger, l10n.reportSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final history = ref.watch(sessionHistoryProvider);
    final sessions = history.value ?? const [];

    if (history.hasValue && sessions.isEmpty) {
      return EmptyState(
        icon: Icons.description_outlined,
        title: l10n.reportsEmptyTitle,
        message: l10n.reportsEmptyMessage,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Text(l10n.reportsHistoryTitle, style: theme.textTheme.titleMedium),
        for (final s in sessions)
          GlassCard(
            key: ValueKey('session-${s.session.id}'),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${s.project.name} · ${s.session.version}',
                  style: theme.textTheme.titleSmall,
                ),
                Pill(
                  label: s.session.status == SessionStatus.completed
                      ? l10n.reportStatusCompleted
                      : l10n.reportStatusActive,
                  color: s.session.status == SessionStatus.completed
                      ? palette.statusSucceeded
                      : palette.statusRunning,
                ),
                Text(l10n.reportsProgress(s.done, s.total)),
                Text(
                  context.formatDate(s.session.updatedAt),
                  style: theme.textTheme.bodySmall,
                ),
                if (s.reports > 0) Text(l10n.reportsCount(s.reports)),
                OutlinedButton.icon(
                  key: ValueKey('report-open-${s.session.id}'),
                  onPressed: () => _open(s.session.id),
                  icon: const Icon(Icons.preview_outlined),
                  label: Text(l10n.reportsOpen),
                ),
              ],
            ),
          ),
        if (_building) const LinearProgressIndicator(),
        if (_data case final d?)
          GlassCard(
            key: const ValueKey('report-detail'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  l10n.reportsDetailTitle(d.projectName, d.sessionVersion),
                  style: theme.textTheme.titleMedium,
                ),
                Text(l10n.reportsStepsLine(d.doneSteps, d.steps.length)),
                Text(l10n.reportsFilesLine(d.files.length)),
                Text(
                  l10n.reportsCommandsLine(d.commands.length, d.checks.length),
                ),
                Text(l10n.reportsDeliverablesLine(d.deliverables.length)),
                for (final a in d.audits)
                  Text(
                    l10n.reportsAuditLine(
                      a.title,
                      a.count(AuditStatus.failure),
                      a.count(AuditStatus.warning),
                    ),
                  ),
                Text(l10n.reportsContents, style: theme.textTheme.bodySmall),
                FilledButton.icon(
                  key: const ValueKey('report-export'),
                  onPressed: () => _export(d),
                  icon: const Icon(Icons.file_download_outlined),
                  label: Text(l10n.reportsExport),
                ),
                if (_savedPath case final path?)
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          path,
                          key: const ValueKey('report-path'),
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.commonCopy,
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: path));
                          showInfo(
                            ScaffoldMessenger.of(context),
                            l10n.commonCopied,
                          );
                        },
                      ),
                    ],
                  ),
                Text(
                  l10n.reportsPdfHint,
                  style: TextStyle(color: palette.statusPedagogy),
                ),
                if (_exports.isNotEmpty) ...[
                  Text(l10n.reportsPrevious, style: theme.textTheme.labelLarge),
                  for (final e in _exports)
                    SelectableText(
                      e,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _DemoReportTile extends StatelessWidget {
  const _DemoReportTile(this.report);

  final DemoReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(report.title, style: theme.textTheme.titleMedium),
              StatusPill(report.status),
              const DemoTag(),
            ],
          ),
          Text(
            context.formatDate(report.date),
            style: theme.textTheme.bodySmall,
          ),
          Text(report.summary),
        ],
      ),
    );
  }
}
