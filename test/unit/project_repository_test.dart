import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/database/app_database.dart';
import 'package:launchpilot/core/domain/action_level.dart';
import 'package:launchpilot/core/domain/step_status.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';
import 'package:launchpilot/features/projects/domain/project_enums.dart';
import 'package:launchpilot/features/projects/domain/project_validation.dart';

import '../support/test_harness.dart';

ChecklistStepsCompanion step(String key, int position, StepStatus status) =>
    ChecklistStepsCompanion.insert(
      sessionId: 0,
      stepKey: key,
      level: ActionLevel.analyze,
      position: position,
      title: 'Étape $key',
      status: status,
      updatedAt: DateTime(2000),
    );

void main() {
  late AppDatabase db;
  late FakePathInspector paths;
  late ProjectRepository repo;

  setUp(() {
    db = memoryDatabase();
    paths = FakePathInspector([
      '/home/testeur/projets/meteo',
      '/home/testeur/projets/site',
      '/home/testeur/ailleurs/meteo',
    ]);
    repo = ProjectRepository(db, paths, clock: steppingClock());
  });
  tearDown(() => db.close());

  group('ProjectValidation', () {
    test('normalise les chemins et interprète ~', () {
      expect(ProjectValidation.normalizePath(' /a/b/../c/ '), '/a/c');
      expect(
        ProjectValidation.normalizePath('~/projets', home: '/home/moi'),
        '/home/moi/projets',
      );
    });

    test('rejette les chemins vides ou relatifs', () {
      expect(
        () => ProjectValidation.normalizePath('  '),
        throwsA(
          isA<ProjectPathException>().having(
            (e) => e.issue,
            'issue',
            ProjectPathIssue.empty,
          ),
        ),
      );
      expect(
        () => ProjectValidation.normalizePath('projets/app'),
        throwsA(
          isA<ProjectPathException>().having(
            (e) => e.issue,
            'issue',
            ProjectPathIssue.notAbsolute,
          ),
        ),
      );
    });

    test('valide les numéros de version', () {
      expect(ProjectValidation.normalizeVersion(' 1.3.0+14 '), '1.3.0+14');
      expect(
        ProjectValidation.normalizeVersion('v2.0.0-beta_1'),
        'v2.0.0-beta_1',
      );
      for (final bad in ['', '1.0 final', '-1.0', 'é', 'x' * 65]) {
        expect(
          () => ProjectValidation.normalizeVersion(bad),
          throwsA(isA<InvalidVersionException>()),
          reason: bad,
        );
      }
    });
  });

  group('projets', () {
    test('ajoute un dossier existant avec un nom déduit', () async {
      final r = await repo.addProject('~/projets/meteo/');
      expect(r.created, isTrue);
      expect(r.project.name, 'meteo');
      expect(r.project.path, '/home/testeur/projets/meteo');
      expect(r.project.favorite, isFalse);
    });

    test('refuse un dossier introuvable', () async {
      await expectLater(
        repo.addProject('/home/testeur/nulle-part'),
        throwsA(
          isA<ProjectPathException>().having(
            (e) => e.issue,
            'issue',
            ProjectPathIssue.notFound,
          ),
        ),
      );
      expect(await repo.stats(), isA<Object>());
      expect((await repo.stats()).projects, 0);
    });

    test('un dossier déjà connu est rouvert, pas dupliqué', () async {
      final first = await repo.addProject('/home/testeur/projets/meteo');
      final again = await repo.addProject(
        '/home/testeur/projets/meteo',
        name: 'Autre',
      );
      expect(again.created, isFalse);
      expect(again.project.id, first.project.id);
      expect(again.project.name, 'meteo');
      expect(
        again.project.lastOpenedAt.isAfter(first.project.lastOpenedAt),
        isTrue,
      );
      expect((await repo.stats()).projects, 1);
    });

    test('liste du plus récent au plus ancien, avec favoris', () async {
      final meteo = await repo.addProject('/home/testeur/projets/meteo');
      await repo.addProject('/home/testeur/projets/site');
      await repo.setFavorite(meteo.project.id, true);

      var list = await repo.loadOverviews();
      expect(list.map((o) => o.project.name), ['site', 'meteo']);
      expect(list.last.project.favorite, isTrue);

      await repo.touchProject(meteo.project.id);
      list = await repo.loadOverviews();
      expect(list.first.project.name, 'meteo');
    });

    test('détecte un dossier déplacé puis le relocalise', () async {
      final r = await repo.addProject('/home/testeur/projets/meteo');
      paths.existing.remove('/home/testeur/projets/meteo');
      expect((await repo.loadOverviews()).single.folderAvailable, isFalse);

      await repo.relocate(r.project.id, '/home/testeur/ailleurs/meteo');
      final o = (await repo.loadOverviews()).single;
      expect(o.folderAvailable, isTrue);
      expect(o.project.path, '/home/testeur/ailleurs/meteo');
    });

    test('relocaliser vers le dossier d\'un autre projet est refusé', () async {
      final meteo = await repo.addProject('/home/testeur/projets/meteo');
      await repo.addProject('/home/testeur/projets/site');
      await expectLater(
        repo.relocate(meteo.project.id, '/home/testeur/projets/site'),
        throwsA(
          isA<ProjectPathException>().having(
            (e) => e.issue,
            'issue',
            ProjectPathIssue.alreadyRegistered,
          ),
        ),
      );
    });

    test('les cibles sont remplacées en bloc', () async {
      final id = (await repo.addProject('/home/testeur/projets/meteo'))
          .project
          .id;
      await repo.replaceTargets(id, [
        ProjectTargetsCompanion.insert(
          projectId: 0,
          targetId: 'android',
          detected: const Value(true),
          evidence: const Value(['android/']),
        ),
        ProjectTargetsCompanion.insert(projectId: 0, targetId: 'web'),
      ]);
      await repo.replaceTargets(id, [
        ProjectTargetsCompanion.insert(
          projectId: 0,
          targetId: 'android',
          confirmed: const Value(true),
        ),
      ]);
      final targets = await repo.targetsOf(id);
      expect(targets.single.targetId, 'android');
      expect(targets.single.confirmed, isTrue);
    });
  });

  group('sessions et checklist', () {
    late int projectId;
    setUp(() async {
      projectId = (await repo.addProject('/home/testeur/projets/meteo'))
          .project
          .id;
    });

    test('démarre une session active au niveau Analyser', () async {
      final s = await repo.startSession(projectId, '1.3.0+14');
      expect(s.status, SessionStatus.active);
      expect(s.currentLevel, ActionLevel.analyze);
      expect((await repo.activeSessionOf(projectId))!.id, s.id);
    });

    test('une seule session active par projet', () async {
      final s = await repo.startSession(projectId, '1.0.0');
      await expectLater(
        repo.startSession(projectId, '1.0.1'),
        throwsA(
          isA<ActiveSessionExistsException>().having(
            (e) => e.sessionId,
            'sessionId',
            s.id,
          ),
        ),
      );
      await repo.completeSession(s.id);
      final next = await repo.startSession(projectId, '1.0.1');
      expect(next.version, '1.0.1');
    });

    test('une version invalide ne crée rien', () async {
      await expectLater(
        repo.startSession(projectId, 'version finale'),
        throwsA(isA<InvalidVersionException>()),
      );
      expect((await repo.stats()).sessions, 0);
    });

    test('progression calculée depuis la checklist persistée', () async {
      final s = await repo.startSession(projectId, '1.0.0');
      await repo.addChecklistSteps(s.id, [
        step('git', 0, StepStatus.succeeded),
        step('analyze', 1, StepStatus.failed),
        step('keystore', 2, StepStatus.pedagogical),
        step('build', 3, StepStatus.todo),
      ]);
      var o = (await repo.loadOverviews()).single;
      expect(o.activeSession!.id, s.id);
      expect((o.stepsDone, o.stepsTotal), (2, 4));
      expect(o.progress, 0.5);

      final ws = (await repo.loadWorkspace(projectId))!;
      expect(ws.steps.map((e) => e.stepKey), [
        'git',
        'analyze',
        'keystore',
        'build',
      ]);
      await repo.updateStepStatus(
        ws.steps[1].id,
        StepStatus.succeeded,
        note: 'corrigé',
      );
      o = (await repo.loadOverviews()).single;
      expect(o.stepsDone, 3);
    });

    test('reprise : la session et le projet sont mis à jour', () async {
      final s = await repo.startSession(projectId, '1.0.0');
      await repo.resumeSession(s);
      final again = (await repo.activeSessionOf(projectId))!;
      expect(again.updatedAt.isAfter(s.updatedAt), isTrue);
    });

    test('une session close n\'est plus reprise', () async {
      final s = await repo.startSession(projectId, '1.0.0');
      await repo.completeSession(s.id);
      expect(await repo.activeSessionOf(projectId), isNull);
      expect((await repo.loadOverviews()).single.activeSession, isNull);
    });

    test(
      'textes validés, rapports et audits sont rattachés à la session',
      () async {
        final s = await repo.startSession(projectId, '1.0.0');
        await repo.addEntry(
          s.id,
          SessionEntryKind.validatedText,
          'store.title',
          'MétéoPlus',
        );
        await repo.addEntry(
          s.id,
          SessionEntryKind.auditResult,
          'lighthouse',
          '{"score":92}',
        );
        final entries = await repo.entriesOf(s.id);
        expect(entries.map((e) => e.kind), [
          SessionEntryKind.validatedText,
          SessionEntryKind.auditResult,
        ]);
      },
    );
  });

  group('suppression contrôlée', () {
    test('retirer un projet efface son historique, pas les autres', () async {
      final meteo = (await repo.addProject('/home/testeur/projets/meteo'))
          .project
          .id;
      final site = (await repo.addProject('/home/testeur/projets/site'))
          .project
          .id;
      final s = await repo.startSession(meteo, '1.0.0');
      await repo.addChecklistSteps(s.id, [
        step('a', 0, StepStatus.todo),
        step('b', 1, StepStatus.todo),
      ]);
      await repo.addEntry(s.id, SessionEntryKind.report, 'r', 'x');
      await repo.startSession(site, '2.0.0');

      final impact = await repo.deletionImpact(meteo);
      expect((impact.sessions, impact.steps), (1, 2));

      await repo.removeProject(meteo);
      final stats = await repo.stats();
      expect((stats.projects, stats.sessions, stats.steps), (1, 1, 0));
      expect(await db.select(db.sessionEntries).get(), isEmpty);
      // Le dossier sur le disque n'est jamais concerné.
      expect(paths.existing, contains('/home/testeur/projets/meteo'));
    });

    test('tout effacer vide chaque table', () async {
      final id = (await repo.addProject('/home/testeur/projets/meteo'))
          .project
          .id;
      final s = await repo.startSession(id, '1.0.0');
      await repo.addChecklistSteps(s.id, [step('a', 0, StepStatus.todo)]);
      await repo.replaceTargets(id, [
        ProjectTargetsCompanion.insert(projectId: 0, targetId: 'web'),
      ]);

      await repo.clearAll();

      expect((await repo.stats()).isEmpty, isTrue);
      for (final table in db.allTables) {
        expect(
          await db.select(table).get(),
          isEmpty,
          reason: table.actualTableName,
        );
      }
    });
  });

  test('le flux d\'accueil se met à jour à chaque modification', () async {
    final emitted = <int>[];
    final sub = repo.watchOverviews().listen((l) => emitted.add(l.length));
    await pumpEventQueue();
    await repo.addProject('/home/testeur/projets/meteo');
    await pumpEventQueue();
    await repo.addProject('/home/testeur/projets/site');
    await pumpEventQueue();
    await sub.cancel();
    expect(emitted.first, 0);
    expect(emitted.last, 2);
  });
}
