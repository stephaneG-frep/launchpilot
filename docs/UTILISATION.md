# Guide d'utilisation de LaunchPilot 1.0.0

LaunchPilot accompagne la publication d'un projet en quatre niveaux :
**Analyser → Préparer → Construire → Publier**. Rien n'est écrit, exécuté,
poussé ou publié sans aperçu et confirmation. Le même contenu existe dans
l'application : **Aide et lexique → Manuel complet** (recherche intégrée).

## Premier parcours

1. **Accueil → Ajouter un projet** : choisis le dossier. Pour découvrir sans
   projet réel : **Découvrir le mode démo** (données fictives signalées).
2. **Rapport de détection** : vérifie technologies, cibles et preuves, coche
   les cibles à publier puis **Valider les cibles**.
3. **Tableau de publication → Nouvelle session** : saisis la version
   (ex. `1.3.0+14`). La checklist est construite pour les cibles retenues.
4. **Checklist pédagogique** : suis les étapes dans l'ordre. Choisis ton
   mode (Débutant, Accompagné, Expert). Les étapes de contenu ont un bouton
   **Ouvrir l'outil**.
5. **Rapports et historique** : en fin de session, **Aperçu du rapport →
   Exporter en HTML**, puis imprime en PDF depuis un navigateur.

## Écrans

| Écran | Rôle |
| --- | --- |
| Accueil | Projets récents, favoris, reprise de session, mode démo |
| Rapport de détection | Technologies, cibles, paquets, SEO, services, permissions, preuves |
| Tableau de publication | Niveaux et progression, protection Git, `.gitignore`, restauration |
| Checklist | Étapes, statuts, explications, risques, vérification, actions |
| Terminal | Commandes autorisées avec aperçu, sortie en direct, arrêt, journal masqué |
| Chat avec l'agent | Questions à l'IA avec contexte choisi ; aperçu avant chaque envoi |
| Contenus et aperçus | Version, changelog, icônes, captures, textes, juridique, Web, Android, iOS |
| Rapports et historique | Toutes les sessions, aperçu et export du rapport |
| Paramètres | IA et clés, mode, thème, langue, hébergeur, statistiques, simulation, données |
| Aide et lexique | Guide rapide, manuel complet, raccourcis, lexique |

Raccourcis : **Ctrl+1 … Ctrl+9, Ctrl+0** pour les écrans, Tab pour
naviguer, Entrée ou Espace pour activer.

## Sécurité au quotidien

- **Mode simulation** (activé par défaut) : seules les commandes en lecture
  seule s'exécutent ; les autres sont prévisualisées. Désactive-le dans
  Paramètres quand tu es prêt.
- **Écritures** : diff, sauvegarde, écriture atomique ; **Restaurer** depuis
  le tableau de publication.
- **Publications** (tag Git, déploiement web, envoi Google Play) :
  récapitulatif puis confirmation renforcée, valable une seule fois. Un push
  ou une publication tapés dans le terminal sont refusés.
- **Secrets** : clés API dans le trousseau ; fichiers de signature jamais
  lus ; secrets masqués dans les journaux, les envois à l'IA et les rapports.

## Par cible

- **Web** : Contenus → Site web (build, audit, aperçu local, Lighthouse),
  SEO, PWA, Hébergement (configuration, mise en ligne, DNS affichés,
  vérification HTTPS).
- **Android** : Contenus → Android (environnement, audit, signature, build,
  livrables) et Play Store (fiche, Fastlane, envoi en brouillon sur la piste
  interne après un premier envoi manuel).
- **iOS** : Contenus → iOS (limites Linux, audit, Info.plist, manifeste de
  confidentialité, compte Apple, CI GitHub Actions ou Codemagic) et App Store
  (fiche, captures, étiquettes de confidentialité, Fastlane deliver).

## Chat avec l'agent

Choisis le fournisseur et enregistre sa clé dans Paramètres. Dans le chat,
coche le contexte à joindre (résumé du projet, checklist, dernière commande),
pose ta question, relis l'aperçu puis confirme. L'agent ne peut rien
exécuter. L'historique est enregistré dans la session ; **Effacer la
conversation** le supprime de LaunchPilot.

## Rapport

Le rapport HTML autonome contient : résumé, technologies et cibles,
livrables (taille, SHA-256, signature), fichiers modifiés, commandes (secrets
masqués), tests et audits, actions restantes, procédure manuelle de
publication et lexique. Il ne charge aucune ressource externe.
