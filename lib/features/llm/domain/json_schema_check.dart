/// Vérifie une valeur JSON contre le sous-ensemble de JSON Schema utilisé
/// par LaunchPilot. Renvoie la liste des écarts (vide si conforme).
///
/// Les fournisseurs ne garantissent pas tous le respect du schéma : la
/// réponse est donc toujours revérifiée ici.
List<String> checkJsonSchema(
  Object? value,
  Map<String, Object?> schema, [
  String path = r'$',
]) {
  final errors = <String>[];
  final type = schema['type'];
  final enumValues = schema['enum'];

  bool isType(String t) => switch (t) {
    'object' => value is Map,
    'array' => value is List,
    'string' => value is String,
    'integer' => value is int || (value is double && value == value.truncate()),
    'number' => value is num,
    'boolean' => value is bool,
    'null' => value == null,
    _ => true,
  };

  if (type is String && !isType(type)) {
    return ['$path : type $type attendu'];
  }
  if (type is List && !type.whereType<String>().any(isType)) {
    return ['$path : un des types $type attendu'];
  }
  if (enumValues is List && !enumValues.contains(value)) {
    errors.add('$path : valeur hors de $enumValues');
  }

  if (value is Map) {
    final properties =
        (schema['properties'] as Map?)?.cast<String, Object?>() ?? const {};
    final required = (schema['required'] as List?)?.cast<String>() ?? const [];
    for (final key in required) {
      if (!value.containsKey(key)) errors.add('$path.$key : champ manquant');
    }
    if (schema['additionalProperties'] == false) {
      for (final key in value.keys) {
        if (!properties.containsKey(key)) {
          errors.add('$path.$key : champ inattendu');
        }
      }
    }
    for (final entry in properties.entries) {
      if (value.containsKey(entry.key) && entry.value is Map) {
        errors.addAll(
          checkJsonSchema(
            value[entry.key],
            (entry.value as Map).cast<String, Object?>(),
            '$path.${entry.key}',
          ),
        );
      }
    }
  }

  if (value is List && schema['items'] is Map) {
    final items = (schema['items'] as Map).cast<String, Object?>();
    for (var i = 0; i < value.length; i++) {
      errors.addAll(checkJsonSchema(value[i], items, '$path[$i]'));
    }
  }
  return errors;
}
