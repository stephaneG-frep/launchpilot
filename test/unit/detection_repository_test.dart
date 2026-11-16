import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/database/app_database.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/detection/data/detection_repository.dart';
import 'package:launchpilot/features/detection/domain/detection_report.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';

import '../support/test_harness.dart';

DetectionReport report({
  Map<PlatformTarget, double> targets = const {},
  List<TechDetection> techs = const [],
}) => DetectionReport(
  scannedAt: DateTime(2026, 10, 2, 9),
  filesScanned: 12,
  technologies: techs,
  targets: [
    for (final t in PlatformTarget.values)
      TargetDetection(
        target: t,
        confidence: targets[t] ?? 0,
        evidence: [if ((targets[t] ?? 0) > 0) Evidence('${t.name}/', 'x')],
      ),
  ],
);

const flutter = TechDetection(
  id: 'flutter',
  label: 'Flutter',
  kind: TechKind.framework,
  confidence: 0.99,
  evidence: [Evidence('pubspec.yaml')],
);
const python = TechDetection(
  id: 'python',
  label: 'Python',
  kind: TechKind.language,
  confidence: 0.6,
  evidence: [Evidence('tool.py')],
  informative: true,
);

void main() {
  late AppDatabase db;
  late DetectionRepository repo;
  late int projectId;

  setUp(() async {
    db = memoryDatabase();
    repo = DetectionRepository(db, clock: steppingClock());
    final projects = ProjectRepository(db, FakePathInspector(['/p/meteo']));
    projectId = (await projects.addProject('/p/meteo')).project.id;
  });
  tearDown(() => db.close());

  test('sans analyse : aucun rapport', () async {
    expect(await repo.load(projectId), isNull);
  });

  test(
    'les cibles retenues suivent la détection tant que rien n\'est validé',
    () async {
      await repo.saveReport(
        projectId,
        report(
          targets: {PlatformTarget.android: 0.95, PlatformTarget.web: 0.3},
        ),
      );
      var d = (await repo.load(projectId))!;
      expect(d.selected, {PlatformTarget.android});
      expect(d.reviewed, isFalse);

      await repo.saveReport(
        projectId,
        report(
          targets: {PlatformTarget.android: 0.95, PlatformTarget.web: 0.9},
        ),
      );
      d = (await repo.load(projectId))!;
      expect(d.selected, {PlatformTarget.android, PlatformTarget.web});
    },
  );

  test('après validation, une nouvelle analyse garde les choix', () async {
    await repo.saveReport(
      projectId,
      report(targets: {PlatformTarget.android: 0.95, PlatformTarget.ios: 0.95}),
    );
    await repo.setTargetSelected(projectId, PlatformTarget.ios, false);
    await repo.setTargetSelected(projectId, PlatformTarget.linux, true);
    await repo.markTargetsReviewed(projectId);

    await repo.saveReport(
      projectId,
      report(targets: {PlatformTarget.android: 0.95, PlatformTarget.ios: 0.95}),
    );
    final d = (await repo.load(projectId))!;
    expect(d.reviewed, isTrue);
    expect(d.selected, {PlatformTarget.android, PlatformTarget.linux});
    final row = (await db.select(db.projectTargets).get()).firstWhere(
      (t) => t.targetId == 'ios',
    );
    expect(row.detected, isTrue, reason: 'la détection reste visible');
    expect(row.confirmed, isFalse);
  });

  test('technologies recopiées dans le projet, informatives exclues', () async {
    await repo.saveReport(projectId, report(techs: [flutter, python]));
    final project = await db.select(db.projects).getSingle();
    expect(project.technologies, ['Flutter']);
  });

  test('retirer le projet supprime son rapport', () async {
    await repo.saveReport(projectId, report());
    await ProjectRepository(db, FakePathInspector()).removeProject(projectId);
    expect(await db.select(db.detectionReports).get(), isEmpty);
    expect(await db.select(db.projectTargets).get(), isEmpty);
  });

  test('le flux se met à jour après un changement de cible', () async {
    await repo.saveReport(
      projectId,
      report(targets: {PlatformTarget.web: 0.9}),
    );
    final seen = <Set<PlatformTarget>>[];
    final sub = repo.watch(projectId).listen((d) => seen.add(d!.selected));
    await pumpEventQueue();
    await repo.setTargetSelected(projectId, PlatformTarget.android, true);
    await pumpEventQueue();
    await sub.cancel();
    expect(seen.first, {PlatformTarget.web});
    expect(seen.last, {PlatformTarget.web, PlatformTarget.android});
  });

  test('analyse réelle dans un isolat sur un projet d\'exemple', () async {
    final r = await const IsolateProjectAnalyzer().analyze(
      'test/fixtures/projects/flutter_app',
    );
    expect(r.technologies.map((t) => t.id), contains('flutter'));
    expect(r.targetFor(PlatformTarget.android).detected, isTrue);
  });
}
