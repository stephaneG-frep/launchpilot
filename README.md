# LaunchPilot

Assistant pédagogique pour préparer, contrôler, construire et publier des
projets (Flutter, web, PWA…). Application Flutter desktop, d'abord pour
Linux/Lubuntu. Le cahier des charges complet est dans [SPEC.md](SPEC.md).

> **Version 1.0.0 — les 11 phases du cahier des charges sont réalisées.**
> Projets et sessions, détection, checklist pédagogique, moteur de commandes
> sécurisé, contenus, Web/PWA, Android, iOS via CI, **chat contextualisé**,
> **rapports HTML imprimables en PDF**, historique et **aide complète**.
> Aucune écriture sans aperçu, aucune publication sans confirmation renforcée.

## Documentation

| Document | Contenu |
| --- | --- |
| [docs/INSTALLATION.md](docs/INSTALLATION.md) | Installer la version compilée ou compiler depuis les sources |
| [docs/UTILISATION.md](docs/UTILISATION.md) | Guide d'utilisation par écran et par cible |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Principes, sécurité, données, arborescence, décisions |
| [docs/SAUVEGARDE.md](docs/SAUVEGARDE.md) | Emplacement des données, sauvegarde, restauration, remise à zéro |
| [docs/DEPANNAGE.md](docs/DEPANNAGE.md) | Problèmes courants et solutions |
| [docs/TESTS.md](docs/TESTS.md) | Tests automatisés et vérifications réelles |
| [docs/LIVRAISON.md](docs/LIVRAISON.md) | Contenu de la livraison et empreintes |

## Prérequis sous Linux (Ubuntu / Lubuntu 22.04)

1. Flutter stable (testé avec Flutter 3.47.2, Dart 3.13.2).
2. Chaîne de compilation Linux desktop et bibliothèques système :

   ```bash
   sudo apt install clang cmake ninja-build pkg-config \
     libgtk-3-dev libsecret-1-dev liblzma-dev libstdc++-12-dev
   ```

3. Un service de trousseau compatible *Secret Service* lancé et déverrouillé
   (gnome-keyring, déjà présent sur Lubuntu, ou KWallet). Sans lui, l'écran
   Paramètres affiche un message clair et la saisie des clés est bloquée.

Vérification : `flutter doctor` doit afficher `[✓] Linux toolchain`.

## Lancer l'application

```bash
cd launchpilot
flutter pub get
flutter run -d linux            # mode debug
flutter build linux --release   # exécutable dans build/linux/x64/release/bundle/
./build/linux/x64/release/bundle/launchpilot
```

Pour découvrir l'interface sans projet réel : **Accueil → « Découvrir le
mode démo »** ou **Paramètres → Mode démo**. Toutes les données de démo sont
fictives et signalées par une bannière et des étiquettes « DÉMO ».

### Projets et sessions

- **Accueil → « Choisir un dossier… »** ouvre le sélecteur natif.
  **« Saisir un chemin »** reste possible (avec un bouton Parcourir).
- Chaque projet affiche sa date de dernière ouverture, son étoile de favori
  et sa progression. Un dossier déplacé ou supprimé est signalé
  « Dossier introuvable » avec un bouton **Relocaliser**.
- **Tableau de publication → « Nouvelle session »** : une session par version
  préparée (au plus une active par projet), reprise depuis l'accueil, close
  après confirmation. Le projet ouvert est mémorisé d'un lancement à l'autre.
- **Retirer de la liste** annonce ce qui sera effacé (sessions, étapes) et ne
  touche jamais aux fichiers du projet.
- **Paramètres → Données locales** : emplacement de la base, volumes, et
  effacement complet protégé par la saisie du mot `EFFACER`. Les clés API ne
  sont pas concernées.

Base : `~/.local/share/com.nabucode.launchpilot/launchpilot.sqlite`.

### Détection (écran Rapport de détection)

- **Analyser le projet** : parcours en lecture seule, dans un isolat, borné
  (20 000 fichiers, profondeur 12, 512 Kio par fichier, 8 Mio au total, 20 s).
  Liens symboliques jamais suivis ; `.git`, `node_modules`, `build`,
  `.dart_tool`, `.next`, `dist`, caches, `fixtures`… ignorés ; fichiers
  sensibles (`key.properties`, keystores, `.env`…) **repérés mais jamais lus**.
  Une limite atteinte rend l'analyse « partielle », ce qui est affiché.
- Reconnaît Flutter (et ses six cibles), Dart, Node.js, React, Vue, Angular,
  Next.js, Nuxt, Astro, Svelte/SvelteKit, Vite, les sites statiques, et à
  titre informatif Python, Django, Flask et FastAPI. Chaque détection affiche
  sa confiance et ses preuves (fichier et élément trouvé).
- Relève aussi : gestionnaire de paquets et scripts, Git (branche, tags, lus
  dans `.git` sans exécuter git), icônes, captures, Fastlane, CI, hébergement,
  PWA, SEO, documents juridiques, signature, permissions Android/iOS et SDK
  tiers (statistiques, publicité, plantages, notifications, back-end, paiement).
