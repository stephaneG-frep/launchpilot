import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/database/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

/// Schémas de référence : `drift_schemas/launchpilot/`.
/// Après toute modification des tables :
///   dart run build_runner build
///   dart run drift_dev make-migrations
/// puis écrire l'étape dans `AppDatabase._steps` et compléter ce fichier.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  group('chaque migration produit exactement le schéma enregistré', () {
    const versions = GeneratedHelper.versions;
    for (final (i, from) in versions.indexed) {
      for (final to in versions.skip(i + 1)) {
        test('v$from → v$to', () async {
          final schema = await verifier.schemaAt(from);
          final db = AppDatabase(schema.newConnection());
          await verifier.migrateAndValidate(db, to);
          await db.close();
        });
      }
    }

    test('une base neuve correspond à la dernière version', () async {
      final db = AppDatabase(await verifier.startAt(versions.last));
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, versions.last);
      expect(db.schemaVersion, versions.last);
    });
  });

  test('v1 → v2 conserve projets, sessions, étapes et entrées', () async {
    final at = DateTime.utc(2026, 9, 30, 12);
    final project = v1.ProjectsData(
      id: 1,
      name: 'meteo',
      path: '/home/demo/meteo',
      favorite: 1,
      technologies: '["Flutter"]',
      createdAt: at.toIso8601String(),
      lastOpenedAt: at.toIso8601String(),
    );
    final target = v1.ProjectTargetsData(
      id: 1,
      projectId: 1,
      targetId: 'android',
      detected: 1,
      confirmed: 1,
      confidence: 0.95,
      evidence: '[]',
    );
    final session = v1.ReleaseSessionsData(
      id: 1,
      projectId: 1,
      version: '1.3.0+14',
      status: 'active',
      currentLevel: 'prepare',
      createdAt: at.toIso8601String(),
      updatedAt: at.toIso8601String(),
    );
    final step = v1.ChecklistStepsData(
      id: 1,
      sessionId: 1,
      stepKey: 'git',
      level: 'analyze',
      position: 0,
      title: 'Git',
      status: 'succeeded',
      updatedAt: at.toIso8601String(),
    );
    final entry = v1.SessionEntriesData(
      id: 1,
      sessionId: 1,
      kind: 'report',
      entryKey: 'r1',
      content: '{}',
      createdAt: at.toIso8601String(),
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, old) {
        batch
          ..insert(old.projects, project)
          ..insert(old.projectTargets, target)
          ..insert(old.releaseSessions, session)
          ..insert(old.checklistSteps, step)
          ..insert(old.sessionEntries, entry);
      },
      validateItems: (db) async {
        expect(
          (await db.select(db.projects).get()).single.toJson(),
          project.toJson(),
        );
        expect(
          (await db.select(db.projectTargets).get()).single.toJson(),
          target.toJson(),
        );
        expect(
          (await db.select(db.releaseSessions).get()).single.toJson(),
          session.toJson(),
        );
        expect(
          (await db.select(db.checklistSteps).get()).single.toJson(),
          step.toJson(),
        );
        expect(
          (await db.select(db.sessionEntries).get()).single.toJson(),
          entry.toJson(),
        );
        expect(await db.select(db.detectionReports).get(), isEmpty);
      },
    );
  });

  test('v2 → v3 conserve projets et rapports de détection', () async {
    final at = DateTime.utc(2026, 10, 2, 9).toIso8601String();
    final project = v2.ProjectsData(
      id: 1,
      name: 'meteo',
      path: '/home/demo/meteo',
      favorite: 0,
      technologies: '["Flutter"]',
      createdAt: at,
      lastOpenedAt: at,
    );
    final report = v2.DetectionReportsData(
      id: 1,
      projectId: 1,
      scannedAt: at,
      report: '{"formatVersion":1}',
      targetsReviewedAt: at,
    );
    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, old) {
        batch
          ..insert(old.projects, project)
          ..insert(old.detectionReports, report);
      },
      validateItems: (db) async {
        expect(
          (await db.select(db.projects).get()).single.toJson(),
          project.toJson(),
        );
        expect(
          (await db.select(db.detectionReports).get()).single.toJson(),
          report.toJson(),
        );
        expect(await db.select(db.commandLogs).get(), isEmpty);
        expect(await db.select(db.fileChanges).get(), isEmpty);
      },
    );
  });

  group('fichier SQLite réel', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('launchpilot_db_'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('les données survivent à la réouverture', () async {
      final file = File('${dir.path}/test.sqlite');
      final now = DateTime(2026, 9, 30, 12);

      final first = AppDatabase(NativeDatabase(file));
      await first
          .into(first.projects)
          .insert(
            ProjectsCompanion.insert(
              name: 'Démo',
              path: '/tmp/demo',
              createdAt: now,
              lastOpenedAt: now,
            ),
          );
      await first.close();

      final second = AppDatabase(NativeDatabase(file));
      addTearDown(second.close);
      final rows = await second.select(second.projects).get();
      expect(rows.single.name, 'Démo');
      expect(rows.single.lastOpenedAt, now);
    });

    test('une base créée par une version plus récente est refusée', () async {
      final file = File('${dir.path}/future.sqlite');
      final db = AppDatabase(
        NativeDatabase(
          file,
          setup: (raw) => raw.execute('PRAGMA user_version = 99'),
        ),
      );
      addTearDown(db.close);
      await expectLater(
        db.select(db.projects).get(),
        throwsA(isA<StateError>()),
      );
    });
  });

  test('aucune colonne n\'est destinée à un secret', () {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final forbidden = RegExp(r'api_key|secret|password|passphrase|token');
    for (final table in db.allTables) {
      for (final column in table.$columns) {
        expect(
          forbidden.hasMatch(column.name),
          isFalse,
          reason: '${table.actualTableName}.${column.name}',
        );
      }
    }
  });
}
