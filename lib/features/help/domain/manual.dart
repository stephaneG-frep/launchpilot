import '../../settings/domain/app_settings.dart';

/// Chapitre du mode d'emploi intégré.
class ManualSection {
  const ManualSection(this.id, this.title, this.paragraphs);

  final String id;
  final String title;
  final List<String> paragraphs;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        paragraphs.any((p) => p.toLowerCase().contains(q));
  }
}

/// Mode d'emploi complet. Contenu pédagogique bilingue, gardé hors des
/// fichiers ARB comme le lexique.
abstract final class Manual {
  static List<ManualSection> forLanguage(AppLanguage language) {
    final fr = language == AppLanguage.fr;
    ManualSection s(
      String id,
      String tf,
      String te,
      List<String> pf,
      List<String> pe,
    ) => ManualSection(id, fr ? tf : te, fr ? pf : pe);

    return [
      s(
        'start',
        'Démarrer',
        'Getting started',
        [
          'LaunchPilot t\'accompagne de l\'analyse à la publication : Analyser, Préparer, Construire, Publier. Rien n\'est publié, poussé ni modifié sans aperçu et confirmation.',
          'Accueil → « Ajouter un projet » : choisis le dossier du projet. LaunchPilot l\'analyse sans exécuter de code et sans lire les fichiers sensibles.',
          'Démarre ensuite une session de version (ex. 1.2.0) : la checklist, les contenus et le rapport y sont rattachés.',
          'Le mode d\'accompagnement (Débutant, Accompagné, Expert) se règle dans les Paramètres et en haut de la checklist.',
        ],
        [
          'LaunchPilot guides you from analysis to publishing: Analyze, Prepare, Build, Publish. Nothing is published, pushed or changed without a preview and confirmation.',
          'Home → "Add a project": pick the project folder. LaunchPilot analyzes it without running code and without reading sensitive files.',
          'Then start a release session (e.g. 1.2.0): the checklist, contents and report are attached to it.',
          'The guidance mode (Beginner, Guided, Expert) is set in Settings and at the top of the checklist.',
        ],
      ),
      s(
        'projects',
        'Projets et sessions',
        'Projects and sessions',
        [
          'Un projet peut avoir une seule session active ; les sessions closes restent dans l\'historique (écran Rapports).',
          'Un dossier déplacé se relocalise depuis l\'accueil. Retirer un projet supprime ses données dans LaunchPilot, jamais ses fichiers.',
        ],
        [
          'A project can have only one active session; closed sessions stay in the history (Reports screen).',
          'A moved folder can be relocated from Home. Removing a project deletes its data in LaunchPilot, never its files.',
        ],
      ),
      s(
        'detection',
        'Rapport de détection',
        'Detection report',
        [
          'Technologies, cibles (Android, iOS, Web, Linux, Windows, macOS), gestionnaires de paquets, SEO, services et permissions sont affichés avec leurs preuves et un niveau de confiance.',
          'Coche ou décoche les cibles puis valide : la checklist et les outils de Contenus suivent ce choix.',
        ],
        [
          'Technologies, targets (Android, iOS, Web, Linux, Windows, macOS), package managers, SEO, services and permissions are shown with evidence and a confidence level.',
          'Tick or untick targets then confirm: the checklist and Content tools follow this choice.',
        ],
      ),
      s(
        'checklist',
        'Checklist pédagogique',
        'Teaching checklist',
        [
          'Chaque étape indique son objectif, son explication, les fichiers concernés, les risques, la vérification et, si besoin, la restauration.',
          'Une étape est bloquée tant que ses prérequis ne sont pas terminés. « Ouvrir l\'outil » mène à l\'outil de Contenus qui la réalise.',
          'Les étapes « commande » passent par l\'aperçu du moteur sécurisé ; en mode simulation, rien d\'autre que la lecture seule ne s\'exécute.',
        ],
        [
          'Each step shows its goal, explanation, affected files, risks, verification and, when relevant, rollback.',
          'A step is blocked until its prerequisites are done. "Open the tool" leads to the Content tool that performs it.',
          '"Command" steps go through the secure engine preview; in simulation mode, only read-only commands run.',
        ],
      ),
      s(
        'terminal',
        'Terminal et sécurité des commandes',
        'Terminal and command safety',
        [
          'Seuls git, flutter, dart, npm, pnpm, yarn, bun, node et, pour des formes précises, firebase, vercel, netlify, lighthouse et fastlane sont acceptés. Pas de shell, pas de sudo, pas de suppression récursive, rien hors du projet.',
          'Chaque commande est prévisualisée avec son niveau de risque. Tag, déploiement et envoi vers un store demandent une confirmation renforcée, valable une seule fois.',
          'Un push Git ou une publication tapés dans le terminal sont refusés : la publication passe par un flux dédié avec récapitulatif. Le journal masque les secrets.',
        ],
        [
          'Only git, flutter, dart, npm, pnpm, yarn, bun, node and, in precise forms, firebase, vercel, netlify, lighthouse and fastlane are accepted. No shell, no sudo, no recursive deletion, nothing outside the project.',
          'Each command is previewed with its risk level. Tags, deployments and store uploads require a reinforced, single-use confirmation.',
          'A Git push or a publication typed in the terminal is refused: publishing goes through a dedicated flow with a summary. The log masks secrets.',
        ],
      ),
      s(
        'protection',
        'Protection du projet et restauration',
        'Project protection and restore',
        [
          'Avant toute écriture : diff, sauvegarde, écriture atomique et liste exacte des fichiers. Un fichier changé depuis l\'aperçu annule l\'écriture.',
          'Tableau de publication → « Restaurer » remet un fichier dans son état précédent, sauf si tu l\'as modifié entre-temps.',
        ],
        [
          'Before any write: diff, backup, atomic write and exact file list. A file changed since the preview cancels the write.',
          'Publishing board → "Restore" puts a file back to its previous state, unless you changed it meanwhile.',
        ],
      ),
      s(
        'content',
        'Contenus',
        'Content',
        [
          'Version et changelog, icônes (sans étirement), captures (masquage des données personnelles), textes de store et documents juridiques (modèles à relire, sans garantie de conformité).',
        ],
        [
          'Version and changelog, icons (never stretched), screenshots (personal data masking), store texts and legal documents (templates to review, no compliance guarantee).',
        ],
      ),
      s(
        'web',
        'Site web et PWA',
        'Website and PWA',
        [
          'Construction selon le framework, audit statique, aperçu local, Lighthouse s\'il est installé, SEO, PWA, configuration Firebase, Vercel, Netlify ou GitHub Pages.',
          'Mise en ligne : récapitulatif puis confirmation renforcée. Les enregistrements DNS sont affichés, jamais modifiés.',
        ],
        [
          'Framework-aware build, static audit, local preview, Lighthouse if installed, SEO, PWA, Firebase, Vercel, Netlify or GitHub Pages configuration.',
          'Deployment: summary then reinforced confirmation. DNS records are shown, never changed.',
        ],
      ),
      s(
        'android',
        'Android et Google Play',
        'Android and Google Play',
        [
          'Audit (API cible 36, identifiant, permissions), signature release sans jamais lire les secrets, App Bundle, livrables avec SHA-256, fiche Play et Fastlane.',
          'Le premier App Bundle s\'envoie à la main dans la Play Console ; ensuite LaunchPilot peut envoyer en brouillon sur la piste interne.',
        ],
        [
          'Audit (target API 36, ID, permissions), release signing without ever reading secrets, App Bundle, deliverables with SHA-256, Play listing and Fastlane.',
          'The first App Bundle is uploaded by hand in the Play Console; then LaunchPilot can upload drafts to the internal track.',
        ],
      ),
      s(
        'ios',
        'iOS et App Store',
        'iOS and App Store',
        [
          'Sous Linux, aucun build iOS n\'est possible. LaunchPilot audite le projet, complète Info.plist et le manifeste de confidentialité, prépare la fiche, Fastlane et une CI macOS (GitHub Actions ou Codemagic).',
        ],
        [
          'On Linux, no iOS build is possible. LaunchPilot audits the project, completes Info.plist and the privacy manifest, prepares the listing, Fastlane and a macOS CI (GitHub Actions or Codemagic).',
        ],
      ),
      s(
        'chat',
        'Chat avec l\'agent',
        'Chat with the agent',
        [
          'Le chat utilise le fournisseur d\'IA choisi dans les Paramètres. Tu choisis le contexte joint (résumé du projet, checklist, dernière commande) ; aucun fichier n\'est envoyé.',
          'Chaque message passe par un aperçu, secrets masqués, et ta confirmation. L\'agent conseille seulement : il n\'exécute rien. L\'historique est enregistré dans la session.',
        ],
        [
          'The chat uses the AI provider chosen in Settings. You choose the attached context (project summary, checklist, last command); no file is sent.',
          'Each message goes through a preview, with secrets masked, and your confirmation. The agent only advises: it runs nothing. The history is saved in the session.',
        ],
      ),
      s(
        'reports',
        'Rapports et historique',
        'Reports and history',
        [
          'L\'écran Rapports liste toutes les sessions. « Aperçu du rapport » rassemble livrables, fichiers modifiés, commandes, tests, audits, actions restantes, procédure et lexique.',
          'Le rapport est un fichier HTML autonome : ouvre-le dans un navigateur puis Imprimer → Enregistrer au format PDF.',
        ],
        [
          'The Reports screen lists all sessions. "Report preview" gathers deliverables, changed files, commands, tests, audits, remaining actions, procedure and glossary.',
          'The report is a standalone HTML file: open it in a browser then Print → Save as PDF.',
        ],
      ),
      s(
        'backup',
        'Sauvegarde des données',
        'Data backup',
        [
          'Base : ~/.local/share/com.nabucode.launchpilot/launchpilot.sqlite. Sauvegardes des fichiers modifiés : ~/.local/share/com.nabucode.launchpilot/backups/. Préférences : stockage local de l\'application.',
          'Les clés API sont dans le trousseau du système (libsecret) et ne sont jamais copiées ailleurs. Pour sauvegarder LaunchPilot, copie le dossier de données application fermée.',
          'Paramètres → « Effacer toutes les données locales » supprime projets, sessions, journaux et sauvegardes de LaunchPilot (jamais les fichiers de tes projets).',
        ],
        [
          'Database: ~/.local/share/com.nabucode.launchpilot/launchpilot.sqlite. Backups of changed files: ~/.local/share/com.nabucode.launchpilot/backups/. Preferences: the app\'s local storage.',
          'API keys live in the system keyring (libsecret) and are never copied elsewhere. To back up LaunchPilot, copy the data folder while the app is closed.',
          'Settings → "Clear all local data" deletes LaunchPilot\'s projects, sessions, logs and backups (never your project files).',
        ],
      ),
      s(
        'troubleshooting',
        'Dépannage',
        'Troubleshooting',
        [
          'Trousseau indisponible : installe et déverrouille gnome-keyring (ou un service libsecret), puis relance LaunchPilot.',
          'Commande « introuvable » : l\'outil n\'est pas dans le PATH ; installe-le dans ton terminal, LaunchPilot n\'installe rien globalement.',
          'Commande refusée : la politique de sécurité la bloque (voir le motif dans l\'aperçu). Publication et push passent par les flux dédiés ou ton propre terminal.',
          'Analyse partielle : le projet dépasse les limites de lecture ; les dossiers lourds (node_modules, build) sont ignorés.',
          'Erreur d\'IA : vérifie la clé, le modèle et la connexion avec « Tester la connexion » dans les Paramètres.',
        ],
        [
          'Keyring unavailable: install and unlock gnome-keyring (or a libsecret service), then restart LaunchPilot.',
          '"Not found" command: the tool is not on the PATH; install it in your terminal, LaunchPilot installs nothing globally.',
          'Refused command: the security policy blocks it (see the reason in the preview). Publishing and pushing go through the dedicated flows or your own terminal.',
          'Partial analysis: the project exceeds the reading limits; heavy folders (node_modules, build) are skipped.',
          'AI error: check the key, the model and the connection with "Test connection" in Settings.',
        ],
      ),
    ];
  }
}
