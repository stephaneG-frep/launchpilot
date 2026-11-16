# Dépannage

| Symptôme | Cause probable | Solution |
| --- | --- | --- |
| « Trousseau verrouillé ou indisponible » dans Paramètres, IA en échec | Trousseau verrouillé — cas typique : **connexion automatique** (aucun mot de passe saisi, donc gnome-keyring n'est pas déverrouillé) | Déverrouille le trousseau (voir ci-dessous), ou désactive la connexion automatique pour qu'il le soit à chaque ouverture de session |
| Aucun service de trousseau | gnome-keyring absent ou arrêté | `sudo apt install gnome-keyring`, puis reconnecte-toi |
| L'application ne démarre pas (`libgtk` ou `libsecret` introuvable) | Bibliothèques système absentes | `sudo apt install libgtk-3-0 libsecret-1-0` |
| Message GTK « CRITICAL » au lancement sous LXQt | Portail de bureau LXQt | Sans conséquence |
| Commande « introuvable » | Outil absent du `PATH` | Installe-le dans ton terminal ; LaunchPilot n'installe rien globalement |
| Commande « interdite » | Politique de sécurité (shell, sudo, suppression, push, publication…) | Lis le motif dans l'aperçu ; publication et push passent par les flux dédiés ou ton terminal |
| Une commande ne s'exécute pas, « simulée » | Mode simulation actif | Désactive-le dans Paramètres → Exécution |
| « Le fichier a changé depuis l'aperçu » | Tu as modifié le fichier entre l'aperçu et la confirmation | Rouvre l'aperçu : rien n'a été écrit |
| « Restauration refusée » | Fichier modifié après l'écriture de LaunchPilot | Restaure à la main ; LaunchPilot n'écrase jamais tes changements |
| Analyse marquée « partielle » | Projet très volumineux | Les dossiers lourds (node_modules, build…) sont ignorés ; le rapport reste exploitable |
| Erreur d'IA (clé, modèle, réseau) | Clé invalide, modèle indisponible, pas de réseau | Paramètres → Tester la connexion ; choisis un autre modèle |
| « Message trop long » dans le chat | Contexte trop volumineux | Décoche un élément de contexte ou raccourcis la question |
| Signature Android « clé de débogage » | `build.gradle` signe le release en debug | Contenus → Android → Configurer la signature release |
| Build iOS impossible | Linux | Normal : utilise la CI macOS générée (GitHub Actions ou Codemagic) |
| Netlify reconstruit le site | CLI récente | La commande générée utilise `--no-build` |
| Rapport : pas de PDF | Le rapport est en HTML | Ouvre-le dans un navigateur → Imprimer → Enregistrer au format PDF |
| Base « plus récente que l'application » | Données créées par une version plus récente | Utilise la version récente ou restaure une sauvegarde |

## Déverrouiller le trousseau sans application graphique

La commande suivante demande au trousseau de s'ouvrir ; une fenêtre
demande ton mot de passe du trousseau (souvent celui de ta session) :

```bash
P=$(gdbus call --session --dest org.freedesktop.secrets \
  --object-path /org/freedesktop/secrets \
  --method org.freedesktop.Secret.Service.Unlock \
  "['/org/freedesktop/secrets/collection/login']" \
  | grep -o "/org/freedesktop/secrets/prompt/[^']*") \
  && gdbus call --session --dest org.freedesktop.secrets --object-path "$P" \
  --method org.freedesktop.Secret.Prompt.Prompt ""
```

Avec une interface : `sudo apt install seahorse`, puis « Mots de passe et
clés » → clic droit sur « Connexion » → Déverrouiller. Relance ensuite le
test de connexion dans LaunchPilot.

## Journaux utiles

- Lance LaunchPilot depuis un terminal pour voir les messages d'erreur :
  `~/Applications/LaunchPilot/bundle/launchpilot`.
- Le journal des commandes (écran Terminal) garde les dernières lignes de
  chaque commande, secrets masqués.
