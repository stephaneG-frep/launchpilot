import '../../core/domain/action_level.dart';
import '../../core/domain/step_status.dart';
import '../checklist/domain/checklist_step.dart';
import '../settings/domain/app_settings.dart';

/// Données entièrement fictives du mode démo. Aucune n'est lue sur le disque
/// et l'interface les signale toujours comme telles.

class DemoProject {
  const DemoProject({
    required this.name,
    required this.path,
    required this.technologies,
    required this.version,
    required this.lastOpened,
    required this.progress,
    this.favorite = false,
  });

  final String name;
  final String path;
  final List<String> technologies;
  final String version;
  final DateTime lastOpened;
  final double progress;
  final bool favorite;
}

class DemoSession {
  const DemoSession({
    required this.projectName,
    required this.version,
    required this.startedAt,
    required this.currentLevel,
    required this.progress,
  });

  final String projectName;
  final String version;
  final DateTime startedAt;
  final ActionLevel currentLevel;
  final double progress;
}

class DemoDetection {
  const DemoDetection({
    required this.technology,
    required this.confidence,
    required this.evidence,
  });

  final String technology;
  final double confidence;
  final List<String> evidence;
}

class DemoTarget {
  const DemoTarget({
    required this.label,
    required this.detected,
    required this.note,
  });

  final String label;
  final bool detected;
  final String note;
}

enum TerminalStream { stdout, stderr }

class DemoTerminalLine {
  const DemoTerminalLine(this.stream, this.text);
  final TerminalStream stream;
  final String text;
}

class DemoReport {
  const DemoReport({
    required this.title,
    required this.date,
    required this.summary,
    required this.status,
  });

  final String title;
  final DateTime date;
  final String summary;
  final StepStatus status;
}

class DemoStoreListing {
  const DemoStoreListing({
    required this.title,
    required this.subtitle,
    required this.shortDescription,
    required this.keywords,
  });

  final String title;
  final String subtitle;
  final String shortDescription;
  final List<String> keywords;
}

