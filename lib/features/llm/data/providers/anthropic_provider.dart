import '../../domain/llm_provider_id.dart';
import '../../domain/llm_types.dart';
import '../http_llm_provider.dart';

/// API Messages d'Anthropic (HTTP brut : pas de SDK officiel pour Dart).
class AnthropicProvider extends HttpLlmProvider {
  AnthropicProvider({
    required super.apiKey,
    required super.model,
    required super.client,
    Uri? baseUrl,
  }) : _base = baseUrl ?? Uri.parse('https://api.anthropic.com');

  final Uri _base;

  /// Modèles acceptant `output_config.effort` et le repli serveur
  /// `fallbacks: "default"` en cas de refus de sécurité.
  static const _modernModels = {
    'claude-fable-5-1',
    'claude-opus-5-5',
    'claude-opus-5',
    'claude-sonnet-5-5',
  };

  static const fallbackBeta = 'server-side-fallback-2026-07-01';

  @override
  LlmProviderId get id => LlmProviderId.anthropic;

  bool get _modern => _modernModels.contains(model);

  Map<String, String> get _headers => {
    'x-api-key': apiKey,
    'anthropic-version': '2023-06-01',
    if (_modern) 'anthropic-beta': fallbackBeta,
  };

  @override
  Future<ConnectionReport> testConnection({CancellationToken? cancel}) async {
    final watch = Stopwatch()..start();
    final r = await sendJson(
      'GET',
      _base.resolve('/v1/models?limit=1000'),
      headers: {'x-api-key': apiKey, 'anthropic-version': '2023-06-01'},
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
      ],
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
      _base.resolve('/v1/messages'),
      headers: _headers,
      body: {
        'model': model,
        'max_tokens': request.maxOutputTokens,
        'system': request.system,
        'messages': [
          {'role': 'user', 'content': request.userContent},
        ],
        'output_config': {
          'format': {'type': 'json_schema', 'schema': request.schema},
          if (_modern) 'effort': 'medium',
        },
        if (_modern) 'fallbacks': 'default',
      },
      timeout: request.timeout,
      cancel: cancel,
    );
    final body = r.body;
    switch (body['stop_reason']) {
      case 'refusal':
        throw const LlmException(LlmErrorKind.refused);
      case 'max_tokens':
        throw const LlmException(LlmErrorKind.truncated);
    }
    final content = body['content'];
    final text = [
      if (content is List)
        for (final block in content)
          if (block is Map && block['type'] == 'text') '${block['text']}',
    ].join();
    final usage = body['usage'];
    return LlmResult(
      provider: id,
      model: body['model']?.toString() ?? model,
      data: parseStructured(text, request),
      usage: usage is Map
          ? LlmUsage(
              inputTokens: HttpLlmProvider.asInt(usage['input_tokens']) ?? 0,
              outputTokens: HttpLlmProvider.asInt(usage['output_tokens']) ?? 0,
            )
          : null,
      elapsed: watch.elapsed,
    );
  }
}
