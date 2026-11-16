import '../../../core/storage/secret_store.dart';
import '../../llm/domain/llm_provider_id.dart';

enum ApiKeyIssue { empty, tooShort, tooLong, invalidCharacters }

class InvalidApiKeyException implements Exception {
  const InvalidApiKeyException(this.issue);
  final ApiKeyIssue issue;

  @override
  String toString() => 'InvalidApiKeyException(${issue.name})';
}

/// Contrôle de forme uniquement : la validité réelle d'une clé ne peut être
/// établie qu'avec un test de connexion (phase 3).
abstract final class ApiKeyValidator {
  static const minLength = 20;
  static const maxLength = 512;
  static final _printableNoSpace = RegExp(r'^[\x21-\x7E]+$');

  static ApiKeyIssue? validate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return ApiKeyIssue.empty;
    if (!_printableNoSpace.hasMatch(value)) {
      return ApiKeyIssue.invalidCharacters;
    }
    if (value.length < minLength) return ApiKeyIssue.tooShort;
    if (value.length > maxLength) return ApiKeyIssue.tooLong;
    return null;
  }
}

/// Gère les clés API des fournisseurs LLM dans le [SecretStore].
/// Seul `LlmService` lit une clé, au moment d'un appel : l'interface ne la
/// reçoit jamais.
class ApiKeyRepository {
  ApiKeyRepository(this._store);

  final SecretStore _store;

  static String storageKeyFor(LlmProviderId provider) =>
      'launchpilot.llm.${provider.name}.api_key';

  Future<bool> hasKey(LlmProviderId provider) =>
      _store.contains(storageKeyFor(provider));

  Future<void> saveKey(LlmProviderId provider, String raw) async {
    final issue = ApiKeyValidator.validate(raw);
    if (issue != null) throw InvalidApiKeyException(issue);
    await _store.write(storageKeyFor(provider), raw.trim());
  }

  Future<void> deleteKey(LlmProviderId provider) =>
      _store.delete(storageKeyFor(provider));

  Future<String?> readKey(LlmProviderId provider) =>
      _store.read(storageKeyFor(provider));
}
