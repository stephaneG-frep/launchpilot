import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:launchpilot/app/app.dart';
import 'package:launchpilot/core/database/app_database.dart';
import 'package:launchpilot/core/domain/cancellation.dart';
import 'package:launchpilot/core/storage/secret_store.dart';
import 'package:launchpilot/features/changes/application/change_providers.dart';
import 'package:launchpilot/features/commands/application/command_providers.dart';
import 'package:launchpilot/features/commands/data/process_command_runner.dart';
import 'package:launchpilot/features/commands/domain/command_result.dart';
import 'package:launchpilot/features/commands/domain/command_spec.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/detection/domain/detection_report.dart';
import 'package:launchpilot/features/llm/application/llm_service.dart';
import 'package:launchpilot/features/projects/application/project_providers.dart';
import 'package:launchpilot/features/projects/data/path_inspector.dart';
import 'package:launchpilot/features/settings/application/api_keys_controller.dart';
import 'package:launchpilot/features/settings/application/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stockage de secrets en mémoire pour les tests. Peut simuler un trousseau
/// indisponible.
class InMemorySecretStore implements SecretStore {
  final Map<String, String> values = {};
  bool failing = false;

  void _check() {
    if (failing) throw const SecretStoreUnavailableException('test');
  }

  @override
  Future<bool> contains(String key) async {
    _check();
    return values.containsKey(key);
  }

  @override
  Future<void> delete(String key) async {
    _check();
    values.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    _check();
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _check();
    values[key] = value;
  }
}

/// Dossiers « existants » simulés : aucune E/S réelle dans les tests.
class FakePathInspector implements PathInspector {
  FakePathInspector([Iterable<String> existing = const []])
    : existing = {...existing};

  final Set<String> existing;

  @override
  String? get homeDirectory => '/home/testeur';

  @override
  Future<bool> isDirectory(String path) async => existing.contains(path);
}

/// Client par défaut des tests : tout appel réseau est une erreur.
final offlineClient = MockClient(
  (request) =>
      throw StateError('Appel réseau interdit en test : ${request.url}'),
);

/// Analyse un projet d'exemple de `test/fixtures/projects`, quel que soit le
/// chemin demandé (lecture synchrone, compatible avec le temps simulé).
class FixtureAnalyzer implements ProjectAnalyzer {
  const FixtureAnalyzer(this.fixture);
  final String fixture;

  @override
  Future<DetectionReport> analyze(String path) async =>
      analyzeProjectSync('test/fixtures/projects/$fixture');
}

/// Sélecteur de dossier qui renvoie [path] (null = annulé).
class FakeFolderPicker implements FolderPicker {
  FakeFolderPicker(this.path);
  String? path;
  int calls = 0;

  @override
  Future<String?> pickDirectory({
    String? initialDirectory,
    String? title,
  }) async {
    calls++;
    return path;
  }
}

String _tempBackups() {
  final dir = Directory.systemTemp.createTempSync('lp_backups_');
  addTearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });
  return dir.path;
}

/// Réponse préenregistrée d'une commande simulée.
typedef FakeOutput = ({int exitCode, List<String> stdout, List<String> stderr});

/// Runner de test : MÊME politique, mêmes confirmations et même mode
/// simulation que le vrai ; seul le lancement du processus est remplacé.
class FakeCommandRunner extends ProcessCommandRunner {
  FakeCommandRunner([Map<String, FakeOutput>? outputs])
    : outputs = outputs ?? {};

  /// Réponses par commande affichée (`git status --porcelain=v1 …`).
  final Map<String, FakeOutput> outputs;
  final executed = <String>[];

  /// Commande qui ne se termine qu'à l'annulation.
  String? hangingCommand;

  @override
  bool insideProject(String workingDirectory, String root) => true;

  @override
  Future<CommandResult> execute(
    CommandSpec spec,
    PolicyDecision decision, {
    CancellationToken? cancel,
    void Function(OutputLine line)? onLine,
  }) async {
    executed.add(spec.display);
    if (spec.display == hangingCommand) {
      onLine?.call(const OutputLine(OutputStream.stdout, 'en cours…'));
      await cancel!.whenCancelled;
      return CommandResult(
        spec: spec,
        decision: decision,
        status: RunStatus.cancelled,
        exitCode: -15,
        lines: const [OutputLine(OutputStream.stdout, 'en cours…')],
      );
    }
    final out =
        outputs[spec.display] ??
        (exitCode: 0, stdout: const <String>[], stderr: const <String>[]);
    final lines = [
      for (final l in out.stdout) OutputLine(OutputStream.stdout, l),
      for (final l in out.stderr) OutputLine(OutputStream.stderr, l),
    ];
    lines.forEach(onLine ?? (_) {});
    return CommandResult(
      spec: spec,
      decision: decision,
      status: out.exitCode == 0 ? RunStatus.succeeded : RunStatus.failed,
      exitCode: out.exitCode,
      duration: const Duration(milliseconds: 1200),
      lines: lines,
    );
  }
}

/// Base SQLite en mémoire, adaptée au temps simulé des tests de widgets.
AppDatabase memoryDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

/// Horloge contrôlée : chaque appel avance d'une minute.
DateTime Function() steppingClock([DateTime? start]) {
  var t = start ?? DateTime(2026, 9, 30, 9);
  return () => t = t.add(const Duration(minutes: 1));
}

const wideScreen = Size(1440, 1000);
const tallScreen = Size(1440, 3200);
const narrowScreen = Size(480, 900);

/// Lance l'application complète avec des préférences et un trousseau simulés.
Future<SharedPreferences> pumpLaunchPilot(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  SecretStore? secretStore,
  AppDatabase? database,
  PathInspector? paths,
  http.Client? httpClient,
  ProjectAnalyzer? analyzer,
  FolderPicker? folderPicker,
  CommandRunner? commandRunner,
  String? backupRoot,
  Size size = wideScreen,
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // Une base fournie par le test reste à sa charge (redémarrage simulé).
  final db = database ?? memoryDatabase();
  if (database == null) addTearDown(db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        secretStoreProvider.overrideWithValue(
          secretStore ?? InMemorySecretStore(),
        ),
        appDatabaseProvider.overrideWithValue(db),
        databaseLocationProvider.overrideWithValue('/tmp/test.sqlite'),
        pathInspectorProvider.overrideWithValue(paths ?? FakePathInspector()),
        httpClientProvider.overrideWithValue(httpClient ?? offlineClient),
        projectAnalyzerProvider.overrideWithValue(
          analyzer ?? const FixtureAnalyzer('flutter_app'),
        ),
        folderPickerProvider.overrideWithValue(
          folderPicker ?? FakeFolderPicker(null),
        ),
        commandRunnerProvider.overrideWithValue(
          commandRunner ?? FakeCommandRunner(),
        ),
        backupRootProvider.overrideWithValue(backupRoot ?? _tempBackups()),
        ...overrides,
      ],
      child: const LaunchPilotApp(),
    ),
  );
  await tester.pumpAndSettle();
  return sharedPrefs;
}

/// Fait défiler jusqu'à l'élément puis le touche.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