- **Cibles** : une case par plateforme. Elles suivent la détection jusqu'à
  « Valider les cibles » ; ensuite, tes choix sont conservés à chaque nouvelle
  analyse.

### Terminal et moteur de commandes

- Commandes **proposées** d'après la détection (git, `flutter pub get/analyze/test`,
  `flutter build` pour les cibles retenues, scripts npm/pnpm/yarn/bun) ou
  **saisies** (découpées sans aucune interprétation de shell).
- **Aperçu obligatoire** : commande exacte, dossier, niveau de risque et
  raisons. Confirmation **à usage unique** liée à la commande exacte ;
  confirmation **renforcée** (case à cocher) pour un tag Git.
- Niveaux : *lecture seule* (git status, flutter analyze…), *fichiers générés*
  (build, pub get, npm ci), *modifie le projet* (git add/commit/switch -c,
  npm run…), *interdite* : push, reset --hard, clean, restore/checkout de
  fichiers, config, publication (`npm publish`, `pub publish`), installations
  globales, `npx`/`dlx`, shells, sudo, outils hors liste, chemins hors du
  projet. Tout ce qui n'est pas reconnu est refusé.
- **Mode simulation** (activé par défaut, Paramètres ou bandeau du terminal) :
  seules les commandes en lecture seule s'exécutent.
- Exécution sans shell, dossier de travail vérifié (liens symboliques
  compris), délai, **bouton Arrêter** (SIGTERM puis SIGKILL), stdout/stderr
  séparés, code de sortie, **secrets masqués** à l'affichage et dans le
  **journal** (historique par projet).

### Checklist (écran Checklist pédagogique)

- Construite pour la **session active** à partir du rapport de détection et
  des **cibles retenues**. Chaque cible est un plugin (`LaunchTarget`) ; le
  moteur ne dépend d'aucune cible précise.
