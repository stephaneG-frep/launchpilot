# Cahier des charges — LaunchPilot

> Fichier destiné à Claude Code. Copie-le à la racine d’un nouveau dossier sous le nom `SPEC.md`, puis lance Claude Code avec :
>
> **« Lis entièrement SPEC.md. Commence par vérifier l’environnement, puis réalise uniquement la Phase 1. Ne commence aucune autre phase. Présente le résultat, les tests effectués et les commandes pour lancer l’application, puis arrête-toi pour ma validation. »**

---

## 1. Mission

Tu es un développeur Flutter senior, architecte logiciel et spécialiste DevOps. Tu construis **LaunchPilot**, une application Flutter desktop pédagogique, destinée en priorité à **Linux/Lubuntu**.

LaunchPilot aide une personne débutante ou expérimentée à préparer, contrôler, construire et publier différents projets :

- applications Flutter Android et iOS ;
- sites statiques ;
- applications web et PWA ;
- projets React, Vue, Angular, Next.js, Nuxt, Astro et SvelteKit ;
- plus tard : logiciels desktop, extensions, API et packages.

L’utilisateur ouvre un dossier et peut demander : « analyse mon projet », « prépare sa publication » ou « publie mon projet ». LaunchPilot détecte la technologie et les cibles, construit une checklist adaptée, explique chaque étape, exécute uniquement les actions autorisées et demande une confirmation avant toute opération sensible ou irréversible.

LaunchPilot est à la fois :

1. un agent de publication universel ;
2. un assistant de contrôle et de sécurité ;
3. un professeur expliquant les opérations ;
4. un gestionnaire de projets et de sessions de publication.

---

## 2. Principes obligatoires

- Plateforme initiale : Flutter desktop Linux. Préparer l’architecture pour Windows et macOS sans les implémenter immédiatement.
- Interface en français, internationalisation prête avec fichiers ARB.
- Flutter stable avec Dart null-safety.
- Material 3, interface responsive adaptée aux petits et grands écrans desktop.
- Gestion d’état : Riverpod.
- Navigation : GoRouter.
- Architecture par fonctionnalités avec séparation `data`, `domain`, `application` et `presentation` lorsque ces couches sont utiles. Ne pas créer de couches artificielles sans contenu.
- Persistance locale : Drift/SQLite pour les projets, sessions et checklists. `SharedPreferences` peut servir uniquement aux préférences simples.
- Secrets : `flutter_secure_storage`, jamais en clair dans SQLite, les fichiers, les journaux ou les prompts.
- Les appels réseau et outils système doivent être derrière des interfaces testables.
- Aucun service distant ni compte obligatoire pour ouvrir l’application et analyser localement un projet.
- Le LLM conseille et produit du contenu structuré, mais ne possède jamais un accès direct et illimité au shell.
- Commentaires en français uniquement lorsqu’ils apportent une information utile. N’explique pas chaque ligne évidente.
- Tests unitaires pour la logique métier et tests de widgets pour les parcours principaux.
- Ne jamais annoncer qu’une politique générée est « juridiquement garantie conforme ». Présenter les documents juridiques comme des modèles à relire et valider.

---

## 3. Expérience visuelle

Créer une identité originale et professionnelle, différente d’un tableau de bord Flutter générique :

- thème sombre principal bleu nuit/indigo, accents turquoise, violet et orange ;
- thème clair disponible ;
- cartes légèrement translucides, gradients discrets, excellente lisibilité ;
- barre latérale sur grand écran et navigation adaptée sur fenêtre étroite ;
- indicateurs de progression, statuts colorés et chronologie des étapes ;
- animations courtes, sobres et désactivables ;
- contraste accessible, navigation clavier, infobulles et tailles de texte adaptées.

Statuts visuels :

- gris : à faire ;
- bleu : en cours ;
- vert : réussi ;
- rouge : échec ou blocage ;
- orange : avertissement ou validation requise ;
- violet : étape pédagogique ou intervention de l’IA.

---

## 4. Modes d’accompagnement

LaunchPilot propose trois modes persistants :

### Débutant

