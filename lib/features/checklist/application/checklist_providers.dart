import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/step_status.dart';
import '../../commands/domain/command_result.dart';
import '../../detection/application/detection_providers.dart';
import '../../projects/application/project_providers.dart';
import '../../settings/application/settings_controller.dart';
import '../data/checklist_repository.dart';
import '../domain/checklist_engine.dart';
import '../domain/checklist_step.dart';
import '../domain/launch_target.dart';
import '../targets/platform_targets.dart';

/// Cibles enregistrées. Ajouter une cible = l'ajouter à cette liste.
final launchTargetsProvider = Provider<List<LaunchTarget>>(
  (ref) => builtInTargets,
);

final checklistEngineProvider = Provider<ChecklistEngine>(
  (ref) => ChecklistEngine(ref.watch(launchTargetsProvider)),
);

final checklistRepositoryProvider = Provider<ChecklistRepository>(
  (ref) => ChecklistRepository(ref.watch(appDatabaseProvider)),
);

/// Ce dont dépend le plan : un changement de statut ne le recalcule pas.
typedef _PlanInputs = ({int sessionId, String root, String version});

/// Plan de la session active, synchronisé avec la base.
final currentPlanProvider = FutureProvider<ChecklistPlan?>((ref) async {
  final inputs = ref.watch(
    currentWorkspaceProvider.select((ws) {
      final w = ws.value;
      final s = w?.activeSession;
      if (w == null || s == null) return null;
      return (sessionId: s.id, root: w.project.path, version: s.version)
          as _PlanInputs?;
    }),
  );
  if (inputs == null) return null;
  final detection = await ref.watch(currentDetectionProvider.future);
  if (detection == null) return null;
  final language = ref.watch(
    settingsControllerProvider.select((s) => s.language),
  );

  final plan = await ref
      .read(checklistEngineProvider)
      .build(
        ProjectInfo(
          root: inputs.root,
          report: detection.report,
          selectedTargets: {for (final t in detection.selected) t.name},
          language: language,
          version: inputs.version,
        ),
      );
  await ref
      .read(checklistRepositoryProvider)
      .sync(inputs.sessionId, plan.steps);
  return plan;
}, retry: (_, _) => null);

/// Plan + statuts enregistrés, prêt à afficher.
@immutable
class ChecklistView {
  ChecklistView(this.sessionId, this.plan, this.records)
    : progress = ChecklistProgress(plan.steps, {
        for (final e in records.entries) e.key: e.value.status,
      });

  final int sessionId;
  final ChecklistPlan plan;
  final Map<String, StepRecordState> records;
  final ChecklistProgress progress;

  List<ChecklistStep> get steps => [
    for (final s in plan.steps) s.withStatus(progress.statuses[s.id]!),
  ];
}

final currentChecklistProvider = StreamProvider<ChecklistView?>((ref) async* {
  final plan = await ref.watch(currentPlanProvider.future);
  final sessionId = ref.watch(
    currentWorkspaceProvider.select((ws) => ws.value?.activeSession?.id),
  );
  if (plan == null || sessionId == null) {
    yield null;
    return;
  }
  yield* ref
      .watch(checklistRepositoryProvider)
      .watch(sessionId)
      .map((records) => ChecklistView(sessionId, plan, records));
}, retry: (_, _) => null);

/// L'action n'est pas permise : prérequis non terminés.
class StepBlockedException implements Exception {
  const StepBlockedException();
}

final checklistActionsProvider = Provider<ChecklistActions>(
  ChecklistActions.new,
);

/// Changements de statut, toujours suivis de la mise à jour du niveau
/// courant de la session.
class ChecklistActions {
  ChecklistActions(this._ref);

  final Ref _ref;

  ChecklistRepository get _repo => _ref.read(checklistRepositoryProvider);

  Future<void> setStatus(
    ChecklistView view,
    ChecklistStep step,
    StepStatus status, {
    String? note,
  }) async {
    if (status != StepStatus.todo && view.progress.isBlocked(step)) {
      throw const StepBlockedException();
    }
    await _repo.setStatus(view.sessionId, step.id, status, note: note);
    final statuses = {...view.progress.statuses, step.id: status};
    await _repo.setCurrentLevel(
      view.sessionId,
      ChecklistProgress(view.plan.steps, statuses).currentLevel,
    );
  }

  /// Statut d'une étape de commande d'après le résultat de son exécution.
  /// Nul : aucun changement (simulation, annulation, refus).
  static StepStatus? statusFor(RunStatus run) => switch (run) {
    RunStatus.succeeded => StepStatus.succeeded,
    RunStatus.failed ||
    RunStatus.timedOut ||
    RunStatus.startFailed => StepStatus.failed,
    RunStatus.simulated || RunStatus.cancelled || RunStatus.blocked => null,
  };

  /// Fin d'une étape manuelle ou pédagogique.
  static StepStatus completionFor(ChecklistStep step) =>
      step.kind == StepKind.pedagogical
      ? StepStatus.pedagogical
      : StepStatus.succeeded;
}
