import 'package:flutter/foundation.dart';

/// Champs d'une fiche de store, avec la limite la plus stricte des stores.
enum StoreField {
  /// Play Store et App Store : 30 caractères.
  title(30),

  /// Sous-titre App Store : 30 caractères.
  subtitle(30),

  /// Description courte Play Store : 80 caractères.
  shortDescription(80),

  /// Description longue : 4000 caractères.
  longDescription(4000),

  /// Mots-clés App Store, séparés par des virgules : 100 caractères.
  keywords(100),

  /// Texte promotionnel App Store : 170 caractères.
  promoText(170);

  const StoreField(this.limit);
  final int limit;
}

/// Textes d'une langue.
@immutable
class StoreTexts {
  const StoreTexts([this.values = const {}]);

  final Map<StoreField, String> values;

  String operator [](StoreField f) => values[f] ?? '';

  StoreTexts copyWith(StoreField field, String value) =>
      StoreTexts({...values, field: value});

  /// Champs qui dépassent leur limite.
  List<StoreField> get overLimit => [
    for (final f in StoreField.values)
      if (this[f].characters > f.limit) f,
  ];

  bool get isEmpty => values.values.every((v) => v.trim().isEmpty);

  Map<String, Object?> toJson() => {
    for (final e in values.entries) e.key.name: e.value,
  };

  factory StoreTexts.fromJson(Map<String, Object?> json) => StoreTexts({
    for (final f in StoreField.values)
      if (json[f.name] is String) f: json[f.name]! as String,
  });

  /// Schéma JSON demandé au LLM (tous les champs obligatoires).
  static Map<String, Object?> get schema => {
    'type': 'object',
    'additionalProperties': false,
    'required': [for (final f in StoreField.values) f.name],
    'properties': {
      for (final f in StoreField.values) f.name: {'type': 'string'},
    },
  };
}

extension on String {
  /// Nombre de caractères visibles (les emojis comptent pour un).
  int get characters => runes.length;
}

/// Longueur affichée par les compteurs de l'interface.
int visibleLength(String s) => s.characters;
