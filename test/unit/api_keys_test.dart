import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/storage/secret_store.dart';
import 'package:launchpilot/features/llm/domain/llm_provider_id.dart';
import 'package:launchpilot/features/settings/application/api_keys_controller.dart';
import 'package:launchpilot/features/settings/data/api_key_repository.dart';

import '../support/test_harness.dart';

/// Clé fictive au format plausible ; ce n'est pas une vraie clé.
const fakeKey = 'sk-test-0000000000000000000000000000';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiKeyValidator', () {
    test('accepte une clé plausible', () {
      expect(ApiKeyValidator.validate(fakeKey), isNull);
      expect(ApiKeyValidator.validate('  $fakeKey \n'), isNull);
    });

    test('rejette les saisies invalides', () {
      expect(ApiKeyValidator.validate(''), ApiKeyIssue.empty);
      expect(ApiKeyValidator.validate('   '), ApiKeyIssue.empty);
      expect(ApiKeyValidator.validate('sk-court'), ApiKeyIssue.tooShort);
      expect(
        ApiKeyValidator.validate('sk-test 0000000000000000000000'),
        ApiKeyIssue.invalidCharacters,
      );
      expect(
        ApiKeyValidator.validate('sk-test-​000000000000000000000'),
        ApiKeyIssue.invalidCharacters,
      );
      expect(
        ApiKeyValidator.validate('a' * (ApiKeyValidator.maxLength + 1)),
        ApiKeyIssue.tooLong,
      );
    });
  });

  group('ApiKeyRepository', () {
    test(
      'enregistre la clé nettoyée sous un identifiant par fournisseur',
      () async {
        final store = InMemorySecretStore();
        final repo = ApiKeyRepository(store);

        await repo.saveKey(LlmProviderId.anthropic, '  $fakeKey  ');

        expect(store.values, {
          ApiKeyRepository.storageKeyFor(LlmProviderId.anthropic): fakeKey,
        });
        expect(await repo.hasKey(LlmProviderId.anthropic), isTrue);
        expect(await repo.hasKey(LlmProviderId.openai), isFalse);
      },
    );

    test('n\'écrit rien si la clé est invalide', () async {
      final store = InMemorySecretStore();
      final repo = ApiKeyRepository(store);
      await expectLater(
        repo.saveKey(LlmProviderId.openai, 'trop court'),
        throwsA(isA<InvalidApiKeyException>()),
      );
      expect(store.values, isEmpty);
    });

    test('supprime uniquement la clé du fournisseur visé', () async {
      final store = InMemorySecretStore();
      final repo = ApiKeyRepository(store);
      await repo.saveKey(LlmProviderId.gemini, fakeKey);
      await repo.saveKey(LlmProviderId.mistral, fakeKey);

      await repo.deleteKey(LlmProviderId.gemini);

      expect(await repo.hasKey(LlmProviderId.gemini), isFalse);
      expect(await repo.hasKey(LlmProviderId.mistral), isTrue);
    });
  });

  group('ApiKeysController', () {
    ProviderContainer containerWith(InMemorySecretStore store) {
      final c = ProviderContainer(
        overrides: [secretStoreProvider.overrideWithValue(store)],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('expose seulement la présence des clés', () async {
      final store = InMemorySecretStore()
        ..values[ApiKeyRepository.storageKeyFor(LlmProviderId.openai)] =
            fakeKey;
      final c = containerWith(store);

      final state = await c.read(apiKeysControllerProvider.future);
      expect(state.hasKey(LlmProviderId.openai), isTrue);
      expect(state.hasKey(LlmProviderId.anthropic), isFalse);
    });

    test('met à jour l\'état après enregistrement puis suppression', () async {
      final store = InMemorySecretStore();
      final c = containerWith(store);
      await c.read(apiKeysControllerProvider.future);
      final notifier = c.read(apiKeysControllerProvider.notifier);

      await notifier.save(LlmProviderId.mistral, fakeKey);
      expect(
        c.read(apiKeysControllerProvider).value!.hasKey(LlmProviderId.mistral),
        isTrue,
      );

      await notifier.delete(LlmProviderId.mistral);
      expect(
        c.read(apiKeysControllerProvider).value!.hasKey(LlmProviderId.mistral),
        isFalse,
      );
      expect(store.values, isEmpty);
    });

    test(
      'passe en erreur sans relance si le trousseau est indisponible',
      () async {
        final store = InMemorySecretStore()..failing = true;
        final c = containerWith(store);

        await expectLater(
          c.read(apiKeysControllerProvider.future),
          throwsA(isA<SecretStoreUnavailableException>()),
        );
        expect(c.read(apiKeysControllerProvider).hasError, isTrue);
      },
    );
  });

  group('SystemSecretStore', () {
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('convertit une erreur native sans en recopier le message', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(
          code: 'Libsecret error',
          message: 'échec avec la valeur $fakeKey',
        );
      });
      final store = SystemSecretStore();

      Object? error;
      try {
        await store.write('k', fakeKey);
      } catch (e) {
        error = e;
      }
      expect(error, isA<SecretStoreUnavailableException>());
      expect(error.toString(), isNot(contains(fakeKey)));
    });

    test('transmet les opérations au plugin', () async {
      final calls = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return call.method == 'containsKey' ? true : null;
      });
      final store = SystemSecretStore();

      await store.write('k', fakeKey);
      expect(await store.contains('k'), isTrue);
      await store.delete('k');

      expect(calls, ['write', 'containsKey', 'delete']);
    });
  });
}
