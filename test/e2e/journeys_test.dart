import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:launchpilot/features/android/application/android_providers.dart';
import 'package:launchpilot/features/android/domain/deliverables.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/detection/data/detection_repository.dart';
import 'package:launchpilot/features/llm/domain/llm_provider_id.dart';
import 'package:launchpilot/features/projects/application/project_providers.dart';
import 'package:launchpilot/features/projects/data/project_repository.dart';
import 'package:launchpilot/features/reports/presentation/reports_screen.dart';
import 'package:launchpilot/features/settings/data/api_key_repository.dart';
import 'package:launchpilot/features/settings/data/settings_repository.dart';
import 'package:path/path.dart' as p;

import '../support/test_harness.dart';

/// Parcours complets sur l'application entière : vrai dossier de projet,
/// vraie base (en mémoire), vrai moteur de checklist et d'écriture ; seuls
/// le lancement des processus, le réseau et les boîtes natives sont simulés.

class FakeReportSaver implements ReportSaver {
  FakeReportSaver(this.path);
  final String path;
  final suggested = <String>[];

  @override
  Future<String?> pickPath(String suggestedName) async {
    suggested.add(suggestedName);
    return path;
  }
}

Directory copyFixture(String name) {
  final dir = Directory.systemTemp.createTempSync('lp_e2e_');
  final src = Directory('test/fixtures/projects/$name');
  for (final f in src.listSync(recursive: true).whereType<File>()) {
    final target = File(p.join(dir.path, p.relative(f.path, from: src.path)));
    target.parent.createSync(recursive: true);
    f.copySync(target.path);
  }
  Process.runSync('git', ['init', '-q'], workingDirectory: dir.path);
  return dir;
}

Future<void> go(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(ValueKey('nav-$name')));
  await tester.pumpAndSettle();
}

Finder keyPrefix(String prefix) => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith(prefix),
);

const secret = 'sk-ant-api03-AbCdEfGhIjKlMnOpQrStUv';
const fakeKey = 'sk-test-00000000000000000000000000000000';

