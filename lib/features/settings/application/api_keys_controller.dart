import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secret_store.dart';
import '../../llm/domain/llm_provider_id.dart';
import '../data/api_key_repository.dart';

final secretStoreProvider = Provider<SecretStore>((ref) => SystemSecretStore());

final apiKeyRepositoryProvider = Provider<ApiKeyRepository>(
  (ref) => ApiKeyRepository(ref.watch(secretStoreProvider)),
);

/// Pas de nouvelle tentative automatique : si le trousseau est indisponible,
/// l'utilisateur doit voir l'erreur plutôt qu'un chargement sans fin.
final apiKeysControllerProvider =
    AsyncNotifierProvider<ApiKeysController, ApiKeysState>(
      ApiKeysController.new,
      retry: (_, _) => null,
    );

/// Indique seulement quels fournisseurs ont une clé : jamais la clé elle-même.
@immutable
class ApiKeysState {
  const ApiKeysState(this._stored);

  final Map<LlmProviderId, bool> _stored;

  bool hasKey(LlmProviderId provider) => _stored[provider] ?? false;

  ApiKeysState withKeyStatus(LlmProviderId provider, bool stored) =>
      ApiKeysState({..._stored, provider: stored});
}

class ApiKeysController extends AsyncNotifier<ApiKeysState> {
  ApiKeyRepository get _repo => ref.read(apiKeyRepositoryProvider);

  @override
  Future<ApiKeysState> build() async {
    final repo = ref.watch(apiKeyRepositoryProvider);
    final stored = <LlmProviderId, bool>{};
    for (final provider in LlmProviderId.values) {
      stored[provider] = await repo.hasKey(provider);
    }
    return ApiKeysState(stored);
  }

  /// Lève [InvalidApiKeyException] ou [SecretStoreUnavailableException].
  Future<void> save(LlmProviderId provider, String rawKey) async {
    await _repo.saveKey(provider, rawKey);
    _markStored(provider, true);
  }

  /// Lève [SecretStoreUnavailableException] si le trousseau est inaccessible.
  Future<void> delete(LlmProviderId provider) async {
    await _repo.deleteKey(provider);
    _markStored(provider, false);
  }

  void _markStored(LlmProviderId provider, bool stored) {
    final current = state.value ?? const ApiKeysState({});
    state = AsyncData(current.withKeyStatus(provider, stored));
  }
}
