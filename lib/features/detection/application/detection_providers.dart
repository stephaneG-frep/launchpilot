import 'dart:isolate';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/application/project_providers.dart';
import '../data/detection_repository.dart';
import '../data/project_scanner.dart';
import '../domain/detection_report.dart';
import '../domain/detectors.dart';

/// Analyse d'un dossier, remplaçable dans les tests de widgets (où ni les
/// isolats ni les E/S réelles ne progressent).
abstract interface class ProjectAnalyzer {
  Future<DetectionReport> analyze(String path);
}

/// Scanner et détecteurs exécutés dans un isolat : l'interface reste fluide.
class IsolateProjectAnalyzer implements ProjectAnalyzer {
  const IsolateProjectAnalyzer();

  @override
  Future<DetectionReport> analyze(String path) =>
      Isolate.run(() => analyzeProjectSync(path));
}

/// Fonction de niveau supérieur : rien du contexte appelant n'est capturé.
DetectionReport analyzeProjectSync(String path) =>
    detectProject(ProjectScanner.scan(path), now: DateTime.now());

/// Sélecteur de dossier natif, remplaçable dans les tests.
abstract interface class FolderPicker {
  Future<String?> pickDirectory({String? initialDirectory, String? title});
}

class NativeFolderPicker implements FolderPicker {
  const NativeFolderPicker();

  @override
  Future<String?> pickDirectory({String? initialDirectory, String? title}) =>
      fs.getDirectoryPath(
        initialDirectory: initialDirectory,
        confirmButtonText: title,
      );
}

final projectAnalyzerProvider = Provider<ProjectAnalyzer>(
  (ref) => const IsolateProjectAnalyzer(),
);

final folderPickerProvider = Provider<FolderPicker>(
  (ref) => const NativeFolderPicker(),
);

final detectionRepositoryProvider = Provider<DetectionRepository>(
  (ref) => DetectionRepository(ref.watch(appDatabaseProvider)),
);

/// Rapport du projet ouvert dans l'espace de travail.
final currentDetectionProvider = StreamProvider<ProjectDetection?>((ref) {
  final id = ref.watch(currentProjectIdProvider);
  if (id == null) return Stream.value(null);
  return ref.watch(detectionRepositoryProvider).watch(id);
}, retry: (_, _) => null);
