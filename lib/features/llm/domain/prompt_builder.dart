import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'llm_provider_id.dart';
import 'llm_types.dart';
import '../../../core/security/secret_redactor.dart';

/// Élément de contexte choisi explicitement par l'utilisateur.
@immutable
class ContextItem {
  const ContextItem({required this.label, required this.content, this.path});

  final String label;
  final String content;

  /// Fichier d'origine, pour exclure les fichiers sensibles.
  final String? path;
}

class PayloadTooLargeException implements Exception {
  const PayloadTooLargeException(this.characters, this.maximum);
  final int characters;
  final int maximum;
}

/// Contenu exact qui partira chez le fournisseur, tel que montré dans
/// l'aperçu. Son [digest] lie une confirmation à ce contenu précis.
@immutable
class LlmPayload {
  const LlmPayload({
    required this.provider,
    required this.model,
    required this.system,
    required this.userContent,
    required this.schemaName,
    required this.schema,
    required this.redactions,
    required this.excludedFiles,
    required this.includesProjectData,
    required this.digest,
  });

  final LlmProviderId provider;
  final String model;
  final String system;
  final String userContent;
  final String schemaName;
  final Map<String, Object?> schema;
  final Map<SecretKind, int> redactions;
  final List<String> excludedFiles;
  final bool includesProjectData;
  final String digest;

  int get redactionCount => redactions.values.fold(0, (a, b) => a + b);

  /// Estimation grossière (≈ 4 caractères par jeton), pour information.
  int get approxInputTokens =>
      ((system.length + userContent.length) / 4).ceil();

  LlmRequest toRequest({Duration timeout = const Duration(seconds: 90)}) =>
      LlmRequest(
        system: system,
        userContent: userContent,
        schemaName: schemaName,
        schema: schema,
        timeout: timeout,
      );
}

/// Construit un envoi minimal : seulement la consigne et les éléments
/// sélectionnés, fichiers sensibles exclus, secrets masqués. Un contenu trop
/// long est refusé plutôt que tronqué en silence.
abstract final class PromptBuilder {
  static const maxCharacters = 60000;

  static LlmPayload build({
    required LlmProviderId provider,
    required String model,
    required String system,
    required String instruction,
    required String schemaName,
    required Map<String, Object?> schema,
    List<ContextItem> items = const [],
  }) {
    final counts = <SecretKind, int>{};
    final excluded = <String>[];

    String clean(String text) {
      final r = SecretRedactor.redact(text);
      r.counts.forEach((k, v) => counts[k] = (counts[k] ?? 0) + v);
      return r.text;
    }

    final buffer = StringBuffer(clean(instruction.trim()));
    for (final item in items) {
      final path = item.path;
      if (path != null && SecretRedactor.isSensitiveFile(path)) {
        excluded.add(path);
        continue;
      }
      buffer
        ..write('\n\n### ${item.label}')
        ..write(path == null ? '' : ' ($path)')
        ..write('\n```\n')
        ..write(clean(item.content))
        ..write('\n```');
    }
    final user = buffer.toString();
    final cleanSystem = clean(system.trim());
    final size = cleanSystem.length + user.length;
    if (size > maxCharacters) {
      throw PayloadTooLargeException(size, maxCharacters);
    }

    final digest = sha256
        .convert(
          utf8.encode(
            jsonEncode([
              provider.name,
              model,
              cleanSystem,
              user,
              schemaName,
              schema,
            ]),
          ),
        )
        .toString();

    return LlmPayload(
      provider: provider,
      model: model,
      system: cleanSystem,
      userContent: user,
      schemaName: schemaName,
      schema: schema,
      redactions: Map.unmodifiable(counts),
      excludedFiles: List.unmodifiable(excluded),
      includesProjectData: items.isNotEmpty,
      digest: digest,
    );
  }
}