class DemoChatMessage {
  const DemoChatMessage({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;
}

class DemoCatalog {
  const DemoCatalog({
    required this.projects,
    required this.session,
    required this.detections,
    required this.targets,
    required this.steps,
    required this.terminalCommand,
    required this.terminalLines,
    required this.terminalExitCode,
    required this.reports,
    required this.listing,
    required this.chat,
  });

  final List<DemoProject> projects;
  final DemoSession session;
  final List<DemoDetection> detections;
  final List<DemoTarget> targets;
  final List<ChecklistStep> steps;
  final String terminalCommand;
  final List<DemoTerminalLine> terminalLines;
  final int terminalExitCode;
  final List<DemoReport> reports;
  final DemoStoreListing listing;
  final List<DemoChatMessage> chat;

  List<ChecklistStep> stepsFor(ActionLevel level) =>
      steps.where((s) => s.level == level).toList();

  /// Une étape pédagogique compte comme terminée dès qu'elle a été lue.
  static bool isDone(ChecklistStep step) =>
      step.status == StepStatus.succeeded ||
      step.status == StepStatus.pedagogical;

  double progressFor(ActionLevel level) {
    final list = stepsFor(level);
    if (list.isEmpty) return 0;
    return list.where(isDone).length / list.length;
  }

  double get globalProgress =>
      steps.isEmpty ? 0 : steps.where(isDone).length / steps.length;

  static DemoCatalog forLanguage(AppLanguage language) {
    String t(String fr, String en) => language == AppLanguage.fr ? fr : en;
    const project = '/home/demo/projets/meteoplus';

    return DemoCatalog(
      projects: [
        DemoProject(
          name: t('MétéoPlus (démo)', 'MeteoPlus (demo)'),
          path: project,
          technologies: const ['Flutter', 'Dart'],
          version: '1.3.0+14',
          lastOpened: DateTime(2026, 9, 29, 18, 42),
          progress: 0.45,
          favorite: true,
        ),
        DemoProject(
          name: t('Atelier Céramique (démo)', 'Pottery Workshop (demo)'),
          path: '/home/demo/projets/atelier-ceramique',
          technologies: const ['Astro', 'HTML/CSS'],
          version: '2.0.1',
          lastOpened: DateTime(2026, 9, 21, 10, 5),
          progress: 1,
        ),
        DemoProject(
          name: t('Carnet de recettes (démo)', 'Recipe Book (demo)'),
          path: '/home/demo/projets/carnet-recettes',
          technologies: const ['React', 'Vite', 'PWA'],
          version: '0.9.0',
          lastOpened: DateTime(2026, 9, 12, 14, 30),
          progress: 0.2,
        ),
      ],
      session: DemoSession(
        projectName: t('MétéoPlus (démo)', 'MeteoPlus (demo)'),
        version: '1.3.0+14',
        startedAt: DateTime(2026, 9, 29, 17, 55),
        currentLevel: ActionLevel.prepare,
        progress: 0.45,
      ),
      detections: [
        const DemoDetection(
          technology: 'Flutter 3.x (Dart)',
          confidence: 0.99,
          evidence: [
            'pubspec.yaml → dependencies.flutter.sdk: flutter',
            'lib/main.dart',
          ],
        ),
        DemoDetection(
          technology: t('Gradle (Android)', 'Gradle (Android)'),
          confidence: 0.95,
          evidence: const [
            'android/app/build.gradle.kts',
            'android/app/src/main/AndroidManifest.xml',
          ],
        ),
        DemoDetection(
          technology: t('Git — branche main', 'Git — main branch'),
          confidence: 1,
          evidence: [
            '.git/HEAD → ref: refs/heads/main',
            t(
              '2 fichiers modifiés non validés',
              '2 modified files not committed',
            ),
          ],
        ),
        DemoDetection(
          technology: 'Firebase Analytics',
          confidence: 0.8,
          evidence: const ['pubspec.yaml → firebase_analytics: ^11.0.0'],
        ),
      ],
      targets: [
        DemoTarget(
          label: 'Android',
          detected: true,
          note: t('Dossier android/ présent', 'android/ folder present'),
        ),
        DemoTarget(
          label: 'iOS',
          detected: true,
          note: t(
            'Dossier ios/ présent — build via CI macOS uniquement',
            'ios/ folder present — build through macOS CI only',
          ),
        ),
        DemoTarget(
          label: 'Web',
          detected: false,
          note: t('Aucun dossier web/', 'No web/ folder'),
        ),
        DemoTarget(
          label: 'Linux',
          detected: false,
          note: t('Aucun dossier linux/', 'No linux/ folder'),
        ),
      ],
      steps: [
        ChecklistStep(
          id: 'demo-git-status',
          level: ActionLevel.analyze,
          title: t('Vérifier l\'état Git', 'Check the Git status'),
          objective: t(
            'Savoir si des modifications ne sont pas encore validées.',
            'Know whether some changes are not committed yet.',
          ),
          explanation: t(
            'Git garde l\'historique de ton code. Avant toute préparation, '
                'LaunchPilot regarde si des fichiers ont changé depuis le '
                'dernier commit, pour ne jamais mélanger tes changements et les siens.',
            'Git keeps your code history. Before preparing anything, '
                'LaunchPilot checks whether files changed since the last '
                'commit, so your changes and its own never get mixed.',
          ),
          whyRequired: t(
            'Un dépôt propre permet de revenir en arrière facilement.',
            'A clean repository makes rolling back easy.',
          ),
          commands: [
            CommandPreview(
              executable: 'git',
              arguments: const ['status', '--porcelain'],
              workingDirectory: project,
              comment: t(
                'Liste les fichiers modifiés, en lecture seule.',
                'Lists modified files, read-only.',
              ),
            ),
          ],
          expectedResult: t(
            'Une liste vide, ou la liste des fichiers modifiés.',
            'An empty list, or the list of modified files.',
          ),
          risks: const [],
          verificationMethod: t(
            'Lance « git status » dans un terminal : le résultat doit être identique.',
            'Run "git status" in a terminal: the result must match.',
          ),
          status: StepStatus.succeeded,
        ),
        ChecklistStep(
          id: 'demo-analyze',
          level: ActionLevel.analyze,
          title: t('Analyser le code Dart', 'Analyze the Dart code'),
          objective: t(
            'Repérer les erreurs avant de construire.',
            'Catch errors before building.',
          ),
          explanation: t(
            'L\'analyseur lit le code sans l\'exécuter et signale erreurs et '
                'avertissements. Un build de production échouerait avec ces erreurs.',
            'The analyzer reads the code without running it and reports '
                'errors and warnings. A release build would fail with them.',
          ),
          whyRequired: t(
            'Publier un code qui ne compile pas est impossible.',
            'Code that does not compile cannot be published.',
          ),
          affectedFiles: const ['lib/'],
          commands: [
            CommandPreview(
              executable: 'flutter',
              arguments: const ['analyze'],
              workingDirectory: project,
              comment: t(
                'Analyse statique, aucune modification.',
                'Static analysis, no change.',
              ),
            ),
          ],
          expectedResult: t('« No issues found! »', '"No issues found!"'),
          risks: const [],
          verificationMethod: t(
            'Le code de sortie doit être 0 et aucune ligne « error » ne doit apparaître.',
            'The exit code must be 0 and no "error" line must appear.',
          ),
          status: StepStatus.failed,
        ),
        ChecklistStep(
          id: 'demo-version',
          level: ActionLevel.prepare,
          title: t('Passer en version 1.3.0+14', 'Bump to version 1.3.0+14'),
          objective: t(
            'Donner un numéro unique à la nouvelle version.',
            'Give the new release a unique number.',
          ),
          explanation: t(
            'Le Play Store refuse deux envois avec le même numéro de build '
                '(la partie après le « + »). 1.3.0 est le nom visible, 14 le '
                'compteur interne.',
            'The Play Store rejects two uploads with the same build number '
                '(the part after "+"). 1.3.0 is the visible name, 14 the '
                'internal counter.',
          ),
          whyRequired: t(
            'Sans nouveau numéro, la publication sera refusée.',
            'Without a new number, the upload will be rejected.',
          ),
          affectedFiles: const ['pubspec.yaml'],
          expectedResult: t(
            'pubspec.yaml contient « version: 1.3.0+14 ».',
            'pubspec.yaml contains "version: 1.3.0+14".',
          ),
          risks: [
            t(
              'Oublier d\'incrémenter le numéro de build.',
              'Forgetting to increment the build number.',
            ),
          ],
          verificationMethod: t(
            'Ouvre pubspec.yaml et lis la ligne « version: ».',
            'Open pubspec.yaml and read the "version:" line.',
          ),
          rollbackMethod: t(
            'Restaurer pubspec.yaml depuis l\'instantané pris avant l\'écriture.',
            'Restore pubspec.yaml from the snapshot taken before writing.',
          ),
          requiresConfirmation: true,
          status: StepStatus.needsValidation,
        ),
        ChecklistStep(
          id: 'demo-keystore',
          level: ActionLevel.prepare,
          title: t(
            'Comprendre la clé de signature Android',
            'Understand the Android signing key',
          ),
          objective: t(
            'Savoir pourquoi le keystore est précieux.',
            'Know why the keystore is precious.',
          ),
          explanation: t(
            'Le keystore est un fichier qui prouve que la mise à jour vient bien '
                'de toi. Si tu le perds, tu ne pourras plus mettre à jour '
                'l\'application sans passer par le support de Google.',
            'The keystore is a file proving that an update really comes from '
                'you. If you lose it, you can no longer update the app without '
                'going through Google support.',
          ),
          whyRequired: t(
            'Toute version Android publiée doit être signée.',
            'Every published Android release must be signed.',
          ),
          affectedFiles: const ['android/key.properties', '.gitignore'],
          expectedResult: t(
            'Tu sais où est ton keystore et il n\'est pas versionné dans Git.',
            'You know where your keystore is and it is not tracked by Git.',
          ),
          risks: [
            t(
              'Keystore envoyé par erreur sur un dépôt public.',
              'Keystore pushed to a public repository by mistake.',
            ),
            t('Mot de passe perdu.', 'Lost password.'),
          ],
          verificationMethod: t(
            '« git check-ignore android/key.properties » doit afficher le chemin.',
            '"git check-ignore android/key.properties" must print the path.',
          ),
          status: StepStatus.pedagogical,
        ),
        ChecklistStep(
          id: 'demo-tests',
          level: ActionLevel.build,
          title: t('Lancer les tests', 'Run the tests'),
          objective: t(
            'Vérifier que rien n\'est cassé.',
            'Check that nothing is broken.',
          ),
          explanation: t(
            'Les tests automatiques rejouent des scénarios de l\'application.',
            'Automated tests replay scenarios of the app.',
          ),
          whyRequired: t(
            'Un test en échec signale une régression avant tes utilisateurs.',
            'A failing test reveals a regression before your users do.',
          ),
          commands: [
            CommandPreview(
              executable: 'flutter',
              arguments: const ['test'],
              workingDirectory: project,
            ),
          ],
          expectedResult: t('« All tests passed! »', '"All tests passed!"'),
          verificationMethod: t(
            'Le code de sortie doit être 0.',
            'The exit code must be 0.',
          ),
          status: StepStatus.running,
        ),
        ChecklistStep(
          id: 'demo-appbundle',
          level: ActionLevel.build,
          title: t(
            'Construire l\'Android App Bundle',
            'Build the Android App Bundle',
          ),
          objective: t(
            'Produire le fichier .aab attendu par le Play Store.',
            'Produce the .aab file expected by the Play Store.',
          ),
          explanation: t(
            'Un App Bundle contient toutes les variantes de ton application ; '
                'Google génère ensuite l\'APK adapté à chaque téléphone.',
            'An App Bundle contains every variant of your app; Google then '
                'generates the right APK for each phone.',
          ),
          whyRequired: t(
            'Le Play Store n\'accepte que ce format pour les nouvelles applications.',
            'The Play Store only accepts this format for new apps.',
          ),
          affectedFiles: const ['build/app/outputs/bundle/release/'],
          commands: [
            CommandPreview(
              executable: 'flutter',
              arguments: const ['build', 'appbundle', '--release'],
              workingDirectory: project,
              comment: t(
                'Compile en mode release et signe avec ton keystore.',
                'Compiles in release mode and signs with your keystore.',
              ),
            ),
          ],
          expectedResult: 'build/app/outputs/bundle/release/app-release.aab',
          risks: [
            t(
              'Build signé avec une clé de débogage.',
              'Build signed with a debug key.',
            ),
          ],
          verificationMethod: t(
            'Le fichier existe ; LaunchPilot affichera sa taille et son empreinte SHA-256.',
            'The file exists; LaunchPilot will show its size and SHA-256 hash.',
          ),
          rollbackMethod: t(
            'Aucun fichier source n\'est modifié : il suffit d\'ignorer le livrable.',
            'No source file is modified: simply ignore the deliverable.',
          ),
          status: StepStatus.todo,
        ),
        ChecklistStep(
          id: 'demo-play-internal',
          level: ActionLevel.publish,
          title: t(
            'Envoyer sur la piste de test interne',
            'Upload to the internal testing track',
          ),
          objective: t(
            'Mettre la version entre les mains de testeurs.',
            'Put the release in testers\' hands.',
          ),
          explanation: t(
            'La piste interne est privée : seuls les testeurs invités voient '
                'la version. C\'est la première marche avant la production.',
            'The internal track is private: only invited testers see the '
                'release. It is the first step before production.',
          ),
          whyRequired: t(
            'Tester sur de vrais appareils avant le grand public.',
            'Test on real devices before the general public.',
          ),
          expectedResult: t(
            'La version apparaît dans la Play Console, piste « Tests internes ».',
            'The release appears in the Play Console, "Internal testing" track.',
          ),
          risks: [
            t(
              'Un envoi ne peut pas être annulé : le numéro de build est consommé.',
              'An upload cannot be undone: the build number is used up.',
            ),
          ],
          verificationMethod: t(
            'Ouvre la Play Console et vérifie la piste de test interne.',
            'Open the Play Console and check the internal testing track.',
          ),
          requiresConfirmation: true,
          isReversible: false,
          status: StepStatus.todo,
        ),
      ],
      terminalCommand: 'flutter analyze',
      terminalLines: [
        DemoTerminalLine(
          TerminalStream.stdout,
          t(
            'Analyse de meteoplus… (données fictives)',
            'Analyzing meteoplus… (fictional data)',
          ),
        ),
        const DemoTerminalLine(
          TerminalStream.stdout,
          '  info • Unused import • lib/widgets/forecast_card.dart:3:8',
        ),
        const DemoTerminalLine(
          TerminalStream.stderr,
          "  error • Undefined name 'apiKey' • lib/services/weather_api.dart:18:24",
        ),
        const DemoTerminalLine(
          TerminalStream.stderr,
          "  error • The argument type 'int?' can't be assigned to 'int' • "
          'lib/models/forecast.dart:42:31',
        ),
        const DemoTerminalLine(
          TerminalStream.stdout,
          '3 issues found. (ran in 2.4s)',
        ),
      ],
      terminalExitCode: 1,
      reports: [
        DemoReport(
          title: t(
            'Atelier Céramique 2.0.1 — Netlify (démo)',
            'Pottery Workshop 2.0.1 — Netlify (demo)',
          ),
          date: DateTime(2026, 9, 21, 11, 20),
          summary: t(
            'Build Astro, audit SEO, déploiement confirmé. 0 action restante.',
            'Astro build, SEO audit, confirmed deployment. 0 remaining action.',
          ),
          status: StepStatus.succeeded,
        ),
        DemoReport(
          title: t(
            'MétéoPlus 1.2.0+13 — Play Store (démo)',
            'MeteoPlus 1.2.0+13 — Play Store (demo)',
          ),
          date: DateTime(2026, 8, 30, 16, 5),
          summary: t(
            'AAB construit, fiche préparée. 2 captures à remplacer.',
            'AAB built, listing prepared. 2 screenshots to replace.',
          ),
          status: StepStatus.needsValidation,
        ),
      ],
      listing: DemoStoreListing(
        title: t('MétéoPlus', 'MeteoPlus'),
        subtitle: t(
          'La météo locale, simple et sans pub',
          'Local weather, simple and ad-free',
        ),
        shortDescription: t(
          'Prévisions heure par heure, alertes pluie et widgets, sans compte.',
          'Hourly forecasts, rain alerts and widgets, no account needed.',
        ),
        keywords: [
          t('météo', 'weather'),
          t('prévisions', 'forecast'),
          t('pluie', 'rain'),
          'widget',
        ],
      ),
      chat: [
        DemoChatMessage(
          fromUser: true,
          text: t(
            'Pourquoi dois-je changer le numéro de build ?',
            'Why must I change the build number?',
          ),
        ),
        DemoChatMessage(
          fromUser: false,
          text: t(
            'Le Play Store identifie chaque envoi par ce numéro. Si tu renvoies '
                '14 alors que 14 existe déjà, l\'envoi est refusé. Je te propose '
                '1.3.0+14 ; tu verras le diff de pubspec.yaml avant toute écriture.',
            'The Play Store identifies each upload by this number. If you send '
                '14 again while 14 already exists, the upload is rejected. I '
                'suggest 1.3.0+14; you will see the pubspec.yaml diff before any write.',
          ),
        ),
      ],
    );
  }
}
