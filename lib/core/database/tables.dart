import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/projects/domain/project_enums.dart';
import '../domain/action_level.dart';
import '../domain/step_status.dart';

/// Aucune table ne contient de secret : clés, mots de passe et jetons
/// vivent uniquement dans le trousseau du système.

@DataClassName('Project')
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get path => text().unique()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();

  /// Technologies détectées (phase 4), en JSON.
  TextColumn get technologies => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime()();
}

/// Cible de publication d'un projet (Android, iOS, web…), détectée puis
/// confirmée ou corrigée par l'utilisateur.
@DataClassName('ProjectTarget')
@TableIndex(name: 'project_targets_project', columns: {#projectId})
class ProjectTargets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get targetId => text()();
  BoolColumn get detected => boolean().withDefault(const Constant(false))();
  BoolColumn get confirmed => boolean().withDefault(const Constant(false))();
  RealColumn get confidence => real().withDefault(const Constant(0))();
  TextColumn get evidence => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {projectId, targetId},
  ];
}

@DataClassName('ReleaseSession')
@TableIndex(name: 'release_sessions_project', columns: {#projectId})
class ReleaseSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get version => text().withLength(min: 1, max: 64)();
  TextColumn get status => textEnum<SessionStatus>()();
  TextColumn get currentLevel => textEnum<ActionLevel>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

/// État persistant d'une étape. Le contenu pédagogique est reconstruit par
/// les cibles (phase 6) à partir de [stepKey] ; seul le suivi est stocké.
@DataClassName('ChecklistStepRecord')
@TableIndex(name: 'checklist_steps_session', columns: {#sessionId})
class ChecklistSteps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(ReleaseSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get stepKey => text()();
  TextColumn get targetId => text().nullable()();
  TextColumn get level => textEnum<ActionLevel>()();
  IntColumn get position => integer()();
  TextColumn get title => text()();
  TextColumn get status => textEnum<StepStatus>()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {sessionId, stepKey},
  ];
}

/// Textes validés, rapports et résultats d'audit rattachés à une session.
@DataClassName('SessionEntry')
@TableIndex(name: 'session_entries_session', columns: {#sessionId})
class SessionEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(ReleaseSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<SessionEntryKind>()();
  TextColumn get entryKey => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Dernier rapport de détection d'un projet (schéma v2).
@DataClassName('DetectionRecord')
class DetectionReports extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().unique().references(
    Projects,
    #id,
    onDelete: KeyAction.cascade,
  )();
  DateTimeColumn get scannedAt => dateTime()();

  /// `DetectionReport` sérialisé (chemins relatifs, aucun contenu de fichier).
  TextColumn get report => text()();

  /// Moment où l'utilisateur a validé les cibles ; nul tant qu'il ne l'a pas
  /// fait (les cibles suivent alors la détection).
  DateTimeColumn get targetsReviewedAt => dateTime().nullable()();
}

/// Journal des commandes exécutées (schéma v3). Arguments et sortie y sont
/// déjà masqués : aucun secret n'est enregistré.
@DataClassName('CommandLogEntry')
@TableIndex(name: 'command_logs_project', columns: {#projectId})
class CommandLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get executable => text()();
  TextColumn get arguments => text().map(const StringListConverter())();
  TextColumn get workingDirectory => text()();
  TextColumn get risk => text()();
  TextColumn get status => text()();
  IntColumn get exitCode => integer().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();

  /// Dernières lignes de sortie, préfixées `1|` (stdout) ou `2|` (stderr).
  TextColumn get output => text().withDefault(const Constant(''))();
}

/// Fichier créé ou modifié par LaunchPilot (schéma v3), avec de quoi le
/// restaurer sans écraser une modification faite depuis par l'utilisateur.
@DataClassName('FileChangeRecord')
@TableIndex(name: 'file_changes_project', columns: {#projectId})
class FileChanges extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();

  /// Regroupe les fichiers écrits ensemble.
  TextColumn get batchId => text()();
  TextColumn get label => text()();

  /// Chemin relatif à la racine du projet.
  TextColumn get path => text()();
  BoolColumn get existedBefore => boolean()();

  /// Copie de l'ancien contenu (nul si le fichier n'existait pas).
  TextColumn get backupPath => text().nullable()();
  TextColumn get beforeHash => text().nullable()();
  TextColumn get afterHash => text()();
  DateTimeColumn get appliedAt => dateTime()();
  DateTimeColumn get restoredAt => dateTime().nullable()();
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb);
    return decoded is List ? decoded.map((e) => '$e').toList() : const [];
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
