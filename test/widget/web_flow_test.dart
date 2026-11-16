import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/detection/data/detection_repository.dart';
import 'package:launchpilot/features/projects/application/project_providers.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';
import 'package:launchpilot/features/settings/data/settings_repository.dart';
import 'package:launchpilot/features/web/application/web_providers.dart';
import 'package:launchpilot/features/web/data/web_services.dart';
import 'package:path/path.dart' as p;

import '../support/test_harness.dart';

class FakeTools implements ToolLocator {
  FakeTools(this.installed);
  final Set<String> installed;

  @override
  Future<bool> isInstalled(String executable) async =>
      installed.contains(executable);
}

class FakeDns implements DnsResolver {
  @override
  Future<List<String>> lookup(String domain) async => ['185.199.108.153'];
}

Directory copyFixture(String name) {
  final dir = Directory.systemTemp.createTempSync('lp_web_');
  final src = Directory('test/fixtures/projects/$name');
  for (final f in src.listSync(recursive: true).whereType<File>()) {
    final target = File(p.join(dir.path, p.relative(f.path, from: src.path)));
    target.parent.createSync(recursive: true);
    f.copySync(target.path);
  }
  return dir;
}

Future<void> confirmWrite(WidgetTester tester) async {
  expect(find.text('Aperçu des modifications'), findsOneWidget);
  await tester.tap(find.byKey(const ValueKey('write-confirm')));
  await tester.pumpAndSettle();
  expect(find.text('Modifications écrites.'), findsWidgets);
}

