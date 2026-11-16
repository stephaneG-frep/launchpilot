import 'package:flutter/foundation.dart';

import '../../../core/domain/action_level.dart';
import '../../../core/domain/step_status.dart';
import 'checklist_step.dart';
import 'launch_target.dart';

/// Anomalie de construction, utile au diagnostic (jamais bloquante).
@immutable
class PlanProblem {
  const PlanProblem(this.stepId, this.message);
  final String stepId;
  final String message;

  @override
  String toString() => '$stepId : $message';
}

@immutable
class ChecklistPlan {
  const ChecklistPlan({required this.steps, this.problems = const []});

  /// Étapes ordonnées : par niveau, puis dépendances respectées.
  final List<ChecklistStep> steps;
  final List<PlanProblem> problems;
}

/// Assemble les étapes de toutes les cibles actives.
class ChecklistEngine {
  const ChecklistEngine(this.targets);

  final List<LaunchTarget> targets;

  Future<ChecklistPlan> build(ProjectInfo project) async {
    final problems = <PlanProblem>[];
    final collected = <ChecklistStep>[];
    final seen = <String>{};

    for (final target in targets) {
      if (!target.alwaysActive &&
          !project.selectedTargets.contains(target.id)) {
        continue;
      }
      for (final step in await target.buildChecklist(project)) {
        if (!step.id.startsWith('${target.id}.')) {
          problems.add(PlanProblem(step.id, 'préfixe ${target.id}. attendu'));
          continue;
        }
        if (!seen.add(step.id)) {
          problems.add(PlanProblem(step.id, 'identifiant en double'));
          continue;
        }
        collected.add(step);
      }
    }

    // Les dépendances vers une étape absente (cible non retenue, outil non
    // détecté) sont ignorées : elles ne doivent pas bloquer l'utilisateur.
    final byId = {for (final s in collected) s.id: s};
    final deps = <String, List<String>>{};
    for (final s in collected) {
      final valid = <String>[];
      for (final d in s.dependsOn) {
        if (byId.containsKey(d)) {
          valid.add(d);
        } else {
          problems.add(PlanProblem(s.id, 'dépendance absente : $d'));
        }
      }
      deps[s.id] = valid;
      for (final d in deps[s.id]!) {
        if (byId[d]!.level.index > s.level.index) {
          problems.add(
            PlanProblem(s.id, 'dépend de $d, d\'un niveau ultérieur'),
          );
        }
      }
    }

    return ChecklistPlan(
      steps: _order(collected, deps, problems),
      problems: problems,
    );
  }

  /// Tri topologique stable, niveau par niveau. Une étape prise dans un
  /// cycle est signalée et placée à la fin de son niveau.
  static List<ChecklistStep> _order(
    List<ChecklistStep> steps,
    Map<String, List<String>> deps,
    List<PlanProblem> problems,
  ) {
    final out = <ChecklistStep>[];
    final placed = <String>{};
    for (final level in ActionLevel.values) {
      final pending = steps.where((s) => s.level == level).toList();
      var progress = true;
      while (pending.isNotEmpty && progress) {
        progress = false;
        for (final s in List.of(pending)) {
          if (deps[s.id]!.every(placed.contains)) {
            out.add(s);
            placed.add(s.id);
            pending.remove(s);
            progress = true;
          }
        }
      }
      for (final s in pending) {
        problems.add(PlanProblem(s.id, 'cycle ou dépendance non résolue'));
        out.add(s);
        placed.add(s.id);
      }
    }
    return out;
  }
}

/// Statuts qui valent « terminé » pour débloquer la suite.
const doneStatuses = {StepStatus.succeeded, StepStatus.pedagogical};

/// Lecture de l'avancement à partir des statuts enregistrés.
@immutable
class ChecklistProgress {
  ChecklistProgress(this.steps, Map<String, StepStatus> statuses)
    : statuses = {
        for (final s in steps) s.id: statuses[s.id] ?? StepStatus.todo,
      };

  final List<ChecklistStep> steps;
  final Map<String, StepStatus> statuses;

  bool isDone(String id) => doneStatuses.contains(statuses[id]);

  /// Prérequis pas encore terminés.
  List<ChecklistStep> blockers(ChecklistStep step) => [
    for (final d in step.dependsOn)
      for (final s in steps)
        if (s.id == d && !isDone(d)) s,
  ];

  bool isBlocked(ChecklistStep step) =>
      !isDone(step.id) && blockers(step).isNotEmpty;

  int get done => steps.where((s) => isDone(s.id)).length;

  double get ratio => steps.isEmpty ? 0 : done / steps.length;

  /// Premier niveau qui contient une étape non terminée (le dernier sinon).
  ActionLevel get currentLevel {
    for (final level in ActionLevel.values) {
      if (steps.any((s) => s.level == level && !isDone(s.id))) return level;
    }
    return ActionLevel.publish;
  }

  /// Prochaine étape faisable, dans l'ordre du plan.
  ChecklistStep? get next {
    for (final s in steps) {
      if (!isDone(s.id) && !isBlocked(s)) return s;
    }
    return null;
  }
}
