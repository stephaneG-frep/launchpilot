import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../core/domain/cancellation.dart';
import '../../../core/security/secret_redactor.dart';
import '../domain/command_policy.dart';
import '../domain/command_result.dart';
import '../domain/command_spec.dart';

/// Exécute des commandes sous contrôle de la [CommandPolicy].
abstract interface class CommandRunner {
  CommandPolicy get policy;

  /// Confirmation à créer uniquement après que l'utilisateur a vu l'aperçu.
  CommandApproval approve(CommandSpec spec);

  Future<CommandResult> run(
    CommandSpec spec, {
    required String projectRoot,
    required bool simulation,
    CommandApproval? approval,
    CancellationToken? cancel,
    void Function(OutputLine line)? onLine,
  });
}

/// Implémentation réelle avec `Process.start`, sans shell.
class ProcessCommandRunner implements CommandRunner {
  ProcessCommandRunner({
    this.policy = const CommandPolicy(),
    this.maxLines = 4000,
  });

  @override
  final CommandPolicy policy;
  final int maxLines;

  final _approvals = <String, String>{};
  final _random = Random.secure();

  /// Évite toute invite interactive et la coloration ANSI.
  static const environment = {
    'NO_COLOR': '1',
    'TERM': 'dumb',
    'GIT_TERMINAL_PROMPT': '0',
    'GIT_PAGER': 'cat',
    'PAGER': 'cat',
    'CI': 'true',
  };

  @override
  CommandApproval approve(CommandSpec spec) {
    final id = List.generate(
      16,
      (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    _approvals[id] = spec.digest;
    return CommandApproval.internal(id, spec.digest);
  }

  /// Vérifie et consomme une confirmation : elle ne sert qu'une fois.
  bool _consume(CommandApproval? approval, CommandSpec spec) {
    if (approval == null) return false;
    final expected = _approvals.remove(approval.id);
    return expected != null &&
        expected == spec.digest &&
        approval.digest == spec.digest;
  }

  @override
  Future<CommandResult> run(
    CommandSpec spec, {
    required String projectRoot,
    required bool simulation,
    CommandApproval? approval,
    CancellationToken? cancel,
    void Function(OutputLine line)? onLine,
  }) async {
    final decision = policy.evaluate(spec, projectRoot);
    CommandResult result(RunStatus status, {String? message}) => CommandResult(
      spec: spec,
      decision: decision,
      status: status,
      message: message,
    );

    if (!decision.allowed) return result(RunStatus.blocked);
    if (decision.risk != RiskLevel.readOnly) {
      // Consommée même en simulation : une confirmation ne se réutilise pas.
      final approved = _consume(approval, spec);
      if (!approved) return result(RunStatus.blocked, message: 'approval');
      if (simulation) return result(RunStatus.simulated);
    }
    if (cancel?.isCancelled ?? false) return result(RunStatus.cancelled);
    if (!insideProject(spec.workingDirectory, projectRoot)) {
      return result(RunStatus.blocked, message: 'workingDirectory');
    }
    return execute(spec, decision, cancel: cancel, onLine: onLine);
  }

  /// Lance réellement le processus, une fois toutes les vérifications faites.
  /// Les tests d'interface remplacent seulement cette partie.
  @protected
  Future<CommandResult> execute(
    CommandSpec spec,
    PolicyDecision decision, {
    CancellationToken? cancel,
    void Function(OutputLine line)? onLine,
  }) async {
    CommandResult result(RunStatus status, {String? message}) => CommandResult(
      spec: spec,
      decision: decision,
      status: status,
      message: message,
    );
    final watch = Stopwatch()..start();
    final Process process;
    try {
      process = await Process.start(
        spec.executable,
        spec.arguments,
        workingDirectory: spec.workingDirectory,
        environment: environment,
        runInShell: false,
      );
    } on ProcessException catch (e) {
      return result(
        RunStatus.startFailed,
        message: SecretRedactor.redact(e.message).text,
      );
    }
    await process.stdin.close();

    final lines = <OutputLine>[];
    var dropped = 0;
    void add(OutputStream stream, String raw) {
      final line = OutputLine(stream, SecretRedactor.redact(raw).text);
      lines.add(line);
      if (lines.length > maxLines) {
        lines.removeAt(0);
        dropped++;
      }
      onLine?.call(line);
    }

    Future<void> pump(Stream<List<int>> source, OutputStream stream) => source
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .forEach((l) => add(stream, l));

    final outDone = pump(process.stdout, OutputStream.stdout);
    final errDone = pump(process.stderr, OutputStream.stderr);

    RunStatus? interruption;
    Future<void> stop(RunStatus why) async {
      if (interruption != null) return;
      interruption = why;
      process.kill(ProcessSignal.sigterm);
      await Future<void>.delayed(const Duration(seconds: 3));
      process.kill(ProcessSignal.sigkill);
    }

    final timer = Timer(spec.timeout, () => stop(RunStatus.timedOut));
    unawaited(cancel?.whenCancelled.then((_) => stop(RunStatus.cancelled)));

    final code = await process.exitCode;
    timer.cancel();
    await Future.wait([outDone, errDone]);
    watch.stop();

    return CommandResult(
      spec: spec,
      decision: decision,
      status:
          interruption ?? (code == 0 ? RunStatus.succeeded : RunStatus.failed),
      exitCode: code,
      duration: watch.elapsed,
      lines: List.unmodifiable(lines),
      truncated: dropped > 0,
    );
  }

  /// Vérification sur les chemins réels : un lien symbolique ne permet pas
  /// de sortir du projet.
  @protected
  bool insideProject(String workingDirectory, String root) {
    try {
      final realRoot = Directory(root).resolveSymbolicLinksSync();
      final realWd = Directory(workingDirectory).resolveSymbolicLinksSync();
      return realWd == realRoot || p.isWithin(realRoot, realWd);
    } on FileSystemException {
      return false;
    }
  }
}
