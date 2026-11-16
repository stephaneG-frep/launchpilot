/// Essai de génération : question fixe, sans aucune donnée de projet, qui
/// vérifie de bout en bout la réponse structurée d'un fournisseur.
abstract final class LlmTrial {
  static const schemaName = 'launchpilot_trial';

  static const schema = <String, Object?>{
    'type': 'object',
    'additionalProperties': false,
    'required': ['answer', 'terms'],
    'properties': {
      'answer': {'type': 'string'},
      'terms': {
        'type': 'array',
        'items': {'type': 'string'},
      },
    },
  };

  static String system(String languageName) =>
      'Tu es LaunchPilot, un assistant pédagogique qui aide à publier des '
      'applications. Réponds en $languageName, simplement et sans jargon '
      'inutile.';
}
