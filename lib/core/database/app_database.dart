import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/projects/domain/project_enums.dart';
import '../domain/action_level.dart';
import '../domain/step_status.dart';
import 'app_database.steps.dart';
import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Projects,
    ProjectTargets,
    ReleaseSessions,
    ChecklistSteps,
    SessionEntries,
    DetectionReports,
    CommandLogs,
    FileChanges,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Base SQLite de l'application, dans le fichier [path].
  factory AppDatabase.open(String path) => AppDatabase(
    driftDatabase(
      name: 'launchpilot',
      native: DriftNativeOptions(databasePath: () async => path),
    ),
  );

  /// Toute modification du schéma incrémente cette valeur et ajoute une
  /// étape de migration, vérifiée par les tests de `test/drift/`.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Une base plus récente que l'application n'est jamais « rétrogradée ».
      if (from > to) {
        throw StateError(
          'Base de données en version $from, application en version $to.',
        );
      }
      await _steps(m, from, to);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Une étape par version, générée par `drift_dev make-migrations`.
  static final _steps = stepByStep(
    from1To2: (m, schema) async {
      await m.createTable(schema.detectionReports);
    },
    from2To3: (m, schema) async {
      await m.createTable(schema.commandLogs);
      await m.createIndex(schema.commandLogsProject);
      await m.createTable(schema.fileChanges);
      await m.createIndex(schema.fileChangesProject);
    },
  );

  /// Efface toutes les données locales, dans une seule transaction.
  Future<void> clearAll() => transaction(() async {
    // L'ordre respecte les clés étrangères même si la cascade est active.
    for (final table in <TableInfo>[
      fileChanges,
      commandLogs,
      detectionReports,
      sessionEntries,
      checklistSteps,
      releaseSessions,
      projectTargets,
      projects,
    ]) {
      await delete(table).go();
    }
  });
}
