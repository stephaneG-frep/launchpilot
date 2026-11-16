import '../../../core/domain/action_level.dart';
import '../../detection/domain/detection_report.dart';
import '../../git/domain/git_status.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/checklist_step.dart';
import '../domain/launch_target.dart';
import 'step_helpers.dart';

/// Tronc commun, actif pour tout projet : Git, secrets, qualité du code,
/// version, changelog, contenus de store et documents légaux.
class CommonTarget implements LaunchTarget {
  const CommonTarget();

  @override
  String get id => 'common';

  @override
  String label(AppLanguage language) =>
      language == AppLanguage.fr ? 'Tronc commun' : 'Common';

  @override
  bool get alwaysActive => true;

  @override
  Future<TargetDetection?> detect(ProjectInfo project) async => null;

  @override
  Future<List<ChecklistStep>> buildChecklist(ProjectInfo p) async {
    final r = p.report;
    final steps = <ChecklistStep>[];
    final hasGit = r.git.present;

    steps.add(
      hasGit
          ? ChecklistStep(
              id: 'common.git',
              level: ActionLevel.analyze,
              kind: StepKind.command,
              title: p.t('Vérifier l\'état Git', 'Check the Git status'),
              objective: p.t(
                'Savoir si des modifications ne sont pas encore validées.',
                'Know whether some changes are not committed yet.',
              ),
              summary: p.t(
                'État du dépôt avant toute préparation.',
                'Repository state before any preparation.',
              ),
              explanation: p.t(
                'Git garde l\'historique du projet. Avant de préparer une '
                    'version, on vérifie ce qui a changé depuis le dernier '
                    'commit : tes modifications ne seront jamais mélangées à '
                    'celles de LaunchPilot.',
                'Git keeps the project history. Before preparing a release, '
                    'we check what changed since the last commit: your changes '
                    'will never be mixed with LaunchPilot\'s.',
              ),
              whyRequired: p.t(
                'Un dépôt propre permet de revenir en arrière facilement.',
                'A clean repository makes rolling back easy.',
              ),
              commands: [
                command(
                  p,
                  'git',
                  const ['status'],
                  comment: p.t(
                    'Liste les fichiers modifiés, en lecture seule.',
                    'Lists modified files, read-only.',
                  ),
                ),
              ],
              expectedResult: p.t(
                '« rien à valider » ou la liste des fichiers modifiés.',
                '"nothing to commit" or the list of modified files.',
              ),
              verificationMethod: p.t(
                'La carte « Protection du projet » du tableau de publication '
                    'affiche le même état.',
                'The "Project protection" card on the publishing board shows '
                    'the same state.',
              ),
              glossary: const ['commit', 'branch'],
            )
          : ChecklistStep(
              id: 'common.git',
              level: ActionLevel.analyze,
              kind: StepKind.manual,
              title: p.t(
                'Mettre le projet sous Git',
                'Put the project under Git',
              ),
              objective: p.t(
                'Pouvoir revenir en arrière à tout moment.',
                'Be able to roll back at any time.',
              ),
              explanation: p.t(
                'Aucun dépôt Git n\'a été trouvé. Par sécurité, LaunchPilot ne '
                    'crée pas de dépôt lui-même : dans un terminal, à la racine '
                    'du projet, lance « git init », puis « git add . » et '
                    '« git commit -m \'Version de départ\' ». Relance ensuite '
                    'l\'analyse du projet.',
                'No Git repository was found. For safety, LaunchPilot does not '
                    'create one itself: in a terminal, at the project root, run '
                    '"git init", then "git add ." and "git commit -m '
                    '\'Initial version\'". Then analyze the project again.',
              ),
              whyRequired: p.t(
                'Sans historique, une erreur peut être impossible à annuler.',
                'Without history, a mistake may be impossible to undo.',
              ),
              expectedResult: p.t(
                'Le rapport de détection indique une branche Git.',
                'The detection report shows a Git branch.',
              ),
              verificationMethod: p.t(
                'Relance l\'analyse : la section Git affiche la branche.',
                'Analyze again: the Git section shows the branch.',
              ),
              glossary: const ['commit'],
            ),
    );

    if (r.sensitiveFiles.isNotEmpty) {
      steps.add(
        ChecklistStep(
          id: 'common.secrets',
          level: ActionLevel.analyze,
          kind: StepKind.manual,
          dependsOn: const ['common.git'],
          title: p.t(
            'Protéger les fichiers sensibles',
            'Protect sensitive files',
          ),
          objective: p.t(
            'S\'assurer qu\'aucun secret ne sera versionné ni publié.',
            'Make sure no secret will be committed or published.',
          ),
          summary: p.t(
            'Fichiers sensibles détectés : vérifie qu\'ils sont ignorés.',
            'Sensitive files detected: check they are ignored.',
          ),
          explanation: p.t(
            'L\'analyse a repéré des fichiers sensibles (sans les lire). '
                'S\'ils sont envoyés sur un dépôt public, n\'importe qui peut '
                'les récupérer. La carte « Protection du projet » propose de '
                'les ajouter au .gitignore, avec un aperçu avant écriture.',
            'The analysis found sensitive files (without reading them). If '
                'pushed to a public repository, anyone can get them. The '
                '"Project protection" card offers to add them to .gitignore, '
                'with a preview before writing.',
          ),
          whyRequired: p.t(
            'Une clé publiée doit être révoquée et remplacée.',
            'A published key must be revoked and replaced.',
          ),
          affectedFiles: r.sensitiveFiles,
          expectedResult: p.t(
            'Tous ces fichiers sont ignorés par Git.',
            'All these files are ignored by Git.',
          ),
          risks: [
            p.t(
              'Un fichier déjà commité reste dans l\'historique même s\'il est '
                  'ajouté au .gitignore.',
              'A file already committed stays in history even once added to '
                  '.gitignore.',
            ),
          ],
          verificationMethod: p.t(
            'La carte « Protection du projet » n\'affiche plus d\'alerte de '
                'fichiers sensibles.',
            'The "Project protection" card no longer shows a sensitive files '
                'warning.',
          ),
          rollbackMethod: p.t(
            'Le bouton « Restaurer » annule l\'ajout au .gitignore.',
            'The "Restore" button undoes the .gitignore change.',
          ),
          glossary: const ['keystore'],
        ),
      );
    }

    final pub = pubPackage(p);
    if (pub != null && p.hasTech('flutter')) {
      steps.addAll([
        ChecklistStep(
          id: 'common.flutter.doctor',
          level: ActionLevel.analyze,
          kind: StepKind.command,
          title: p.t(
            'Vérifier l\'installation Flutter',
            'Check the Flutter install',
          ),
          objective: p.t(
            'Confirmer que les outils de chaque plateforme sont prêts.',
            'Confirm each platform\'s tools are ready.',
          ),
          explanation: p.t(
            '« flutter doctor » contrôle Flutter, le SDK Android, Chrome et la '
                'chaîne Linux. Une croix rouge signale un outil manquant pour '
                'une plateforme : ce n\'est bloquant que si tu vises cette '
                'plateforme.',
            '"flutter doctor" checks Flutter, the Android SDK, Chrome and the '
                'Linux toolchain. A red cross flags a tool missing for one '
                'platform: it only matters if you target that platform.',
          ),
          whyRequired: p.t(
            'Un build échoue si un outil manque.',
            'A build fails when a tool is missing.',
          ),
          commands: [
            command(p, 'flutter', const ['doctor', '-v'], pkg: pub),
          ],
          expectedResult: p.t(
            'Des coches vertes pour les plateformes visées.',
            'Green ticks for the targeted platforms.',
          ),
          verificationMethod: p.t(
            'Lis chaque ligne [✓] / [✗] dans la sortie du terminal.',
            'Read each [✓] / [✗] line in the terminal output.',
          ),
          glossary: const ['flutterDoctor'],
        ),
        ChecklistStep(
          id: 'common.flutter.deps',
          level: ActionLevel.analyze,
          kind: StepKind.command,
          title: p.t('Installer les dépendances', 'Install dependencies'),
          objective: p.t(
            'Télécharger les bibliothèques déclarées dans pubspec.yaml.',
            'Download the libraries declared in pubspec.yaml.',
          ),
          explanation: p.t(
            '« flutter pub get » récupère les paquets et met à jour '
                'pubspec.lock. Seuls des fichiers générés sont modifiés.',
            '"flutter pub get" fetches packages and updates pubspec.lock. '
                'Only generated files change.',
          ),
          whyRequired: p.t(
            'L\'analyse et le build en ont besoin.',
            'Analysis and build need them.',
          ),
          affectedFiles: const ['pubspec.lock', '.dart_tool/'],
          commands: [
            command(p, 'flutter', const ['pub', 'get'], pkg: pub),
          ],
          expectedResult: p.t('« Got dependencies! »', '"Got dependencies!"'),
          verificationMethod: p.t(
            'Le code de sortie est 0.',
            'The exit code is 0.',
          ),
          glossary: const ['dependencies'],
        ),
        ChecklistStep(
          id: 'common.flutter.analyze',
          level: ActionLevel.analyze,
          kind: StepKind.command,
          dependsOn: const ['common.flutter.deps'],
          title: p.t('Analyser le code', 'Analyze the code'),
          objective: p.t(
            'Repérer les erreurs avant de construire.',
            'Catch errors before building.',
          ),
          explanation: p.t(
            'L\'analyseur lit le code sans l\'exécuter et signale erreurs, '
                'avertissements et conseils. Les erreurs feraient échouer le '
                'build de production.',
            'The analyzer reads the code without running it and reports '
                'errors, warnings and hints. Errors would make the release '
                'build fail.',
          ),
          whyRequired: p.t(
            'Un code qui ne compile pas ne peut pas être publié.',
            'Code that does not compile cannot be published.',
          ),
          commands: [
            command(p, 'flutter', const ['analyze'], pkg: pub),
          ],
          expectedResult: p.t('« No issues found! »', '"No issues found!"'),
          verificationMethod: p.t(
            'Code de sortie 0 et aucune ligne « error ».',
            'Exit code 0 and no "error" line.',
          ),
          glossary: const ['staticAnalysis'],
        ),
        ChecklistStep(
          id: 'common.flutter.test',
          level: ActionLevel.analyze,
          kind: StepKind.command,
          dependsOn: const ['common.flutter.deps'],
          title: p.t('Lancer les tests', 'Run the tests'),
          objective: p.t(
            'Vérifier que rien n\'est cassé.',
            'Check that nothing is broken.',
          ),
          explanation: p.t(
            '« flutter test » exécute les tests du dossier test/. S\'il '
                'n\'existe pas, la commande échoue : c\'est le signe qu\'il '
                'serait utile d\'écrire quelques tests.',
            '"flutter test" runs the tests in test/. If the folder does not '
                'exist, the command fails: a sign some tests would help.',
          ),
          whyRequired: p.t(
            'Un test qui échoue révèle une régression avant tes utilisateurs.',
            'A failing test reveals a regression before your users do.',
          ),
          commands: [
            command(p, 'flutter', const ['test'], pkg: pub),
          ],
          expectedResult: p.t('« All tests passed! »', '"All tests passed!"'),
          verificationMethod: p.t('Code de sortie 0.', 'Exit code 0.'),
          glossary: const ['tests'],
        ),
      ]);
    }

    final node = nodePackage(p);
    if (node != null) {
      final mgr = node.manager;
      steps.add(
        ChecklistStep(
          id: 'common.node.install',
          level: ActionLevel.analyze,
          kind: StepKind.command,
          title: p.t('Installer les dépendances', 'Install dependencies'),
          objective: p.t(
            'Installer les paquets déclarés dans package.json.',
            'Install the packages declared in package.json.',
          ),
          explanation: p.t(
            '« $mgr install » installe les dépendances dans node_modules en '
                'suivant le fichier de verrouillage.',
            '"$mgr install" installs dependencies in node_modules following '
                'the lock file.',
          ),
          whyRequired: p.t('Le build en a besoin.', 'The build needs them.'),
          affectedFiles: const ['node_modules/'],
          commands: [
            command(p, mgr, const ['install'], pkg: node),
          ],
          expectedResult: p.t('Code de sortie 0.', 'Exit code 0.'),
          verificationMethod: p.t(
            'Le dossier node_modules existe.',
            'The node_modules folder exists.',
          ),
          glossary: const ['dependencies'],
        ),
      );
      for (final (script, glossary) in [
        ('lint', 'staticAnalysis'),
        ('test', 'tests'),
      ]) {
        if (!node.scripts.containsKey(script)) continue;
        steps.add(
          ChecklistStep(
            id: 'common.node.$script',
            level: ActionLevel.analyze,
            kind: StepKind.command,
            dependsOn: const ['common.node.install'],
            title: p.t('Script « $script »', '"$script" script'),
            objective: p.t(
              'Lancer le script « $script » du projet.',
              'Run the project\'s "$script" script.',
            ),
            explanation: p.t(
              'Ce script est défini dans package.json : '
                  '« ${node.scripts[script]} ».',
              'This script is defined in package.json: '
                  '"${node.scripts[script]}".',
            ),
            whyRequired: p.t(
              'Il vérifie la qualité avant le build.',
              'It checks quality before the build.',
            ),
            commands: [
              command(p, mgr, ['run', script], pkg: node),
            ],
            expectedResult: p.t('Code de sortie 0.', 'Exit code 0.'),
            verificationMethod: p.t('Code de sortie 0.', 'Exit code 0.'),
            glossary: [glossary],
          ),
        );
      }
    }

    final version = p.version;
    if (hasGit && version != null) {
      final branch = releaseBranchName(version);
      steps.add(
        ChecklistStep(
          id: 'common.branch',
          level: ActionLevel.prepare,
          kind: StepKind.command,
          dependsOn: const ['common.git'],
          title: p.t(
            'Créer la branche de version',
            'Create the release branch',
          ),
          objective: p.t(
            'Préparer la version $version à part du reste du travail.',
            'Prepare release $version apart from the rest of the work.',
          ),
          explanation: p.t(
            'Une branche dédiée isole les changements de la version. Tu '
                'pourras la fusionner quand tout sera prêt.',
            'A dedicated branch isolates the release changes. You can merge '
                'it when everything is ready.',
          ),
          whyRequired: p.t(
            'Recommandé : facilite la relecture et l\'annulation.',
            'Recommended: eases review and rollback.',
          ),
          commands: [
            command(p, 'git', ['switch', '-c', branch]),
          ],
          expectedResult: p.t(
            '« Switched to a new branch \'$branch\' »',
            '"Switched to a new branch \'$branch\'"',
          ),
          verificationMethod: p.t(
            'La carte « Protection du projet » indique la branche $branch.',
            'The "Project protection" card shows branch $branch.',
          ),
          rollbackMethod: p.t(
            'Revenir sur ta branche précédente avec ton outil Git habituel.',
            'Switch back to your previous branch with your usual Git tool.',
          ),
          requiresConfirmation: true,
          glossary: const ['branch'],
        ),
      );
    }

    steps.addAll([
      ChecklistStep(
        id: 'common.version',
        level: ActionLevel.prepare,
        kind: StepKind.manual,
        toolTab: 'version',
        title: p.t('Fixer le numéro de version', 'Set the version number'),
        objective: p.t(
          version == null
              ? 'Donner un numéro unique à la nouvelle version.'
              : 'Inscrire la version $version dans le projet.',
          version == null
              ? 'Give the new release a unique number.'
              : 'Write version $version into the project.',
        ),
        summary: p.t(
          'Nom de version + numéro de build en hausse.',
          'Version name + increased build number.',
        ),
        explanation: p.t(
          'La version visible suit le versionnage sémantique ; le numéro de '
              'build doit augmenter à chaque envoi sur un store. L\'outil '
              '« Version » propose le prochain numéro et ne modifie que la '
              'ligne concernée, après aperçu.',
          'The visible version follows semantic versioning; the build number '
              'must increase with every store upload. The "Version" tool '
              'suggests the next number and only changes that line, after a '
              'preview.',
        ),
        whyRequired: p.t(
          'Un store refuse deux envois avec le même numéro de build.',
          'A store rejects two uploads with the same build number.',
        ),
        affectedFiles: [
          if (pub != null) pub.manifest,
          if (node != null) node.manifest,
        ],
        expectedResult: p.t(
          'Le manifeste porte la nouvelle version.',
          'The manifest carries the new version.',
        ),
        verificationMethod: p.t(
          'Ouvre le manifeste et lis la ligne « version ».',
          'Open the manifest and read the "version" line.',
        ),
        glossary: const ['semver', 'buildNumber'],
      ),
      ChecklistStep(
        id: 'common.changelog',
        level: ActionLevel.prepare,
        kind: StepKind.manual,
        toolTab: 'changelog',
        dependsOn: const ['common.version'],
        title: p.t('Rédiger le changelog', 'Write the changelog'),
        objective: p.t(
          'Expliquer ce qui change dans cette version.',
          'Explain what changes in this release.',
        ),
        explanation: p.t(
          'Le changelog résume les nouveautés et corrections, pour les '
              'développeurs ou le grand public. L\'outil « Changelog » le '
              'prépare à partir des commits ; tu le relis avant écriture.',
          'The changelog summarizes features and fixes, for developers or '
              'the public. The "Changelog" tool drafts it from commits; you '
              'review it before writing.',
        ),
        whyRequired: p.t(
          'Les stores et les utilisateurs l\'affichent.',
          'Stores and users display it.',
        ),
        expectedResult: p.t(
          'Un texte clair, rangé par nouveautés et corrections.',
          'A clear text, grouped by features and fixes.',
        ),
        verificationMethod: p.t(
          'Relis-le comme le ferait un utilisateur.',
          'Read it as a user would.',
        ),
        glossary: const ['changelog', 'commit'],
      ),
    ]);

    final targets = p.selectedTargets;
    final stores = targets.contains('android') || targets.contains('ios');
    final listed = stores || targets.contains('web');
    if (listed) {
      steps.addAll([
        ChecklistStep(
          id: 'common.icons',
          level: ActionLevel.prepare,
          kind: StepKind.manual,
          toolTab: 'icons',
          title: p.t('Préparer les icônes', 'Prepare the icons'),
          objective: p.t(
            'Fournir l\'icône dans toutes les tailles demandées.',
            'Provide the icon in every required size.',
          ),
          explanation: p.t(
            'À partir d\'une image carrée d\'au moins 1024 px, l\'outil '
                '« Icônes » génère chaque taille sans déformer l\'image. Tu '
                'vois chaque fichier avant qu\'il soit remplacé.',
            'From a square image of at least 1024 px, the "Icons" tool '
                'generates every size without distorting the image. You see '
                'each file before it is replaced.',
          ),
          whyRequired: p.t(
            'Une icône manquante ou floue fait refuser ou dévaloriser '
                'l\'application.',
            'A missing or blurry icon gets the app rejected or looks poor.',
          ),
          expectedResult: p.t(
            'Les icônes de chaque plateforme visée sont à jour.',
            'The icons of every targeted platform are up to date.',
          ),
          verificationMethod: p.t(
            'Lance l\'application : la nouvelle icône apparaît.',
            'Launch the app: the new icon shows up.',
          ),
          rollbackMethod: p.t(
            'Le bouton « Restaurer » remet les anciennes icônes.',
            'The "Restore" button puts the old icons back.',
          ),
          glossary: const ['storeListing'],
        ),
        ChecklistStep(
          id: 'common.texts',
          level: ActionLevel.prepare,
          kind: StepKind.manual,
          toolTab: 'texts',
          title: p.t('Rédiger la fiche', 'Write the listing'),
          objective: p.t(
            'Préparer le nom, les descriptions et les mots-clés.',
            'Prepare the name, descriptions and keywords.',
          ),
          explanation: p.t(
            'Chaque store limite la longueur des champs : les compteurs '
                'l\'indiquent. L\'IA peut proposer un premier jet à partir de '
                'ton pitch ; tu gardes la main sur le texte final.',
            'Each store limits field length: the counters show it. The AI '
                'can suggest a first draft from your pitch; you keep control '
                'over the final text.',
          ),
          whyRequired: p.t(
            'La fiche est obligatoire pour publier.',
            'The listing is required to publish.',
          ),
          expectedResult: p.t(
            'Des textes relus, dans les limites, enregistrés dans la session.',
            'Reviewed texts, within limits, saved in the session.',
          ),
          verificationMethod: p.t(
            'Aucun compteur n\'est en rouge.',
            'No counter is red.',
          ),
          glossary: const ['storeListing'],
        ),
      ]);
    }
    if (stores) {
      steps.add(
        ChecklistStep(
          id: 'common.screenshots',
          level: ActionLevel.prepare,
          kind: StepKind.manual,
          toolTab: 'screenshots',
          title: p.t('Préparer les captures', 'Prepare the screenshots'),
          objective: p.t(
            'Montrer l\'application aux formats acceptés par les stores.',
            'Show the app in the formats the stores accept.',
          ),
          explanation: p.t(
            'Importe tes captures : l\'outil contrôle leurs dimensions, '
                'permet de masquer les données personnelles, puis ajoute un '
                'fond et une légende.',
            'Import your screenshots: the tool checks their size, lets you '
                'hide personal data, then adds a background and a caption.',
          ),
          whyRequired: p.t(
            'Les stores exigent au moins deux captures.',
            'Stores require at least two screenshots.',
          ),
          risks: [
            p.t(
              'Une capture peut révéler un e-mail, un nom ou une adresse : '
                  'masque-les avant export.',
              'A screenshot may reveal an email, a name or an address: hide '
                  'them before exporting.',
            ),
          ],
          affectedFiles: const ['store_assets/screenshots/'],
          expectedResult: p.t(
            'Des captures au bon format dans store_assets/screenshots/.',
            'Correctly sized screenshots in store_assets/screenshots/.',
          ),
          verificationMethod: p.t(
            'Chaque capture affiche une pastille verte pour le store visé.',
            'Each screenshot shows a green pill for the target store.',
          ),
          glossary: const ['storeListing'],
        ),
      );
    }
    steps.add(
      ChecklistStep(
        id: 'common.legal',
        level: ActionLevel.prepare,
        kind: StepKind.manual,
        toolTab: 'legal',
        title: p.t('Préparer les documents légaux', 'Prepare legal documents'),
        objective: p.t(
          'Disposer d\'une politique de confidentialité et de mentions '
              'légales à relire.',
          'Have a privacy policy and a legal notice to review.',
        ),
        explanation: p.t(
          'Un questionnaire, pré-rempli d\'après l\'analyse, produit des '
              'modèles modifiables. Ce sont des modèles : ils ne garantissent '
              'pas la conformité juridique et doivent être relus.',
          'A questionnaire, prefilled from the analysis, produces editable '
              'templates. They are templates: they do not guarantee legal '
              'compliance and must be reviewed.',
        ),
        whyRequired: p.t(
          'Les stores exigent une politique de confidentialité accessible.',
          'Stores require an accessible privacy policy.',
        ),
        affectedFiles: const ['legal/'],
        risks: [
          p.t(
            'Un document inexact engage l\'éditeur : fais-le relire en cas '
                'de doute.',
            'An inaccurate document binds the publisher: have it reviewed '
                'when in doubt.',
          ),
        ],
        expectedResult: p.t(
          'Les documents sont écrits dans legal/ et publiés en ligne.',
          'The documents are written in legal/ and published online.',
        ),
        verificationMethod: p.t(
          'L\'adresse de la politique s\'ouvre dans un navigateur.',
          'The policy URL opens in a browser.',
        ),
        glossary: const ['privacyPolicy'],
      ),
    );
    return steps;
  }
}
