import '../../domain/llm_provider_id.dart';
import '../../domain/llm_types.dart';
import '../http_llm_provider.dart';

/// Base commune à OpenAI et Mistral, dont les API « chat completions »
/// ont la même forme.
abstract class ChatCompletionsProvider extends HttpLlmProvider {
  ChatCompletionsProvider({
    required super.apiKey,
    required super.model,
    required super.client,
    required this.baseUrl,
  });

  final Uri baseUrl;

  Map<String, String> get authHeaders => {'authorization': 'Bearer $apiKey'};

  /// Corps propre au fournisseur : format de réponse et limite de sortie.
  Map<String, Object?> requestBody(LlmRequest request);

  @override
  Future<ConnectionReport> testConnection({CancellationToken? cancel}) async {
    final watch = Stopwatch()..start();
    final r = await sendJson(
      'GET',
      baseUrl.resolve('models'),
      headers: authHeaders,
      timeout: HttpLlmProvider.connectionTimeout,
      cancel: cancel,
    );
    final data = r.body['data'];
    return ConnectionReport(
      provider: id,
      configuredModel: model,
      availableModels: [
        if (data is List)
          for (final m in data)
            if (m is Map && m['id'] is String) m['id'] as String,
      ]..sort(),
      latency: watch.elapsed,
    );
  }

  @override
  Future<LlmResult> generateStructured(
    LlmRequest request, {
    CancellationToken? cancel,
  }) async {
    final watch = Stopwatch()..start();
    final r = await sendJson(
      'POST',
      baseUrl.resolve('chat/completions'),
      headers: authHeaders,
      body: requestBody(request),
      timeout: request.timeout,
      cancel: cancel,
    );
    final body = r.body;
    final choices = body['choices'];
    final choice = choices is List && choices.isNotEmpty && choices.first is Map
        ? (choices.first as Map)
        : const {};
    final message = choice['message'] is Map
        ? choice['message'] as Map
        : const {};

    if (message['refusal'] != null) {
      throw const LlmException(LlmErrorKind.refused);
    }
    switch (choice['finish_reason']) {
      case 'length':
        throw const LlmException(LlmErrorKind.truncated);
      case 'content_filter':
        throw const LlmException(LlmErrorKind.refused);
    }
    final content = message['content'];
    if (content is! String) {
      throw const LlmException(LlmErrorKind.invalidResponse);
    }
    final usage = body['usage'];
    return LlmResult(
      provider: id,
      model: body['model']?.toString() ?? model,
      data: parseStructured(content, request),
      usage: usage is Map
          ? LlmUsage(
              inputTokens: HttpLlmProvider.asInt(usage['prompt_tokens']) ?? 0,
              outputTokens:
                  HttpLlmProvider.asInt(usage['completion_tokens']) ?? 0,
            )
          : null,
      elapsed: watch.elapsed,
    );
  }
}

class OpenAiProvider extends ChatCompletionsProvider {
  OpenAiProvider({
    required super.apiKey,
    required super.model,
    required super.client,
    Uri? baseUrl,
  }) : super(baseUrl: baseUrl ?? Uri.parse('https://api.openai.com/v1/'));

  @override
  LlmProviderId get id => LlmProviderId.openai;

  @override
  Map<String, Object?> requestBody(LlmRequest request) => {
    'model': model,
    'messages': [
      {'role': 'system', 'content': request.system},
      {'role': 'user', 'content': request.userContent},
    ],
    'max_completion_tokens': request.maxOutputTokens,
    // Sortie contrainte par le schéma (mode strict).
    'response_format': {
      'type': 'json_schema',
      'json_schema': {
        'name': request.schemaName,
        'schema': request.schema,
        'strict': true,
      },
    },
  };

  @override
  LlmException mapError(int status, Map<String, Object?> body) {
    final error = body['error'];
    // Quota épuisé : 429 chez OpenAI, mais ce n'est pas une limite de débit.
    if (error is Map && error['code'] == 'insufficient_quota') {
      return LlmException(
        LlmErrorKind.billing,
        statusCode: status,
        detail: safeDetail(body),
      );
    }
    if (error is Map && error['code'] == 'model_not_found') {
      return LlmException(
        LlmErrorKind.modelNotFound,
        statusCode: status,
        detail: safeDetail(body),
      );
    }
    return super.mapError(status, body);
  }
}

class MistralProvider extends ChatCompletionsProvider {
  MistralProvider({
    required super.apiKey,
    required super.model,
    required super.client,
    Uri? baseUrl,
  }) : super(baseUrl: baseUrl ?? Uri.parse('https://api.mistral.ai/v1/'));

  @override
  LlmProviderId get id => LlmProviderId.mistral;

  @override
  Map<String, Object?> requestBody(LlmRequest request) => {
    'model': model,
    'messages': [
      {
        'role': 'system',
        'content':
            '${request.system}\n\n${HttpLlmProvider.schemaInstruction(request)}',
      },
      {'role': 'user', 'content': request.userContent},
    ],
    'max_tokens': request.maxOutputTokens,
    // Mode JSON ; le respect du schéma est vérifié côté client.
    'response_format': {'type': 'json_object'},
  };
}
