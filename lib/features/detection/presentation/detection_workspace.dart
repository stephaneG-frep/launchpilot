import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/destinations.dart';
import '../../../core/domain/explanation_level.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/adaptive_grid.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/page_frame.dart';
import '../../../l10n/app_localizations.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/project_views.dart';
import '../../projects/presentation/project_dialogs.dart';
import '../../settings/application/settings_controller.dart';
import '../application/detection_providers.dart';
import '../data/detection_repository.dart';
import '../domain/detection_report.dart';
import '../domain/detectors.dart' show SeoCheck;
import '../domain/scan_snapshot.dart';

/// Rapport de détection du projet ouvert : analyse à la demande, preuves,
/// confiance et correction des cibles.
class DetectionWorkspace extends ConsumerStatefulWidget {
  const DetectionWorkspace({super.key});

  @override
  ConsumerState<DetectionWorkspace> createState() => _DetectionWorkspaceState();
}

class _DetectionWorkspaceState extends ConsumerState<DetectionWorkspace> {
  bool _scanning = false;
  String? _error;

  Future<void> _analyze(ProjectWorkspace ws) async {
    setState(() {
      _scanning = true;
      _error = null;
    });
    try {
      final report = await ref
          .read(projectAnalyzerProvider)
          .analyze(ws.project.path);
      await ref
          .read(detectionRepositoryProvider)
          .saveReport(ws.project.id, report);
    } on Exception catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final workspace = ref.watch(currentWorkspaceProvider);
    final detection = ref.watch(currentDetectionProvider);

    final ws = workspace.value;
    if (workspace.isLoading && ws == null) {
      return const LinearProgressIndicator();
    }
    if (ws == null) {
      return EmptyState(
        icon: Icons.radar,
        title: l10n.publicationNoProjectTitle,
        message: l10n.detectionEmptyMessage,
        actions: [
          FilledButton.icon(
            key: const ValueKey('detection-pick-folder'),
            onPressed: () => pickAndAddProject(context, ref),
            icon: const Icon(Icons.folder_open),
            label: Text(l10n.homeChooseFolder),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go(AppDestination.home.path),
            icon: const Icon(Icons.home_outlined),
            label: Text(l10n.publicationGoHome),
          ),
        ],
      );
    }

    final current = detection.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: [
        _Header(
          ws: ws,
          detection: current,
          scanning: _scanning,
          error: _error,
          onAnalyze: () => _analyze(ws),
        ),
        if (current != null) ..._report(context, ws.project.id, current),
      ],
    );
  }

  List<Widget> _report(
    BuildContext context,
    int projectId,
    ProjectDetection detection,
  ) {
    final l10n = context.l10n;
    final r = detection.report;
    return [
      if (r.partial) _PartialWarning(r.partialReasons),
      SectionTitle(l10n.detectionTechnologies),
      if (r.technologies.isEmpty)
        Text(l10n.detectionNoTechnology)
      else
        AdaptiveGrid(
          minItemWidth: 320,
          maxColumns: 2,
          children: [for (final t in r.technologies) _TechCard(t)],
        ),
      SectionTitle(l10n.detectionTargets),
      _TargetsPanel(projectId: projectId, detection: detection),
      SectionTitle(l10n.detectionPackages),
      if (r.packages.isEmpty)
        Text(l10n.detectionNothingFound)
      else
        AdaptiveGrid(
          minItemWidth: 320,
          maxColumns: 2,
          children: [for (final p in r.packages) _PackageCard(p)],
        ),
      SectionTitle('Git'),
      _GitCard(r.git),
      SectionTitle(l10n.detectionPublishingFiles),
      _FindingsPanel(r),
      AdaptiveGrid(
        minItemWidth: 340,
        maxColumns: 2,
        children: [_PermissionsCard(r.permissions), _ServicesCard(r.services)],
      ),
      if (r.sensitiveFiles.isNotEmpty)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 18,
              color: LaunchPalette.of(context).statusWarning,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.detectionSensitive(r.sensitiveFiles.join(', '))),
            ),
          ],
        ),
    ];
  }
}

