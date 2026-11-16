import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/watch_tables.dart';
import '../../../core/security/secret_redactor.dart';
import '../domain/command_result.dart';

/// Journal des commandes. Arguments et sortie sont masqués avant écriture
/// (la sortie l'est déjà par le runner ; double sécurité).
class CommandLogRepository {
  CommandLogRepository(this._db);

  final AppDatabase _db;

  static const tailLines = 200;

  Future<void> log(int projectId, CommandResult r, DateTime startedAt) {
    final tail = r.lines.length > tailLines
        ? r.lines.sublist(r.lines.length - tailLines)
        : r.lines;
    return _db
        .into(_db.commandLogs)
        .insert(
          CommandLogsCompanion.insert(
            projectId: projectId,
            executable: r.spec.executable,
            arguments: [
              for (final a in r.spec.arguments) SecretRedactor.redact(a).text,
            ],
            workingDirectory: r.spec.workingDirectory,
            risk: r.decision.risk.name,
            status: r.status.name,
            exitCode: Value(r.exitCode),
            startedAt: startedAt,
            durationMs: Value(r.duration.inMilliseconds),
            output: Value(
              tail
                  .map(
                    (l) =>
                        '${l.stream == OutputStream.stdout ? 1 : 2}|'
                        '${SecretRedactor.redact(l.text).text}',
                  )
                  .join('\n'),
            ),
          ),
        );
  }

  Stream<List<CommandLogEntry>> watch(int projectId, {int limit = 30}) =>
      watchTables(
        _db,
        [_db.commandLogs],
        () =>
            (_db.select(_db.commandLogs)
                  ..where((t) => t.projectId.equals(projectId))
                  ..orderBy([(t) => OrderingTerm.desc(t.id)])
                  ..limit(limit))
                .get(),
      );

  /// Lignes de sortie d'une entrée du journal.
  static List<OutputLine> outputOf(CommandLogEntry e) => [
    for (final raw in e.output.split('\n'))
      if (raw.length >= 2)
        OutputLine(
          raw.startsWith('2|') ? OutputStream.stderr : OutputStream.stdout,
          raw.substring(2),
        ),
  ];
}
