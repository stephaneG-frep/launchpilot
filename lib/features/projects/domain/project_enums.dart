/// Cycle de vie d'une session de préparation de version.
enum SessionStatus {
  /// Peut être reprise. Au plus une session active par projet.
  active,

  /// Close par l'utilisateur ; conservée pour l'historique.
  completed,
}

/// Nature d'un élément enregistré au cours d'une session.
enum SessionEntryKind { validatedText, report, auditResult }
