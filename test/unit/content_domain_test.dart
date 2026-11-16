import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:launchpilot/features/content/domain/changelog.dart';
import 'package:launchpilot/features/content/domain/icons.dart';
import 'package:launchpilot/features/content/domain/legal.dart';
import 'package:launchpilot/features/content/domain/screenshots.dart';
import 'package:launchpilot/features/content/domain/store_texts.dart';
import 'package:launchpilot/features/content/domain/version.dart';
import 'package:launchpilot/features/detection/application/detection_providers.dart';
import 'package:launchpilot/features/settings/domain/app_settings.dart';

/// Image PNG de test, unie.
Uint8List png(int w, int h, {List<int> rgba = const [220, 40, 40, 255]}) {
  final image = img.Image(width: w, height: h, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(rgba[0], rgba[1], rgba[2], rgba[3]));
  return img.encodePng(image);
}

void main() {
  group('SemVer', () {
    test('lecture, incréments et numéro de build', () {
      final v = SemVer.tryParse('1.2.3+7')!;
      expect(v.bumped(VersionBump.patch).toString(), '1.2.4+8');
      expect(v.bumped(VersionBump.minor).toString(), '1.3.0+8');
      expect(v.bumped(VersionBump.major).toString(), '2.0.0+8');
      expect(v.bumped(VersionBump.none).toString(), '1.2.3+8');
      expect(
        v.bumped(VersionBump.patch, incrementBuild: false).toString(),
        '1.2.4+7',
      );
      expect(
        SemVer.tryParse('1.0.0')!.bumped(VersionBump.minor).toString(),
        '1.1.0',
      );
      expect(SemVer.tryParse('v2.0.0-beta.1')!.pre, 'beta.1');
      expect(SemVer.tryParse('1.0'), isNull);
      expect(SemVer.tryParse('1.2.4+1')!.compareTo(v), greaterThan(0));
    });

    test('pubspec : seule la valeur change, le reste est conservé', () {
      const pubspec = '''name: meteo
# Version publiée
version: 1.2.0+7 # ne pas oublier
environment:
  sdk: ^3.5.0
''';
      expect(readVersion(VersionFileKind.pubspec, pubspec), '1.2.0+7');
      expect(
        writeVersion(VersionFileKind.pubspec, pubspec, '1.3.0+8'),
        pubspec.replaceFirst('1.2.0+7', '1.3.0+8'),
      );
      expect(
        writeVersion(
          VersionFileKind.pubspec,
          'version: "1.0.0+1"\n',
          '1.0.1+2',
        ),
        'version: "1.0.1+2"\n',
      );
      expect(
        writeVersion(VersionFileKind.pubspec, 'name: x\n', '1.0.0'),
        isNull,
      );
    });

    test('package.json : mise en forme intacte', () {
      const json =
          '{\n  "name": "site",\n  "version": "0.9.0",\n  "private": true\n}\n';
      expect(readVersion(VersionFileKind.packageJson, json), '0.9.0');
      expect(
        writeVersion(VersionFileKind.packageJson, json, '1.0.0'),
        json.replaceFirst('0.9.0', '1.0.0'),
      );
    });
  });

  group('changelog', () {
    const sep = logFieldSeparator;
    final commits = parseGitLog(
      [
        'a1b2c3d${sep}feat(meteo): ajoute les alertes pluie${sep}Léa',
        'b2c3d4e${sep}fix: corrige le crash au démarrage${sep}Léa',
        'c3d4e5f${sep}chore: met à jour les dépendances${sep}Bot',
        'd4e5f6a${sep}feat!: nouvelle API${sep}Léa',
        'e5f6a7b${sep}Message libre${sep}Max',
      ].join('\n'),
    );
    String title(ChangeGroup g) => g.name;

    test('lecture et classement Conventional Commits', () {
      expect(commits, hasLength(5));
      expect(commits.first.type, 'feat');
      expect(commits.first.scope, 'meteo');
      expect(commits.first.description, 'ajoute les alertes pluie');
      expect(groupOf(commits[3]), ChangeGroup.breaking);
      expect(groupOf(commits[2]), ChangeGroup.other);
      expect(groupOf(commits[4]), ChangeGroup.other);
    });

    test('version technique et version grand public', () {
      final tech = technicalChangelog(commits, title, heading: '1.3.0');
      expect(tech, startsWith('## 1.3.0\n'));
      expect(
        tech,
        contains('- **meteo** : Ajoute les alertes pluie (a1b2c3d)'),
      );
      expect(tech, contains('### other'));

      final public = publicChangelog(
        commits,
        title,
        heading: '1.3.0',
        fallback: 'x',
      );
      expect(public, contains('- Ajoute les alertes pluie'));
      expect(public, contains('- Corrige le crash au démarrage'));
      expect(public, isNot(contains('dépendances')));
      expect(public, isNot(contains('a1b2c3d')));
      expect(
        publicChangelog(
          const [],
          title,
          heading: '1.0.0',
          fallback: 'Corrections mineures.',
        ),
        contains('Corrections mineures.'),
      );
    });

    test('insertion en tête, sans doublon pour la même version', () {
      const section = '## 1.3.0\n\n- Nouveau\n';
      expect(
        prependChangelog(null, section, title: 'Changelog'),
        '# Changelog\n\n## 1.3.0\n\n- Nouveau\n',
      );

      const existing = '# Changelog\n\n## 1.2.0\n\n- Ancien\n';
      final once = prependChangelog(existing, section, title: 'Changelog');
      expect(once.indexOf('## 1.3.0'), lessThan(once.indexOf('## 1.2.0')));
      expect(once, contains('- Ancien'));

      final again = prependChangelog(
        once,
        '## 1.3.0\n\n- Corrigé\n',
        title: 'Changelog',
      );
      expect('## 1.3.0'.allMatches(again), hasLength(1));
      expect(again, contains('- Corrigé'));
      expect(again, isNot(contains('- Nouveau')));
      expect(again, contains('- Ancien'));
    });
  });

  group('icônes', () {
    test('inspection : taille, forme et transparence', () {
      final ok = inspectIcon(png(1024, 1024));
      expect(ok.issues, isEmpty);
      expect(ok.usable, isTrue);

      final wide = inspectIcon(png(800, 600, rgba: [0, 0, 0, 0]));
      expect(
        wide.issues,
        containsAll([
          IconIssue.belowRecommended,
          IconIssue.notSquare,
          IconIssue.transparent,
        ]),
      );
      expect(wide.usable, isTrue);

      expect(inspectIcon(png(200, 200)).usable, isFalse);
      expect(inspectIcon(utf8.encode('pas une image')).issues, [
        IconIssue.unreadable,
      ]);
    });

    test('plans Android, iOS et web', () {
      expect(androidIcons('android').map((t) => t.size), [
        48,
        72,
        96,
        144,
        192,
      ]);
      final (ios, contents) = iosDefaultIcons(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset',
      );
      expect(
        ios.map((t) => t.size),
        containsAll([40, 60, 120, 180, 167, 1024]),
      );
      expect(ios.every((t) => t.opaque), isTrue);
      expect(iosIconsFromContents('d', contents).length, ios.length);
      final custom = iosIconsFromContents(
        'd',
        jsonEncode({
          'images': [
            {'size': '60x60', 'scale': '3x', 'filename': 'Perso.png'},
            {'size': '20x20', 'scale': '2x'},
          ],
        }),
      );
      expect(custom.single.path, 'd/Perso.png');
      expect(custom.single.size, 180);
      expect(
        webIcons('web', flutter: true).where((t) => t.maskable),
        hasLength(2),
      );
    });

    test('génération : bonnes tailles, jamais étirée, opaque si demandé', () {
      // Source rouge 400 × 200 : doit être centrée, pas déformée.
      final icons = generateIcons(png(400, 200), const [
        IconTarget('a.png', 100),
        IconTarget('b.png', 64, opaque: true),
        IconTarget('c.png', 100, maskable: true),
      ], background: 0xFF0000FF);

      final a = img.decodeImage(icons['a.png']!)!;
      expect((a.width, a.height), (100, 100));
      expect(a.getPixel(50, 5).a, 0, reason: 'bande transparente en haut');
      expect(a.getPixel(50, 50).r, greaterThan(200), reason: 'motif au centre');

      final b = img.decodeImage(icons['b.png']!)!;
      expect(b.hasAlpha, isFalse);
      expect(b.getPixel(32, 2).b, 255, reason: 'fond de la couleur choisie');

      final c = img.decodeImage(icons['c.png']!)!;
      expect(c.getPixel(2, 50).b, 255, reason: 'marge de sécurité maskable');
    });
  });

  group('captures', () {
    test('compatibilité par store', () {
      final iphone = checkScreenshot(1290, 2796);
      expect(iphone[ScreenshotSlot.iphone69], isTrue);
      expect(
        iphone[ScreenshotSlot.playPhone],
        isFalse,
        reason: 'rapport > 2:1',
      );
      final play = checkScreenshot(1080, 1920);
      expect(play[ScreenshotSlot.playPhone], isTrue);
      expect(play[ScreenshotSlot.iphone69], isFalse);
      expect(checkScreenshot(2796, 1290)[ScreenshotSlot.iphone69], isTrue);
      expect(checkScreenshot(200, 300)[ScreenshotSlot.playPhone], isFalse);
    });

    test('masquage opaque des zones choisies', () {
      final masked = applyMasks(png(100, 100), const [
        MaskRect(0.5, 0.5, 0.0, 0.0),
      ]);
      final image = img.decodeImage(masked)!;
      expect(image.getPixel(10, 10).r, 32);
      expect(image.getPixel(80, 80).r, 220, reason: 'hors zone : intact');
      expect(imageSize(masked), (100, 100));
    });
  });

  group('textes de fiche', () {
    test('limites, aller-retour JSON et schéma', () {
      final texts = const StoreTexts()
          .copyWith(StoreField.title, 'x' * 31)
          .copyWith(StoreField.keywords, 'météo, pluie');
      expect(texts.overLimit, [StoreField.title]);
      expect(
        StoreTexts.fromJson(texts.toJson())[StoreField.keywords],
        'météo, pluie',
      );
      expect(visibleLength('🌧️ Pluie'), lessThan('🌧️ Pluie'.length));
      expect(
        (StoreTexts.schema['required']! as List),
        hasLength(StoreField.values.length),
      );
    });
  });

  group('juridique', () {
    final report = analyzeProjectSync('test/fixtures/projects/flutter_app');

    test('préremplissage d\'après la détection', () {
      final a = LegalAnswers.fromDetection(report, appName: 'Météo');
      expect(
        a.data,
        containsAll([
          DataCategory.photos,
          DataCategory.usage,
          DataCategory.advertisingId,
        ]),
      );
      expect(
        a.thirdParties,
        containsAll(['Firebase Analytics', 'Google AdMob']),
      );
      expect(a.missing, containsAll(['publisherName', 'email', 'hostName']));
      expect(LegalAnswers.fromJson(a.toJson()).toJson(), a.toJson());
    });

    test('modèles : avertissement, réponses et repères à compléter', () {
      final a = LegalAnswers.fromDetection(
        report,
        appName: 'Météo',
      ).copyWith(publisherName: 'Léa Martin', email: 'lea@example.org');
      final policy = privacyPolicy(a, AppLanguage.fr, DateTime(2026, 10, 30));
      expect(policy, startsWith('<!-- Modèle généré par LaunchPilot'));
      expect(policy, contains('ne garantit pas la conformité'));
      expect(policy, contains('Météo est éditée par Léa Martin'));
      expect(policy, contains('lea@example.org'));
      expect(policy, contains('Google AdMob'));
      expect(policy, contains('2026-10-30'));
      expect(policy, isNot(contains('conforme au RGPD')));

      final notice = legalNotice(a, AppLanguage.fr);
      expect(notice, contains('[NOM DE L\'HÉBERGEUR]'));
      expect(notice, isNot(contains('SIREN')));
      expect(
        legalNotice(
          a.copyWith(publisherType: PublisherType.company),
          AppLanguage.fr,
        ),
        contains('SIREN'),
      );
      final en = privacyPolicy(a, AppLanguage.en, DateTime(2026));
      expect(en, contains('# Privacy policy'));
      expect(en, contains('does not guarantee legal compliance'));
    });

    test('bannière : consentement mémorisé, scripts chargés après accord', () {
      final banner = cookieBanner(
        const LegalAnswers(usesCookies: true),
        AppLanguage.fr,
      );
      expect(banner, contains('localStorage'));
      expect(banner, contains('data-consent="refuse"'));
      expect(banner, contains('seulement ici'));
    });
  });
}
