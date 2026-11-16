import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/domain/action_level.dart';
import 'package:launchpilot/core/domain/step_status.dart';
import 'package:launchpilot/features/checklist/data/checklist_repository.dart';
import 'package:launchpilot/features/checklist/domain/checklist_engine.dart';
import 'package:launchpilot/features/checklist/domain/checklist_step.dart';
import 'package:launchpilot/features/checklist/domain/launch_target.dart';
import 'package:launchpilot/features/checklist/targets/platform_targets.dart';
import 'package:launchpilot/features/commands/domain/command_policy.dart';
import 'package:launchpilot/features/commands/domain/command_spec.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/detection/domain/detection_report.dart';
import 'package:launchpilot/features/help/domain/glossary.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';
import 'package:launchpilot/features/settings/domain/app_settings.dart';

import '../support/test_harness.dart';

const root = '/home/testeur/projets/app';

ProjectInfo info(
  String fixture,
  Set<String> targets, {
  AppLanguage language = AppLanguage.fr,
  String? version,
}) => ProjectInfo(
  root: root,
  report: analyzeProjectSync('test/fixtures/projects/$fixture'),
  selectedTargets: targets,
  language: language,
  version: version,
);

/// Cible fictive : prouve qu'une nouvelle cible s'ajoute sans toucher au
/// moteur.
class SnapTarget implements LaunchTarget {
  const SnapTarget();
  @override
  String get id => 'snap';
  @override
  String label(AppLanguage language) => 'Snap';
  @override
  bool get alwaysActive => false;
  @override
  Future<TargetDetection?> detect(ProjectInfo project) async => null;
  @override
  Future<List<ChecklistStep>> buildChecklist(ProjectInfo p) async => [
    step('snap.yaml', ActionLevel.prepare),
    step(
      'snap.publish',
      ActionLevel.publish,
      deps: ['snap.yaml', 'linux.build'],
    ),
  ];
}

ChecklistStep step(
  String id,
  ActionLevel level, {
  List<String> deps = const [],
}) => ChecklistStep(
  id: id,
  level: level,
  title: id,
  objective: 'o',
  explanation: 'e',
  whyRequired: 'w',
  expectedResult: 'r',
  verificationMethod: 'v',
  dependsOn: deps,
);

class ListTarget implements LaunchTarget {
  const ListTarget(this.id, this.steps);
  @override
  final String id;
  final List<ChecklistStep> steps;
  @override
  String label(AppLanguage language) => id;
  @override
  bool get alwaysActive => true;
  @override
  Future<TargetDetection?> detect(ProjectInfo project) async => null;
  @override
  Future<List<ChecklistStep>> buildChecklist(ProjectInfo p) async => steps;
}

