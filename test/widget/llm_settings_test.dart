import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:launchpilot/features/llm/application/llm_service.dart';
import 'package:launchpilot/features/llm/domain/llm_provider_id.dart';
import 'package:launchpilot/features/settings/data/api_key_repository.dart';
import 'package:launchpilot/features/settings/data/settings_repository.dart';

import '../support/test_harness.dart';

/// Clé fictive : aucun appel réseau réel n'est fait.
const fakeKey = 'sk-test-00000000000000000000000000000000';

http.Response jsonResponse(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

InMemorySecretStore storeWithKey([
  LlmProviderId id = LlmProviderId.anthropic,
]) =>
    InMemorySecretStore()..values[ApiKeyRepository.storageKeyFor(id)] = fakeKey;

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('nav-settings')));
  await tester.pumpAndSettle();
}

void main() {
  group('test de connexion', () {
    testWidgets('désactivé sans clé enregistrée', (tester) async {
      await pumpLaunchPilot(tester, size: tallScreen);
      await openSettings(tester);
      final button = tester.widget<OutlinedButton>(
        find.byKey(const ValueKey('llm-test-anthropic')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('trousseau verrouillé entre-temps : message clair', (
      tester,
    ) async {
      final store = storeWithKey();
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        secretStore: store,
        httpClient: MockClient((_) async => jsonResponse({'data': []})),
      );
      await openSettings(tester);
      store.failing = true;
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('llm-test-anthropic')),
      );
      expect(
        find.textContaining('trousseau du système est verrouillé'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('trousseau verrouillé dès l\'ouverture : message clair', (
      tester,
    ) async {
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        secretStore: storeWithKey()..failing = true,
      );
      await openSettings(tester);
      expect(
        find.textContaining('trousseau du système est verrouillé'),
        findsWidgets,
      );
    });

    testWidgets('liste les modèles et confirme le modèle choisi', (
      tester,
    ) async {
      final requests = <http.Request>[];
      final client = MockClient((r) async {
        requests.add(r);
        return jsonResponse({
          'data': [
            {'id': 'claude-opus-5-5'},
            {'id': 'claude-haiku-4-5'},
          ],
        });
      });
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        secretStore: storeWithKey(),
        httpClient: client,
      );
      await openSettings(tester);

      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('llm-test-anthropic')),
      );

      expect(requests.single.url.path, '/v1/models');
      expect(requests.single.headers['x-api-key'], fakeKey);
      expect(find.textContaining('2 modèles disponibles'), findsOneWidget);
      expect(
        find.text('Le modèle « claude-opus-5-5 » est disponible.'),
        findsOneWidget,
      );
      expect(find.textContaining(fakeKey), findsNothing);

      // Choix d'un autre modèle dans la liste renvoyée.
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('llm-choose-model-anthropic')),
      );
      await tester.tap(find.text('claude-haiku-4-5').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Le modèle « claude-haiku-4-5 » est disponible.'),
        findsOneWidget,
      );
    });

    testWidgets('clé refusée : message clair, clé jamais affichée', (
      tester,
    ) async {
      final client = MockClient(
        (_) async => jsonResponse({
          'error': {
            'type': 'authentication_error',
            'message': 'invalid x-api-key $fakeKey',
          },
        }, 401),
      );
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        secretStore: storeWithKey(),
        httpClient: client,
      );
      await openSettings(tester);
      await scrollAndTap(
        tester,
        find.byKey(const ValueKey('llm-test-anthropic')),
      );

      expect(
        find.text(
          'Clé API refusée par le fournisseur. Vérifie-la ou remplace-la.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('[SECRET MASQUÉ]'), findsOneWidget);
      expect(find.textContaining(fakeKey), findsNothing);
    });

    testWidgets('le modèle saisi est mémorisé', (tester) async {
      final prefs = await pumpLaunchPilot(tester, size: tallScreen);
      await openSettings(tester);
      final field = find.byKey(const ValueKey('llm-model-mistral'));
      await tester.ensureVisible(field);
      await tester.enterText(field, 'mistral-small-latest');
      await tester.pumpAndSettle();
      expect(
        prefs.getString(LlmModelsController.prefsKey(LlmProviderId.mistral)),
        'mistral-small-latest',
      );

      await tester.enterText(field, '');
      await tester.pumpAndSettle();
      expect(
        prefs.containsKey(LlmModelsController.prefsKey(LlmProviderId.mistral)),
        isFalse,
      );
    });
  });

  group('essai de génération', () {
    final trial = find.byKey(const ValueKey('llm-trial'));

    testWidgets('bloqué sans clé pour le fournisseur préféré', (tester) async {
      await pumpLaunchPilot(tester, size: tallScreen);
      await openSettings(tester);
      await tester.ensureVisible(trial);
      expect(tester.widget<FilledButton>(trial).onPressed, isNull);
      expect(
        find.text('Enregistre d\'abord une clé pour Anthropic Claude.'),
        findsOneWidget,
      );
    });

    testWidgets('aperçu, confirmation, réponse et usage', (tester) async {
      final requests = <http.Request>[];
      final client = MockClient((r) async {
        requests.add(r);
        return jsonResponse({
          'model': 'claude-opus-5-5',
          'stop_reason': 'end_turn',
          'content': [
            {
              'type': 'text',
              'text': '{"answer":"Un compteur interne.","terms":["versionCode","release","store"]}',
            },
          ],
          'usage': {'input_tokens': 120, 'output_tokens': 45},
        });
      });
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        secretStore: storeWithKey(),
        httpClient: client,
      );
      await openSettings(tester);
      await scrollAndTap(tester, trial);

      // Mode Débutant : l'aperçu est déplié d'office, rien n'est encore parti.
      expect(find.text('Envoyer à Anthropic Claude ?'), findsOneWidget);
      expect(find.textContaining('numéro de build'), findsWidgets);
      expect(find.text('Aucun secret détecté'), findsOneWidget);
      expect(
        find.text('Aucune donnée de ton projet n\'est incluse.'),
        findsOneWidget,
      );
      expect(requests, isEmpty);

      await tester.tap(find.byKey(const ValueKey('llm-send-confirm')));
      await tester.pumpAndSettle();

      expect(requests, hasLength(1));
      final body = jsonDecode(requests.single.body) as Map;
      expect(body['messages'].toString(), contains('numéro de build'));
      expect(requests.single.body, isNot(contains(fakeKey)));
      expect(find.text('Réponse reçue'), findsOneWidget);
      expect(find.text('Un compteur interne.'), findsOneWidget);
      expect(find.text('versionCode'), findsOneWidget);
      expect(find.textContaining('120 jetons en entrée'), findsOneWidget);
      expect(find.text('Réponse produite par claude-opus-5-5'), findsOneWidget);
    });

    testWidgets('annuler la boîte d\'aperçu n\'envoie rien', (tester) async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return jsonResponse({});
      });
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        secretStore: storeWithKey(),
        httpClient: client,
      );
      await openSettings(tester);
      await scrollAndTap(tester, trial);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('requête annulée en cours de route', (tester) async {
      final never = Completer<http.Response>();
      final client = MockClient((_) => never.future);
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        secretStore: storeWithKey(),
        httpClient: client,
      );
      await openSettings(tester);
      await scrollAndTap(tester, trial);
      await tester.tap(find.byKey(const ValueKey('llm-send-confirm')));
      await tester.pump();
      expect(find.text('Requête en cours…'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('llm-send-cancel')));
      await tester.pumpAndSettle();
      expect(find.text('Échec de la requête'), findsOneWidget);
      expect(find.text('Requête annulée.'), findsOneWidget);
    });

    testWidgets('mode Expert : aperçu replié mais disponible', (tester) async {
      await pumpLaunchPilot(
        tester,
        size: tallScreen,
        secretStore: storeWithKey(),
        prefs: {SettingsRepository.kExplanationLevel: 'expert'},
      );
      await openSettings(tester);
      await scrollAndTap(tester, trial);
      expect(find.text('Consignes'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('llm-send-toggle-preview')));
      await tester.pumpAndSettle();
      expect(find.text('Consignes'), findsOneWidget);
    });
  });
}
