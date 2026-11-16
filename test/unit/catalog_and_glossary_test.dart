import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/app/destinations.dart';
import 'package:launchpilot/core/domain/action_level.dart';
import 'package:launchpilot/core/domain/step_status.dart';
import 'package:launchpilot/features/demo/demo_catalog.dart';
import 'package:launchpilot/features/help/domain/glossary.dart';
import 'package:launchpilot/features/settings/domain/app_settings.dart';

void main() {
  group('DemoCatalog', () {
    final fr = DemoCatalog.forLanguage(AppLanguage.fr);
    final en = DemoCatalog.forLanguage(AppLanguage.en);

    test('les deux langues ont exactement la même structure', () {
      expect(fr.steps.map((s) => s.id), en.steps.map((s) => s.id));
      expect(fr.steps.map((s) => s.status), en.steps.map((s) => s.status));
      expect(fr.projects.length, en.projects.length);
      expect(fr.detections.length, en.detections.length);
      expect(fr.terminalLines.length, en.terminalLines.length);
    });

    test('les identifiants d\'étapes sont uniques', () {
      final ids = fr.steps.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('illustre les six statuts et les quatre niveaux', () {
      expect(fr.steps.map((s) => s.status).toSet(), StepStatus.values.toSet());
      for (final level in ActionLevel.values) {
        expect(fr.stepsFor(level), isNotEmpty, reason: level.name);
      }
    });

    test('chaque projet fictif est signalé comme démo', () {
      for (final p in fr.projects) {
        expect(p.name, contains('(démo)'));
        expect(p.path, startsWith('/home/demo/'));
      }
      for (final p in en.projects) {
        expect(p.name, contains('(demo)'));
      }
    });

    test(
      'toute étape irréversible ou de publication exige une confirmation',
      () {
        for (final s in fr.steps) {
          if (!s.isReversible || s.level == ActionLevel.publish) {
            expect(s.requiresConfirmation, isTrue, reason: s.id);
          }
        }
      },
    );

    test('les commandes de démo ne passent jamais par un shell', () {
      for (final s in fr.steps) {
        for (final c in s.commands) {
          expect(c.executable, isNot(anyOf('bash', 'sh', 'zsh')));
          expect(c.arguments, isNot(contains('-c')));
        }
      }
    });

    test('calcule la progression', () {
      final analyze = fr.stepsFor(ActionLevel.analyze);
      final done = analyze.where(DemoCatalog.isDone).length;
      expect(fr.progressFor(ActionLevel.analyze), done / analyze.length);
      expect(fr.globalProgress, inInclusiveRange(0, 1));
    });
  });

  group('Glossary', () {
    test('est trié et identique en nombre dans les deux langues', () {
      final fr = Glossary.forLanguage(AppLanguage.fr);
      final en = Glossary.forLanguage(AppLanguage.en);
      expect(fr.length, en.length);
      final terms = fr.map((e) => e.term.toLowerCase()).toList();
      expect(terms, [...terms]..sort());
    });

    test('recherche dans les termes et les définitions', () {
      final all = Glossary.forLanguage(AppLanguage.fr);
      expect(Glossary.search(all, ''), all);
      expect(
        Glossary.search(all, 'keystore').map((e) => e.term),
        contains('Keystore'),
      );
      expect(
        Glossary.search(all, 'hors ligne').map((e) => e.term),
        contains('PWA'),
      );
      expect(Glossary.search(all, 'zzzz'), isEmpty);
    });
  });

  group('AppDestination', () {
    test('dix écrans avec des raccourcis uniques 1…9 puis 0', () {
      expect(AppDestination.values, hasLength(10));
      expect(AppDestination.values.map((d) => d.shortcutKey).toList(), [
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '0',
      ]);
    });

    test('retrouve l\'écran depuis le chemin', () {
      expect(AppDestination.fromLocation('/'), AppDestination.home);
      expect(AppDestination.fromLocation('/settings'), AppDestination.settings);
      expect(AppDestination.fromLocation('/inconnu'), AppDestination.home);
    });
  });
}