Explications détaillées, vocabulaire défini, commandes commentées, instructions précises, une validation fréquente et un bouton « Montre-moi comment vérifier ».

### Accompagné

Explications condensées, regroupement raisonnable des actions et confirmation des modifications importantes.

### Expert

Interface plus dense, actions groupées et automatisation accélérée, tout en conservant les confirmations de sécurité obligatoires.

Chaque étape de checklist doit pouvoir exposer :

```dart
enum ExplanationLevel { beginner, guided, expert }

class ChecklistStep {
  final String id;
  final String title;
  final String objective;
  final String explanation;
  final String whyRequired;
  final List<String> affectedFiles;
  final List<CommandPreview> commands;
  final String expectedResult;
  final List<String> risks;
  final String verificationMethod;
  final String? rollbackMethod;
  final bool requiresConfirmation;
  final bool isReversible;
  final ChecklistStepStatus status;
}
```

Le modèle exact peut être adapté si nécessaire, mais aucune information métier ci-dessus ne doit être perdue.

---

## 5. Niveaux d’action

Toujours distinguer clairement :

1. **Analyser** : lecture seule, sans modification.
2. **Préparer** : génération de contenus et configurations, avec aperçu des modifications.
3. **Construire** : compilation ou création des livrables.
4. **Publier** : envoi vers un store ou un hébergeur.

L’utilisateur doit pouvoir s’arrêter après n’importe quel niveau. La publication ne doit jamais être déclenchée implicitement après un build.

---

## 6. Fonctionnalités

### 6.1 Gestion des projets et sessions

- Ouvrir un dossier avec un sélecteur natif.
- Afficher les projets récents, favoris, date de dernière ouverture et progression.
- Enregistrer le chemin, les technologies détectées, les cibles, les textes validés, les rapports, les résultats d’audit et la checklist.
- Créer une session distincte pour chaque préparation de version.
- Reprendre une session interrompue.
- Ne jamais stocker le contenu des secrets.
- Détecter si le dossier a été déplacé ou supprimé et proposer de le relocaliser.

### 6.2 Détection du projet

Scanner de façon bornée et performante le dossier choisi. Ignorer notamment `.git`, `node_modules`, `build`, `.dart_tool`, `.next`, `dist`, caches et binaires.

Reconnaître au minimum :

- Flutter avec `pubspec.yaml` et ses cibles ;
- HTML/CSS/JavaScript statique ;
- React/Vite, Vue/Vite, Angular, Next.js, Nuxt, Astro, Svelte/SvelteKit ;
- Node.js ;
- détection informative de Django, Flask et FastAPI.

Identifier :

- technologies, gestionnaire de paquets et scripts disponibles ;
- cibles Android, iOS, web, Linux, Windows et macOS ;
- Git, branche active, tags et modifications non validées ;
- icônes, captures, fastlane, CI, fichiers d’hébergement, manifeste PWA, SEO et documents juridiques ;
- permissions, SDK analytics/publicitaires, crash reporting et services tiers détectables statiquement.

Afficher le niveau de confiance et les preuves de chaque détection. L’utilisateur confirme ou corrige les cibles.

### 6.3 Couche LLM

Créer une interface commune `LlmProvider` et des adaptateurs pour :

- Anthropic Claude ;
- OpenAI ;
- Google Gemini ;
- Mistral.

Fonctions attendues : test de connexion, génération structurée, timeout, annulation, erreurs compréhensibles et estimation indicative de l’usage lorsque disponible.

Avant tout appel :

- minimiser les données envoyées ;
- afficher ce qui sera transmis en mode débutant ;
- retirer les secrets, tokens, mots de passe, fichiers de signature et variables sensibles ;
- ne jamais envoyer un projet complet sans sélection et consentement explicites.

### 6.4 Version et changelog

- Lire la version dans les fichiers adaptés à la technologie.
- Proposer major, minor, patch et numéro de build.
- Afficher un diff avant écriture.
- Générer un changelog depuis les commits depuis le dernier tag.
- Reformuler le changelog pour un public technique ou grand public.
- Ne jamais créer automatiquement un tag ni pousser sur un dépôt sans confirmation dédiée.