String _percent(AppLocalizations l10n, double v) =>
    l10n.percentValue((v * 100).round());

class _Header extends ConsumerWidget {
  const _Header({
    required this.ws,
    required this.detection,
    required this.scanning,
    required this.error,
    required this.onAnalyze,
  });

  final ProjectWorkspace ws;
  final ProjectDetection? detection;
  final bool scanning;
  final String? error;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final beginner =
        ref.watch(
          settingsControllerProvider.select((s) => s.explanationLevel),
        ) ==
        ExplanationLevel.beginner;
    final report = detection?.report;

    return GlassCard(
      accent: theme.colorScheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(ws.project.name, style: theme.textTheme.titleLarge),
          SelectableText(
            ws.project.path,
            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
          if (!ws.folderAvailable)
            Pill(
              label: l10n.homeFolderMissing,
              color: palette.statusWarning,
              icon: Icons.warning_amber_rounded,
            ),
          Text(
            report == null
                ? l10n.detectionNeverScanned
                : l10n.detectionScannedAt(
                    context.formatDate(report.scannedAt),
                    report.filesScanned,
                  ),
          ),
          if (beginner || report == null)
            Text(
              l10n.detectionReadOnlyNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (error != null)
            Text(
              l10n.detectionFailed(error!),
              style: TextStyle(color: palette.statusFailed),
            ),
          const SizedBox(height: 4),
          if (scanning)
            Row(
              spacing: 12,
              children: [
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                Text(l10n.detectionAnalyzing),
              ],
            )
          else
            FilledButton.icon(
              key: const ValueKey('detection-analyze'),
              onPressed: ws.folderAvailable ? onAnalyze : null,
              icon: Icon(report == null ? Icons.radar : Icons.refresh),
              label: Text(
                report == null ? l10n.detectionAnalyze : l10n.detectionRescan,
              ),
            ),
        ],
      ),
    );
  }
}

class _PartialWarning extends StatelessWidget {
  const _PartialWarning(this.reasons);

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = [
      for (final r in reasons)
        switch (r) {
          PartialReason.maxFiles => l10n.partialMaxFiles,
          PartialReason.maxDepth => l10n.partialMaxDepth,
          PartialReason.readBudget => l10n.partialReadBudget,
          PartialReason.timeout => l10n.partialTimeout,
          _ => l10n.partialUnreadable,
        },
    ].join(', ');
    final color = LaunchPalette.of(context).statusWarning;
    return Row(
      children: [
        Icon(Icons.warning_amber_rounded, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(l10n.detectionPartial(text))),
      ],
    );
  }
}

class _EvidenceList extends StatelessWidget {
  const _EvidenceList(this.evidence);

  final List<Evidence> evidence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        for (final e in evidence)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.subdirectory_arrow_right,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SelectableText(
                  '$e',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _TechCard extends StatelessWidget {
  const _TechCard(this.tech);

  final TechDetection tech;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final color = tech.confidence >= 0.9
        ? palette.statusSucceeded
        : palette.statusWarning;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(tech.label, style: theme.textTheme.titleMedium),
              if (tech.informative)
                Pill(
                  label: l10n.detectionInformative,
                  color: palette.statusPedagogy,
                  icon: Icons.info_outline,
                ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: tech.confidence,
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                l10n.detectionConfidence((tech.confidence * 100).round()),
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          Text(l10n.detectionEvidence, style: theme.textTheme.labelLarge),
          _EvidenceList(tech.evidence),
        ],
      ),
    );
  }
}

String targetLabel(PlatformTarget t) => switch (t) {
  PlatformTarget.android => 'Android',
  PlatformTarget.ios => 'iOS',
  PlatformTarget.web => 'Web',
  PlatformTarget.linux => 'Linux',
  PlatformTarget.windows => 'Windows',
  PlatformTarget.macos => 'macOS',
};

class _TargetsPanel extends ConsumerWidget {
  const _TargetsPanel({required this.projectId, required this.detection});

