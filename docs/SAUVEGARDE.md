# Sauvegarde et restauration des données de LaunchPilot

## Où sont les données

| Donnée | Emplacement |
| --- | --- |
| Base SQLite (projets, cibles, sessions, checklist, entrées de session, journal des commandes, fichiers modifiés) | `~/.local/share/com.nabucode.launchpilot/launchpilot.sqlite` |
| Copies des fichiers avant modification (pour « Restaurer ») | `~/.local/share/com.nabucode.launchpilot/backups/` |
| Préférences (thème, langue, mode, hébergeur, réglages web et iOS par projet) | `~/.local/share/com.nabucode.launchpilot/shared_preferences.json` |
| Clés API des fournisseurs d'IA | Trousseau du système (libsecret), entrées `launchpilot.llm.<fournisseur>.api_key` |
| Rapports exportés | L'emplacement choisi lors de l'export |

Aucun secret n'est écrit dans la base, les préférences, les journaux ou les
rapports (vérifié par des tests).

## Sauvegarder

1. Ferme LaunchPilot.
2. Copie le dossier de données :

   ```bash
   tar -czf launchpilot-donnees-$(date +%F).tar.gz \
     -C ~/.local/share com.nabucode.launchpilot
   ```

Les clés API ne sont pas dans cette archive : garde-les dans ton
gestionnaire de mots de passe ou ressaisis-les après restauration.

## Restaurer

1. Ferme LaunchPilot.
2. Mets de côté le dossier actuel s'il existe
   (`mv ~/.local/share/com.nabucode.launchpilot ~/.local/share/com.nabucode.launchpilot.ancien`).
3. Extrais l'archive :

   ```bash
   tar -xzf launchpilot-donnees-AAAA-MM-JJ.tar.gz -C ~/.local/share
   ```

4. Relance LaunchPilot. Une base d'une version plus ancienne est migrée
   automatiquement (schéma actuel : v3) ; une base plus récente que
   l'application est refusée sans être modifiée.

Si un projet a changé de place sur le disque, utilise **Accueil →
Relocaliser**.

## Repartir de zéro

**Paramètres → Effacer toutes les données locales** (mot de confirmation
demandé) supprime projets, sessions, journaux, sauvegardes et réglages de
projets de LaunchPilot. Les fichiers de tes projets ne sont jamais touchés.
Les clés API se suppriment une à une dans Paramètres.
