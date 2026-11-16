import 'dart:async';

/// Jeton d'annulation partagé entre l'interface et une opération en cours
/// (requête LLM, commande).
class CancellationToken {
  final _completer = Completer<void>();

  bool get isCancelled => _completer.isCompleted;

  /// Se termine au moment de l'annulation.
  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (!_completer.isCompleted) _completer.complete();
  }
}
