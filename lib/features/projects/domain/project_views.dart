import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';

/// Projet tel qu'affiché à l'accueil : session active et progression.
@immutable
class ProjectOverview {
  const ProjectOverview({
    required this.project,
    required this.folderAvailable,
    this.activeSession,
    this.stepsDone = 0,
    this.stepsTotal = 0,
  });

  final Project project;
  final ReleaseSession? activeSession;
  final int stepsDone;
  final int stepsTotal;

  /// Faux si le dossier a été déplacé ou supprimé depuis l'enregistrement.
  final bool folderAvailable;

  double get progress => stepsTotal == 0 ? 0 : stepsDone / stepsTotal;
}

/// Projet ouvert dans l'espace de travail, avec sa session active.
@immutable
class ProjectWorkspace {
  const ProjectWorkspace({
    required this.project,
    required this.folderAvailable,
    this.activeSession,
    this.steps = const [],
  });

  final Project project;
  final bool folderAvailable;
  final ReleaseSession? activeSession;
  final List<ChecklistStepRecord> steps;
}

/// Ce que supprimerait le retrait d'un projet.
@immutable
class ProjectDeletionImpact {
  const ProjectDeletionImpact({required this.sessions, required this.steps});
  final int sessions;
  final int steps;
}

@immutable
class LocalDataStats {
  const LocalDataStats({
    required this.projects,
    required this.sessions,
    required this.steps,
  });

  final int projects;
  final int sessions;
  final int steps;

  bool get isEmpty => projects == 0 && sessions == 0 && steps == 0;
}
