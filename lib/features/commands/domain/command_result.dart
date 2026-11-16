import 'package:flutter/foundation.dart';

import 'command_spec.dart';

enum OutputStream { stdout, stderr }

/// Ligne de sortie, déjà masquée.
@immutable
class OutputLine {
  const OutputLine(this.stream, this.text);
  final OutputStream stream;
  final String text;
}

enum RunStatus {
  succeeded,
  failed,
  cancelled,
  timedOut,

  /// Refusée par la politique, ou confirmation absente/invalide.
  blocked,

  /// Mode simulation : prévisualisée, non exécutée.
  simulated,

  /// Exécutable introuvable ou processus impossible à lancer.
  startFailed,
}

@immutable
class CommandResult {
  const CommandResult({
    required this.spec,
    required this.decision,
    required this.status,
    this.exitCode,
    this.duration = Duration.zero,
    this.lines = const [],
    this.truncated = false,
    this.message,
  });

  final CommandSpec spec;
  final PolicyDecision decision;
  final RunStatus status;
  final int? exitCode;
  final Duration duration;
  final List<OutputLine> lines;

  /// Les premières lignes ont été abandonnées (sortie très longue).
  final bool truncated;

  /// Précision technique (déjà masquée), par exemple une erreur de lancement.
  final String? message;

  bool get succeeded => status == RunStatus.succeeded;

  String text([OutputStream? only]) => [
    for (final l in lines)
      if (only == null || l.stream == only) l.text,
  ].join('\n');
}

/// Confirmation donnée pour UNE commande précise, consommée à l'usage.
@immutable
class CommandApproval {
  const CommandApproval.internal(this.id, this.digest);
  final String id;
  final String digest;
}
