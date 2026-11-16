import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/watch_tables.dart';
import '../domain/detection_report.dart';

/// Dernier rapport d'un projet et choix de cibles de l'utilisateur.
@immutable
class ProjectDetection {
  const ProjectDetection({
    required this.report,
    required this.selected,
    this.targetsReviewedAt,
  });

  final DetectionReport report;

  /// Cibles retenues : celles détectées tant que l'utilisateur n'a rien
  /// validé, puis ses propres choix.
  final Set<PlatformTarget> selected;
  final DateTime? targetsReviewedAt;

  bool get reviewed => targetsReviewedAt != null;
}

class DetectionRepository {
  DetectionRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Stream<ProjectDetection?> watch(int projectId) => watchTables(_db, [
    _db.detectionReports,
    _db.projectTargets,
  ], () => load(projectId));

  Future<ProjectDetection?> load(int projectId) async {
    final row = await (_db.select(
      _db.detectionReports,
    )..where((t) => t.projectId.equals(projectId))).getSingleOrNull();
    if (row == null) return null;
    final targets = await (_db.select(
      _db.projectTargets,
    )..where((t) => t.projectId.equals(projectId))).get();
    return ProjectDetection(
      report: DetectionReport.fromJson(
        (jsonDecode(row.report) as Map).cast<String, Object?>(),
      ),
      selected: {
        for (final t in targets)
          if (t.confirmed) ?PlatformTarget.values.asNameMap()[t.targetId],
      },
      targetsReviewedAt: row.targetsReviewedAt,
    );
  }

  /// Enregistre un nouveau rapport. Si l'utilisateur avait déjà validé ses
  /// cibles, ses choix sont conservés ; sinon ils suivent la détection.
  Future<void> saveReport(int projectId, DetectionReport report) =>
      _db.transaction(() async {
        final previous = await (_db.select(
          _db.detectionReports,
        )..where((t) => t.projectId.equals(projectId))).getSingleOrNull();
        final reviewed = previous?.targetsReviewedAt != null;
        final oldChoices = {
          for (final t in await (_db.select(
            _db.projectTargets,
          )..where((t) => t.projectId.equals(projectId))).get())
            t.targetId: t.confirmed,
        };

        final encoded = jsonEncode(report.toJson());
        if (previous == null) {
          await _db
              .into(_db.detectionReports)
              .insert(
                DetectionReportsCompanion.insert(
                  projectId: projectId,
                  scannedAt: report.scannedAt,
                  report: encoded,
                ),
              );
        } else {
          await (_db.update(
            _db.detectionReports,
          )..where((t) => t.id.equals(previous.id))).write(
            DetectionReportsCompanion(
              scannedAt: Value(report.scannedAt),
              report: Value(encoded),
            ),
          );
        }

        await (_db.update(
          _db.projects,
        )..where((t) => t.id.equals(projectId))).write(
          ProjectsCompanion(
            technologies: Value([
              for (final t in report.technologies)
                if (!t.informative) t.label,
            ]),
          ),
        );

        await (_db.delete(
          _db.projectTargets,
        )..where((t) => t.projectId.equals(projectId))).go();
        for (final t in report.targets) {
          final kept = reviewed ? oldChoices[t.target.name] : null;
          await _db
              .into(_db.projectTargets)
              .insert(
                ProjectTargetsCompanion.insert(
                  projectId: projectId,
                  targetId: t.target.name,
                  detected: Value(t.detected),
                  confirmed: Value(kept ?? t.detected),
                  confidence: Value(t.confidence),
                  evidence: Value([for (final e in t.evidence) '$e']),
                ),
              );
        }
      });

  Future<void> setTargetSelected(
    int projectId,
    PlatformTarget target,
    bool selected,
  ) =>
      (_db.update(_db.projectTargets)..where(
            (t) =>
                t.projectId.equals(projectId) & t.targetId.equals(target.name),
          ))
          .write(ProjectTargetsCompanion(confirmed: Value(selected)));

  /// L'utilisateur a relu et validé les cibles.
  Future<void> markTargetsReviewed(int projectId) =>
      (_db.update(_db.detectionReports)
            ..where((t) => t.projectId.equals(projectId)))
          .write(DetectionReportsCompanion(targetsReviewedAt: Value(_now())));
}
