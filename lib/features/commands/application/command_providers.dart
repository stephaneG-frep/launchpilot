import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain/cancellation.dart';
import '../../projects/application/project_providers.dart';
import '../../settings/application/settings_controller.dart';
import '../data/command_log_repository.dart';
import '../data/process_command_runner.dart';
import '../domain/command_result.dart';
import '../domain/command_spec.dart';

/// Un seul runner pour toute l'application : il détient les confirmations.
final commandRunnerProvider = Provider<CommandRunner>(
  (ref) => ProcessCommandRunner(),
);

final commandLogRepositoryProvider = Provider<CommandLogRepository>(
  (ref) => CommandLogRepository(ref.watch(appDatabaseProvider)),
);

final currentCommandLogProvider = StreamProvider<List<CommandLogEntry>>((ref) {
  final id = ref.watch(currentProjectIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(commandLogRepositoryProvider).watch(id);
}, retry: (_, _) => null);

/// État du terminal intégré : commande en cours ou dernière exécutée.
@immutable
class TerminalState {
  const TerminalState({
    this.spec,
    this.decision,
    this.lines = const [],
    this.running = false,
    this.result,
    this.revision = 0,
  });

  final CommandSpec? spec;
  final PolicyDecision? decision;

  /// Liste mutable pendant l'exécution ; [revision] signale les ajouts.
  final List<OutputLine> lines;
  final bool running;
  final CommandResult? result;
  final int revision;

  TerminalState bumped() => TerminalState(
    spec: spec,
    decision: decision,
    lines: lines,
    running: running,
    result: result,
    revision: revision + 1,
  );
}

final terminalControllerProvider =
    NotifierProvider<TerminalController, TerminalState>(TerminalController.new);

class TerminalController extends Notifier<TerminalState> {
  CancellationToken? _cancel;

  @override
  TerminalState build() => const TerminalState();

  bool get busy => state.running;

  /// Exécute [spec] dans le projet [projectId]. Une seule commande à la fois.
  Future<CommandResult?> run({
    required int projectId,
    required String projectRoot,
    required CommandSpec spec,
    CommandApproval? approval,
  }) async {
    if (state.running) return null;
    final runner = ref.read(commandRunnerProvider);
    final cancel = _cancel = CancellationToken();
    final lines = <OutputLine>[];
    state = TerminalState(
      spec: spec,
      decision: runner.policy.evaluate(spec, projectRoot),
      lines: lines,
      running: true,
    );
    final startedAt = DateTime.now();
    final result = await runner.run(
      spec,
      projectRoot: projectRoot,
      simulation: ref.read(settingsControllerProvider).simulationMode,
      approval: approval,
      cancel: cancel,
      onLine: (line) {
        lines.add(line);
        if (ref.mounted) state = state.bumped();
      },
    );
    _cancel = null;
    if (!ref.mounted) return result;
    state = TerminalState(
      spec: spec,
      decision: result.decision,
      lines: result.lines,
      result: result,
    );
    await ref
        .read(commandLogRepositoryProvider)
        .log(projectId, result, startedAt);
    return result;
  }

  void cancel() => _cancel?.cancel();
}