### 6.5 Identité visuelle et contenus

- Importer une icône source, recommander 1024 × 1024 minimum et vérifier le format.
- Générer les tailles Android, iOS, favicon et PWA sans étirer ni écraser l’image.
- Importer des captures d’écran, vérifier leurs dimensions et proposer plusieurs cadres de présentation.
- Prévoir ultérieurement la capture automatisée à partir de scénarios contrôlés.
- Permettre de masquer ou signaler les données personnelles visibles.
- Générer puis rendre éditables : titre, sous-titre, description courte, description longue, mots-clés, textes promotionnels et variantes linguistiques.
- Prévisualiser la fiche de store et les aperçus sociaux.

### 6.6 Analyse des permissions, données et juridique

Analyser autant que possible :

- permissions déclarées Android/iOS ;
- caméra, micro, localisation, contacts, stockage et notifications ;
- authentification, publicité, analytics, crash reporting et domaines externes ;
- cookies et traceurs web ;
- incohérences entre permissions déclarées et fonctions détectées.

À partir d’un questionnaire, produire des modèles éditables de politique de confidentialité, mentions légales et bannière de consentement. Toujours afficher un avertissement indiquant qu’une validation humaine ou juridique peut être nécessaire.

### 6.7 Android

- Vérifier la configuration SDK, Java/Gradle et Flutter Doctor.
- Vérifier ou guider la création du keystore.
- Ne jamais afficher ni journaliser son mot de passe.
- Ajouter les fichiers sensibles au `.gitignore` après aperçu et validation.
- Vérifier identifiant d’application, version, permissions, icônes et signature.
- Construire `flutter build appbundle --release` et, sur demande, l’APK correspondant.
- Préparer la fiche Play Store et Fastlane `supply`.
- Contrôler les livrables produits et afficher leur chemin, taille et empreinte SHA-256.

### 6.8 iOS

- Détecter que le build local iOS n’est pas possible sous Linux.
- Ne jamais simuler un faux build réussi.
- Préparer les métadonnées, captures, informations de confidentialité et Fastlane.
- Proposer Codemagic ou GitHub Actions avec runner macOS.
- Générer la configuration CI après validation.
- Expliquer certificats, profils de provisioning et étapes restant à faire sur les services Apple.

### 6.9 Web et PWA

- Déterminer la commande de build depuis le framework et les scripts du projet ; ne pas inventer une commande silencieusement.
- Build de production dans un dossier identifié.
- Audit Lighthouse si l’outil est installé, sinon guide d’installation non bloquant.
- SEO : title, description, canonical, Open Graph, Twitter Cards, `robots.txt`, `sitemap.xml` et schema.org.
- PWA : manifeste, icônes, couleurs, service worker et contrôle du mode hors ligne lorsque pertinent.
- Vérifier responsive, liens, pages d’erreur, formulaires, accessibilité et HTTPS.
- Déploiement guidé vers Firebase Hosting, Vercel, Netlify ou GitHub Pages.
- Afficher clairement les enregistrements DNS recommandés, mais ne jamais modifier le DNS sans confirmation dédiée.
- Proposer Plausible ou Umami lorsque l’utilisateur veut des statistiques respectueuses de la vie privée.

### 6.10 Système de cibles extensible

Chaque cible implémente une interface commune, par exemple :

```dart
abstract interface class LaunchTarget {
  String get id;
  String get label;
  Future<TargetDetection> detect(ProjectInfo project);
  Future<List<ChecklistStep>> buildChecklist(ProjectInfo project);
}
```

Le cœur ne doit pas dépendre des implémentations Android, iOS ou Web. Une cible Microsoft Store, Snap ou Flathub devra pouvoir être ajoutée sans modifier le moteur de checklist.

### 6.11 Rapport final

Exporter un rapport HTML autonome et imprimable en PDF contenant :

- résumé du projet et de la session ;
- technologies et cibles détectées ;
- versions et livrables ;
- fichiers modifiés ;
- commandes exécutées avec secrets masqués ;
- résultats des tests et audits ;
- avertissements et actions restantes ;
- procédure manuelle de publication ;
- lexique pédagogique contextualisé.

