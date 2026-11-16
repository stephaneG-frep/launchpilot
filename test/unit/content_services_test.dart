import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/database/app_database.dart';
import 'package:launchpilot/features/changes/data/project_writer.dart';
import 'package:launchpilot/features/commands/data/process_command_runner.dart';
import 'package:launchpilot/features/content/data/changelog_service.dart';
import 'package:launchpilot/features/content/data/content_repository.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';
import 'package:path/path.dart' as p;

import '../support/test_harness.dart';

Future<void> git(String dir, List<String> args) async {
  final r = await Process.run('git', [
    '-c',
    'user.name=Test',
    '-c',
    'user.email=test@exemple.fr',
    ...args,
  ], workingDirectory: dir);
  if (r.exitCode != 0) fail('git ${args.join(' ')} : ${r.stderr}');
}

void main() {
  group('ProjectWriter et fichiers binaires', () {
    late Directory project;
    late Directory backups;
    late AppDatabase db;
    late ProjectWriter writer;
    late int projectId;

    setUp(() async {
      project = Directory.systemTemp.createTempSync('lp_bin_');
      backups = Directory.systemTemp.createTempSync('lp_bak_');
      db = memoryDatabase();
      writer = ProjectWriter(db, backupRoot: backups.path);
      projectId = (await ProjectRepository(
        db,
        FakePathInspector([project.path]),
      ).addProject(project.path)).project.id;
    });
    tearDown(() async {
      await db.close();
      project.deleteSync(recursive: true);
      backups.deleteSync(recursive: true);
    });

    test('remplacement sauvegardé octet par octet puis restauré', () async {
      final icon = File(p.join(project.path, 'web/favicon.png'))
        ..parent.createSync(recursive: true)
        ..writeAsBytesSync([0, 1, 2, 255]);
      final set = await writer.planBinary(project.path, 'Icônes', {
        'web/favicon.png': Uint8List.fromList([9, 8, 7, 0, 200]),
        'web/icons/Icon-192.png': Uint8List.fromList([1, 2, 3]),
      });
      expect(set.files.first.isText, isFalse);
      expect(set.files.first.diff, isNull);
      expect(set.files.last.creates, isTrue);

      await writer.apply(projectId, project.path, set, writer.approve(set));
      expect(icon.readAsBytesSync(), [9, 8, 7, 0, 200]);

      final rows = await db.select(db.fileChanges).get();
      expect(
        await writer.restore(project.path, rows.first.id),
        RestoreOutcome.restored,
      );
      expect(icon.readAsBytesSync(), [0, 1, 2, 255]);
    });

    test('fichier binaire identique : aucun changement', () async {
      File(p.join(project.path, 'a.png')).writeAsBytesSync([1, 2]);
      final set = await writer.planBinary(project.path, 'x', {
        'a.png': Uint8List.fromList([1, 2]),
      });
      expect(set.files.single.changes, isFalse);
    });
  });

  group('ChangelogService sur un vrai dépôt', () {
    late Directory dir;
    setUp(() async {
      dir = Directory.systemTemp.createTempSync('lp_log_');
      await git(dir.path, ['init', '-q', '-b', 'main']);
    });
    tearDown(() => dir.deleteSync(recursive: true));

    Future<void> commit(String message) async {
      File(p.join(dir.path, 'f.txt')).writeAsStringSync(message);
      await git(dir.path, ['add', '.']);
      await git(dir.path, ['commit', '-q', '-m', message]);
    }

    test('commits depuis le dernier tag, sans rien modifier', () async {
      await commit('feat: première version');
      await git(dir.path, ['tag', 'v1.0.0']);
      await commit('fix: correction du cache');
      await commit('feat(ui): mode sombre');

      final range = await ChangelogService(ProcessCommandRunner())
          .commits(dir.path);
      expect(range.sinceTag, 'v1.0.0');
      expect(range.limited, isFalse);
      expect(range.commits.map((c) => c.subject), [
        'feat(ui): mode sombre',
        'fix: correction du cache',
      ]);
      expect(range.commits.first.scope, 'ui');
    });

    test('sans tag : derniers commits, plage limitée', () async {
      await commit('chore: départ');
      final range = await ChangelogService(ProcessCommandRunner())
          .commits(dir.path);
      expect(range.sinceTag, isNull);
      expect(range.limited, isTrue);
      expect(range.commits, hasLength(1));
    });
  });

  test('ContentRepository garde la dernière version par clé', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final projects = ProjectRepository(db, FakePathInspector(['/p']));
    final id = (await projects.addProject('/p')).project.id;
    final session = await projects.startSession(id, '1.0.0');
    final repo = ContentRepository(db);
    await repo.saveJson(session.id, ContentRepository.storeTextsKey, {'a': 1});
    await repo.saveJson(session.id, ContentRepository.storeTextsKey, {'a': 2});
    expect(await repo.latestJson(session.id, ContentRepository.storeTextsKey), {
      'a': 2,
    });
    expect(
      await repo.latestJson(session.id, ContentRepository.legalAnswersKey),
      isNull,
    );
  });
}
