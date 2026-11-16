import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../projects/application/project_providers.dart';
import '../data/project_writer.dart';

/// Dossier des copies de sauvegarde, hors des projets. Surchargé dans
/// `main()` et dans les tests.
final backupRootProvider = Provider<String>(
  (ref) => throw UnimplementedError('backupRootProvider non surchargé'),
);

final projectWriterProvider = Provider<ProjectWriter>(
  (ref) => ProjectWriter(
    ref.watch(appDatabaseProvider),
    backupRoot: ref.watch(backupRootProvider),
  ),
);

/// Fichiers modifiés par LaunchPilot dans le projet ouvert.
final currentFileChangesProvider = StreamProvider<List<FileChangeRecord>>((
  ref,
) {
  final id = ref.watch(currentProjectIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(projectWriterProvider).watchChanges(id);
}, retry: (_, _) => null);
