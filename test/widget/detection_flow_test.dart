import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/detection/domain/detection_report.dart';
import 'package:launchpilot/features/settings/data/settings_repository.dart';

import '../support/test_harness.dart';

const meteo = '/home/testeur/projets/meteo';

Future<void> go(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(ValueKey('nav-$name')));
  await tester.pumpAndSettle();
}

Future<void> pickAndAnalyze(WidgetTester tester) async {
  await scrollAndTap(tester, find.byKey(const ValueKey('home-pick-folder')));
  await scrollAndTap(tester, find.byKey(const ValueKey('detection-analyze')));
}

bool switchValue(WidgetTester tester, PlatformTarget t) => tester
    .widget<Switch>(find.byKey(ValueKey('target-switch-${t.name}')))
    .value;

class _FailingAnalyzer implements ProjectAnalyzer {
  @override
  Future<DetectionReport> analyze(String path) async =>
      throw const FileSystemLikeException('accès refusé');
}

class FileSystemLikeException implements Exception {
  const FileSystemLikeException(this.message);
  final String message;
  @override
  String toString() => message;
}

void main() {
  testWidgets('choisir un dossier, analyser, lire le rapport', (tester) async {
    final picker = FakeFolderPicker(meteo);
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      paths: FakePathInspector([meteo]),
      folderPicker: picker,
    );

    await scrollAndTap(tester, find.byKey(const ValueKey('home-pick-folder')));
    expect(picker.calls, 1);
    expect(find.text('Rapport de détection'), findsOneWidget);
    expect(find.text('Ce projet n\'a pas encore été analysé.'), findsOneWidget);

    await scrollAndTap(tester, find.byKey(const ValueKey('detection-analyze')));

    expect(find.textContaining('fichiers parcourus'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Confiance : 99 %'), findsOneWidget);
    expect(find.textContaining('dependencies.flutter'), findsOneWidget);
    expect(switchValue(tester, PlatformTarget.android), isTrue);
    expect(switchValue(tester, PlatformTarget.ios), isTrue);
    expect(switchValue(tester, PlatformTarget.linux), isFalse);
    expect(
      find.text('Sous Linux, la construction iOS passera par une CI macOS.'),
      findsOneWidget,
    );
    expect(find.text('android.permission.CAMERA'), findsOneWidget);
    expect(find.text('Google AdMob'), findsOneWidget);
    expect(find.textContaining('Pas de dépôt Git'), findsOneWidget);
    expect(
      find.text(
        'Fichiers sensibles repérés et non lus : android/key.properties',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('valeur-fixture-ne-doit-pas-etre-lue'),
      findsNothing,
    );

    // Les technologies sont reportées sur la carte du projet à l'accueil.
    await go(tester, 'home');
    expect(find.text('Flutter'), findsOneWidget);
  });

  testWidgets('corriger et valider les cibles, conservées à la réanalyse', (
    tester,
  ) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      paths: FakePathInspector([meteo]),
      folderPicker: FakeFolderPicker(meteo),
    );
    await pickAndAnalyze(tester);
    expect(find.textContaining('Cibles à valider'), findsOneWidget);

    await scrollAndTap(
      tester,
      find.byKey(const ValueKey('target-switch-linux')),
    );
    await scrollAndTap(tester, find.byKey(const ValueKey('target-switch-web')));
    await scrollAndTap(
      tester,
      find.byKey(const ValueKey('detection-validate-targets')),
    );
    expect(find.text('Cibles validées.'), findsOneWidget);
    expect(find.textContaining('Cibles validées le'), findsOneWidget);

    await scrollAndTap(tester, find.byKey(const ValueKey('detection-analyze')));
    expect(switchValue(tester, PlatformTarget.linux), isTrue);
    expect(switchValue(tester, PlatformTarget.web), isFalse);
    expect(switchValue(tester, PlatformTarget.android), isTrue);
  });

  testWidgets('sélection annulée : rien n\'est ajouté', (tester) async {
    final picker = FakeFolderPicker(null);
    await pumpLaunchPilot(tester, size: tallScreen, folderPicker: picker);
    await scrollAndTap(tester, find.byKey(const ValueKey('home-pick-folder')));
    expect(picker.calls, 1);
    expect(find.text('Bienvenue dans LaunchPilot'), findsOneWidget);
    expect(find.text('Aucun projet pour l\'instant'), findsOneWidget);
  });

  testWidgets('saisie du chemin : bouton Parcourir', (tester) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      paths: FakePathInspector([meteo]),
      folderPicker: FakeFolderPicker(meteo),
    );
    await scrollAndTap(tester, find.byKey(const ValueKey('home-add-project')));
    await tester.tap(find.byKey(const ValueKey('dialog-browse')));
    await tester.pumpAndSettle();
    expect(find.text(meteo), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('dialog-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Projet « meteo » ajouté.'), findsOneWidget);
  });

  testWidgets('échec de l\'analyse : message clair', (tester) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      paths: FakePathInspector([meteo]),
      folderPicker: FakeFolderPicker(meteo),
      analyzer: _FailingAnalyzer(),
    );
    await pickAndAnalyze(tester);
    expect(find.text('L\'analyse a échoué : accès refusé'), findsOneWidget);
    expect(find.text('Ce projet n\'a pas encore été analysé.'), findsOneWidget);
  });

  testWidgets('site React : SEO et scripts affichés', (tester) async {
    await pumpLaunchPilot(
      tester,
      size: tallScreen,
      paths: FakePathInspector([meteo]),
      folderPicker: FakeFolderPicker(meteo),
      analyzer: const FixtureAnalyzer('react_vite'),
    );
    await pickAndAnalyze(tester);
    expect(find.text('pnpm'), findsOneWidget);
    expect(find.text('build: tsc && vite build'), findsOneWidget);
    expect(find.text('Meta description'), findsOneWidget);
    expect(find.text('Sentry'), findsOneWidget);
  });

  for (final lang in ['fr', 'en']) {
    testWidgets('aucun débordement en fenêtre étroite ($lang)', (tester) async {
      await pumpLaunchPilot(
        tester,
        size: narrowScreen,
        paths: FakePathInspector([meteo]),
        folderPicker: FakeFolderPicker(meteo),
        prefs: {
          SettingsRepository.kTextSize: 'extraLarge',
          SettingsRepository.kLanguage: lang,
        },
      );
      await pickAndAnalyze(tester);
      // Tout le rapport est parcouru jusqu'en bas.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -20000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