- Étapes rangées par niveau (Analyser → Préparer → Construire → Publier) puis
  par dépendances. Une étape est **bloquée** tant que ses prérequis ne sont
  pas terminés (« Termine d'abord : … »).
- Trois types : **commande** (aperçu et exécution par le moteur sécurisé ; le
  résultat fixe le statut, une simulation ne change rien), **vérification**
  (« C'est vérifié ») et **à comprendre** (« J'ai compris »). « Recommencer »
  remet une étape à faire.
- Les étapes de contenu (version, changelog, icônes, textes, captures,
  documents légaux) ont un bouton **Ouvrir l'outil** qui mène à l'outil
  correspondant (`/content?tab=…`), de même que les étapes Web (SEO, PWA,
  audit, hébergement, mise en ligne, DNS, vérification en ligne). Les étapes
  iOS (audit, textes d'accès, manifeste, compte Apple, fiche, CI,
  TestFlight) mènent aux outils iOS et App Store. Les étapes Android (audit,
  permissions, clé, signature, livrables, fiche, Fastlane, piste interne)
  mènent aux outils Android et Play Store.
- **Reprise** : les statuts sont enregistrés ; le contenu des étapes est
  régénéré (nouvelles étapes ajoutées, étapes devenues sans objet retirées,
  par exemple quand une cible est décochée). Le niveau courant de la session
  suit l'avancement.
- **Pédagogie** : Débutant (objectif, explication complète, raison,
  vérification sur demande), Accompagné (résumé), Expert (commande en tête).
  Les termes du lexique cités par une étape s'ouvrent d'un clic.

### Contenus (écran Contenus et aperçus)

Six outils, pour le projet ouvert. **Toute écriture** passe par l'aperçu
(diff pour le texte, miniatures avant/après pour les images), la
confirmation, la sauvegarde et la restauration ciblée de la phase 5.

- **Version** : lit `pubspec.yaml` / `package.json` (y compris dans un
  sous-dossier), propose majeure / mineure / correctif avec numéro de build
  incrémenté, ou une version saisie (validée). Seule la ligne `version` est
  remplacée ; le reste du fichier est conservé à l'identique.
- **Changelog** : lit les commits depuis le dernier tag (sinon les 50
  derniers) par des commandes Git **en lecture seule**. Classement par type
  (commits conventionnels), version **technique** ou **publique** (corrections
  internes masquées), modifiable, reformulation optionnelle par l'IA
  (seuls les messages de commit sont envoyés, après aperçu). Écrit en tête de
  `CHANGELOG.md` (la section d'une même version est remplacée). Le **tag**
  `v<version>` passe par l'aperçu de commande avec **confirmation renforcée**
  et n'est **jamais poussé**.
- **Icônes** : image source contrôlée (≥ 512 px, 1024 px recommandés, carrée,
  transparence signalée). Génération Android (mipmaps 48 → 192 px), iOS
  (`AppIcon.appiconset` + `Contents.json`, fond opaque imposé par Apple), web
  (favicon, `Icon-192/512`, variantes *maskable*). Jamais d'étirement : une
  image non carrée est centrée.
- **Captures** : import de PNG/JPEG/WebP, pastilles de conformité Play Store
  et App Store (iPhone 6,9", 6,5", iPad 13"), **masquage** de zones
  (rectangles opaques, appliqués avant tout traitement), cadre dégradé et
  légende, export au format Play / iPhone / iPad dans
  `store_assets/screenshots/<format>/`.
- **Textes** : titre, sous-titre, descriptions, mots-clés, texte promo, par
  langue (FR/EN), compteurs et limites des stores, aperçus fiche et partage
  social. Proposition par l'IA à partir d'un pitch (aucun fichier envoyé).
  Enregistrés dans la **session** active.
- **Juridique** : avertissement permanent (**modèles à relire, aucune
  garantie de conformité**), questionnaire prérempli d'après la détection
  (permissions, SDK publicitaires/analytiques, hébergement), réponses
  enregistrées dans la session, puis modèles modifiables : politique de
  confidentialité, mentions légales, bannière de consentement (si cookies),
  écrits dans `legal/`.

### Web et PWA (écran Contenus, cible Web retenue)

Quatre outils supplémentaires apparaissent quand la cible **Web** est
retenue. Toute écriture passe par l'aperçu (diff), la confirmation, la
sauvegarde et la restauration ciblée.

- **Site web** : commande de build **déduite du framework et des scripts du
  projet**, jamais inventée (Flutter : `flutter build web --release` →
  `build/web` ; Vite : script `build` → `dist` ; Create React App → `build` ;
  Nuxt `generate` → `.output/public`…). Rendu serveur (Next.js sans export,
  Nuxt sans `generate`) et absence de script sont signalés. Dossier de sortie
  modifiable. **Audit statique** (site construit ou sources + dossier
  public) : title, description, canonical, Open Graph, carte Twitter,
  schema.org, `lang`, `noindex`, robots.txt, sitemap.xml, viewport,
  manifeste et icônes, service worker et hors ligne, textes alternatifs,
  étiquettes, boutons vides, liens internes cassés, contenu mixte HTTP,
  formulaires en HTTP, page 404. **Aperçu local** sur 127.0.0.1 uniquement
  (sans sortie du dossier). **Lighthouse** s'il est installé (sinon guide
  non bloquant) ; rapport dans `lighthouse-report.json`.
- **SEO** : titre, description (compteurs), adresse, image de partage,
  compte X, langue, type schema.org ; aperçus moteur de recherche et partage.
  Écrit `robots.txt` et `sitemap.xml` dans le dossier public et un bloc de
  balises délimité dans la page source (doublons retirés, visibles dans le
  diff). Si le framework gère `<head>` (Next.js…), les balises sont
  affichées à recopier. **Statistiques** Plausible ou Umami (sans cookie) :
  ajout, remplacement ou retrait du script.
- **PWA** : nom, nom court, description, couleurs, mode d'affichage ;
  manifeste fusionné (clés et icônes existantes conservées), lien et
  `theme-color` dans la page, **service worker** hors ligne facultatif
  (`sw.js` + enregistrement). Le service worker automatique de Flutter étant
  déprécié, c'est expliqué.
- **Hébergement** : `firebase.json` + `.firebaserc` (fusion avec l'existant),
  `vercel.json` ou `netlify.toml` (redirections d'application monopage,
  cache), workflow **GitHub Pages** (`--base-href` du dépôt, CNAME,
  `.nojekyll`). **Mise en ligne** (prévisualisation ou production) : outil
  installé, site construit, récapitulatif à cocher (dépôt modifié et mode
  simulation signalés), puis aperçu de la commande avec **confirmation
  renforcée**. La connexion (`firebase login`…) se fait dans ton terminal :
  LaunchPilot ne voit aucun identifiant. GitHub Pages : publication par ton
  push (jamais fait par LaunchPilot). **DNS** recommandés (A/AAAA/CNAME par
  hébergeur ; Firebase : valeurs de la console ; Vercel : à confirmer avec
  `vercel domains inspect`) — **jamais modifiés** ; vérification en lecture
  seule de la résolution. **Vérification en ligne** : HTTPS, redirection
  HTTP → HTTPS, HSTS.
- **Politique de commandes** : `firebase`, `vercel`, `netlify` et
  `lighthouse` sont reconnus, mais seules les **formes exactes** produites
  par LaunchPilot sont acceptées. Un déploiement tapé dans le terminal est
  refusé (« passe par le flux dédié ») ; l'origine de la commande fait partie
  de l'empreinte de confirmation.
- **Paramètres → Hébergement** : hébergeur et outil de statistiques proposés
  par défaut. Les réglages web de chaque projet (identifiants publics, jamais
  de secret) sont supprimés avec le projet.

### Android et Google Play (écran Contenus, cible Android retenue, Flutter)

- **Environnement** : `flutter doctor -v` (lecture seule) résumé sur les
  sections Android (SDK, Java, licences) ; versions de Gradle, du plugin
  Android et de Kotlin lues dans le projet. Les licences s'acceptent dans ton
  terminal (`flutter doctor --android-licenses`, interactif).
- **Audit** : lecture de `build.gradle(.kts)` et `AndroidManifest.xml` —
  identifiant (`com.example` refusé), nom affiché, version issue du pubspec,
  **API cible** (Google Play exige l'API 36 depuis le 31 août 2026 pour les
  nouvelles applications et les mises à jour), signature du build release,
  `debuggable`, trafic HTTP en clair, icônes par densité, secrets de
  signature ignorés par Git. **Permissions** classées (normale, sensible,
  restreinte avec déclaration Play) et confrontées aux plugins du projet
  (permission sans fonction, plugin sans permission, identifiant
  publicitaire).
- **Signature** : commande `keytool` à lancer dans ton terminal (les mots de
  passe ne passent jamais par LaunchPilot), modèle de `key.properties` à
  remplir toi-même, explication de la signature d'application Play.
  « Configurer la signature release » modifie `build.gradle(.kts)` sur le
  modèle de la documentation Flutter (Kotlin ou Groovy), avec diff ; un
  fichier non reconnu n'est pas modifié (extrait à recopier).
  `key.properties` et les keystores ne sont **jamais lus ni écrits** ;
  ajout de `/android/key.properties`, `*.jks`, `*.keystore` au `.gitignore`
  après aperçu.
- **Construction** : `flutter build appbundle --release` et, sur demande,
  `flutter build apk --release` (option par architecture), via l'aperçu de
  commande.
- **Livrables** : chemin, taille, SHA-256 (calculés dans un isolat) et
  signature constatée dans le fichier (certificat « Android Debug » repéré).
- **Play Store** : fiche par langue (fr-FR, en-US) préremplie avec les
  textes de store et le changelog de la session, limites Google Play ;
  icône 512 px et visuel 1024 × 500 générés sans déformation ; captures de
  l'outil Captures. **Fastlane** : `Appfile`, `Fastfile` (lanes `check`,
  `internal` en brouillon, `metadata`) et métadonnées `supply` écrits après
  aperçu, **sans aucune clé**. **Envoi** : Fastlane installé, App Bundle
  signé avec ta clé, chemin de la clé du compte de service (jamais lue ni
  copiée, avertissement si elle est dans le projet), récapitulatif puis
  confirmation renforcée. Le tout premier envoi reste manuel dans la Play
  Console ; LaunchPilot ne publie jamais en production.
- **Politique de commandes** : `fastlane` reconnu pour ses seules lanes
  générées, avec `json_key:/chemin.json` ; un envoi tapé dans le terminal
  est refusé.

### iOS et App Store (écran Contenus, cible iOS retenue, Flutter)

- **Limites de Linux**, affichées en permanence : pas de Xcode, donc ni
  build (`flutter build ios/ipa`), ni signature, ni simulateur, ni envoi
  depuis ce poste. Tout se prépare ici et une CI macOS construit. App Store
  Connect exige **Xcode 26 / SDK iOS 26** depuis le 28 avril 2026.
- **Audit** (sans Xcode) : `Info.plist`, `project.pbxproj`, icône App Store —
  identifiant (`com.example` refusé), nom affiché, version issue du pubspec,
  **textes d'accès exigés par les plugins** (manquants ou trop vagues),
  manifeste de confidentialité (présent et référencé par le projet),
  déclaration de chiffrement, équipe Apple, signature, icône 1024 px sans
  canal alpha.
- **Info.plist** : textes d'accès proposés (à adapter) et
  `ITSAppUsesNonExemptEncryption`, écrits avec diff ; le reste du fichier
  est conservé.
- **Manifeste de confidentialité** : `PrivacyInfo.xcprivacy` préparé depuis
  le questionnaire juridique, puis **ajouté à la cible Runner** dans
  `project.pbxproj` (groupe et phase de ressources, comme Xcode) ; un projet
  non reconnu n'est pas modifié.
- **Étapes chez Apple** expliquées (programme développeur, App ID, fiche App
  Store Connect, clé API, confidentialité de l'app, TestFlight) ainsi que
  certificats et profils de provisioning.
- **CI** : GitHub Actions (runner `macos-26`, lancement manuel uniquement,
  signature automatique par la clé App Store Connect, export `.ipa`, envoi
  TestFlight, `ios/ExportOptions.plist`) ou Codemagic (`codemagic.yaml` :
  `xcode-project use-profiles`, `flutter build ipa`, publication TestFlight
  par l'intégration). Seuls les **noms** des secrets sont indiqués ;
  LaunchPilot ne pousse rien et ne déclenche aucun build.
- **App Store** : fiche par langue (nom, sous-titre, description, mots-clés,
  texte promotionnel, nouveautés) préremplie depuis la session, adresses
  d'assistance et de confidentialité, copyright ; captures iPhone/iPad de
  l'outil Captures ; étiquettes « Confidentialité de l'app » déduites du
  questionnaire ; **Fastlane deliver** (`Appfile`, `Fastfile` avec lanes
  `metadata` et `beta`, métadonnées et captures) sans aucune clé — à lancer
  sur un Mac ou dans la CI.

### Chat avec l'agent

- Utilise le fournisseur choisi dans les Paramètres (sans clé : explication
  et lien vers les Paramètres, rien n'est envoyé).
- Contexte **choisi par l'utilisateur** : résumé du projet (nom, version,
  technologies, cibles — aucun chemin, aucun fichier), état de la checklist,
  dernière commande (sortie déjà masquée), plus les derniers échanges.
- Chaque question passe par le dialogue d'aperçu de la couche LLM (secrets
  masqués, confirmation à usage unique, annulation). Réponse structurée
  (réponse + questions de relance cliquables).
- L'agent ne peut exécuter aucune commande ni modifier aucun fichier ;
  questions rapides proposées (prochaine étape, reformulation, erreur de la
  dernière commande, ce qui reste à faire).
- Historique enregistré dans la session (40 derniers messages), effaçable.

### Rapports et historique

- Historique de **toutes les sessions** (projet, version, statut,
  avancement, rapports exportés).
- **Aperçu du rapport** puis **Exporter en HTML** (emplacement choisi par
  l'utilisateur) : fichier autonome, sans ressource externe, mise en page
  d'impression pour obtenir un **PDF** depuis un navigateur. Contenu :
  résumé de session, technologies et cibles, livrables (taille, SHA-256,
  signature), fichiers créés ou modifiés, commandes (secrets masqués), tests
  et audits (web, Android, iOS recalculés), actions restantes, procédure
  manuelle de publication par cible, lexique des termes cités. Tout le
  contenu est échappé. Chaque export est noté dans la session.

### Aide et lexique

- Guide rapide, **manuel complet** (14 chapitres FR/EN : démarrage, projets,
  détection, checklist, sécurité des commandes, protection, contenus, web,
  Android, iOS, chat, rapports, sauvegarde, dépannage) avec recherche,
  raccourcis clavier et lexique.

### Protection du projet (Tableau de publication)

- État Git en direct : branche, modifications non validées (LaunchPilot n'y
  touche jamais). Proposition de branche `launchpilot/release-<version>`.
- Fichiers sensibles détectés mais non ignorés par Git : proposition d'ajout
  au `.gitignore`, **diff** avant écriture.
- Chaque écriture : vérification du chemin (dans le projet, jamais un fichier
  sensible), contenu inchangé depuis l'aperçu, **sauvegarde** puis écriture
  atomique. Liste exacte des fichiers modifiés ; **Restaurer** fichier par
  fichier, refusé si tu as modifié le fichier entre-temps.
  Sauvegardes : `~/.local/share/com.nabucode.launchpilot/backups/`.

### Fournisseurs d'IA (Paramètres → Intelligence artificielle)

- Pour chaque fournisseur : clé API (trousseau), **modèle** modifiable et
  **Tester la connexion**. Le test liste les modèles du compte (aucun jeton
  consommé) et indique si le modèle choisi est disponible ; on peut ensuite
  choisir un modèle dans cette liste.
- Modèles par défaut : `claude-opus-5-5`, `gpt-5`, `gemini-2.5-pro`,
  `mistral-large-latest`. Seul celui de Claude est garanti à jour ; les
  autres sont des points de départ à vérifier avec le test de connexion.
- **Essai de génération** : question fixe, sans donnée de projet, envoyée au
  fournisseur préféré. Il montre l'aperçu exact de l'envoi (déplié en mode
  Débutant), demande une confirmation, peut être annulé en cours de route et
  affiche la réponse structurée, le modèle et les jetons consommés.

Raccourcis : `Ctrl+1` … `Ctrl+9` et `Ctrl+0` ouvrent les dix écrans (en
AZERTY aussi, et depuis le pavé numérique).

## Tests et qualité

```bash
dart format lib test
flutter analyze
flutter test
```

Les tests n'ont pas besoin de la chaîne Linux ni d'un trousseau : le
stockage des secrets, la base SQLite (en mémoire) et la vérification des
dossiers sont remplacés par des implémentations de test. Le client HTTP des
tests **refuse tout appel réseau** : aucune vraie clé ni aucun vrai
fournisseur n'est utilisé.

| Fichier | Contenu |
| --- | --- |
| `test/unit/settings_test.dart` | Préférences : défauts, persistance, valeurs corrompues, absence de clés dans les préférences |
| `test/unit/api_keys_test.dart` | Validation des clés, dépôt, contrôleur, erreurs du trousseau sans fuite de la valeur |
| `test/unit/catalog_and_glossary_test.dart` | Cohérence du mode démo (FR/EN), invariants de sécurité, lexique, destinations |
| `test/unit/theme_test.dart` | Contraste WCAG des couleurs de statut et du texte, densité du mode Expert |
| `test/widget/navigation_test.dart` | Dix écrans, trois dispositions, raccourcis clavier, boutons « phase ultérieure », débordements |
| `test/widget/settings_screen_test.dart` | Thème, langue, mode, fournisseur, saisie/suppression sécurisée des clés |
| `test/widget/demo_mode_test.dart` | Bannière démo, checklist adaptée au mode, terminal simulé, lexique |
| `test/unit/project_repository_test.dart` | Chemins et versions, projets, favoris, relocalisation, sessions, progression, retrait en cascade, effacement, flux réactif |
| `test/drift/launchpilot/migration_test.dart` | Chaque migration produit le schéma enregistré (index compris), v1 → v2 et v2 → v3 conservent les données, réouverture d'un fichier réel, refus d'une base plus récente, aucune colonne de secret |
| `test/unit/secret_redactor_test.dart` | Masquage : clés Anthropic/OpenAI/Google/AWS, jetons GitHub, JWT, Bearer, mots de passe, variables secrètes, chaînes de connexion, PEM ; idempotence ; fichiers sensibles |
| `test/unit/llm_providers_test.dart` | Pour chacun des 4 fournisseurs (clients HTTP simulés) : test de connexion, génération validée, erreurs HTTP, clé jamais recopiée, délai, annulation, réseau ; spécificités de chaque API |
| `test/unit/llm_service_test.dart` | `PromptBuilder` (exclusions, masquage, refus sans troncature, empreinte) ; confirmation unique et liée au contenu ; clé absente |
| `test/widget/llm_settings_test.dart` | Test de connexion, choix du modèle, erreur de clé, essai de génération (aperçu, envoi, usage, annulation), mode Expert |
| `test/unit/detection_test.dart` | Scanner (dossiers ignorés, liens symboliques, fichiers sensibles non lus, limites, `.git`) et détecteurs sur 5 projets d'exemple (`test/fixtures/projects`) et des instantanés |
| `test/unit/detection_repository_test.dart` | Rapport en base, cibles suivant la détection puis conservées après validation, cascade, flux, analyse réelle en isolat |
| `test/widget/detection_flow_test.dart` | Sélecteur natif, analyse, rapport, correction et validation des cibles, Parcourir, échec, SEO/scripts, débordements |
| `test/unit/command_engine_test.dart` | Découpage des commandes ; ~60 cas de politique (lecture seule → interdite), chemins hors projet ; runner réel : sortie, masquage, délai, annulation, confirmation unique, lien symbolique |
| `test/unit/protection_test.dart` | `git status` (porcelain), vrai dépôt temporaire, `.gitignore`, diff, écrivain (confirmation, contenu changé, fichiers sensibles, hors projet, restauration ciblée et conflit) |
| `test/widget/engine_flow_test.dart` | Aperçu et exécution, simulation, commande interdite, tag, arrêt, journal masqué, protection Git, `.gitignore` avec diff, restauration, branche de version |
| `test/unit/checklist_engine_test.dart` | Plans Flutter/React/mixte, ordre et dépendances, commandes toutes autorisées, lexique, FR/EN, cible « Snap » ajoutée sans toucher au moteur, cycles et anomalies, progression, synchronisation sans écriture inutile |
| `test/widget/checklist_flow_test.dart` | États vides, blocage, étapes manuelles et pédagogiques, commande réussie/simulée/échouée, niveaux d'explication, lexique, reprise après redémarrage, cible retirée, débordements |
| `test/unit/content_domain_test.dart` | Versions sémantiques et réécriture d'une seule ligne, commits conventionnels et changelogs, icônes (contrôles, tailles, pas d'étirement, opacité), captures (formats, masquage), limites des textes, modèles juridiques |
| `test/unit/content_services_test.dart` | Écriture binaire sauvegardée et restaurée, changelog sur un vrai dépôt Git (avec et sans tag), dernière valeur enregistrée par session |
| `test/widget/content_flow_test.dart` | Sur une copie réelle du projet d'exemple : version, changelog + tag en confirmation renforcée, icônes générées, icône trop petite, captures masquées et exportées, textes et compteurs, questionnaire et documents juridiques, lien depuis la checklist |
| `test/unit/web_domain_test.dart` | Plans de build (Flutter, Vite, Next.js, statique), audit (site complet, défauts, monopage, manifeste), SEO (échappement, idempotence, JSON-LD sûr, robots, sitemap), statistiques, PWA, fichiers d'hébergement, commandes de déploiement, DNS, politique (déploiement refusé hors flux dédié, formes exactes), serveur local réel (traversée, lien symbolique), vérification HTTPS |
| `test/widget/web_flow_test.dart` | Sur des copies réelles des projets d'exemple : plan et audit, SEO écrit après aperçu, PWA Flutter, hébergement Firebase + déploiement simulé, déploiement Netlify réellement lancé hors simulation (runner simulé), GitHub Pages et DNS, outils masqués sans cible Web, hébergeur par défaut |
| `test/unit/android_domain_test.dart` | Lecture Gradle (Kotlin, Groovy, commentaires) et manifeste, versions d'outils, lecteur (secrets jamais lus), audit (modèle par défaut, projet prêt, Git, valeurs Flutter, publicité), signature release (Kotlin, Groovy, imports, idempotence, fichier non reconnu), livrables (AAB/APK debug, signés, non signés, SHA-256), `flutter doctor`, fiche et métadonnées supply, Fastfile sans secret, visuels, politique Fastlane |
| `test/widget/android_flow_test.dart` | Sur une copie réelle du projet d'exemple Android : audit, `flutter doctor`, signature et `.gitignore` après aperçu, build et livrable signé en debug, fiche Play + Fastlane écrits, envoi simulé puis réellement lancé hors simulation (runner simulé) |
| `test/unit/ios_domain_test.dart` | Info.plist (premier niveau), pbxproj (cible Runner), lecteur et icône, audit (défauts, projet prêt, manifeste non référencé, alpha, textes vagues), écriture plist (échappement, structure), manifeste depuis le questionnaire, ajout au pbxproj (identifiants uniques, bon groupe et bonne phase), fiche et deliver, Fastfile/ExportOptions sans secret, workflow GitHub et codemagic.yaml validés en YAML |
| `test/widget/ios_flow_test.dart` | Sur une copie réelle du modèle iOS Flutter : limites et audit, Info.plist après aperçu, manifeste ajouté au projet, CI GitHub puis Codemagic, fiche App Store + Fastlane, outils masqués sans cible iOS |
| `test/unit/reports_chat_test.dart` | Rapport HTML (sections, autonome, échappement, anglais, nom de fichier, procédures), chat (résumés sans chemin, checklist, dernière commande, historique limité, JSON), manuel FR/EN et recherche |
| `test/e2e/journeys_test.dart` | Parcours complets : du dossier au rapport exporté (analyse, session, commande, écriture, push refusé, secret masqué dans le rapport) ; chat avec contexte choisi, secret masqué, aucun chemin envoyé, historique après redémarrage ; manuel consultable FR/EN |
| `test/widget/projects_flow_test.dart` | Ajout, session, redémarrage, clôture, favoris, relocalisation, retrait, effacement, séparation démo/réel, débordements |

### Ajouter une cible de publication

Créer une classe qui implémente `LaunchTarget`
(`lib/features/checklist/domain/launch_target.dart`) : identifiant (préfixe
des étapes), libellé, `detect`, `buildChecklist`. L'ajouter à la liste de
`launchTargetsProvider`. Le moteur, l'écran et la persistance ne changent pas.

### Modifier le schéma de la base

```bash
# 1. modifier lib/core/database/tables.dart et incrémenter schemaVersion
dart run build_runner build
dart run drift_dev make-migrations     # schéma vN, assistants et test/drift/launchpilot/
# 2. écrire l'étape fromNToN+1 dans AppDatabase._steps et compléter
#    test/drift/launchpilot/migration_test.dart (attention : make-migrations
#    peut régénérer ce fichier, y reporter les tests existants)
```

## Architecture

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
- **Couches seulement si utiles** : `settings` a les quatre couches ; les
  écrans encore vides n'ont que `presentation`.
- **Préférences simples** dans `SharedPreferences` (`lp.*`). **Clés API**
  uniquement dans le trousseau via `SecretStore` (`launchpilot.llm.<fournisseur>.api_key`).
  Aucune API ne renvoie la clé à l'interface ; le champ est masqué, sans
  suggestions, et vidé après l'enregistrement. Les erreurs natives du
  trousseau sont réduites à leur code pour ne jamais recopier une valeur.
- **Drift/SQLite** (génération de code imposée par Drift) : projets, cibles,
  sessions, étapes de checklist et entrées de session (textes validés,
  rapports, audits). Clés étrangères actives, suppression en cascade. Une
  étape stocke son suivi (statut, note) ; son contenu pédagogique sera
  reconstruit par les cibles en phase 6. Aucune colonne ne peut contenir de
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

## Limites connues (version 1.0.0)

- Le chat n'a jamais appelé un vrai fournisseur pendant le développement
  (pas de clé) : il est vérifié avec un client HTTP simulé.
- Le rapport est un HTML imprimable : le PDF s'obtient par l'impression du
  navigateur (pas de génération PDF intégrée, pour ne pas ajouter de
  dépendance).
- Les tests de bout en bout pilotent l'application complète dans
  l'environnement de test Flutter (vrais dossiers, vraie base en mémoire,
  processus et réseau simulés) ; ils ne pilotent pas la fenêtre réelle.
- Windows et macOS ne sont pas générés : LaunchPilot est livré pour Linux.

### Rappel des limites de la Phase 10

- Aucun build iOS n'a pu être exécuté (Linux) : la configuration CI est
  vérifiée par des tests (YAML valide, commandes attendues) mais pas lancée
  sur un vrai runner macOS ni avec un vrai compte Apple.
- L'envoi depuis GitHub Actions utilise `xcrun altool --upload-app` avec la
  clé API ; à valider lors du premier vrai lancement (Codemagic gère
  l'envoi lui-même).
- L'ajout du manifeste au `project.pbxproj` suit exactement le modèle
  Flutter actuel ; il n'a pas pu être ouvert dans Xcode.
- Les étiquettes « Confidentialité de l'app » se saisissent à la main dans
  App Store Connect ; les textes d'accès proposés sont à adapter.
- La liste plugins → textes d'accès couvre les plugins courants seulement.

### Rappel des limites de la Phase 9

- Aucun envoi réel vers Google Play n'a été fait (Fastlane non installé, pas
  de compte de service) : l'envoi est vérifié par les tests de politique et
  un runner simulé.
- Vérifié pour de vrai sur ce poste : un App Bundle Flutter de débogage est
  bien repéré comme tel ; après « Configurer la signature release » sur le
  modèle Flutter actuel (AGP 9.1, Gradle 9.3), le build compile et l'App
  Bundle est vu comme signé (certificat confirmé par `jarsigner`).
- L'API cible fournie par Flutter (`flutter.targetSdkVersion`) n'est pas
  résolue : sa valeur dépend de ta version de Flutter.
- La cohérence permissions/plugins repose sur une liste de plugins connus ;
  un plugin absent de la liste peut donner un faux « sans fonction ».
- Les captures pour tablette et la vidéo de la fiche ne sont pas gérées.

### Rappel des limites de la Phase 8

- Aucun déploiement réel ni audit Lighthouse n'a été exécuté pendant le
  développement (outils non installés sur le poste) : les commandes sont
  vérifiées par les tests de politique et un runner simulé.
- L'audit est statique : pas de rendu dans un navigateur, pas de
  vérification des liens externes ; le contrôle responsive et hors ligne se
  fait à la main dans l'aperçu local.
- Le dossier de sortie d'Angular, SvelteKit et Next.js (export) est une
  convention à confirmer. Les frameworks à rendu serveur ne sont pas
  déployés par LaunchPilot.
- Les valeurs DNS Vercel affichées sont les valeurs générales ; Firebase ne
  donne les siennes que dans sa console.
- Vercel/Netlify peuvent demander de lier le dossier à un projet
  (`vercel link`, `netlify link`) dans ton propre terminal au premier usage.

### Rappel des limites de la Phase 7

- Les documents juridiques sont des **modèles** : ils ne garantissent pas la
  conformité et doivent être relus (par un professionnel si besoin).
- Les icônes adaptatives Android (premier plan / arrière-plan séparés) et
  les icônes de bureau (Linux, Windows, macOS) ne sont pas générées.
- Les captures ne sont pas prises automatiquement : elles sont importées. Le
  masquage est manuel (rectangles) ; aucune détection automatique de données
  personnelles.
- Les textes de store sont enregistrés dans la session, pas encore envoyés
  aux consoles (phases 9 et 10).
- Le changelog s'appuie sur les messages de commit ; des messages non
  conventionnels sont rangés dans « Autres changements ».

### Rappel des limites de la Phase 6

- Les étapes « vérification » sont déclarées faites par l'utilisateur ;
  LaunchPilot ne contrôle pas encore automatiquement leur résultat.
- Une cible décochée puis recochée repart de « à faire » pour ses étapes.
- Les automatismes de SEO, déploiement, Play Store et iOS arrivent avec les
  phases 8 à 10 ; leurs étapes sont manuelles d'ici là.

### Rappel des limites de la Phase 5

- Les sauvegardes conservent l'ancien contenu des fichiers modifiés par
  LaunchPilot (jamais les fichiers sensibles, qu'il n'écrit pas) ; elles sont
  supprimées avec le projet ou par « Effacer toutes les données locales ».
- Les vérifications Git automatiques (état, fichiers ignorés) sont des
  commandes en lecture seule lancées sans aperçu et non journalisées ; tout
  ce que l'utilisateur déclenche passe par l'aperçu et le journal.
- Les scripts npm/pnpm/yarn/bun sont classés « modifie le projet » : leur
  contenu, défini par le projet, n'est pas analysé.
- Un seul processus à la fois dans le terminal.

### Rappel des limites de la Phase 4

- Les modifications Git non validées nécessitent `git status` : elles seront
  vérifiées avec le moteur de commandes (phase 5).
- Les permissions et SDK sont relevés, mais l'analyse de cohérence
  (permission déclarée sans fonction correspondante) viendra avec les audits
  Android/iOS (phases 7 et 9).
- Dans un dépôt contenant plusieurs projets, c'est le manifeste le plus
  proche de la racine qui est retenu pour chaque écosystème ; les preuves
  indiquent toujours le chemin.
- Pas d'annulation pendant l'analyse : elle est bornée à 20 s.

### Rappel des limites de la Phase 3

- **Aucun appel réel n'a été testé** : pas de clé disponible pendant le
  développement. Les formats d'API sont couverts par des tests simulés ;
  un premier test de connexion avec ta clé confirmera chaque fournisseur.
- Réponses non diffusées en continu (pas de streaming) : délai de 90 s par
  génération, 20 s pour le test de connexion.
- L'usage est affiché en jetons, sans estimation de coût (les tarifs varient
  selon le compte et le modèle).
- Le chat avec l'agent arrive en phase 11 ; l'envoi d'extraits de projet
  sera utilisé à partir des phases de détection et de checklist.

### Rappel des limites de la Phase 2

- Ajout d'un projet par son chemin seulement : le sélecteur natif et
  l'analyse du contenu (technologies, cibles) arrivent en phase 4.
- Les sessions n'ont pas encore de checklist : son moteur arrive en phase 6.
  La progression affichée est donc de 0 % pour une nouvelle session.
- L'historique des sessions closes est conservé en base mais ne sera
  consultable qu'avec l'écran Rapports (phase 11).
- Pas de commandes ni d'appels LLM : phases 3 et 5.
- Le test de connexion aux fournisseurs arrive en phase 3 ; une clé
  enregistrée n'est vérifiée que sur sa forme.
- Les hébergeurs préférés seront configurables avec le module Web (phase 8).
