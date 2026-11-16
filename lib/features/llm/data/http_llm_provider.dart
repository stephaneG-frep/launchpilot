import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/json_schema_check.dart';
import '../domain/llm_provider_id.dart';
import '../domain/llm_types.dart';
import '../../../core/security/secret_redactor.dart';

/// Réponse HTTP décodée.
typedef JsonResponse = ({int status, Map<String, Object?> body});

/// Socle commun des adaptateurs : envoi HTTP avec délai et annulation,
/// traduction des erreurs, extraction et validation du JSON produit.
abstract class HttpLlmProvider implements LlmProvider {
  HttpLlmProvider({
    required this.apiKey,
    required this.model,
    required this._client,
  });

  final String apiKey;
  @override
  final String model;
  final http.Client _client;

  static const connectionTimeout = Duration(seconds: 20);

  @override
  LlmProviderId get id;

  // ------------------------------------------------------------- transport

  Future<JsonResponse> sendJson(
    String method,
    Uri url, {
    required Map<String, String> headers,
    Object? body,
    required Duration timeout,
    CancellationToken? cancel,
  }) async {
    if (cancel?.isCancelled ?? false) {
      throw const LlmException(LlmErrorKind.cancelled);
    }
    final abort = Completer<void>();
    LlmErrorKind? interruption;
    void interrupt(LlmErrorKind kind) {
      if (abort.isCompleted) return;
      interruption = kind;
      abort.complete();
    }

    final timer = Timer(timeout, () => interrupt(LlmErrorKind.timeout));
    unawaited(
      cancel?.whenCancelled.then((_) => interrupt(LlmErrorKind.cancelled)),
    );

    final request = http.AbortableRequest(
      method,
      url,
      abortTrigger: abort.future,
    )..headers.addAll(headers);
    if (body != null) {
      request
        ..headers['content-type'] = 'application/json'
        ..body = jsonEncode(body);
    }

    try {
      final sending = _client.send(request).then(http.Response.fromStream);
      final response = await Future.any<http.Response?>([
        sending,
        abort.future.then((_) => null),
      ]);
      if (response == null) {
        sending.ignore();
        throw LlmException(interruption!);
      }
      final decoded = _decode(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw mapError(response.statusCode, decoded);
      }
      return (status: response.statusCode, body: decoded);
    } on http.RequestAbortedException {
      throw LlmException(interruption ?? LlmErrorKind.cancelled);
    } on SocketException {
      throw LlmException(interruption ?? LlmErrorKind.network);
    } on http.ClientException {
      throw LlmException(interruption ?? LlmErrorKind.network);
    } on HandshakeException {
      throw const LlmException(LlmErrorKind.network);
    } finally {
      timer.cancel();
    }
  }

  Map<String, Object?> _decode(http.Response response) {
    if (response.body.isEmpty) return const {};
    try {
      final value = jsonDecode(utf8.decode(response.bodyBytes));
      return value is Map ? value.cast<String, Object?>() : {'value': value};
    } on FormatException {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        throw const LlmException(LlmErrorKind.invalidResponse);
      }
      return const {};
    }
  }

  // ------------------------------------------------------------- erreurs

  /// Message d'erreur du fournisseur, s'il en donne un.
  String? errorMessage(Map<String, Object?> body) {
    final error = body['error'];
    if (error is Map) return error['message']?.toString();
    if (error is String) return error;
    return body['message']?.toString() ?? body['detail']?.toString();
  }

  /// Traduction d'un statut HTTP ; les adaptateurs affinent si besoin.
  LlmException mapError(int status, Map<String, Object?> body) {
    final kind = switch (status) {
      400 => LlmErrorKind.badRequest,
      401 => LlmErrorKind.invalidKey,
      402 => LlmErrorKind.billing,
      403 => LlmErrorKind.permissionDenied,
      404 => LlmErrorKind.modelNotFound,
      408 => LlmErrorKind.timeout,
      413 => LlmErrorKind.requestTooLarge,
      422 => LlmErrorKind.badRequest,
      429 => LlmErrorKind.rateLimited,
      503 || 529 => LlmErrorKind.overloaded,
      >= 500 => LlmErrorKind.serverError,
      _ => LlmErrorKind.badRequest,
    };
    return LlmException(kind, statusCode: status, detail: safeDetail(body));
  }

  /// Détail lisible, sans la clé ni aucun secret, borné en longueur.
  String? safeDetail(Map<String, Object?> body) {
    final message = errorMessage(body);
    if (message == null || message.isEmpty) return null;
    final clean = SecretRedactor.redactKnown(message, [apiKey]);
    return clean.length > 300 ? '${clean.substring(0, 300)}…' : clean;
  }

  // ------------------------------------------------------------- réponses

  /// Extrait l'objet JSON d'un texte (éventuellement entouré de ```json)
  /// puis le valide contre le schéma demandé.
  Map<String, Object?> parseStructured(String text, LlmRequest request) {
    var candidate = text.trim();
    final fenced = RegExp(r'^```[a-zA-Z]*\s*([\s\S]*?)\s*```$')
        .firstMatch(candidate);
    if (fenced != null) candidate = fenced[1]!;
    Object? value;
    try {
      value = jsonDecode(candidate);
    } on FormatException {
      throw const LlmException(
        LlmErrorKind.invalidResponse,
        detail: 'JSON illisible',
      );
    }
    if (value is! Map) {
      throw const LlmException(
        LlmErrorKind.invalidResponse,
        detail: 'Un objet JSON était attendu',
      );
    }
    final errors = checkJsonSchema(value, request.schema);
    if (errors.isNotEmpty) {
      throw LlmException(
        LlmErrorKind.invalidResponse,
        detail: errors.take(3).join(' ; '),
      );
    }
    return value.cast<String, Object?>();
  }

  /// Consigne ajoutée pour les fournisseurs sans contrainte de schéma native.
  static String schemaInstruction(LlmRequest request) =>
      'Réponds uniquement avec un objet JSON valide, sans texte autour, '
      'conforme à ce schéma JSON (${request.schemaName}) :\n'
      '${jsonEncode(request.schema)}';

  static int? asInt(Object? v) => v is num ? v.toInt() : null;
}
