import '../../domain/llm_provider_id.dart';
import '../../domain/llm_types.dart';
import '../http_llm_provider.dart';

/// API Gemini (Google AI Studio). La clé passe dans un en-tête, jamais
/// dans l'URL, pour ne pas apparaître dans des journaux d'accès.
class GeminiProvider extends HttpLlmProvider {
  GeminiProvider({
    required super.apiKey,
    required super.model,
    required super.client,
    Uri? baseUrl,
  }) : _base =
           baseUrl ??
           Uri.parse('https://generativelanguage.googleapis.com/v1beta/');

  final Uri _base;

  static const _blockedReasons = {
    'SAFETY',
    'RECITATION',
    'BLOCKLIST',
    'PROHIBITED_CONTENT',
    'SPII',
  };

  @override
  LlmProviderId get id => LlmProviderId.gemini;

  Map<String, String> get _headers => {'x-goog-api-key': apiKey};

  @override
  Future<ConnectionReport> testConnection({CancellationToken? cancel}) async {
    final watch = Stopwatch()..start();
    final r = await sendJson(
      'GET',
      _base.resolve('models?pageSize=1000'),
      headers: _headers,
      timeout: HttpLlmProvider.connectionTimeout,
      cancel: cancel,
    );
    final models = r.body['models'];
    return ConnectionReport(
      provider: id,
      configuredModel: model,
      availableModels: [
        if (models is List)
          for (final m in models)
            if (m is Map && m['name'] is String)
              (m['name'] as String).replaceFirst('models/', ''),
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
      _base.resolve('models/${Uri.encodeComponent(model)}:generateContent'),
      headers: _headers,
      body: {
        'systemInstruction': {
          'parts': [
            {
              'text':
                  '${request.system}\n\n${HttpLlmProvider.schemaInstruction(request)}',
            },
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': request.userContent},
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'maxOutputTokens': request.maxOutputTokens,
        },
      },
      timeout: request.timeout,
      cancel: cancel,
    );
    final body = r.body;
    final feedback = body['promptFeedback'];
    if (feedback is Map && feedback['blockReason'] != null) {
      throw const LlmException(LlmErrorKind.refused);
    }
    final candidates = body['candidates'];
    final candidate =
        candidates is List && candidates.isNotEmpty && candidates.first is Map
        ? candidates.first as Map
        : const {};
    final finish = candidate['finishReason'];
    if (finish == 'MAX_TOKENS') {
      throw const LlmException(LlmErrorKind.truncated);
    }
    if (_blockedReasons.contains(finish)) {
      throw const LlmException(LlmErrorKind.refused);
    }
    final content = candidate['content'];
    final parts = content is Map ? content['parts'] : null;
    final text = [
      if (parts is List)
        for (final p in parts)
          if (p is Map && p['text'] is String && p['thought'] != true)
            p['text'] as String,
    ].join();
    if (text.isEmpty) throw const LlmException(LlmErrorKind.invalidResponse);

    final usage = body['usageMetadata'];
    return LlmResult(
      provider: id,
      model: body['modelVersion']?.toString() ?? model,
      data: parseStructured(text, request),
      usage: usage is Map
          ? LlmUsage(
              inputTokens:
                  HttpLlmProvider.asInt(usage['promptTokenCount']) ?? 0,
              outputTokens:
                  HttpLlmProvider.asInt(usage['candidatesTokenCount']) ?? 0,
            )
          : null,
      elapsed: watch.elapsed,
    );
  }

  @override
  LlmException mapError(int status, Map<String, Object?> body) {
    // Gemini renvoie 400 (et non 401) pour une clé invalide.
    final error = body['error'];
    final details = error is Map ? error['details'] : null;
    final invalidKey =
        details is List &&
        details.any((d) => d is Map && d['reason'] == 'API_KEY_INVALID');
    final message = errorMessage(body) ?? '';
    if (invalidKey || message.contains('API key not valid')) {
      return LlmException(
        LlmErrorKind.invalidKey,
        statusCode: status,
        detail: safeDetail(body),
      );
    }
    return super.mapError(status, body);
  }
}
