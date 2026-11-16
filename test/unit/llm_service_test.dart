import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:launchpilot/features/llm/application/llm_service.dart';
import 'package:launchpilot/features/llm/domain/llm_provider_id.dart';
import 'package:launchpilot/features/llm/domain/llm_trial.dart';
import 'package:launchpilot/features/llm/domain/llm_types.dart';
import 'package:launchpilot/features/llm/domain/prompt_builder.dart';
import 'package:launchpilot/core/security/secret_redactor.dart';
import 'package:launchpilot/features/settings/data/api_key_repository.dart';

import '../support/test_harness.dart';

const fakeKey = 'sk-test-00000000000000000000000000000000';

LlmPayload payload({
  List<ContextItem> items = const [],
  String question = 'Q',
}) => PromptBuilder.build(
  provider: LlmProviderId.mistral,
  model: 'mistral-large-latest',
  system: 'Consigne',
  instruction: question,
  schemaName: LlmTrial.schemaName,
  schema: LlmTrial.schema,
  items: items,
);

void main() {
  group('PromptBuilder', () {
    test('masque les secrets et exclut les fichiers sensibles', () {
      final p = payload(
        items: const [
          ContextItem(
            label: 'Configuration',
            path: 'android/app/build.gradle',
            content: 'storePassword=secretissime\nminSdk 23',
          ),
          ContextItem(
            label: 'Signature',
            path: 'android/key.properties',
            content: 'keyAlias=upload',
          ),
          ContextItem(label: 'Env', path: '.env', content: 'API=1'),
        ],
      );
      expect(p.userContent, isNot(contains('secretissime')));
      expect(p.userContent, contains('minSdk 23'));
      expect(p.userContent, isNot(contains('keyAlias')));
      expect(p.excludedFiles, ['android/key.properties', '.env']);
      expect(p.redactions[SecretKind.password], 1);
      expect(p.includesProjectData, isTrue);
    });

    test('refuse un contenu trop long au lieu de le tronquer', () {
      expect(
        () => payload(
          items: [
            ContextItem(
              label: 'Gros fichier',
              content: 'x' * (PromptBuilder.maxCharacters + 1),
            ),
          ],
        ),
        throwsA(isA<PayloadTooLargeException>()),
      );
    });

    test('l\'empreinte change avec le contenu', () {
      expect(payload().digest, payload().digest);
      expect(payload().digest, isNot(payload(question: 'Autre').digest));
      expect(payload().includesProjectData, isFalse);
    });
  });

  group('LlmService', () {
    late InMemorySecretStore store;
    late int calls;
    late List<http.Request> requests;
    late LlmService service;

    setUp(() {
      store = InMemorySecretStore();
      calls = 0;
      requests = [];
      final client = MockClient((r) async {
        calls++;
        requests.add(r);
        return http.Response(
          jsonEncode({
            'model': 'mistral-large-latest',
            'choices': [
              {
                'finish_reason': 'stop',
                'message': {'content': '{"answer":"ok","terms":[]}'},
              },
            ],
          }),
          200,
        );
      });
      service = LlmService(
        keys: ApiKeyRepository(store),
        client: client,
        modelFor: (id) => id.defaultModel,
      );
    });

    Future<void> storeKey() =>
        ApiKeyRepository(store).saveKey(LlmProviderId.mistral, fakeKey);

    test('sans clé enregistrée : erreur claire, aucun appel', () async {
      final p = payload();
      await expectLater(
        service.send(p, service.grantConsent(p)),
        throwsA(
          isA<LlmException>().having(
            (e) => e.kind,
            'kind',
            LlmErrorKind.missingKey,
          ),
        ),
      );
      expect(calls, 0);
    });

    test(
      'envoie avec une confirmation valide, clé seulement en en-tête',
      () async {
        await storeKey();
        final p = payload();
        final result = await service.send(p, service.grantConsent(p));
        expect(result.data['answer'], 'ok');
        expect(calls, 1);
        expect(requests.single.body, isNot(contains(fakeKey)));
        expect(requests.single.headers['authorization'], 'Bearer $fakeKey');
      },
    );

    test('une confirmation ne peut pas être réutilisée', () async {
      await storeKey();
      final p = payload();
      final consent = service.grantConsent(p);
      await service.send(p, consent);
      await expectLater(
        service.send(p, consent),
        throwsA(isA<ConsentException>()),
      );
      expect(calls, 1);
    });

    test('une confirmation ne vaut que pour le contenu confirmé', () async {
      await storeKey();
      final confirmed = payload(question: 'Contenu vu');
      final other = payload(question: 'Contenu différent');
      final consent = service.grantConsent(confirmed);
      await expectLater(
        service.send(other, consent),
        throwsA(isA<ConsentException>()),
      );
      expect(calls, 0);
      // Et elle a été consommée par la tentative.
      await expectLater(
        service.send(confirmed, consent),
        throwsA(isA<ConsentException>()),
      );
    });

    test('le test de connexion ne demande pas de confirmation', () async {
      await storeKey();
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'data': [
              {'id': 'mistral-large-latest'},
            ],
          }),
          200,
        ),
      );
      final s = LlmService(
        keys: ApiKeyRepository(store),
        client: client,
        modelFor: (id) => id.defaultModel,
      );
      final report = await s.testConnection(LlmProviderId.mistral);
      expect(report.configuredModelAvailable, isTrue);
    });

    test('trousseau verrouillé : erreur claire, aucun appel réseau', () async {
      final locked = InMemorySecretStore()..failing = true;
      var calls = 0;
      final s = LlmService(
        keys: ApiKeyRepository(locked),
        client: MockClient((_) async {
          calls++;
          return http.Response('{}', 200);
        }),
        modelFor: (id) => id.defaultModel,
      );
      await expectLater(
        s.testConnection(LlmProviderId.anthropic),
        throwsA(
          isA<LlmException>().having(
            (e) => e.kind,
            'kind',
            LlmErrorKind.keyringUnavailable,
          ),
        ),
      );
      expect(calls, 0);
    });
  });
}
