/// Fournisseurs LLM pris en charge.
///
/// [defaultModel] n'est qu'un point de départ modifiable dans les paramètres :
/// le test de connexion indique si le compte y a réellement accès.
enum LlmProviderId {
  anthropic(
    label: 'Anthropic Claude',
    keyConsoleUrl: 'https://console.anthropic.com/settings/keys',
    defaultModel: 'claude-opus-5-5',
  ),
  openai(
    label: 'OpenAI',
    keyConsoleUrl: 'https://platform.openai.com/api-keys',
    defaultModel: 'gpt-5',
  ),
  gemini(
    label: 'Google Gemini',
    keyConsoleUrl: 'https://aistudio.google.com/apikey',
    defaultModel: 'gemini-2.5-pro',
  ),
  mistral(
    label: 'Mistral AI',
    keyConsoleUrl: 'https://console.mistral.ai/api-keys',
    defaultModel: 'mistral-large-latest',
  );

  const LlmProviderId({
    required this.label,
    required this.keyConsoleUrl,
    required this.defaultModel,
  });

  final String label;
  final String keyConsoleUrl;
  final String defaultModel;
}