void main() {
  late Directory dir;
  tearDown(() => dir.deleteSync(recursive: true));

  Future<FakeCommandRunner> start(
    WidgetTester tester, {
    String fixture = 'react_vite',
    String tool = 'web',
    Set<String> tools = const {},
    bool simulation = true,
  }) async {
    dir = copyFixture(fixture);
    final db = memoryDatabase();
    addTearDown(db.close);
    final projects = ProjectRepository(db, FakePathInspector([dir.path]));
    final id = (await projects.addProject(dir.path)).project.id;
    await DetectionRepository(db).saveReport(id, analyzeProjectSync(dir.path));
    final runner = FakeCommandRunner();
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      prefs: {
        CurrentProjectController.prefsKey: id,
        SettingsRepository.kSimulation: simulation,
      },
      paths: FakePathInspector([dir.path]),
      commandRunner: runner,
      overrides: [
        toolLocatorProvider.overrideWithValue(FakeTools(tools)),
        dnsResolverProvider.overrideWithValue(FakeDns()),
      ],
    );
    await tester.tap(find.byKey(const ValueKey('nav-content')));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byKey(ValueKey('tool-$tool')));
    return runner;
  }

  testWidgets(
    'site web : plan de build, audit des sources, Lighthouse absent',
    (tester) async {
      await start(tester);
      expect(find.text('Technologie : React + Vite'), findsOneWidget);
      expect(find.text('pnpm run build'), findsOneWidget);
      expect(
        find.text(
          'Pas encore de index.html dans le dossier de sortie : construis le site.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('web-lighthouse-missing')),
        findsOneWidget,
      );

      await tester.tap(find.text('Sources'));
      await tester.pumpAndSettle();
      await scrollAndTap(tester, find.byKey(const ValueKey('web-audit')));
      expect(find.byKey(const ValueKey('web-audit-summary')), findsOneWidget);
      // Description trop courte ; robots.txt (dans public/) bien trouvé.
      for (final id in const ['audit-descriptionLength', 'audit-robots']) {
        await tester.scrollUntilVisible(
          find.byKey(ValueKey(id)),
          200,
          scrollable: find.byType(Scrollable).first,
        );
      }
      expect(
        find.textContaining('La description fait 19 caractères'),
        findsOneWidget,
      );
      expect(find.textContaining('Ajoute un robots.txt'), findsNothing);

      await scrollAndTap(tester, find.byKey(const ValueKey('web-build')));
      expect(find.byKey(const ValueKey('cmd-preview-run')), findsOneWidget);
    },
  );

  testWidgets('SEO : balises, robots.txt et sitemap après aperçu', (
    tester,
  ) async {
    await start(tester, tool: 'seo');
    final write = find.byKey(const ValueKey('seo-write'));
    await tester.ensureVisible(write);
    expect(tester.widget<FilledButton>(write).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('seo-siteUrl')),
      'https://recettes.example',
    );
    await tester.enterText(
      find.byKey(const ValueKey('seo-title')),
      'Carnet de recettes familial',
    );
    await tester.enterText(
      find.byKey(const ValueKey('seo-description')),
      'Toutes les recettes de la famille, classées et faciles à retrouver.',
    );
    await tester.pumpAndSettle();
    expect(find.text('Carnet de recettes familial'), findsWidgets);
    final indexBefore = File(p.join(dir.path, 'index.html')).readAsStringSync();

    await scrollAndTap(tester, write);
    expect(
      File(p.join(dir.path, 'index.html')).readAsStringSync(),
      indexBefore,
      reason: 'rien avant confirmation',
    );
    await confirmWrite(tester);
    final index = File(p.join(dir.path, 'index.html')).readAsStringSync();
    expect(index, contains('<title>Carnet de recettes familial</title>'));
    expect(index, contains('href="https://recettes.example/"'));
    expect(
      File(p.join(dir.path, 'public/robots.txt')).readAsStringSync(),
      contains('Sitemap: https://recettes.example/sitemap.xml'),
    );
    expect(
      File(p.join(dir.path, 'public/sitemap.xml')).readAsStringSync(),
      contains('<loc>https://recettes.example/</loc>'),
    );
  });

  testWidgets('PWA Flutter : manifeste complété et service worker', (
    tester,
  ) async {
    await start(tester, fixture: 'flutter_app', tool: 'pwa');
    await tester.enterText(
      find.byKey(const ValueKey('pwa-shortName')),
      'Météo',
    );
    await scrollAndTap(tester, find.byKey(const ValueKey('pwa-worker')));
    expect(find.textContaining('déprécié'), findsOneWidget);
    await scrollAndTap(tester, find.byKey(const ValueKey('pwa-write')));
    await confirmWrite(tester);
    final manifest = jsonDecode(
      File(p.join(dir.path, 'web/manifest.json')).readAsStringSync(),
    ) as Map;
    expect(manifest['short_name'], 'Météo');
    expect(manifest['theme_color'], isNotEmpty);
    expect(File(p.join(dir.path, 'web/sw.js')).existsSync(), isTrue);
    expect(
      File(p.join(dir.path, 'web/index.html')).readAsStringSync(),
      contains("register('sw.js')"),
    );
  });

  testWidgets('hébergement : configuration, DNS, déploiement simulé', (
    tester,
  ) async {
    final runner = await start(
      tester,
      fixture: 'flutter_app',
      tool: 'hosting',
      tools: {'firebase'},
    );
    await scrollAndTap(tester, find.byKey(const ValueKey('host-firebase')));
    final prepare = find.byKey(const ValueKey('hosting-prepare'));
    expect(tester.widget<FilledButton>(prepare).onPressed, isNull);
    await tester.enterText(
      find.byKey(const ValueKey('hosting-firebase')),
      'meteo-1234',
    );
    await tester.pumpAndSettle();
    await scrollAndTap(tester, prepare);
    await confirmWrite(tester);
    final firebase = jsonDecode(
      File(p.join(dir.path, 'firebase.json')).readAsStringSync(),
    ) as Map;
    expect(firebase['hosting']['public'], 'build/web');

    // Pas de build : pas de déploiement possible.
    final prod = find.byKey(const ValueKey('deploy-production'));
    await tester.ensureVisible(prod);
    expect(tester.widget<FilledButton>(prod).onPressed, isNull);

    File(p.join(dir.path, 'build/web/index.html'))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('<html></html>');
    await tester.enterText(
      find.byKey(const ValueKey('hosting-domain')),
      'www.meteo.fr',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('console Firebase'), findsOneWidget);

    await scrollAndTap(tester, prod);
    expect(find.text('Récapitulatif : mise en production'), findsOneWidget);
    expect(find.textContaining('rien ne sera publié'), findsOneWidget);
    final cont = find.byKey(const ValueKey('deploy-continue'));
    expect(tester.widget<FilledButton>(cont).onPressed, isNull);
    await tester.tap(find.byKey(const ValueKey('deploy-ack')));
    await tester.pumpAndSettle();
    await tester.tap(cont);
    await tester.pumpAndSettle();

    final run = find.byKey(const ValueKey('cmd-preview-run'));
    expect(
      find.textContaining(
        'firebase deploy --only hosting --project meteo-1234',
      ),
      findsWidgets,
    );
    expect(tester.widget<FilledButton>(run).onPressed, isNull);
    await tester.tap(find.byKey(const ValueKey('cmd-reinforced')));
    await tester.pumpAndSettle();
    await tester.tap(run);
    await tester.pumpAndSettle();
    expect(
      runner.executed.where((c) => !c.startsWith('git ')),
      isEmpty,
      reason: 'mode simulation',
    );
  });

  testWidgets('hors simulation, le déploiement confirmé est exécuté', (
    tester,
  ) async {
    final runner = await start(
      tester,
      tool: 'hosting',
      tools: {'netlify'},
      simulation: false,
    );
    File(p.join(dir.path, 'dist/index.html'))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('<html></html>');
    await scrollAndTap(tester, find.byKey(const ValueKey('host-netlify')));
    await scrollAndTap(tester, find.byKey(const ValueKey('deploy-preview')));
    await tester.tap(find.byKey(const ValueKey('deploy-ack')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('deploy-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cmd-reinforced')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
    await tester.pumpAndSettle();
    expect(runner.executed.where((c) => !c.startsWith('git ')), [
      'netlify deploy --dir=dist --no-build',
    ]);
  });

  testWidgets('GitHub Pages : DNS recommandés, aucun push proposé', (
    tester,
  ) async {
    await start(tester, fixture: 'static_site', tool: 'hosting');
    await scrollAndTap(tester, find.byKey(const ValueKey('host-githubPages')));
    expect(find.byKey(const ValueKey('hosting-github-steps')), findsOneWidget);
    expect(find.byKey(const ValueKey('deploy-production')), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('hosting-github')),
      'alex/atelier',
    );
    await tester.enterText(
      find.byKey(const ValueKey('hosting-domain')),
      'atelier.fr',
    );
    await tester.pumpAndSettle();
    expect(find.text('185.199.111.153'), findsOneWidget);
    expect(find.text('alex.github.io'), findsOneWidget);
    expect(find.textContaining('ne modifie jamais le DNS'), findsOneWidget);
    await scrollAndTap(tester, find.byKey(const ValueKey('dns-check')));
    expect(
      find.text('Le domaine pointe vers : 185.199.108.153'),
      findsOneWidget,
    );
  });

  testWidgets('outils web masqués sans cible Web', (tester) async {
    dir = copyFixture('python_api');
    final db = memoryDatabase();
    addTearDown(db.close);
    final projects = ProjectRepository(db, FakePathInspector([dir.path]));
    final id = (await projects.addProject(dir.path)).project.id;
    await DetectionRepository(db).saveReport(id, analyzeProjectSync(dir.path));
    await pumpLaunchPilot(
      tester,
      database: db,
      prefs: {CurrentProjectController.prefsKey: id},
      paths: FakePathInspector([dir.path]),
    );
    await tester.tap(find.byKey(const ValueKey('nav-content')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tool-hosting')), findsNothing);
    expect(find.byKey(const ValueKey('tool-version')), findsOneWidget);
  });

  testWidgets('hébergeur par défaut des paramètres repris par le projet', (
    tester,
  ) async {
    dir = copyFixture('react_vite');
    final db = memoryDatabase();
    addTearDown(db.close);
    final projects = ProjectRepository(db, FakePathInspector([dir.path]));
    final id = (await projects.addProject(dir.path)).project.id;
    await DetectionRepository(db).saveReport(id, analyzeProjectSync(dir.path));
    final prefs = await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      prefs: {CurrentProjectController.prefsKey: id},
      paths: FakePathInspector([dir.path]),
    );
    await tester.tap(find.byKey(const ValueKey('nav-settings')));
    await tester.pumpAndSettle();
    await scrollAndTap(
      tester,
      find.byKey(const ValueKey('settings-host-vercel')),
    );
    expect(prefs.getString(SettingsRepository.kPreferredHost), 'vercel');
    await tester.tap(find.text('Plausible'));
    await tester.pumpAndSettle();
    expect(prefs.getString(SettingsRepository.kAnalytics), 'plausible');

    await tester.tap(find.byKey(const ValueKey('nav-content')));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.byKey(const ValueKey('tool-hosting')));
    final chip = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('host-vercel')),
    );
    expect(chip.selected, isTrue);
    expect(find.text('Fichiers préparés : public/vercel.json'), findsOneWidget);
  });
}