---

## 7. Sécurité et garde-fous

### 7.1 Commandes

Le LLM ne lance jamais directement une chaîne arbitraire. Toute commande passe par un `CommandRunner` contrôlé :

- exécutable et arguments séparés, sans `bash -c` sauf nécessité explicitement justifiée ;
- répertoire de travail explicite ;
- liste d’outils autorisés ;
- validation des arguments et détection des opérations dangereuses ;
- aperçu de la commande avant exécution ;
- mode simulation global ;
- confirmation selon le niveau de risque ;
- timeout, annulation et bouton d’arrêt ;
- capture séparée de stdout, stderr et du code de sortie ;
- masquage centralisé des secrets dans l’affichage et les journaux.

Interdire par défaut les suppressions récursives, écritures hors du projet, commandes privilégiées, modifications système, publication, push Git et gestion DNS. Leur prise en charge future nécessitera un flux dédié et une confirmation renforcée.

### 7.2 Protection du projet

Avant toute écriture :

- détecter Git et les changements locaux ;
- avertir si le dépôt est sale ;
- proposer un instantané ou une branche `launchpilot/release-<version>` ;
- afficher le diff prévu ;
- conserver la liste exacte des fichiers créés ou modifiés ;
- proposer une restauration ciblée, sans écraser les changements préexistants.

Ne jamais utiliser une commande destructrice pour « nettoyer » un projet. Ne jamais supprimer ni annuler les modifications existantes de l’utilisateur.

### 7.3 Confirmations renforcées

Exiger une confirmation explicite accompagnée d’un récapitulatif pour :

- publication sur un store ;
- déploiement en production ;
- push ou création de tag Git ;
- modification DNS ;
- création/remplacement de clés ou certificats ;
- écrasement de fichiers ;
- envoi de données du projet à un LLM.

Une confirmation ne peut pas être réutilisée pour une autre action.

---

## 8. Écrans

1. **Accueil** : ouvrir un projet, projets récents, favoris et reprise de session.
2. **Rapport de détection** : technologies, preuves, confiance, cibles modifiables.
3. **Tableau de publication** : niveaux Analyser/Préparer/Construire/Publier et progression globale.
4. **Checklist pédagogique** : étapes, statut, explication, risques, fichiers, vérification et actions.
5. **Terminal intégré** : sortie en direct, filtre stdout/stderr, arrêt et copie.
6. **Chat avec l’agent** : questions, reformulations et aide contextualisée.
7. **Contenus et aperçus** : textes, icônes, captures et prévisualisation des stores/SEO.
8. **Rapports et historique** : sessions et exports.
9. **Paramètres** : LLM, clés API, mode d’accompagnement, thème, langue et hébergeurs préférés.
10. **Aide et lexique** : mode d’emploi intégré et termes techniques.

Les phases initiales peuvent présenter certains écrans sous forme d’état vide soigné, mais aucun bouton ne doit prétendre fonctionner s’il n’est pas implémenté. Utiliser « Disponible dans une phase ultérieure » si nécessaire.

---

## 9. Découpage obligatoire

Réalise exactement une phase à la fois. À la fin d’une phase, arrête toute modification et attends ma validation explicite.

### Phase 1 — Socle exécutable

- Vérifier Flutter et Linux, puis créer le projet si nécessaire sans écraser un projet existant.
- Ajouter Riverpod, GoRouter, internationalisation ARB et stockage sécurisé.
- Créer l’identité visuelle, thèmes clair/sombre et responsive.
- Créer la navigation vers les dix écrans avec états vides honnêtes.
- Rendre les Paramètres fonctionnels pour thème, langue, mode d’accompagnement, fournisseur LLM et saisie/suppression sécurisée des clés.
- Ne faire aucun appel réel aux fournisseurs dans cette phase.
- Ajouter une abstraction du stockage sécurisé afin de pouvoir la tester.
- Ajouter un mode démo visuel avec données fictives clairement identifiées.
- Ajouter les premiers tests unitaires/widgets et un README de lancement Linux.

### Phase 2 — Persistance locale