  final int projectId;
  final ProjectDetection detection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final repo = ref.read(detectionRepositoryProvider);
    final reviewedAt = detection.targetsReviewedAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(l10n.detectionTargetsHint),
        AdaptiveGrid(
          minItemWidth: 260,
          maxColumns: 3,
          children: [
            for (final t in PlatformTarget.values)
              _TargetTile(
                detection: detection.report.targetFor(t),
                selected: detection.selected.contains(t),
                onChanged: (v) => repo.setTargetSelected(projectId, t, v),
              ),
          ],
        ),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  reviewedAt == null
                      ? Icons.pending_outlined
                      : Icons.verified_outlined,
                  color: reviewedAt == null
                      ? palette.statusWarning
                      : palette.statusSucceeded,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    reviewedAt == null
                        ? l10n.detectionTargetsToReview
                        : l10n.detectionTargetsReviewed(
                            context.formatDate(reviewedAt),
                          ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            FilledButton.tonalIcon(
              key: const ValueKey('detection-validate-targets'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await repo.markTargetsReviewed(projectId);
                showInfo(messenger, l10n.detectionTargetsValidated);
              },
              icon: const Icon(Icons.check),
              label: Text(l10n.detectionValidateTargets),
            ),
          ],
        ),
      ],
    );
  }
}

class _TargetTile extends StatelessWidget {
  const _TargetTile({
    required this.detection,
    required this.selected,
    required this.onChanged,
  });

  final TargetDetection detection;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final t = detection.target;
    final detected = detection.detected;

    return GlassCard(
      accent: selected ? theme.colorScheme.secondary : null,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(targetLabel(t), style: theme.textTheme.titleMedium),
              ),
              Text(l10n.detectionTargetSelected),
              Switch(
                key: ValueKey('target-switch-${t.name}'),
                value: selected,
                onChanged: onChanged,
              ),
            ],
          ),
          Pill(
            label: detected
                ? '${l10n.detectionTargetDetected} · ${_percent(l10n, detection.confidence)}'
                : l10n.detectionTargetNotDetected,
            color: detected ? palette.statusSucceeded : palette.statusTodo,
            icon: detected ? Icons.check : Icons.remove,
          ),
          if (detection.evidence.isNotEmpty) _EvidenceList(detection.evidence),
          if (t == PlatformTarget.ios && (selected || detected))
            Text(
              l10n.detectionIosLinuxNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.statusPedagogy,
              ),
            ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard(this.info);

  final PackageManagerInfo info;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final mono = theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace');
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(info.manager, style: theme.textTheme.titleMedium),
              Pill(label: info.manifest, color: theme.colorScheme.secondary),
            ],
          ),
          Text(info.lockFile ?? l10n.detectionNoLockFile, style: mono),
          if (info.scripts.isEmpty && info.manager != 'pub')
            Text(l10n.detectionNoScripts)
          else
            for (final e in info.scripts.entries)
              SelectableText('${e.key}: ${e.value}', style: mono),
        ],
      ),
    );
  }
}

class _GitCard extends StatelessWidget {
  const _GitCard(this.git);