void main() {
  const engine = ChecklistEngine(builtInTargets);

  group('plan d\'une application Flutter', () {
    late ChecklistPlan plan;
    setUpAll(() async {
      plan = await engine.build(info('flutter_app', {'android', 'ios', 'web'}));
    });

    test('cibles retenues seulement, sans anomalie', () {
      final targets = plan.steps.map((s) => s.targetId).toSet();
      expect(targets, {'common', 'android', 'ios', 'web'});
      expect(plan.problems, isEmpty);
    });

    test('ordre : niveaux croissants, prérequis avant leurs suites', () {
      final index = {for (final (i, s) in plan.steps.indexed) s.id: i};
      for (final (i, s) in plan.steps.indexed) {
        if (i > 0) {
          expect(
            s.level.index,
            greaterThanOrEqualTo(plan.steps[i - 1].level.index),
            reason: s.id,
          );
        }
        for (final d in s.dependsOn) {
          expect(index[d], lessThan(i), reason: '${s.id} après $d');
        }
      }
    });

    test('étapes attendues et adaptées au projet', () {
      final ids = plan.steps.map((s) => s.id).toList();
      expect(
        ids,
        containsAll([
          'common.git',
          'common.secrets',
          'common.flutter.analyze',
          'android.keystore',
          'android.appbundle',
          'android.play',
          'ios.ci',
          'web.build',
        ]),
      );
      final git = plan.steps.firstWhere((s) => s.id == 'common.git');
      expect(git.kind, StepKind.manual, reason: 'pas de dépôt Git');
      expect(ids, isNot(contains('common.branch')));
      final perms = plan.steps.firstWhere((s) => s.id == 'android.permissions');
      expect(perms.explanation, contains('CAMERA'));
      final play = plan.steps.firstWhere((s) => s.id == 'android.play');
      expect(play.laterPhase, isNull);
      expect(play.toolTab, 'play');
      expect(play.isReversible, isFalse);
      expect(play.requiresConfirmation, isTrue);
    });

    test('toutes les commandes passent la politique de sécurité', () {
      for (final s in plan.steps) {
        if (s.kind == StepKind.command) {
          expect(s.commands, isNotEmpty, reason: s.id);
        }
        for (final c in s.commands) {
          final d = const CommandPolicy().evaluate(
            CommandSpec(
              executable: c.executable,
              arguments: c.arguments,
              workingDirectory: c.workingDirectory ?? root,
            ),
            root,
          );
          expect(d.allowed, isTrue, reason: '${s.id} : ${c.display}');
        }
      }
    });

    test('chaque terme cité existe dans le lexique, dans les deux langues', () {
      for (final lang in AppLanguage.values) {
        final glossary = Glossary.forLanguage(lang);
        for (final s in plan.steps) {
          for (final id in s.glossary) {
            expect(
              Glossary.byId(glossary, id),
              isNotNull,
              reason: '${s.id}/$id',
            );
          }
        }
      }
    });

    test('toute étape irréversible exige une confirmation', () {
      for (final s in plan.steps) {
        if (!s.isReversible) {
          expect(s.requiresConfirmation, isTrue, reason: s.id);
        }
      }
    });
  });

  test('mêmes étapes en anglais, textes traduits et complets', () async {
    final fr = await engine.build(
      info('flutter_app', {'android', 'web', 'linux'}),
    );
    final en = await engine.build(
      info('flutter_app', {
        'android',
        'web',
        'linux',
      }, language: AppLanguage.en),
    );
    expect(en.steps.map((s) => s.id), fr.steps.map((s) => s.id));
    for (final (i, s) in en.steps.indexed) {
      expect(s.title, isNot(fr.steps[i].title), reason: s.id);
      for (final text in [
        s.title,
        s.objective,
        s.explanation,
        s.whyRequired,
        s.expectedResult,
        s.verificationMethod,
      ]) {
        expect(text.trim(), isNotEmpty, reason: s.id);
      }
    }
  });

  test('projet React : dépendances, build par le script du projet', () async {
    final plan = await engine.build(info('react_vite', {'web'}));
    expect(plan.problems, isEmpty);
    final build = plan.steps.firstWhere((s) => s.id == 'web.build');
    expect(build.commands.single.display, 'pnpm run build');
    expect(build.dependsOn, ['common.node.install']);
    expect(plan.steps.any((s) => s.id.startsWith('common.flutter')), isFalse);
  });

  test('site React dans un dépôt contenant aussi du Flutter', () async {
    final base = info('flutter_app', const {});
    final r = analyzeProjectSync('test/fixtures/projects/react_vite');
    final mixed = ProjectInfo(
      root: root,
      report: DetectionReport(
        scannedAt: r.scannedAt,
        filesScanned: 1,
        technologies: [...base.report.technologies, ...r.technologies],
        targets: r.targets,
        packages: [...base.report.packages, ...r.packages],
      ),
      selectedTargets: const {'web'},
      language: AppLanguage.fr,
    );
    final plan = await engine.build(mixed);
    final build = plan.steps.firstWhere((s) => s.id == 'web.build');
    expect(build.commands.single.display, 'pnpm run build');
  });

  test(
    'branche de version proposée quand Git et version sont connus',
    () async {
      final base = info('flutter_app', const {}, version: '1.3.0+14');
      final withGit = ProjectInfo(
        root: base.root,
        report: DetectionReport(
          scannedAt: base.report.scannedAt,
          filesScanned: 1,
          technologies: base.report.technologies,
          targets: base.report.targets,
          packages: base.report.packages,
          git: const GitSnapshot(present: true, branch: 'main'),
        ),
        selectedTargets: const {},
        language: AppLanguage.fr,
        version: '1.3.0+14',
      );
      final plan = await engine.build(withGit);
      final branch = plan.steps.firstWhere((s) => s.id == 'common.branch');
      expect(
        branch.commands.single.display,
        'git switch -c launchpilot/release-1.3.0-14',
      );
      expect(
        plan.steps.firstWhere((s) => s.id == 'common.git').kind,
        StepKind.command,
      );
    },
  );

  group('extensibilité et robustesse', () {
    test('une nouvelle cible s\'ajoute sans modifier le moteur', () async {
      const extended = ChecklistEngine([...builtInTargets, SnapTarget()]);
      final without = await extended.build(info('flutter_app', {'linux'}));
      expect(without.steps.any((s) => s.targetId == 'snap'), isFalse);

      final plan = await extended.build(info('flutter_app', {'linux', 'snap'}));
      final ids = plan.steps.map((s) => s.id).toList();
      expect(ids, containsAll(['snap.yaml', 'snap.publish']));
      expect(ids.indexOf('linux.build'), lessThan(ids.indexOf('snap.publish')));
      expect(plan.problems, isEmpty);
    });

    test(
      'cycle signalé, dépendance absente ignorée, préfixe vérifié',
      () async {
        final plan = await ChecklistEngine([
          ListTarget('x', [
            step('x.a', ActionLevel.analyze, deps: ['x.b']),
            step('x.b', ActionLevel.analyze, deps: ['x.a']),
            step('x.c', ActionLevel.prepare, deps: ['x.inconnue']),
            step('y.intrus', ActionLevel.analyze),
            step('x.a', ActionLevel.build),
          ]),
        ]).build(info('flutter_app', const {}));
        final messages = plan.problems.map((p) => p.toString()).join('\n');
        expect(messages, contains('x.a : cycle'));
        expect(messages, contains('dépendance absente : x.inconnue'));
        expect(messages, contains('y.intrus : préfixe x. attendu'));
        expect(messages, contains('x.a : identifiant en double'));
        expect(plan.steps.map((s) => s.id), ['x.a', 'x.b', 'x.c']);
      },
    );
  });

  group('ChecklistProgress', () {
    final steps = [
      step('c.a', ActionLevel.analyze),
      step('c.b', ActionLevel.analyze, deps: ['c.a']),
      step('c.c', ActionLevel.build, deps: ['c.b']),
    ];

    test('blocage, prochaine étape et niveau courant', () {
      var p = ChecklistProgress(steps, const {});
      expect(p.isBlocked(steps[1]), isTrue);
      expect(p.blockers(steps[1]).single.id, 'c.a');
      expect(p.next!.id, 'c.a');
      expect(p.currentLevel, ActionLevel.analyze);

      p = ChecklistProgress(steps, {
        'c.a': StepStatus.succeeded,
        'c.b': StepStatus.pedagogical,
      });
      expect(p.isBlocked(steps[2]), isFalse);
      expect(p.next!.id, 'c.c');
      expect(p.currentLevel, ActionLevel.build);
      expect(p.ratio, closeTo(2 / 3, 1e-9));
    });

    test('un échec ne débloque pas la suite', () {
      final p = ChecklistProgress(steps, {'c.a': StepStatus.failed});
      expect(p.isBlocked(steps[1]), isTrue);
    });
  });

  group('ChecklistRepository', () {
    test(
      'synchronisation : ajout, mise à jour, suppression, statuts gardés',
      () async {
        final db = memoryDatabase();
        addTearDown(db.close);
        final projects = ProjectRepository(db, FakePathInspector([root]));
        final id = (await projects.addProject(root)).project.id;
        final session = await projects.startSession(id, '1.0.0');
        final repo = ChecklistRepository(db);

        await repo.sync(session.id, [
          step('c.a', ActionLevel.analyze),
          step('c.b', ActionLevel.prepare),
        ]);
        await repo.setStatus(
          session.id,
          'c.a',
          StepStatus.succeeded,
          note: 'ok',
        );

        await repo.sync(session.id, [
          step('c.a', ActionLevel.analyze),
          step('c.n', ActionLevel.analyze),
        ]);
        final records = await repo.load(session.id);
        expect(records.keys, unorderedEquals(['c.a', 'c.n']));
        expect(records['c.a']!.status, StepStatus.succeeded);
        expect(records['c.a']!.note, 'ok');
        expect(records['c.n']!.status, StepStatus.todo);

        final rows = await (db.select(db.checklistSteps)).get();
        expect(
          {for (final r in rows) r.stepKey: r.position},
          {'c.a': 0, 'c.n': 1},
        );
      },
    );

    test('rien n\'est écrit si le plan n\'a pas changé', () async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final projects = ProjectRepository(db, FakePathInspector([root]));
      final id = (await projects.addProject(root)).project.id;
      final session = await projects.startSession(id, '1.0.0');
      final repo = ChecklistRepository(db);
      final plan = [step('c.a', ActionLevel.analyze)];
      await repo.sync(session.id, plan);

      var updates = 0;
      final sub = db.tableUpdates().listen((_) => updates++);
      await repo.sync(session.id, plan);
      await pumpEventQueue();
      await sub.cancel();
      expect(updates, 0);
    });

    test('niveau courant de la session', () async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final projects = ProjectRepository(db, FakePathInspector([root]));
      final id = (await projects.addProject(root)).project.id;
      final session = await projects.startSession(id, '1.0.0');
      await ChecklistRepository(db)
          .setCurrentLevel(session.id, ActionLevel.build);
      expect(
        (await projects.activeSessionOf(id))!.currentLevel,
        ActionLevel.build,
      );
    });
  });
}
