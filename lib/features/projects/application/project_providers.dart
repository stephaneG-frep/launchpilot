import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ios/application/ios_providers.dart';
import '../../web/application/web_providers.dart';
import '../../../core/database/app_database.dart';
import '../../changes/application/change_providers.dart';
import '../../settings/application/settings_controller.dart';
import '../data/path_inspector.dart';
import '../data/project_repository.dart';
import '../domain/project_views.dart';

/// Surchargé dans `main()` (fichier SQLite) et dans les tests (mémoire).
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider non surchargé'),
);

/// Chemin du fichier SQLite, affiché dans les paramètres.
final databaseLocationProvider = Provider<String?>((ref) => null);

final pathInspectorProvider = Provider<PathInspector>(
  (ref) => const LocalPathInspector(),
);

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(pathInspectorProvider),
  ),
);

final projectOverviewsProvider = StreamProvider<List<ProjectOverview>>(
  (ref) => ref.watch(projectRepositoryProvider).watchOverviews(),
  retry: (_, _) => null,
);

final localDataStatsProvider = StreamProvider<LocalDataStats>(
  (ref) => ref.watch(projectRepositoryProvider).watchStats(),
  retry: (_, _) => null,
);

/// Projet ouvert dans l'espace de travail, mémorisé entre deux lancements.
final currentProjectIdProvider =
    NotifierProvider<CurrentProjectController, int?>(
      CurrentProjectController.new,
    );

final currentWorkspaceProvider = StreamProvider<ProjectWorkspace?>((ref) {
  final id = ref.watch(currentProjectIdProvider);
  if (id == null) return Stream.value(null);
  return ref.watch(projectRepositoryProvider).watchWorkspace(id);
}, retry: (_, _) => null);

class CurrentProjectController extends Notifier<int?> {
  static const prefsKey = 'lp.currentProjectId';

  @override
  int? build() => ref.watch(sharedPreferencesProvider).getInt(prefsKey);

  Future<void> select(int? projectId) async {
    state = projectId;
    final prefs = ref.read(sharedPreferencesProvider);
    if (projectId == null) {
      await prefs.remove(prefsKey);
    } else {
      await prefs.setInt(prefsKey, projectId);
    }
  }
}

final projectActionsProvider = Provider<ProjectActions>(ProjectActions.new);

/// Opérations déclenchées par l'interface. Garde le projet courant cohérent
/// avec les données (retrait, effacement…).
class ProjectActions {
  ProjectActions(this._ref);

  final Ref _ref;

  ProjectRepository get _repo => _ref.read(projectRepositoryProvider);
  CurrentProjectController get _current =>
      _ref.read(currentProjectIdProvider.notifier);

  Future<({Project project, bool created})> addAndOpen(
    String path, {
    String? name,
  }) async {
    final result = await _repo.addProject(path, name: name);
    await _current.select(result.project.id);
    return result;
  }

  Future<void> open(int projectId) async {
    await _repo.touchProject(projectId);
    await _current.select(projectId);
  }

  Future<void> setFavorite(int projectId, bool favorite) =>
      _repo.setFavorite(projectId, favorite);

  Future<void> relocate(int projectId, String path) =>
      _repo.relocate(projectId, path);

  Future<void> remove(int projectId) async {
    await _repo.removeProject(projectId);
    await _ref.read(projectWriterProvider).deleteBackups(projectId);
    await _ref.read(webConfigRepositoryProvider).delete(projectId);
    await _ref.read(iosConfigRepositoryProvider).delete(projectId);
    if (_ref.read(currentProjectIdProvider) == projectId) {
      await _current.select(null);
    }
  }

  Future<ReleaseSession> startSession(int projectId, String version) async {
    final session = await _repo.startSession(projectId, version);
    await _current.select(projectId);
    return session;
  }

  Future<void> resumeSession(ReleaseSession session) async {
    await _repo.resumeSession(session);
    await _current.select(session.projectId);
  }

  Future<void> completeSession(int sessionId) =>
      _repo.completeSession(sessionId);

  Future<void> clearAllLocalData() async {
    await _repo.clearAll();
    await _ref.read(projectWriterProvider).deleteBackups();
    await _ref.read(webConfigRepositoryProvider).deleteAll();
    await _ref.read(iosConfigRepositoryProvider).deleteAll();
    await _current.select(null);
  }
}
