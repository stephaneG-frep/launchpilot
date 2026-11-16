import 'package:http/http.dart' as http;

import '../domain/llm_provider_id.dart';
import '../domain/llm_types.dart';
import 'providers/anthropic_provider.dart';
import 'providers/gemini_provider.dart';
import 'providers/openai_compatible.dart';

LlmProvider createLlmProvider(
  LlmProviderId id, {
  required String apiKey,
  required String model,
  required http.Client client,
}) => switch (id) {
  LlmProviderId.anthropic => AnthropicProvider(
    apiKey: apiKey,
    model: model,
    client: client,
  ),
  LlmProviderId.openai => OpenAiProvider(
    apiKey: apiKey,
    model: model,
    client: client,
  ),
  LlmProviderId.gemini => GeminiProvider(
    apiKey: apiKey,
    model: model,
    client: client,
  ),
  LlmProviderId.mistral => MistralProvider(
    apiKey: apiKey,
    model: model,
    client: client,
  ),
};
