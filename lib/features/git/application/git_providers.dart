import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../commands/application/command_providers.dart';
import '../../detection/application/detection_providers.dart';
import '../../projects/application/project_providers.dart';
import '../data/git_service.dart';
import '../domain/git_status.dart';
import '../domain/gitignore_advisor.dart';

final gitServiceProvider = Provider<GitService>(
  (ref) => GitService(ref.watch(commandRunnerProvider)),
);

/// État Git du projet ouvert (lecture seule). `ref.invalidate` pour
/// rafraîchir.
final gitStatusProvider = FutureProvider<GitStatus?>((ref) async {
  final path = ref.watch(
    currentWorkspaceProvider.select(
      (ws) =>
          ws.value?.folderAvailable ?? false ? ws.value!.project.path : null,
    ),
  );
  if (path == null) return null;
  return ref.watch(gitServiceProvider).status(path);
}, retry: (_, _) => null);

/// Fichiers sensibles repérés par la détection et pas encore ignorés par
/// Git : candidats à un ajout dans `.gitignore`.
final gitignoreProposalProvider = FutureProvider<List<String>>((ref) async {
  final status = await ref.watch(gitStatusProvider.future);
  if (status == null || !status.isRepo) return const [];
  final detection = await ref.watch(currentDetectionProvider.future);
  if (detection == null) return const [];
  final candidates = sensitiveFilesToIgnore(detection.report.sensitiveFiles);
  if (candidates.isEmpty) return const [];
  final root = ref.read(currentWorkspaceProvider).value!.project.path;
  final ignored = await ref.read(gitServiceProvider).ignored(root, candidates);
  return [
    for (final c in candidates)
      if (!ignored.contains(c)) c,
  ];
}, retry: (_, _) => null);
