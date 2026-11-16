import 'package:flutter/foundation.dart';

import '../../../core/domain/cancellation.dart';
import 'llm_provider_id.dart';

export '../../../core/domain/cancellation.dart';

/// Nature d'un échec, traduite en message clair par l'interface.
enum LlmErrorKind {
  missingKey,
  invalidKey,
  permissionDenied,
  billing,
  modelNotFound,
  badRequest,
  requestTooLarge,
  rateLimited,
  overloaded,
  serverError,
  timeout,
  cancelled,
  network,
  invalidResponse,
  refused,
  truncated,

  /// Trousseau du système verrouillé ou indisponible : la clé est illisible.
  keyringUnavailable,
}

class LlmException implements Exception {
  const LlmException(this.kind, {this.statusCode, this.detail});

  final LlmErrorKind kind;
  final int? statusCode;

  /// Message technique du fournisseur, déjà débarrassé de tout secret.
  final String? detail;

  /// Vaut la peine de réessayer plus tard.
  bool get isTransient => const {
    LlmErrorKind.rateLimited,
    LlmErrorKind.overloaded,
    LlmErrorKind.serverError,
    LlmErrorKind.timeout,
    LlmErrorKind.network,
  }.contains(kind);

  @override
  String toString() =>
      'LlmException(${kind.name}${statusCode == null ? '' : ', $statusCode'})';
}

/// Demande de génération structurée. [userContent] doit déjà avoir été
/// minimisé et nettoyé par `PromptBuilder`.
@immutable
class LlmRequest {
  const LlmRequest({
    required this.system,
    required this.userContent,
    required this.schemaName,
    required this.schema,
    this.maxOutputTokens = 16000,
    this.timeout = const Duration(seconds: 90),
  });

  final String system;
  final String userContent;
  final String schemaName;

  /// Sous-ensemble de JSON Schema accepté par les quatre fournisseurs :
  /// objets avec `additionalProperties: false`, tableaux, chaînes, nombres,
  /// booléens, `enum`.
  final Map<String, Object?> schema;
  final int maxOutputTokens;
  final Duration timeout;
}

@immutable
class LlmUsage {
  const LlmUsage({required this.inputTokens, required this.outputTokens});

  final int inputTokens;
  final int outputTokens;

  int get total => inputTokens + outputTokens;
}

@immutable
class LlmResult {
  const LlmResult({
    required this.provider,
    required this.model,
    required this.data,
    this.usage,
    required this.elapsed,
  });

  final LlmProviderId provider;

  /// Modèle ayant réellement répondu (il peut différer en cas de repli).
  final String model;
  final Map<String, Object?> data;
  final LlmUsage? usage;
  final Duration elapsed;
}

@immutable
class ConnectionReport {
  const ConnectionReport({
    required this.provider,
    required this.configuredModel,
    required this.availableModels,
    required this.latency,
  });

  final LlmProviderId provider;
  final String configuredModel;
  final List<String> availableModels;
  final Duration latency;

  bool get configuredModelAvailable =>
      availableModels.contains(configuredModel);
}

/// Interface commune des fournisseurs. Aucune implémentation n'a accès au
/// shell ni au disque : elles ne font que des appels HTTP.
abstract interface class LlmProvider {
  LlmProviderId get id;
  String get model;

  /// Vérifie la clé en listant les modèles : ne consomme aucun jeton.
  Future<ConnectionReport> testConnection({CancellationToken? cancel});

  /// Réponse JSON conforme à [LlmRequest.schema], validée côté client.
  Future<LlmResult> generateStructured(
    LlmRequest request, {
    CancellationToken? cancel,
  });
}
