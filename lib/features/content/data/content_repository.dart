import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../projects/domain/project_enums.dart';

/// Contenus validés d'une session (textes de fiche, réponses juridiques,
/// changelogs), rangés dans `session_entries`. Chaque enregistrement est
/// conservé : le plus récent fait foi.
class ContentRepository {
  ContentRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static const storeTextsKey = 'store.texts';
  static const legalAnswersKey = 'legal.answers';
  static String changelogKey(String version) => 'changelog.$version';

  Future<void> saveJson(int sessionId, String key, Object? value) => _db
      .into(_db.sessionEntries)
      .insert(
        SessionEntriesCompanion.insert(
          sessionId: sessionId,
          kind: SessionEntryKind.validatedText,
          entryKey: key,
          content: jsonEncode(value),
          createdAt: _now(),
        ),
      );

  Future<Object?> latestJson(int sessionId, String key) async {
    final row =
        await (_db.select(_db.sessionEntries)
              ..where(
                (t) => t.sessionId.equals(sessionId) & t.entryKey.equals(key),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : jsonDecode(row.content);
  }
}