  final GitSnapshot git;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = LaunchPalette.of(context);
    final theme = Theme.of(context);
    if (!git.present) {
      return Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: palette.statusWarning),
          const SizedBox(width: 10),
          Expanded(child: Text(l10n.detectionGitAbsent)),
        ],
      );
    }
    final shown = git.tags.reversed.take(8).join(', ');
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          if (git.linkedWorktree)
            Text(l10n.detectionGitWorktree)
          else ...[
            if (git.branch != null) Text(l10n.detectionGitBranch(git.branch!)),
            if (git.detachedCommit != null)
              Text(l10n.detectionGitDetached(git.detachedCommit!)),
            Text(l10n.detectionGitTags(git.tags.length, shown)),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.detectionGitStatusLater,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FindingsPanel extends StatelessWidget {
  const _FindingsPanel(this.report);

  final DetectionReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    String label(FindingCategory c) => switch (c) {
      FindingCategory.icon => l10n.categoryIcon,
      FindingCategory.screenshot => l10n.categoryScreenshot,
      FindingCategory.fastlane => l10n.categoryFastlane,
      FindingCategory.ci => l10n.categoryCi,
      FindingCategory.hosting => l10n.categoryHosting,
      FindingCategory.pwa => l10n.categoryPwa,
      FindingCategory.seo => l10n.detectionSeo,
      FindingCategory.legal => l10n.categoryLegal,
      FindingCategory.signing => l10n.categorySigning,
    };
    String detail(FileFinding f) => switch (f.detail) {
      null => f.path,
      'notRead' => '${f.path} (${l10n.signingNotRead})',
      final d => '${f.path} · $d',
    };

    final categories = FindingCategory.values.where(
      (c) => c != FindingCategory.seo,
    );
    final seo = {
      for (final f in report.findingsOf(FindingCategory.seo)) f.detail,
    };
    final showSeo =
        report.targetFor(PlatformTarget.web).detected || seo.isNotEmpty;

    return AdaptiveGrid(
      minItemWidth: 300,
      maxColumns: 3,
      children: [
        for (final c in categories)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(label(c), style: theme.textTheme.titleSmall),
                if (report.findingsOf(c).isEmpty)
                  Text(
                    l10n.detectionNothingFound,
                    style: TextStyle(color: palette.statusTodo),
                  )
                else
                  for (final f in report.findingsOf(c).take(8))
                    SelectableText(
                      detail(f),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
              ],
            ),
          ),
        if (showSeo)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(l10n.detectionSeo, style: theme.textTheme.titleSmall),
                for (final check in SeoCheck.all)
                  Row(
                    children: [
                      Icon(
                        seo.contains(check) ? Icons.check : Icons.close,
                        size: 16,
                        color: seo.contains(check)
                            ? palette.statusSucceeded
                            : palette.statusTodo,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(switch (check) {
                          SeoCheck.title => l10n.seoTitle,
                          SeoCheck.description => l10n.seoDescription,
                          SeoCheck.canonical => l10n.seoCanonical,
                          SeoCheck.openGraph => l10n.seoOpenGraph,
                          SeoCheck.twitterCard => l10n.seoTwitterCard,
                          SeoCheck.structuredData => l10n.seoStructuredData,
                          SeoCheck.robots => l10n.seoRobots,
                          _ => l10n.seoSitemap,
                        }, style: theme.textTheme.bodySmall),
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

class _PermissionsCard extends StatelessWidget {
  const _PermissionsCard(this.permissions);

  final List<PermissionFinding> permissions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(l10n.detectionPermissions, style: theme.textTheme.titleSmall),
          if (permissions.isEmpty) Text(l10n.detectionNoPermissions),
          for (final p in permissions)
            Row(
              children: [
                Pill(
                  label: targetLabel(p.target),
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    p.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ServicesCard extends StatelessWidget {
  const _ServicesCard(this.services);

  final List<ServiceFinding> services;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    String kind(ServiceKind k) => switch (k) {
      ServiceKind.analytics => l10n.serviceAnalytics,
      ServiceKind.ads => l10n.serviceAds,
      ServiceKind.crashReporting => l10n.serviceCrash,
      ServiceKind.messaging => l10n.serviceMessaging,
      ServiceKind.backend => l10n.serviceBackend,
      ServiceKind.payments => l10n.servicePayments,
    };
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(l10n.detectionServices, style: theme.textTheme.titleSmall),
          if (services.isEmpty) Text(l10n.detectionNoServices),
          for (final s in services)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(s.label),
                    Pill(
                      label: kind(s.kind),
                      color:
                          s.kind == ServiceKind.ads ||
                              s.kind == ServiceKind.analytics
                          ? palette.statusWarning
                          : palette.statusRunning,
                    ),
                  ],
                ),
                _EvidenceList([s.evidence]),
              ],
            ),
        ],
      ),
    );
  }
}
