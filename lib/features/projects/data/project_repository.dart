import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/watch_tables.dart';
import '../../../core/domain/action_level.dart';
import '../../../core/domain/step_status.dart';
import '../domain/project_enums.dart';
import '../domain/project_validation.dart';
import '../domain/project_views.dart';
import 'path_inspector.dart';

/// Accès persistant aux projets, sessions, cibles et checklists.
///
/// Ne lit ni ne modifie jamais le contenu des dossiers de projet : seule
/// leur existence est vérifiée.
class ProjectRepository {
  ProjectRepository(this._db, this._paths, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final PathInspector _paths;
  final DateTime Function() _now;

  /// Une étape pédagogique compte comme faite dès qu'elle a été lue.
  static const doneStatuses = [StepStatus.succeeded, StepStatus.pedagogical];

  // ---------------------------------------------------------------- lecture

  Stream<List<ProjectOverview>> watchOverviews() => watchTables(_db, [
    _db.projects,
    _db.releaseSessions,
    _db.checklistSteps,
  ], loadOverviews);

  /// Projets du plus récemment ouvert au plus ancien.
  Future<List<ProjectOverview>> loadOverviews() async {
    final projects = _db.projects;
    final sessions = _db.releaseSessions;
    final rows =
        await (_db.select(projects).join([
              leftOuterJoin(
                sessions,
                sessions.projectId.equalsExp(projects.id) &
                    sessions.status.equalsValue(SessionStatus.active),
              ),
            ])..orderBy([
              OrderingTerm.desc(projects.lastOpenedAt),
              OrderingTerm.desc(projects.id),
            ]))
            .get();
    final counts = await _stepCounts();

    return [
      for (final row in rows)
        await _overview(
          row.readTable(projects),
          row.readTableOrNull(sessions),
          counts,
        ),
    ];
  }

  Future<ProjectOverview> _overview(
    Project project,
    ReleaseSession? session,
    Map<int, (int, int)> counts,
  ) async {
    final (done, total) = session == null
        ? (0, 0)
        : counts[session.id] ?? (0, 0);
    return ProjectOverview(
      project: project,
      activeSession: session,
      stepsDone: done,
      stepsTotal: total,
      folderAvailable: await _paths.isDirectory(project.path),
    );
  }

  /// (faites, total) par session.
  Future<Map<int, (int, int)>> _stepCounts() async {
    final steps = _db.checklistSteps;
    final total = steps.id.count();
    final done = steps.id.count(filter: steps.status.isInValues(doneStatuses));
    final query = _db.selectOnly(steps)
      ..addColumns([steps.sessionId, total, done])
      ..groupBy([steps.sessionId]);
    return {
      for (final r in await query.get())
        r.read(steps.sessionId)!: (r.read(done)!, r.read(total)!),
    };
  }

  Stream<ProjectWorkspace?> watchWorkspace(int projectId) => watchTables(_db, [
    _db.projects,
    _db.releaseSessions,
    _db.checklistSteps,
  ], () => loadWorkspace(projectId));

  Future<ProjectWorkspace?> loadWorkspace(int projectId) async {
    final project = await _projectOrNull(projectId);
    if (project == null) return null;
    final session = await activeSessionOf(projectId);
    final steps = session == null
        ? const <ChecklistStepRecord>[]
        : await (_db.select(_db.checklistSteps)
                ..where((t) => t.sessionId.equals(session.id))
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();
    return ProjectWorkspace(
      project: project,
      activeSession: session,
      steps: steps,
      folderAvailable: await _paths.isDirectory(project.path),
    );
  }

  Future<ReleaseSession?> activeSessionOf(int projectId) =>
      (_db.select(_db.releaseSessions)..where(
            (t) =>
                t.projectId.equals(projectId) &
                t.status.equalsValue(SessionStatus.active),
          ))
          .getSingleOrNull();

  Stream<LocalDataStats> watchStats() => watchTables(_db, [
    _db.projects,
    _db.releaseSessions,
    _db.checklistSteps,
  ], stats);

  Future<LocalDataStats> stats() async {
    Future<int> count(TableInfo table) async {
      final c = countAll();
      final row = await (_db.selectOnly(table)..addColumns([c])).getSingle();
      return row.read(c)!;
    }

    return LocalDataStats(
      projects: await count(_db.projects),
      sessions: await count(_db.releaseSessions),
      steps: await count(_db.checklistSteps),
    );
  }

  Future<ProjectDeletionImpact> deletionImpact(int projectId) async {
    final sessionIds =
        await (_db.selectOnly(_db.releaseSessions)
              ..addColumns([_db.releaseSessions.id])
              ..where(_db.releaseSessions.projectId.equals(projectId)))
            .map((r) => r.read(_db.releaseSessions.id)!)
            .get();
    final c = countAll();
    final steps =
        await (_db.selectOnly(_db.checklistSteps)
              ..addColumns([c])
              ..where(_db.checklistSteps.sessionId.isIn(sessionIds)))
            .getSingle();
    return ProjectDeletionImpact(
      sessions: sessionIds.length,
      steps: steps.read(c)!,
    );
  }

  // ---------------------------------------------------------------- projets

  /// Enregistre un dossier existant. S'il est déjà connu, il est simplement
  /// rouvert : `created` vaut alors faux.
  Future<({Project project, bool created})> addProject(
    String rawPath, {
    String? name,
  }) async {
    final path = await _existingDirectory(rawPath);
    final existing = await (_db.select(
      _db.projects,
    )..where((t) => t.path.equals(path))).getSingleOrNull();
    if (existing != null) {
      await touchProject(existing.id);
      return (project: (await _projectOrNull(existing.id))!, created: false);
    }
    final now = _now();
    final id = await _db
        .into(_db.projects)
        .insert(
          ProjectsCompanion.insert(
            name: ProjectValidation.nameFor(path, name),
            path: path,
            createdAt: now,
            lastOpenedAt: now,
          ),
        );
    return (project: (await _projectOrNull(id))!, created: true);
  }

  Future<void> touchProject(int projectId) =>
      (_db.update(_db.projects)..where((t) => t.id.equals(projectId))).write(
        ProjectsCompanion(lastOpenedAt: Value(_now())),
      );

  Future<void> setFavorite(int projectId, bool favorite) =>
      (_db.update(_db.projects)..where((t) => t.id.equals(projectId))).write(
        ProjectsCompanion(favorite: Value(favorite)),
      );

  /// Nouveau chemin d'un projet dont le dossier a été déplacé.
  Future<void> relocate(int projectId, String rawPath) async {
    final path = await _existingDirectory(rawPath);
    final other =
        await (_db.select(
              _db.projects,
            )..where((t) => t.path.equals(path) & t.id.equals(projectId).not()))
            .getSingleOrNull();
    if (other != null) {
      throw const ProjectPathException(ProjectPathIssue.alreadyRegistered);
    }
    await (_db.update(
      _db.projects,
    )..where((t) => t.id.equals(projectId))).write(
      ProjectsCompanion(path: Value(path), lastOpenedAt: Value(_now())),
    );
  }

  /// Retire le projet et tout son historique local (cascade). Les fichiers
  /// du projet sur le disque ne sont pas touchés.
  Future<void> removeProject(int projectId) =>
      (_db.delete(_db.projects)..where((t) => t.id.equals(projectId))).go();

  Future<void> replaceTargets(
    int projectId,
    List<ProjectTargetsCompanion> targets,
  ) => _db.transaction(() async {
    await (_db.delete(
      _db.projectTargets,
    )..where((t) => t.projectId.equals(projectId))).go();
    for (final target in targets) {
      await _db
          .into(_db.projectTargets)
          .insert(target.copyWith(projectId: Value(projectId)));
    }
  });

  Future<List<ProjectTarget>> targetsOf(int projectId) =>
      (_db.select(_db.projectTargets)
            ..where((t) => t.projectId.equals(projectId))
            ..orderBy([(t) => OrderingTerm.asc(t.targetId)]))
          .get();

  // --------------------------------------------------------------- sessions

  /// Lève [ActiveSessionExistsException] si une session est déjà en cours.
  Future<ReleaseSession> startSession(int projectId, String rawVersion) async {
    final version = ProjectValidation.normalizeVersion(rawVersion);
    return _db.transaction(() async {
      final active = await activeSessionOf(projectId);
      if (active != null) throw ActiveSessionExistsException(active.id);
      final now = _now();
      final id = await _db
          .into(_db.releaseSessions)
          .insert(
            ReleaseSessionsCompanion.insert(
              projectId: projectId,
              version: version,
              status: SessionStatus.active,
              currentLevel: ActionLevel.analyze,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await touchProject(projectId);
      return (_db.select(
        _db.releaseSessions,
      )..where((t) => t.id.equals(id))).getSingle();
    });
  }

  Future<void> resumeSession(ReleaseSession session) =>
      _db.transaction(() async {
        await _touchSession(session.id);
        await touchProject(session.projectId);
      });

  Future<void> completeSession(int sessionId) {
    final now = _now();
    return (_db.update(
      _db.releaseSessions,
    )..where((t) => t.id.equals(sessionId))).write(
      ReleaseSessionsCompanion(
        status: const Value(SessionStatus.completed),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> addChecklistSteps(
    int sessionId,
    List<ChecklistStepsCompanion> steps,
  ) => _db.transaction(() async {
    final now = _now();
    for (final step in steps) {
      await _db
          .into(_db.checklistSteps)
          .insert(
            step.copyWith(sessionId: Value(sessionId), updatedAt: Value(now)),
          );
    }
    await _touchSession(sessionId);
  });

  Future<void> updateStepStatus(
    int stepId,
    StepStatus status, {
    String? note,
  }) => _db.transaction(() async {
    final step = await (_db.select(
      _db.checklistSteps,
    )..where((t) => t.id.equals(stepId))).getSingle();
    await (_db.update(
      _db.checklistSteps,
    )..where((t) => t.id.equals(stepId))).write(
      ChecklistStepsCompanion(
        status: Value(status),
        note: note == null ? const Value.absent() : Value(note),
        updatedAt: Value(_now()),
      ),
    );
    await _touchSession(step.sessionId);
  });

  /// Le contenu doit déjà être débarrassé de tout secret (masquage central
  /// prévu avec le moteur de commandes, phase 5).
  Future<void> addEntry(
    int sessionId,
    SessionEntryKind kind,
    String key,
    String content,
  ) => _db
      .into(_db.sessionEntries)
      .insert(
        SessionEntriesCompanion.insert(
          sessionId: sessionId,
          kind: kind,
          entryKey: key,
          content: content,
          createdAt: _now(),
        ),
      );

  Future<List<SessionEntry>> entriesOf(int sessionId) =>
      (_db.select(_db.sessionEntries)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<void> clearAll() => _db.clearAll();

  // -------------------------------------------------------------- internes

  Future<Project?> _projectOrNull(int id) => (_db.select(
    _db.projects,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> _touchSession(int sessionId) =>
      (_db.update(_db.releaseSessions)..where((t) => t.id.equals(sessionId)))
          .write(ReleaseSessionsCompanion(updatedAt: Value(_now())));

  Future<String> _existingDirectory(String rawPath) async {
    final path = ProjectValidation.normalizePath(
      rawPath,
      home: _paths.homeDirectory,
    );
    if (!await _paths.isDirectory(path)) {
      throw const ProjectPathException(ProjectPathIssue.notFound);
    }
    return path;
  }
}
