import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/database/app_database.dart';
import 'package:launchpilot/features/changes/data/project_writer.dart';
import 'package:launchpilot/features/changes/domain/line_diff.dart';
import 'package:launchpilot/features/commands/data/process_command_runner.dart';
import 'package:launchpilot/features/git/data/git_service.dart';
import 'package:launchpilot/features/git/domain/git_status.dart';
import 'package:launchpilot/features/git/domain/gitignore_advisor.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';
import 'package:path/path.dart' as p;

import '../support/test_harness.dart';

/// Prépare un dépôt de test. Ces commandes sont lancées par le test
/// lui-même : la politique de LaunchPilot les refuserait (init, config…).
Future<void> git(String dir, List<String> args) async {
  final r = await Process.run('git', args, workingDirectory: dir);
  if (r.exitCode != 0) fail('git ${args.join(' ')} : ${r.stderr}');
}

void main() {
  group('parsePorcelainZ', () {
    test('branche, suivi, modifications, renommage, non suivi', () {
      final s = parsePorcelainZ(
        '## main...origin/main [ahead 2, behind 1]\u0000'
        ' M lib/main.dart\u0000'
        'A  nouveau.txt\u0000'
        'R  neuf.dart\u0000ancien.dart\u0000'
        '?? notes.md\u0000',
      );
      expect(s.branch, 'main');
      expect(s.upstream, 'origin/main');
      expect((s.ahead, s.behind), (2, 1));
      expect(s.changes.map((c) => c.path), [
        'lib/main.dart',
        'nouveau.txt',
        'neuf.dart',
        'notes.md',
      ]);
      expect(s.changes[2].originalPath, 'ancien.dart');
      expect(s.changes[3].untracked, isTrue);
      expect(s.changes[1].staged, isTrue);
      expect(s.clean, isFalse);
    });

    test('dépôt neuf et HEAD détachée', () {
      expect(parsePorcelainZ('## No commits yet on main\u0000').branch, 'main');
      final detached = parsePorcelainZ('## HEAD (no branch)\u0000');
      expect(detached.branch, isNull);
      expect(detached.clean, isTrue);
    });

    test('nom de branche de version', () {
      expect(releaseBranchName('1.3.0+14'), 'launchpilot/release-1.3.0-14');
    });
  });

  group('GitService sur un vrai dépôt', () {
    late Directory dir;
    setUp(() async {
      dir = Directory.systemTemp.createTempSync('lp_git_');
      await git(dir.path, ['init', '-q', '-b', 'main']);
      File(p.join(dir.path, '.gitignore')).writeAsStringSync('build/\n');
      File(p.join(dir.path, 'app.txt')).writeAsStringSync('v1');
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('lit la branche et les fichiers non suivis', () async {
      final s = await GitService(ProcessCommandRunner()).status(dir.path);
      expect(s.isRepo, isTrue);
      expect(s.branch, 'main');
      expect(
        s.changes.map((c) => c.path),
        unorderedEquals(['.gitignore', 'app.txt']),
      );
    });

    test('indique les fichiers déjà ignorés', () async {
      final ignored = await GitService(ProcessCommandRunner())
          .ignored(dir.path, ['build/out.txt', 'android/key.properties']);
      expect(ignored, {'build/out.txt'});
    });

    test('dossier hors dépôt', () async {
      final plain = Directory.systemTemp.createTempSync('lp_nogit_');
      addTearDown(() => plain.deleteSync(recursive: true));
      final s = await GitService(ProcessCommandRunner()).status(plain.path);
      expect(s.isRepo, isFalse);
    });
  });

  group('gitignore', () {
    test('ignore les vrais secrets, pas les modèles', () {
      expect(
        sensitiveFilesToIgnore([
          '.env',
          '.env.example',
          'android/key.properties',
        ]),
        ['.env', 'android/key.properties'],
      );
    });

    test('ajoute un bloc ancré, sans doublon', () {
      final once = gitignoreWithEntries('build/\n', [
        '.env',
        'android/key.properties',
      ]);
      expect(
        once,
        'build/\n\n$gitignoreHeader\n/.env\n/android/key.properties\n',
      );
      expect(gitignoreWithEntries(once, ['.env']), once);
      expect(gitignoreWithEntries(null, ['.env']), '$gitignoreHeader\n/.env\n');
    });
  });

  group('lineDiff', () {
    test('ajouts, suppressions et contexte', () {
      final hunks = lineDiff('a\nb\nc\nd\n', 'a\nB\nc\nd\ne\n')!;
      expect(hunks, hasLength(1));
      final ops = [
        for (final l in hunks.single.lines) '${l.op.name[0]}${l.text}',
      ];
      expect(ops, ['sa', 'rb', 'aB', 'sc', 'sd', 'ae']);
      expect(hunks.single.header, '@@ -1,4 +1,5 @@');
    });

    test('création de fichier et fichiers identiques', () {
      expect(
        lineDiff(
          null,
          'x\ny\n',
        )!.single.lines.every((l) => l.op == DiffOp.added),
        isTrue,
      );
      expect(lineDiff('x\n', 'x\n'), isEmpty);
    });

    test('changements éloignés : blocs séparés', () {
      final before = List.generate(40, (i) => 'l$i').join('\n');
      final after = before.replaceFirst('l2', 'X').replaceFirst('l35', 'Y');
      expect(lineDiff(before, after), hasLength(2));
    });
  });

  group('ProjectWriter', () {
    late Directory project;
    late Directory backups;
    late AppDatabase db;
    late ProjectWriter writer;
    late int projectId;

    File file(String rel) => File(p.join(project.path, rel));

    setUp(() async {
      project = Directory.systemTemp.createTempSync('lp_proj_');
      backups = Directory.systemTemp.createTempSync('lp_bak_');
      db = memoryDatabase();
      writer = ProjectWriter(
        db,
        backupRoot: backups.path,
        clock: steppingClock(),
      );
      projectId = (await ProjectRepository(
        db,
        FakePathInspector([project.path]),
      ).addProject(project.path)).project.id;
      file('.gitignore').writeAsStringSync('build/\n');
    });
    tearDown(() async {
      await db.close();
      project.deleteSync(recursive: true);
      backups.deleteSync(recursive: true);
    });

    test('aperçu, confirmation, écriture et sauvegarde', () async {
      final set = await writer.plan(project.path, 'Protection', {
        '.gitignore': 'build/\n/.env\n',
        'docs/NOTES.md': '# Notes\n',
      });
      expect(set.files.first.before, 'build/\n');
      expect(set.files.last.creates, isTrue);

      await writer.apply(projectId, project.path, set, writer.approve(set));

      expect(file('.gitignore').readAsStringSync(), 'build/\n/.env\n');
      expect(file('docs/NOTES.md').readAsStringSync(), '# Notes\n');
      final rows = await db.select(db.fileChanges).get();
      expect(rows.map((r) => r.path), ['.gitignore', 'docs/NOTES.md']);
      expect(File(rows.first.backupPath!).readAsStringSync(), 'build/\n');
      expect(rows.last.backupPath, isNull);
    });

    test('sans confirmation valide : rien n\'est écrit', () async {
      final set = await writer.plan(project.path, 'x', {'.gitignore': 'y\n'});
      final other = await writer.plan(project.path, 'x', {'.gitignore': 'z\n'});
      final approval = writer.approve(other);
      await expectLater(
        writer.apply(projectId, project.path, set, approval),
        throwsA(isA<WriteException>()),
      );
      expect(file('.gitignore').readAsStringSync(), 'build/\n');

      final ok = writer.approve(set);
      await writer.apply(projectId, project.path, set, ok);
      await expectLater(
        writer.apply(projectId, project.path, set, ok),
        throwsA(
          isA<WriteException>().having(
            (e) => e.issue,
            'issue',
            WriteIssue.notApproved,
          ),
        ),
      );
    });

    test('fichier modifié depuis l\'aperçu : tout est annulé', () async {
      final set = await writer.plan(project.path, 'x', {
        'a.txt': 'nouveau\n',
        '.gitignore': 'build/\n/.env\n',
      });
      file('.gitignore').writeAsStringSync('build/\nmodifié par moi\n');
      await expectLater(
        writer.apply(projectId, project.path, set, writer.approve(set)),
        throwsA(
          isA<WriteException>().having(
            (e) => e.issue,
            'issue',
            WriteIssue.changedSincePreview,
          ),
        ),
      );
      expect(file('a.txt').existsSync(), isFalse);
      expect(await db.select(db.fileChanges).get(), isEmpty);
    });

    test(
      'refuse les fichiers sensibles et les chemins hors du projet',
      () async {
        for (final (path, issue) in [
          ('android/key.properties', WriteIssue.sensitiveFile),
          ('.env', WriteIssue.sensitiveFile),
          ('../voisin.txt', WriteIssue.outsideProject),
          ('/etc/hosts', WriteIssue.outsideProject),
        ]) {
          await expectLater(
            writer.plan(project.path, 'x', {path: 'x'}),
            throwsA(
              isA<WriteException>().having((e) => e.issue, 'issue', issue),
            ),
            reason: path,
          );
        }
        final outside = Directory.systemTemp.createTempSync('lp_out_');
        addTearDown(() => outside.deleteSync(recursive: true));
        Link(p.join(project.path, 'lien')).createSync(outside.path);
        await expectLater(
          writer.plan(project.path, 'x', {'lien/fuite.txt': 'x'}),
          throwsA(
            isA<WriteException>().having(
              (e) => e.issue,
              'issue',
              WriteIssue.outsideProject,
            ),
          ),
        );
      },
    );

    test('restauration ciblée, sans écraser un changement ultérieur', () async {
      final set = await writer.plan(project.path, 'x', {
        '.gitignore': 'build/\n/.env\n',
        'cree.txt': 'créé\n',
      });
      await writer.apply(projectId, project.path, set, writer.approve(set));
      final rows = await db.select(db.fileChanges).get();
      final gitignore = rows.firstWhere((r) => r.path == '.gitignore');
      final created = rows.firstWhere((r) => r.path == 'cree.txt');

      // L'utilisateur retouche le fichier créé : sa restauration est refusée.
      file('cree.txt').writeAsStringSync('créé et complété\n');
      expect(
        await writer.restore(project.path, created.id),
        RestoreOutcome.conflict,
      );
      expect(file('cree.txt').readAsStringSync(), 'créé et complété\n');

      // L'autre fichier est intact : restauré seul.
      expect(
        await writer.restore(project.path, gitignore.id),
        RestoreOutcome.restored,
      );
      expect(file('.gitignore').readAsStringSync(), 'build/\n');
      expect(
        await writer.restore(project.path, gitignore.id),
        RestoreOutcome.alreadyRestored,
      );
    });

    test('restaurer une création supprime le fichier', () async {
      final set = await writer.plan(project.path, 'x', {'neuf.txt': 'n\n'});
      await writer.apply(projectId, project.path, set, writer.approve(set));
      final row = (await db.select(db.fileChanges).get()).single;
      expect(
        await writer.restore(project.path, row.id),
        RestoreOutcome.restored,
      );
      expect(file('neuf.txt').existsSync(), isFalse);
    });

    test('suppression des sauvegardes', () async {
      final set = await writer.plan(project.path, 'x', {'.gitignore': 'x\n'});
      await writer.apply(projectId, project.path, set, writer.approve(set));
      expect(
        Directory(p.join(backups.path, '$projectId')).existsSync(),
        isTrue,
      );
      await writer.deleteBackups(projectId);
      expect(
        Directory(p.join(backups.path, '$projectId')).existsSync(),
        isFalse,
      );
    });
  });
}
