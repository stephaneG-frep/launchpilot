# Installation de LaunchPilot 1.0.0 (Linux)

LaunchPilot est une application de bureau Flutter pour Linux (testée sur
Ubuntu / Lubuntu 22.04, x86-64).

## 1. Utiliser la version compilée

L'archive `LaunchPilot_V1.0.0_linux_x64.tar.gz` contient le dossier `bundle/`
produit par `flutter build linux --release`.

```bash
mkdir -p ~/Applications/LaunchPilot
tar -xzf LaunchPilot_V1.0.0_linux_x64.tar.gz -C ~/Applications/LaunchPilot
~/Applications/LaunchPilot/bundle/launchpilot
```

Bibliothèques système nécessaires à l'exécution (présentes sur une Ubuntu de
bureau ; sinon) :

```bash
sudo apt install libgtk-3-0 libsecret-1-0 gnome-keyring
```

Le dossier `bundle/` doit rester entier (`lib/` et `data/` à côté de
l'exécutable). Pour un raccourci de menu, crée
`~/.local/share/applications/launchpilot.desktop` :

```ini
[Desktop Entry]
Type=Application
Name=LaunchPilot
Exec=/home/<toi>/Applications/LaunchPilot/bundle/launchpilot
Terminal=false
Categories=Development;
```

## 2. Compiler depuis les sources

Prérequis :

1. Flutter stable (testé avec Flutter 3.47.2, Dart 3.13.2).
2. Chaîne Linux desktop :

   ```bash
   sudo apt install clang cmake ninja-build pkg-config \
     libgtk-3-dev libsecret-1-dev liblzma-dev libstdc++-12-dev
   ```

3. Un service *Secret Service* lancé et déverrouillé (gnome-keyring ou
   KWallet) pour stocker les clés API.

Puis :

```bash
unzip LaunchPilot_V1.0.0_source.zip -d launchpilot && cd launchpilot
flutter pub get
flutter test                    # facultatif : 493 tests
flutter build linux --release
./build/linux/x64/release/bundle/launchpilot
```

`flutter doctor` doit afficher `[✓] Linux toolchain`.

## 3. Outils facultatifs (jamais installés par LaunchPilot)

LaunchPilot détecte ces outils dans le `PATH` et explique comment les
installer ; il ne lance jamais d'installation globale.

| Outil | Usage dans LaunchPilot |
| --- | --- |
| Git | État du dépôt, changelog, tag (confirmation renforcée) |
| SDK Android + Java | Build App Bundle / APK |
| Node.js + gestionnaire (npm, pnpm, yarn, bun) | Sites web JavaScript |
| `firebase`, `vercel`, `netlify` | Mise en ligne web (flux dédié) |
| `lighthouse` + Chrome/Chromium | Audit de performance |
| `fastlane` | Envoi sur la piste interne de Google Play |

Les clés des fournisseurs d'IA (Anthropic, OpenAI, Google Gemini, Mistral)
se saisissent dans **Paramètres → Intelligence artificielle** ; elles sont
rangées dans le trousseau du système.