void main() {
  late Directory dir;
  late Directory out;
  setUp(() {
    dir = copyFixture('flutter_app');
    out = Directory.systemTemp.createTempSync('lp_report_');
  });
  tearDown(() {
    dir.deleteSync(recursive: true);
    out.deleteSync(recursive: true);
  });

  testWidgets(
    'débutant : du dossier au rapport, sans jamais exposer un secret',
    (tester) async {
      final runner = FakeCommandRunner({
        'flutter doctor -v': (
          exitCode: 0,
          stdout: ['[✓] Flutter (Channel stable)'],
          stderr: <String>[],
        ),
        'git log --grep=$secret': (
          exitCode: 0,
          stdout: ['commit a1 contient $secret'],
          stderr: <String>[],
        ),
      });
      final saver = FakeReportSaver(p.join(out.path, 'rapport.html'));
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        paths: FakePathInspector([dir.path]),
        folderPicker: FakeFolderPicker(dir.path),
        commandRunner: runner,
        overrides: [
          reportSaverProvider.overrideWithValue(saver),
          deliverableInspectorProvider.overrideWithValue(
            (job) async => inspectDeliverables(job),
          ),
        ],
      );

      // 1. Ouvrir et analyser le projet, valider les cibles.
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('home-pick-folder')),
      );
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('detection-analyze')),
      );
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('detection-validate-targets')),
      );

      // 2. Démarrer une session de version.
      await go(tester, 'publication');
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('board-new-session')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('new-session-version')),
        '1.3.0',
      );
      await tester.tap(find.byKey(const ValueKey('dialog-confirm')));
      await tester.pumpAndSettle();
      expect(find.text('Session 1.3.0 démarrée.'), findsOneWidget);

      // 3. Checklist : une commande en lecture seule, prévisualisée puis lancée.
      await go(tester, 'checklist');
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('step-run-common.flutter.doctor')),
      );
      await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
      await tester.pumpAndSettle();
      expect(runner.executed, contains('flutter doctor -v'));

      // 4. Contenus : la version est écrite après aperçu.
      await go(tester, 'content');
      await scrollAndTap(tester, find.byKey(const ValueKey('tool-version')));
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('version-write-pubspec.yaml')),
      );
      await tester.tap(find.byKey(const ValueKey('write-confirm')));
      await tester.pumpAndSettle();
      expect(
        File(p.join(dir.path, 'pubspec.yaml')).readAsStringSync(),
        contains('version: 1.2.1+8'),
      );

      // 5. Terminal : un push est refusé, une commande contenant un secret
      // est journalisée masquée.
      await go(tester, 'terminal');
      await tester.enterText(
        find.byKey(const ValueKey('terminal-custom')),
        'git push origin main',
      );
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('terminal-custom-preview')),
      );
      expect(find.text('Interdite'), findsOneWidget);
      expect(find.byKey(const ValueKey('cmd-preview-run')), findsNothing);
      await tester.tap(find.text('Fermer'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('terminal-custom')),
        'git log --grep=$secret',
      );
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('terminal-custom-preview')),
      );
      await tester.tap(find.byKey(const ValueKey('cmd-preview-run')));
      await tester.pumpAndSettle();
      expect(runner.executed, isNot(contains('git push origin main')));

      // 6. Rapport : aperçu puis export HTML.
      await go(tester, 'reports');
      await scrollAndTap(tester, keyPrefix('report-open-').first);
      expect(find.byKey(const ValueKey('report-detail')), findsOneWidget);
      expect(find.text('1 fichier créé ou modifié'), findsOneWidget);
      await scrollAndTap(tester, find.byKey(const ValueKey('report-export')));
      expect(find.text('Rapport enregistré.'), findsOneWidget);
      expect(saver.suggested.single, endsWith('-1.3.0-${_today()}.html'));

      final html = File(saver.path).readAsStringSync();
      expect(html, contains('1.3.0'));
      expect(html, contains('flutter doctor -v'));
      expect(html, contains('<code>pubspec.yaml</code>'));
      expect(html, contains('Procédure manuelle de publication'));
      expect(html, contains('Lexique'));
      expect(html, contains('Android —'));
      expect(
        html,
        isNot(contains(secret)),
        reason: 'secret jamais dans le rapport',
      );
      expect(html, isNot(contains('git push')));
      expect(find.text('1 rapport exporté'), findsOneWidget);
    },
  );

  testWidgets('chat : contexte choisi, secret masqué, historique conservé', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final client = MockClient((r) async {
      requests.add(r);
      return http.Response(
        jsonEncode({
          'model': 'claude-opus-5-5',
          'stop_reason': 'end_turn',
          'content': [
            {
              'type': 'text',
              'text': jsonEncode({
                'answer': 'Commence par vérifier l\'état Git.',
                'followUps': ['Comment créer la clé de signature ?'],
              }),
            },
          ],
          'usage': {'input_tokens': 300, 'output_tokens': 40},
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final db = memoryDatabase();
    addTearDown(db.close);
    final projects = ProjectRepository(db, FakePathInspector([dir.path]));
    final id = (await projects.addProject(dir.path)).project.id;
    await DetectionRepository(db).saveReport(id, analyzeProjectSync(dir.path));
    await projects.startSession(id, '1.3.0');
    final store = InMemorySecretStore()
      ..values[ApiKeyRepository.storageKeyFor(LlmProviderId.anthropic)] =
          fakeKey;
    final prefs = await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      secretStore: store,
      httpClient: client,
      prefs: {CurrentProjectController.prefsKey: id},
      paths: FakePathInspector([dir.path]),
    );

    await go(tester, 'agent');
    expect(find.byKey(const ValueKey('chat-safety')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('chat-ctx-checklist')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('chat-input')),
      'Par quoi commencer ? Ma clé est $secret',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('chat-send')));
    await tester.pumpAndSettle();
    expect(requests, isEmpty, reason: 'rien ne part avant confirmation');
    await tester.tap(find.byKey(const ValueKey('llm-send-confirm')));
    await tester.pumpAndSettle();

    expect(requests, hasLength(1));
    final body = requests.single.body;
    expect(body, contains('Checklist'));
    expect(body, contains('Projet : ${p.basename(dir.path)}'));
    expect(body, isNot(contains(secret)));
    expect(body, isNot(contains(fakeKey)));
    expect(
      body,
      isNot(contains(dir.path)),
      reason: 'aucun chemin local envoyé',
    );

    await tester.tap(find.byKey(const ValueKey('llm-send-close')));
    await tester.pumpAndSettle();
    expect(find.text('Commence par vérifier l\'état Git.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('chat-followup-0')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('chat-input')))
          .controller!
          .text,
      'Comment créer la clé de signature ?',
    );

    // Redémarrage : la conversation de la session est retrouvée.
    await tester.pumpWidget(const SizedBox());
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      database: db,
      secretStore: store,
      httpClient: client,
      prefs: {for (final k in prefs.getKeys()) k: prefs.get(k)!},
      paths: FakePathInspector([dir.path]),
    );
    await go(tester, 'agent');
    expect(find.text('Commence par vérifier l\'état Git.'), findsOneWidget);
    expect(find.textContaining('Par quoi commencer ?'), findsOneWidget);

    await scrollAndTap(tester, find.byKey(const ValueKey('chat-clear')));
    await tester.tap(find.byKey(const ValueKey('chat-clear-confirm')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('chat-empty')), findsOneWidget);
  });

  testWidgets('aide : mode d\'emploi consultable, en français et en anglais', (
    tester,
  ) async {
    await pumpLaunchPilot(tester, size: tallScreen);
    await go(tester, 'help');
    await tester.enterText(
      find.byKey(const ValueKey('manual-search')),
      'trousseau',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('manual-backup-found')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('manual-troubleshooting-found')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('manual-android-found')), findsNothing);
    expect(find.textContaining('gnome-keyring'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      prefs: {SettingsRepository.kLanguage: 'en'},
    );
    await go(tester, 'help');
    expect(find.text('Full manual'), findsOneWidget);
    expect(find.text('Getting started'), findsOneWidget);
  });
}

String _today() {
  final d = DateTime.now();
  return '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
}
