import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:launchpilot/features/llm/data/llm_provider_factory.dart';
import 'package:launchpilot/features/llm/data/providers/anthropic_provider.dart';
import 'package:launchpilot/features/llm/domain/json_schema_check.dart';
import 'package:launchpilot/features/llm/domain/llm_provider_id.dart';
import 'package:launchpilot/features/llm/domain/llm_trial.dart';
import 'package:launchpilot/features/llm/domain/llm_types.dart';

/// Clé fictive : aucun appel réseau réel n'est fait dans ces tests.
const fakeKey = 'sk-test-00000000000000000000000000000000';

const request = LlmRequest(
  system: 'Consigne',
  userContent: 'Question',
  schemaName: LlmTrial.schemaName,
  schema: LlmTrial.schema,
  maxOutputTokens: 512,
);

const validJson = '{"answer":"Un compteur.","terms":["build","version"]}';

http.Response json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// Réponse de génération réussie, dans le format de chaque fournisseur.
Object successBody(LlmProviderId id, String text) => switch (id) {
  LlmProviderId.anthropic => {
    'model': 'claude-opus-5-5',
    'stop_reason': 'end_turn',
    'content': [
      {'type': 'thinking', 'thinking': ''},
      {'type': 'text', 'text': text},
    ],
    'usage': {'input_tokens': 42, 'output_tokens': 17},
  },
  LlmProviderId.gemini => {
    'modelVersion': 'gemini-2.5-pro',
    'candidates': [
      {
        'finishReason': 'STOP',
        'content': {
          'parts': [
            {'text': text},
          ],
        },
      },
    ],
    'usageMetadata': {'promptTokenCount': 42, 'candidatesTokenCount': 17},
  },
  _ => {
    'model': 'modele-test',
    'choices': [
      {
        'finish_reason': 'stop',
        'message': {'role': 'assistant', 'content': text},
      },
    ],
    'usage': {'prompt_tokens': 42, 'completion_tokens': 17},
  },
};

LlmProvider make(LlmProviderId id, http.Client client, {String? model}) =>
    createLlmProvider(
      id,
      apiKey: fakeKey,
      model: model ?? id.defaultModel,
      client: client,
    );

