import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/watch_tables.dart';
import '../../../core/domain/action_level.dart';
import '../../../core/domain/step_status.dart';
import '../domain/checklist_step.dart';

@immutable
class StepRecordState {
  const StepRecordState(this.status, this.note);
  final StepStatus status;
  final String? note;
}

/// Suivi persistant des étapes d'une session. Le contenu des étapes est
/// régénéré par les cibles ; seuls statut, note et ordre sont stockés.
class ChecklistRepository {
  ChecklistRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// Aligne la base sur le plan : nouvelles étapes ajoutées (à faire),
  /// existantes mises à jour sans toucher au statut, disparues supprimées.
  /// N'écrit que ce qui change, pour ne pas relancer inutilement les flux.
  Future<void> sync(int sessionId, List<ChecklistStep> plan) =>
      _db.transaction(() async {
        final existing = {
          for (final r in await (_db.select(
            _db.checklistSteps,
          )..where((t) => t.sessionId.equals(sessionId))).get())
            r.stepKey: r,
        };
        final now = _now();
        for (final (position, step) in plan.indexed) {
          final row = existing.remove(step.id);
          if (row == null) {
            await _db
                .into(_db.checklistSteps)
                .insert(
                  ChecklistStepsCompanion.insert(
                    sessionId: sessionId,
                    stepKey: step.id,
                    targetId: Value(step.targetId),
                    level: step.level,
                    position: position,
                    title: step.title,
                    status: StepStatus.todo,
                    updatedAt: now,
                  ),
                );
          } else if (row.position != position ||
              row.title != step.title ||
              row.level != step.level ||
              row.targetId != step.targetId) {
            await (_db.update(
              _db.checklistSteps,
            )..where((t) => t.id.equals(row.id))).write(
              ChecklistStepsCompanion(
                position: Value(position),
                title: Value(step.title),
                level: Value(step.level),
                targetId: Value(step.targetId),
              ),
            );
          }
        }
        if (existing.isNotEmpty) {
          await (_db.delete(_db.checklistSteps)..where(
                (t) => t.id.isIn([for (final r in existing.values) r.id]),
              ))
              .go();
        }
      });

  Stream<Map<String, StepRecordState>> watch(int sessionId) =>
      watchTables(_db, [_db.checklistSteps], () => load(sessionId));

  Future<Map<String, StepRecordState>> load(int sessionId) async => {
    for (final r in await (_db.select(
      _db.checklistSteps,
    )..where((t) => t.sessionId.equals(sessionId))).get())
      r.stepKey: StepRecordState(r.status, r.note),
  };

  Future<void> setStatus(
    int sessionId,
    String stepKey,
    StepStatus status, {
    String? note,
  }) => _db.transaction(() async {
    final now = _now();
    await (_db.update(_db.checklistSteps)..where(
          (t) => t.sessionId.equals(sessionId) & t.stepKey.equals(stepKey),
        ))
        .write(
          ChecklistStepsCompanion(
            status: Value(status),
            note: Value(note),
            updatedAt: Value(now),
          ),
        );
    await (_db.update(_db.releaseSessions)
          ..where((t) => t.id.equals(sessionId)))
        .write(ReleaseSessionsCompanion(updatedAt: Value(now)));
  });

  Future<void> setCurrentLevel(int sessionId, ActionLevel level) =>
      (_db.update(_db.releaseSessions)..where(
            (t) =>
                t.id.equals(sessionId) &
                t.currentLevel.equalsValue(level).not(),
          ))
          .write(ReleaseSessionsCompanion(currentLevel: Value(level)));
}
