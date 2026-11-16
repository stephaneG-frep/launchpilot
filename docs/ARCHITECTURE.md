# Architecture de LaunchPilot 1.0.0

Application Flutter desktop (Linux), Material 3, Riverpod 3 sans génération
de code, GoRouter, Drift/SQLite (schéma v3), traductions ARB français /
anglais. 167 fichiers Dart dans `lib/` (hors traductions générées).

## Principes

1. **Le cœur ne dépend d'aucune plateforme** : chaque cible (commun, Android,
   iOS, Web, Linux, Windows, macOS) est un plugin `LaunchTarget` qui fournit
   ses étapes ; le moteur de checklist ne connaît que l'interface.
2. **Aucune action sans aperçu** : écritures via `ProjectWriter` (diff,
   sauvegarde, écriture atomique, restauration ciblée) ; commandes via le
   `CommandRunner` (politique, aperçu, confirmation à usage unique).
3. **Le LLM conseille, il n'agit pas** : `LlmService` exige une confirmation
   liée à l'empreinte du contenu envoyé ; aucune API ne lui donne accès au
   shell ou au disque.
4. **Secrets** : `flutter_secure_storage` (libsecret) seulement ; masquage
   central (`SecretRedactor`) dans les journaux, les envois à l'IA et les
   rapports ; fichiers de signature jamais lus.

## Modèle de sécurité des commandes

- Exécutable et arguments séparés, `Process.start` sans shell, environnement
  non interactif, délai et annulation.
- Liste blanche : git, flutter, dart, npm, pnpm, yarn, bun, node ; formes
  exactes pour firebase, vercel, netlify, lighthouse et fastlane.
- Niveaux de risque : lecture seule (exécutable en simulation), local,
  sensible (confirmation), interdit. Tag, déploiement et envoi store :
  confirmation renforcée.
- `CommandSpec.purpose` : une publication n'est acceptée que si elle vient du
  flux dédié (récapitulatif) ; l'origine fait partie de l'empreinte de
  confirmation. Tapée dans le terminal, elle est refusée.
- Chemins hors projet, suppressions récursives, sudo, push Git, gestion DNS
  et installations globales : interdits.

## Données

| Table | Contenu |
| --- | --- |
| `projects`, `project_targets` | Projets et cibles retenues |
| `release_sessions` | Sessions de version (une active par projet) |
| `checklist_steps` | Suivi des étapes (statut, note, ordre) |
| `session_entries` | Textes validés, rapports exportés, historique du chat |
| `detection_reports` | Dernier rapport de détection (JSON, chemins relatifs) |
| `command_logs` | Journal des commandes (déjà masqué) |
| `file_changes` | Fichiers écrits, empreintes et sauvegardes |

Préférences simples (`lp.*`) dans SharedPreferences, y compris les réglages
web (`lp.web.<id>`) et iOS (`lp.ios.<id>`) par projet, sans secret.

## Arborescence

```
lib/
  main.dart                  Préférences, ouverture de la base, ProviderScope
  app/                       MaterialApp, GoRouter, coque et navigation
  core/
    database/                Drift : tables, AppDatabase (schéma v3), étapes de
                             migration, observation des tables
    security/                SecretRedactor (masquage, fichiers sensibles)
    domain/                  ActionLevel, ExplanationLevel, StepStatus
    l10n/                    Extensions de traduction et formats de date
    storage/secret_store.dart  Abstraction SecretStore + implémentation libsecret
    theme/                   Thèmes clair/sombre, palette LaunchPilot
    widgets/                 GlassCard, PageFrame, EmptyState, badges…
  features/
    settings/                domain / data / application / presentation
    projects/                domain / data (ProjectRepository, PathInspector) /
                             application (fournisseurs, ProjectActions) / dialogues
    checklist/               Moteur (plan, progression), cibles enfichables
                             (targets/), synchronisation, écran et cartes
    commands/                Politique, runner sans shell, journal, aperçu, terminal
    git/                     État Git (porcelain), .gitignore, carte Protection
    changes/                 Diff, ProjectWriter (texte et binaire, sauvegarde,
                             restauration ciblée)
    content/
      domain/                Version, changelog, icônes, captures, textes,
                             modèles juridiques (code pur, testé)
      data/                  ChangelogService (Git en lecture seule),
                             ContentRepository (valeurs de session)
      application/           Sélecteur d'images, génération en isolat
      presentation/          Écran Contenus et ses outils
    web/
      domain/                Plan de build, audit statique, SEO, PWA,
                             hébergeurs (fichiers, commandes, DNS), Lighthouse
      data/                  SiteReader (lecture bornée), serveur d'aperçu
                             local, vérification HTTPS, DNS, outils installés,
                             réglages web par projet
      application/           Fournisseurs (plan, réglages, outils)
      presentation/          Onglets Site web, SEO, PWA, Hébergement
    android/
      domain/                Lecture Gradle/manifeste, audit, signature
                             release, livrables (SHA-256, signature),
                             fiche Play, Fastlane, visuels
      data/                  AndroidReader (secrets jamais lus)
      application/           Inspection des livrables en isolat
      presentation/          Onglets Android et Play Store
    ios/
      domain/                Info.plist et pbxproj, audit, édition plist,
                             manifeste de confidentialité (et ajout au
                             projet Xcode), fiche App Store, Fastlane, CI
      data/                  IosReader, réglages iOS par projet
      presentation/          Onglets iOS et App Store
    detection/
      domain/                Modèle du rapport, instantané, détecteurs purs
      data/                  ProjectScanner (borné), DetectionRepository
      application/           Analyse en isolat, sélecteur de dossier natif
      presentation/          Rapport, correction des cibles
    llm/
      domain/                LlmProvider, erreurs, annulation,
                             PromptBuilder, vérification de schéma JSON
      data/                  HttpLlmProvider + adaptateurs Anthropic, OpenAI,
                             Mistral (chat completions), Gemini
      application/           LlmService (clé lue au dernier moment, confirmation
                             à usage unique), modèles choisis, client HTTP
      presentation/          Test de connexion, dialogue d'envoi, essai
    checklist/               Modèle ChecklistStep (§ 4 du SPEC) et affichage
    demo/                    Catalogue fictif bilingue
    help/                    Lexique et mode d'emploi
    agent_chat/              Chat : contexte choisi, historique de session
    reports/                 Rapport de session (données, HTML), historique
    home, publication, terminal
  l10n/                      app_fr.arb (modèle), app_en.arb, classes générées
```