void main() {
  group('checkJsonSchema', () {
    test('accepte une valeur conforme', () {
      expect(
        checkJsonSchema({
          'answer': 'ok',
          'terms': ['a'],
        }, LlmTrial.schema),
        isEmpty,
      );
    });

    test('signale champ manquant, champ inattendu et mauvais type', () {
      final errors = checkJsonSchema({
        'answer': 3,
        'extra': true,
        'terms': ['a', 2],
      }, LlmTrial.schema);
      expect(errors.join('\n'), contains(r'$.answer : type string'));
      expect(errors.join('\n'), contains(r'$.extra : champ inattendu'));
      expect(errors.join('\n'), contains(r'$.terms[1]'));
      expect(
        checkJsonSchema({'answer': 'x'}, LlmTrial.schema).single,
        contains('terms : champ manquant'),
      );
    });

    test('vérifie les énumérations', () {
      const schema = {
        'type': 'string',
        'enum': ['a', 'b'],
      };
      expect(checkJsonSchema('a', schema), isEmpty);
      expect(checkJsonSchema('c', schema), isNotEmpty);
    });
  });

  for (final id in LlmProviderId.values) {
    group(id.label, () {
      test('le test de connexion liste les modèles sans exposer la clé dans l\'URL', () async {
        late http.Request sent;
        final client = MockClient((r) async {
          sent = r;
          return json(switch (id) {
            LlmProviderId.gemini => {
              'models': [
                {'name': 'models/${id.defaultModel}'},
                {'name': 'models/autre'},
              ],
            },
            _ => {
              'data': [
                {'id': id.defaultModel},
                {'id': 'autre'},
              ],
            },
          });
        });
        final report = await make(id, client).testConnection();

        expect(sent.method, 'GET');
        expect(sent.url.toString(), isNot(contains(fakeKey)));
        expect(sent.headers.values.join(), contains(fakeKey));
        expect(report.availableModels, contains(id.defaultModel));
        expect(report.configuredModelAvailable, isTrue);
      });

      test('génération structurée : JSON validé et usage', () async {
        late http.Request sent;
        final client = MockClient((r) async {
          sent = r;
          return json(successBody(id, validJson));
        });
        final result = await make(id, client).generateStructured(request);

        expect(result.data['answer'], 'Un compteur.');
        expect(result.data['terms'], ['build', 'version']);
        expect(result.usage!.inputTokens, 42);
        expect(result.usage!.outputTokens, 17);
        expect(result.provider, id);
        expect(sent.url.toString(), isNot(contains(fakeKey)));
        final body = jsonDecode(sent.body) as Map;
        expect(jsonEncode(body), contains('Question'));
      });

      test('accepte un JSON entouré d\'un bloc de code', () async {
        final client = MockClient(
          (_) async => json(successBody(id, '```json\n$validJson\n```')),
        );
        final result = await make(id, client).generateStructured(request);
        expect(result.data['answer'], 'Un compteur.');
      });

      test('rejette une réponse non conforme au schéma', () async {
        final client = MockClient(
          (_) async => json(successBody(id, '{"answer":"ok"}')),
        );
        await expectLater(
          make(id, client).generateStructured(request),
          throwsA(
            isA<LlmException>()
                .having((e) => e.kind, 'kind', LlmErrorKind.invalidResponse)
                .having((e) => e.detail, 'detail', contains('terms')),
          ),
        );
      });

      test('clé refusée : message traduit, clé jamais recopiée', () async {
        final client = MockClient(
          (_) async => json({
            'error': {
              'message': 'Incorrect API key provided: $fakeKey',
              'type': 'authentication_error',
              if (id == LlmProviderId.gemini)
                'details': [
                  {'reason': 'API_KEY_INVALID'},
                ],
            },
          }, id == LlmProviderId.gemini ? 400 : 401),
        );
        try {
          await make(id, client).testConnection();
          fail('exception attendue');
        } on LlmException catch (e) {
          expect(e.kind, LlmErrorKind.invalidKey);
          expect(e.detail, isNot(contains(fakeKey)));
          expect(e.toString(), isNot(contains(fakeKey)));
        }
      });

      for (final (status, kind) in [
        (404, LlmErrorKind.modelNotFound),
        (429, LlmErrorKind.rateLimited),
        (500, LlmErrorKind.serverError),
        (529, LlmErrorKind.overloaded),
      ]) {
        test('HTTP $status → ${kind.name}', () async {
          final client = MockClient(
            (_) async => json({
              'error': {'message': 'échec $status'},
            }, status),
          );
          await expectLater(
            make(id, client).generateStructured(request),
            throwsA(
              isA<LlmException>()
                  .having((e) => e.kind, 'kind', kind)
                  .having((e) => e.statusCode, 'status', status),
            ),
          );
        });
      }

      test('délai dépassé', () async {
        final never = Completer<http.Response>();
        final client = MockClient((_) => never.future);
        const quick = LlmRequest(
          system: 's',
          userContent: 'u',
          schemaName: 'n',
          schema: LlmTrial.schema,
          timeout: Duration(milliseconds: 50),
        );
        await expectLater(
          make(id, client).generateStructured(quick),
          throwsA(
            isA<LlmException>().having(
              (e) => e.kind,
              'kind',
              LlmErrorKind.timeout,
            ),
          ),
        );
      });

      test('annulation pendant la requête', () async {
        final never = Completer<http.Response>();
        final client = MockClient((_) => never.future);
        final cancel = CancellationToken();
        final future = make(
          id,
          client,
        ).generateStructured(request, cancel: cancel);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        cancel.cancel();
        await expectLater(
          future,
          throwsA(
            isA<LlmException>().having(
              (e) => e.kind,
              'kind',
              LlmErrorKind.cancelled,
            ),
          ),
        );
      });

      test('annulée avant l\'envoi : aucun appel réseau', () async {
        var calls = 0;
        final client = MockClient((_) async {
          calls++;
          return json({});
        });
        final cancel = CancellationToken()..cancel();
        await expectLater(
          make(id, client).testConnection(cancel: cancel),
          throwsA(isA<LlmException>()),
        );
        expect(calls, 0);
      });

      test('erreur réseau', () async {
        final client = MockClient(
          (_) async => throw http.ClientException('connexion refusée'),
        );
        await expectLater(
          make(id, client).testConnection(),
          throwsA(
            isA<LlmException>().having(
              (e) => e.kind,
              'kind',
              LlmErrorKind.network,
            ),
          ),
        );
      });
    });
  }

  group('spécificités', () {
    Future<Map<String, Object?>> captureBody(
      LlmProviderId id, {
      String? model,
      void Function(http.Request)? onRequest,
    }) async {
      late http.Request sent;
      final client = MockClient((r) async {
        sent = r;
        onRequest?.call(r);
        return json(successBody(id, validJson));
      });
      await make(id, client, model: model).generateStructured(request);
      return (jsonDecode(sent.body) as Map).cast<String, Object?>();
    }

    test('Anthropic : sortie contrainte, effort et repli serveur', () async {
      late http.Request req;
      final body = await captureBody(
        LlmProviderId.anthropic,
        onRequest: (r) => req = r,
      );
      expect(req.headers['anthropic-version'], '2023-06-01');
      expect(req.headers['x-api-key'], fakeKey);
      expect(req.headers['anthropic-beta'], AnthropicProvider.fallbackBeta);
      expect(body['model'], 'claude-opus-5-5');
      expect(body['fallbacks'], 'default');
      final config = body['output_config'] as Map;
      expect((config['format'] as Map)['type'], 'json_schema');
      expect(config['effort'], 'medium');
      expect(body['system'], 'Consigne');
    });

    test(
      'Anthropic : pas de repli ni d\'effort sur un modèle plus ancien',
      () async {
        late http.Request req;
        final body = await captureBody(
          LlmProviderId.anthropic,
          model: 'claude-haiku-4-5',
          onRequest: (r) => req = r,
        );
        expect(req.headers.containsKey('anthropic-beta'), isFalse);
        expect(body.containsKey('fallbacks'), isFalse);
        expect((body['output_config'] as Map).containsKey('effort'), isFalse);
      },
    );

    test('Anthropic : refus et réponse tronquée', () async {
      for (final (reason, kind) in [
        ('refusal', LlmErrorKind.refused),
        ('max_tokens', LlmErrorKind.truncated),
      ]) {
        final client = MockClient(
          (_) async => json({'stop_reason': reason, 'content': <Object>[]}),
        );
        await expectLater(
          make(LlmProviderId.anthropic, client).generateStructured(request),
          throwsA(isA<LlmException>().having((e) => e.kind, 'kind', kind)),
        );
      }
    });

    test('OpenAI : schéma strict et refus explicite', () async {
      final body = await captureBody(LlmProviderId.openai);
      final format = body['response_format'] as Map;
      expect(format['type'], 'json_schema');
      expect((format['json_schema'] as Map)['strict'], isTrue);

      final client = MockClient(
        (_) async => json({
          'choices': [
            {
              'finish_reason': 'stop',
              'message': {'content': null, 'refusal': 'Je ne peux pas.'},
            },
          ],
        }),
      );
      await expectLater(
        make(LlmProviderId.openai, client).generateStructured(request),
        throwsA(
          isA<LlmException>().having(
            (e) => e.kind,
            'kind',
            LlmErrorKind.refused,
          ),
        ),
      );
    });

    test('OpenAI : quota épuisé distingué de la limite de débit', () async {
      final client = MockClient(
        (_) async => json({
          'error': {'message': 'quota', 'code': 'insufficient_quota'},
        }, 429),
      );
      await expectLater(
        make(LlmProviderId.openai, client).generateStructured(request),
        throwsA(
          isA<LlmException>().having(
            (e) => e.kind,
            'kind',
            LlmErrorKind.billing,
          ),
        ),
      );
    });

    test('Mistral : mode JSON et schéma dans la consigne', () async {
      final body = await captureBody(LlmProviderId.mistral);
      expect((body['response_format'] as Map)['type'], 'json_object');
      final system = ((body['messages'] as List).first as Map)['content'];
      expect(system, contains('launchpilot_trial'));
    });

    test(
      'Gemini : réponse JSON, clé en en-tête, blocage de sécurité',
      () async {
        late http.Request req;
        final body = await captureBody(
          LlmProviderId.gemini,
          onRequest: (r) => req = r,
        );
        expect(req.headers['x-goog-api-key'], fakeKey);
        expect(req.url.path, endsWith('gemini-2.5-pro:generateContent'));
        expect(
          (body['generationConfig'] as Map)['responseMimeType'],
          'application/json',
        );

        final client = MockClient(
          (_) async => json({
            'promptFeedback': {'blockReason': 'SAFETY'},
          }),
        );
        await expectLater(
          make(LlmProviderId.gemini, client).generateStructured(request),
          throwsA(
            isA<LlmException>().having(
              (e) => e.kind,
              'kind',
              LlmErrorKind.refused,
            ),
          ),
        );
      },
    );
  });
}
