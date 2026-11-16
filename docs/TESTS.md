# Tests de LaunchPilot 1.0.0

493 tests automatisés (33 fichiers), tous verts sur Flutter 3.47.2 /
Dart 3.13.2 : `flutter test` (environ 2 minutes).

## Lancer les tests et l'analyse

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


## Ce qui a été vérifié en réel (hors tests automatisés)

- Démarrage de la version release sous Linux à chaque phase.
- Phase 9 : un App Bundle Flutter réel de débogage est repéré comme tel ; la
  signature release générée compile (plugin Android 9.1, Gradle 9.3) et
  l'App Bundle obtenu est vu comme signé (certificat confirmé par
  `jarsigner`) ; l'analyse de `flutter doctor -v` fonctionne sur une vraie
  sortie.
- Phase 10 : plists générés validés par un vrai analyseur (`plistlib`) ;
  fixture iOS issue d'un vrai `flutter create --platforms=ios`.

## Ce qui n'a pas pu être vérifié en réel

- Aucun appel réel aux fournisseurs d'IA (pas de clé) : clients HTTP simulés.
- Aucun déploiement web, envoi Google Play, build iOS ni audit Lighthouse
  réel (outils ou comptes absents) : politique et flux vérifiés avec un
  runner simulé.
