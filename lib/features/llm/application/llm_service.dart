import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../settings/application/api_keys_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../../../core/storage/secret_store.dart';
import '../../settings/data/api_key_repository.dart';
import '../data/llm_provider_factory.dart';
import '../domain/llm_provider_id.dart';
import '../domain/llm_types.dart';
import '../domain/prompt_builder.dart';

/// Confirmation donnée par l'utilisateur pour UN envoi précis.
@immutable
class LlmConsent {
  const LlmConsent._(this.id, this.digest);
  final String id;
  final String digest;
}

/// La confirmation manque, a déjà servi ou ne correspond pas au contenu.
class ConsentException implements Exception {
  const ConsentException();
}

/// Point d'entrée unique vers les fournisseurs. Lit la clé au dernier moment
/// et ne l'expose jamais ; refuse tout envoi sans confirmation valide.
class LlmService {
  LlmService({
    required this._keys,
    required this._client,
    required this._modelFor,
  });

  final ApiKeyRepository _keys;
  final http.Client _client;
  final String Function(LlmProviderId) _modelFor;
  final _pending = <String, String>{};
  final _random = Random.secure();

  String modelFor(LlmProviderId provider) => _modelFor(provider);

  /// À appeler uniquement quand l'utilisateur a confirmé l'aperçu.
  LlmConsent grantConsent(LlmPayload payload) {
    final id = List.generate(
      16,
      (_) => _random.nextInt(256),
    ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    _pending[id] = payload.digest;
    return LlmConsent._(id, payload.digest);
  }

  Future<ConnectionReport> testConnection(
    LlmProviderId id, {
    CancellationToken? cancel,
  }) async {
    final provider = await _provider(id, _modelFor(id));
    return provider.testConnection(cancel: cancel);
  }

  /// Envoie [payload] si [consent] a été donné pour ce contenu exact et n'a
  /// pas encore servi. La confirmation est consommée même en cas d'échec.
  Future<LlmResult> send(
    LlmPayload payload,
    LlmConsent consent, {
    CancellationToken? cancel,
  }) async {
    final expected = _pending.remove(consent.id);
    if (expected == null ||
        expected != payload.digest ||
        consent.digest != payload.digest) {
      throw const ConsentException();
    }
    final provider = await _provider(payload.provider, payload.model);
    return provider.generateStructured(payload.toRequest(), cancel: cancel);
  }

  Future<LlmProvider> _provider(LlmProviderId id, String model) async {
    final String? key;
    try {
      key = await _keys.readKey(id);
    } on SecretStoreUnavailableException {
      throw const LlmException(LlmErrorKind.keyringUnavailable);
    }
    if (key == null || key.isEmpty) {
      throw const LlmException(LlmErrorKind.missingKey);
    }
    return createLlmProvider(id, apiKey: key, model: model, client: _client);
  }
}

/// Client HTTP partagé, remplacé par un client simulé dans les tests.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// Modèle choisi par fournisseur, mémorisé dans les préférences.
final llmModelsProvider =
    NotifierProvider<LlmModelsController, Map<LlmProviderId, String>>(
      LlmModelsController.new,
    );

class LlmModelsController extends Notifier<Map<LlmProviderId, String>> {
  static String prefsKey(LlmProviderId id) => 'lp.llmModel.${id.name}';

  @override
  Map<LlmProviderId, String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return {
      for (final id in LlmProviderId.values)
        id: prefs.getString(prefsKey(id)) ?? id.defaultModel,
    };
  }

  /// Une valeur vide rétablit le modèle par défaut.
  Future<void> setModel(LlmProviderId id, String model) async {
    final value = model.trim();
    final prefs = ref.read(sharedPreferencesProvider);
    if (value.isEmpty || value == id.defaultModel) {
      await prefs.remove(prefsKey(id));
      state = {...state, id: id.defaultModel};
    } else {
      await prefs.setString(prefsKey(id), value);
      state = {...state, id: value};
    }
  }
}

final llmServiceProvider = Provider<LlmService>(
  (ref) => LlmService(
    keys: ref.watch(apiKeyRepositoryProvider),
    client: ref.watch(httpClientProvider),
    modelFor: (id) => ref.read(llmModelsProvider)[id]!,
  ),
);
