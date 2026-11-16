# Livraison LaunchPilot 1.0.0

Date : 16 novembre 2026. Les 11 phases du cahier des charges (`SPEC.md`)
sont réalisées.

## Fichiers livrés (dossier `agent_IA/delivery/`)

| Fichier | Contenu |
| --- | --- |
| `LaunchPilot_V1.0.0_linux_x64.tar.gz` | Version release Linux x86-64 (dossier `bundle/`, exécutable `launchpilot`) |
| `LaunchPilot_V1.0.0_source.zip` | Sources propres (sans `build/`, `.dart_tool/`, fichiers générés locaux) |
| `LaunchPilot_V1.0.0-README.md` | README du projet |
| `LaunchPilot_V1.0.0-INSTALLATION.md` | Installation et compilation |
| `LaunchPilot_V1.0.0-GUIDE_UTILISATEUR.md` | Guide d'utilisation |
| `LaunchPilot_V1.0.0-ARCHITECTURE.md` | Architecture et décisions |
| `LaunchPilot_V1.0.0-SAUVEGARDE.md` | Sauvegarde et restauration |
| `LaunchPilot_V1.0.0-DEPANNAGE.md` | Dépannage |
| `LaunchPilot_V1.0.0-TESTS.md` | Tests et vérifications |
| `LaunchPilot_V1.0.0-LIVRAISON.md` | Ce document |

## Empreintes SHA-256

```
7bc9c04d1b53362d7a60969b78af183abe44dc3fe7934c3f833efbce3a1d290f  LaunchPilot_V1.0.0_linux_x64.tar.gz
```

L'empreinte de `LaunchPilot_V1.0.0_source.zip` figure dans la copie
`delivery/LaunchPilot_V1.0.0-LIVRAISON.md` (une archive ne peut pas contenir
sa propre empreinte). Vérification : `sha256sum -c` sur ces lignes, depuis le
dossier `delivery/`.

## Correctif du 16 novembre 2026

Trousseau verrouillé (cas de la connexion automatique) : la couche IA
affiche désormais un message clair au lieu d'échouer sans explication ;
procédure de déverrouillage ajoutée au dépannage.

## Contrôles effectués avant livraison

- `dart format` : aucun changement ; `flutter analyze` : aucun problème.
- `flutter test` : 493 tests réussis.
- `flutter build linux --release` : réussi ; l'exécutable démarre, y compris
  depuis l'archive extraite dans un autre dossier.
- Archive source extraite ailleurs : `flutter pub get`, `flutter analyze`
  sans problème et parcours de bout en bout réussis.
- Aucun secret réel dans les sources : le seul `key.properties` est un
  fichier factice de test (« valeur-fixture-ne-doit-pas-etre-lue »), qui
  vérifie que LaunchPilot ne lit jamais les fichiers de signature.

## Environnement de construction

Ubuntu 22.04 (LXQt), Flutter 3.47.2 stable, Dart 3.13.2.