Décisions :

- **Riverpod 3 sans génération de code** et **GoRouter** (`ShellRoute` + une
  route par écran, transition en fondu supprimée si les animations sont
  désactivées).
- **Couches seulement si utiles** : `domain` (code pur, testé), `data`
  (disque, base, réseau), `application` (fournisseurs Riverpod),
  `presentation` (écrans).
- **Préférences simples** dans `SharedPreferences` (`lp.*`). **Clés API**
  uniquement dans le trousseau via `SecretStore` (`launchpilot.llm.<fournisseur>.api_key`).
  Aucune API ne renvoie la clé à l'interface ; le champ est masqué, sans
  suggestions, et vidé après l'enregistrement. Les erreurs natives du
  trousseau sont réduites à leur code pour ne jamais recopier une valeur.
- **Drift/SQLite** (génération de code imposée par Drift) : projets, cibles,
  sessions, étapes de checklist et entrées de session (textes validés,
  rapports, audits). Clés étrangères actives, suppression en cascade. Une
  étape stocke son suivi (statut, note) ; son contenu pédagogique est
  reconstruit par les cibles. Aucune colonne ne peut contenir de
  secret (vérifié par test).
- **Flux réactifs** : l'accueil et le tableau se recalculent à chaque
  modification des tables concernées.
- **Vérification des dossiers** derrière `PathInspector` : existence
  uniquement, jamais de lecture du contenu.
- **LLM sans SDK** : aucun SDK officiel n'existe en Dart pour ces API ; les
  adaptateurs font des appels HTTP bruts via `package:http`
  (`AbortableRequest` pour l'annulation et le délai). Le LLM n'a accès ni au
  shell ni au disque.
- **Sorties structurées** : schéma natif chez Anthropic (`output_config.format`)
  et OpenAI (`json_schema` strict) ; mode JSON + schéma dans la consigne chez
  Gemini et Mistral. La réponse est **toujours revérifiée** côté client.
- **Claude** : `anthropic-version: 2023-06-01`, effort `medium` et repli
  serveur `fallbacks: "default"` (beta `server-side-fallback-2026-07-01`) sur
  les modèles récents ; un refus (`stop_reason: refusal`) est signalé.
- **Garde-fous d'envoi** : fichiers sensibles exclus (`key.properties`,
  `.jks`, `.env`…), secrets masqués, contenu trop long refusé (jamais
  tronqué), confirmation liée à l'empreinte SHA-256 du contenu et
  **consommée à la première utilisation**. Les messages d'erreur des
  fournisseurs sont nettoyés (la clé en cours est masquée même si aucun
  motif ne la reconnaît).
- **Messages** : chaque confirmation remplace la précédente au lieu de
  s'ajouter à une file d'attente.
- **Traductions** : libellés d'interface dans les ARB ; les contenus
  (lexique, données de démo) sont dans du code Dart bilingue.
- **Mode Expert** : `VisualDensity.compact` et checklist condensée. **Taille
  du texte** et **animations** appliquées globalement via `MediaQuery`.
- **Accessibilité** : contrastes vérifiés par des tests (≥ 4,5:1 pour les
  statuts), en-têtes sémantiques, infobulles, navigation clavier.
- Windows et macOS ne sont pas générés ; aucun code ne dépend de Linux en
  dehors de `linux/` (titre, taille minimale 420 × 560, fond de fenêtre).


## Tests

Voir [TESTS.md](TESTS.md).
