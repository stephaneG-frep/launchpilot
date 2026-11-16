/// Statut d'une étape, partagé par la checklist, le tableau de publication
/// et les rapports. Chaque valeur correspond à une couleur de statut.
enum StepStatus {
  /// Gris : à faire.
  todo,

  /// Bleu : en cours.
  running,

  /// Vert : réussi.
  succeeded,

  /// Rouge : échec ou blocage.
  failed,

  /// Orange : avertissement ou validation requise.
  needsValidation,

  /// Violet : étape pédagogique ou intervention de l'IA.
  pedagogical,
}
