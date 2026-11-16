import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain/action_level.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../android/application/android_providers.dart';
import '../../android/data/android_reader.dart';
import '../../android/domain/android_audit.dart';
import '../../android/domain/deliverables.dart';
import '../../android/presentation/android_texts.dart';
import '../../checklist/application/checklist_providers.dart';
import '../../checklist/domain/checklist_engine.dart';
import '../../checklist/domain/launch_target.dart';
import '../../detection/data/detection_repository.dart';
import '../../detection/domain/detection_report.dart';
import '../../help/domain/glossary.dart';
import '../../ios/application/ios_providers.dart';
import '../../ios/domain/ios_audit.dart';
import '../../ios/presentation/ios_texts.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/project_enums.dart';
import '../../settings/domain/app_settings.dart';
import '../../web/application/web_providers.dart';
import '../../web/domain/web_audit.dart';
import '../../web/domain/web_build.dart';
import '../../web/presentation/audit_texts.dart';
import '../domain/report.dart';

/// Version de LaunchPilot inscrite dans les rapports.
const launchPilotVersion = '1.0.0';

final reportBuilderProvider = Provider<ReportBuilder>(ReportBuilder.new);

/// Réunit tout ce qu'un rapport de session doit contenir. Ne lit que la
/// base, les rapports de détection et les fichiers du projet (jamais un
/// fichier sensible) ; les commandes sont déjà masquées dans le journal.
class ReportBuilder {
  ReportBuilder(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(appDatabaseProvider);

  Future<ReportData> build(
    int sessionId,
    AppLanguage language,
    AppLocalizations l10n, {
    DateTime? now,
  }) async {
    final session = await (_db.select(
      _db.releaseSessions,
    )..where((t) => t.id.equals(sessionId))).getSingle();
    final project = await (_db.select(
      _db.projects,
    )..where((t) => t.id.equals(session.projectId))).getSingle();
    final root = project.path;
    final detection = await DetectionRepository(_db).load(project.id);
    final report = detection?.report;
    final selected = detection?.selected ?? const <PlatformTarget>{};

    // Étapes : enregistrées pour la session, dans l'ordre du plan.
    final records =
        await (_db.select(_db.checklistSteps)
              ..where((t) => t.sessionId.equals(sessionId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    const done = doneStatuses;
    final steps = [
      for (final s in records)
        ReportStep(
          title: s.title,
          target: s.targetId ?? 'common',
          level: s.level.label(l10n),
          status: s.status.label(l10n),
          done: done.contains(s.status),
        ),
    ];

    // Lexique : termes cités par les étapes du plan actuel.
    final glossaryIds = <String>{};
    if (report != null) {
      final plan = await _ref
          .read(checklistEngineProvider)
          .build(
            ProjectInfo(
              root: root,
              report: report,
              selectedTargets: {for (final t in selected) t.name},
              language: language,
              version: session.version,
            ),
          );
      for (final s in plan.steps) {
        glossaryIds.addAll(s.glossary);
      }
    }
    final glossary = [
      for (final e in Glossary.forLanguage(language))
        if (glossaryIds.contains(e.id)) (e.term, e.definition),
    ];

    final files =
        await (_db.select(_db.fileChanges)
              ..where(
                (t) =>
                    t.projectId.equals(project.id) &
                    t.appliedAt.isBiggerOrEqualValue(session.createdAt),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.appliedAt)]))
            .get();
    final logs =
        await (_db.select(_db.commandLogs)
              ..where(
                (t) =>
                    t.projectId.equals(project.id) &
                    t.startedAt.isBiggerOrEqualValue(session.createdAt),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
            .get();
    bool isCheck(CommandLogEntry c) {
      final a = c.arguments;
      return switch (c.executable) {
        'flutter' || 'dart' =>
          a.contains('test') || a.contains('analyze') || a.contains('doctor'),
        'npm' ||
        'pnpm' ||
        'yarn' ||
        'bun' => a.contains('test') || a.contains('lint'),
        'lighthouse' => true,
        _ => false,
      };
    }

    final commands = [
      for (final c in logs)
        ReportCommand(
          display: [c.executable, ...c.arguments].join(' '),
          status: c.status,
          exitCode: c.exitCode,
          at: c.startedAt,
          durationMs: c.durationMs,
          isCheck: isCheck(c),
        ),
    ];

    final audits = <ReportAudit>[];
    final deliverables = <ReportDeliverable>[];
    final flutter = report?.technologies.any((t) => t.id == 'flutter') ?? false;
    if (report != null && selected.contains(PlatformTarget.web)) {
      final plan = planWebBuild(report);
      if (plan != null) {
        final site = _ref.read(siteReaderProvider).read(root, plan.outputDir);
        if (site != null) {
          final a = auditSite(site, spa: plan.spa);
          audits.add(
            ReportAudit('Web', [
              for (final i in a.items)
                ReportAuditLine(
                  i.status,
                  auditText(i, language).label,
                  auditText(i, language).fix,
                ),
            ]),
          );
        }
      }
    }
    if (report != null &&
        flutter &&
        selected.contains(PlatformTarget.android)) {
      final reader = _ref.read(androidReaderProvider);
      final android = reader.read(root, report);
      if (android != null) {
        final pub = reader.pubspec(root, report);
        final checks = auditAndroid(
          android,
          dependencies: pub.dependencies,
          pubVersion: pub.version,
        );
        audits.add(
          ReportAudit('Android', [
            for (final c in checks)
              ReportAuditLine(
                c.status,
                androidCheckText(c, language).label,
                androidCheckText(c, language).fix,
              ),
          ]),
        );
      }
      final found = await _ref.read(deliverableInspectorProvider)((
        root: root,
        paths: deliverableCandidates(AndroidReader.pubDir(report)),
      ));
      for (final d in found) {
        deliverables.add(
          ReportDeliverable(
            d.path,
            formatSize(d.size, locale: language.name),
            d.sha256,
            switch (d.signing) {
              DeliverableSigning.debug => l10n.androidSignedDebug,
              DeliverableSigning.signed => l10n.androidSignedRelease,
              DeliverableSigning.unsigned => l10n.androidUnsigned,
            },
          ),
        );
      }
    }
    if (report != null && flutter && selected.contains(PlatformTarget.ios)) {
      final ios = _ref.read(iosReaderProvider).read(root, report);
      if (ios != null) {
        final deps = _ref
            .read(androidReaderProvider)
            .pubspec(root, report)
            .dependencies;
        final checks = auditIos(
          ios,
          linuxHost: _ref.read(hostIsLinuxProvider),
          dependencies: deps,
        );
        audits.add(
          ReportAudit('iOS', [
            for (final c in checks)
              ReportAuditLine(
                c.status,
                iosCheckText(c, language).label,
                iosCheckText(c, language).fix,
              ),
          ]),
        );
      }
    }

    return ReportData(
      language: language,
      appVersion: launchPilotVersion,
      generatedAt: now ?? DateTime.now(),
      projectName: project.name,
      sessionVersion: session.version,
      sessionStatus: session.status == SessionStatus.completed
          ? l10n.reportStatusCompleted
          : l10n.reportStatusActive,
      sessionCreated: session.createdAt,
      sessionCompleted: session.completedAt,
      currentLevel: session.currentLevel.label(l10n),
      technologies: [for (final t in report?.technologies ?? const []) t.label],
      targets: [
        for (final t in PlatformTarget.values)
          if (selected.contains(t)) t.name,
      ],
      steps: steps,
      files: [
        for (final f in files)
          ReportFile(f.path, f.label, f.appliedAt, created: !f.existedBefore),
      ],
      commands: commands,
      deliverables: deliverables,
      audits: audits,
      procedures: {
        for (final t in PlatformTarget.values)
          if (selected.contains(t)) t.name: manualProcedure(t.name, language),
      },
      glossary: glossary,
    );
  }
}

/// Résumé d'une session pour l'historique.
typedef SessionSummary = ({
  ReleaseSession session,
  Project project,
  int done,
  int total,
  int reports,
});

/// Toutes les sessions, les plus récentes d'abord.
final sessionHistoryProvider = FutureProvider<List<SessionSummary>>((
  ref,
) async {
  final db = ref.watch(appDatabaseProvider);
  // Recalculé à chaque changement de session ou d'étape.
  ref.watch(projectOverviewsProvider);
  final sessions = await (db.select(
    db.releaseSessions,
  )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
  final projects = {
    for (final p in await db.select(db.projects).get()) p.id: p,
  };
  final steps = await db.select(db.checklistSteps).get();
  final entries = await (db.select(
    db.sessionEntries,
  )..where((t) => t.kind.equalsValue(SessionEntryKind.report))).get();
  const done = doneStatuses;
  return [
    for (final s in sessions)
      if (projects[s.projectId] case final p?)
        (
          session: s,
          project: p,
          done: steps
              .where((x) => x.sessionId == s.id && done.contains(x.status))
              .length,
          total: steps.where((x) => x.sessionId == s.id).length,
          reports: entries.where((e) => e.sessionId == s.id).length,
        ),
  ];
}, retry: (_, _) => null);

/// Niveau courant, utile aux tests.
String levelName(ActionLevel l) => l.name;