- Drift/SQLite, modèles projet/session/cible/checklist.
- Accueil avec projets récents et reprise de session.
- Migrations testées et suppression contrôlée des données locales.

### Phase 3 — Couche LLM

- Interface commune, quatre fournisseurs et test de connexion.
- Réponses structurées, timeouts, annulation, erreurs et filtrage des secrets.
- Tests avec clients simulés ; aucune vraie clé dans les tests.

### Phase 4 — Détection

- Sélecteur de dossier, scanner sécurisé et détecteurs de technologies.
- Rapport avec preuves, confiance et correction manuelle.
- Tests à partir de petits projets fixtures.

### Phase 5 — Moteur sécurisé

- `CommandRunner`, terminal, simulation, annulation et journal masqué.
- Analyse Git, aperçu des diffs et mécanisme de restauration ciblée.
- Aucun déploiement réel dans cette phase.

### Phase 6 — Checklist et pédagogie

- Moteur de checklist, statuts, dépendances, reprise et plugins de cibles.
- Trois niveaux d’explication, lexique et méthodes de vérification.

### Phase 7 — Tronc commun

- Versions, changelog, icônes, textes, captures importées et questionnaire légal.
- Aperçu et validation avant chaque écriture.

### Phase 8 — Web/PWA

- Build, audit, SEO, PWA et préparations Firebase/Vercel/Netlify/GitHub Pages.
- Déploiement réel uniquement après confirmation explicite.

### Phase 9 — Android

- Audit Android, permissions, signature, AAB/APK, fiche Play Store et Fastlane.
- Ne jamais inclure les secrets dans le projet livré.

### Phase 10 — iOS via CI

- Métadonnées, confidentialité, Fastlane et configurations Codemagic/GitHub Actions macOS.
- Explication claire de toutes les limites Linux.

### Phase 11 — Chat, rapports et livraison

- Chat contextualisé, rapports HTML/PDF, historique et aide complète.
- Tests de bout en bout des parcours importants.
- Documentation architecture, installation, utilisation, sauvegarde et dépannage.
- Build Linux release et archive source propre.

---

## 10. Définition de « terminé » pour chaque phase

Une phase n’est terminée que si :

- le code demandé est réellement implémenté, sans faux boutons ni TODO bloquant ;
- `dart format` a été exécuté ;
- `flutter analyze` ne contient aucune erreur ;
- tous les tests de la phase réussissent ;
- l’application démarre sous Linux, sauf blocage environnemental précisément documenté ;
- le README ou la documentation pertinente est actualisé ;
- les nouveaux fichiers et décisions d’architecture sont listés ;
- les limites connues sont expliquées ;
- aucune phase suivante n’a été commencée.

---

## 11. Règles de travail pour Claude Code

1. Lis entièrement ce document avant d’agir.
2. Inspecte d’abord le dossier et l’état Git. Préserve tous les fichiers et changements existants.
3. Avant chaque phase, présente brièvement : objectif, fichiers envisagés, dépendances et risques.
4. Si une décision importante n’est pas couverte, pose une question. Pour un détail mineur et réversible, choisis une solution raisonnable et documente-la.
5. N’ajoute pas une dépendance si la bibliothèque standard ou une dépendance déjà présente suffit proprement.
6. N’invente pas de résultat de commande, test, build ou publication.
7. Ne modifie jamais `SPEC.md` sans autorisation.
8. Ne stocke et n’affiche aucune clé réelle.
9. N’utilise jamais de commandes destructrices pour corriger ou nettoyer le projet.
10. À la fin de la phase, fournis : résumé, fichiers créés/modifiés, commandes lancées, résultats d’analyse/tests, procédure de lancement, captures si possible, limites et choix à valider.
11. Arrête-toi ensuite. N’enchaîne pas automatiquement sur la phase suivante, même si tout fonctionne.

---

## 12. Instruction de départ

Commence uniquement par la **Phase 1 — Socle exécutable**. Si le dossier est vide, initialise proprement LaunchPilot. S’il contient déjà un projet, réalise d’abord un audit non destructif et explique comment tu vas l’adapter. À la fin de la Phase 1, attends ma validation explicite.
