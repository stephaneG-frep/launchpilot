import '../../settings/domain/app_settings.dart';

class GlossaryEntry {
  const GlossaryEntry(this.id, this.term, this.definition);

  /// Identifiant stable, référencé par les étapes de checklist.
  final String id;
  final String term;
  final String definition;
}

/// Lexique pédagogique. C'est du contenu et non des libellés d'interface :
/// il reste ici plutôt que dans les fichiers ARB.
abstract final class Glossary {
  static List<GlossaryEntry> forLanguage(AppLanguage language) {
    final fr = language == AppLanguage.fr;
    GlossaryEntry e(
      String id,
      String term,
      String defFr,
      String defEn, {
      String? termEn,
    }) => GlossaryEntry(id, fr ? term : termEn ?? term, fr ? defFr : defEn);

    final entries = [
      e(
        'aab',
        'AAB (Android App Bundle)',
        'Format de publication exigé par le Play Store. Google en extrait un APK adapté à chaque appareil.',
        'Publishing format required by the Play Store. Google derives an APK tailored to each device from it.',
      ),
      e(
        'appStoreConnect',
        'App Store Connect',
        'Site d\'Apple où l\'on crée la fiche de l\'application, reçoit les builds, gère TestFlight et soumet à la vérification.',
        'Apple\'s site where you create the app record, receive builds, manage TestFlight and submit for review.',
      ),
      e(
        'privacyManifest',
        'Manifeste de confidentialité',
        'Fichier PrivacyInfo.xcprivacy embarqué dans une application iOS : il déclare les données collectées, le pistage et les API sensibles utilisées.',
        'PrivacyInfo.xcprivacy file bundled in an iOS app: it declares collected data, tracking and the sensitive APIs used.',
        termEn: 'Privacy manifest',
      ),
      e(
        'apk',
        'APK',
        'Fichier d\'installation Android, utile pour tester ou distribuer hors du Play Store.',
        'Android install file, useful for testing or distributing outside the Play Store.',
      ),
      e(
        'build',
        'Build',
        'Compilation du code source en un livrable exécutable ou publiable.',
        'Compiling source code into a runnable or publishable deliverable.',
      ),
      e(
        'branch',
        'Branche Git',
        'Ligne de travail parallèle dans un dépôt. Préparer une version sur sa propre branche évite de mélanger ce travail avec le reste.',
        'Parallel line of work in a repository. Preparing a release on its own branch keeps that work separate from the rest.',
        termEn: 'Git branch',
      ),
      e(
        'changelog',
        'Changelog',
        'Liste des changements d\'une version, destinée aux développeurs ou aux utilisateurs.',
        'List of changes in a release, for developers or users.',
      ),
      e(
        'ci',
        'CI (intégration continue)',
        'Service qui construit et teste automatiquement le projet sur un serveur, par exemple GitHub Actions ou Codemagic.',
        'Service that automatically builds and tests the project on a server, such as GitHub Actions or Codemagic.',
        termEn: 'CI (continuous integration)',
      ),
      e(
        'commit',
        'Commit',
        'Enregistrement d\'un ensemble de modifications dans l\'historique Git, avec un message qui les décrit.',
        'Recording of a set of changes in Git history, with a message describing them.',
      ),
      e(
        'dependencies',
        'Dépendances',
        'Bibliothèques externes utilisées par le projet (pubspec.yaml, package.json). Elles doivent être installées avant de construire.',
        'External libraries used by the project (pubspec.yaml, package.json). They must be installed before building.',
        termEn: 'Dependencies',
      ),
      e(
        'dns',
        'DNS',
        'Annuaire d\'Internet qui relie un nom de domaine à un serveur. Une erreur peut rendre un site inaccessible.',
        'The Internet\'s directory linking a domain name to a server. A mistake can make a site unreachable.',
      ),
      e(
        'fastlane',
        'Fastlane',
        'Outil qui automatise l\'envoi des métadonnées, captures et versions vers les stores.',
        'Tool that automates uploading metadata, screenshots and releases to the stores.',
      ),
      e(
        'flutterDoctor',
        'flutter doctor',
        'Commande qui vérifie l\'installation de Flutter et des outils de chaque plateforme (Android SDK, Chrome, chaîne Linux…).',
        'Command that checks the Flutter installation and each platform\'s tools (Android SDK, Chrome, Linux toolchain…).',
      ),
      e(
        'https',
        'HTTPS',
        'Version chiffrée du web, signalée par le cadenas du navigateur. Les hébergeurs la fournissent gratuitement ; une ressource chargée en http:// sur une page HTTPS est bloquée.',
        'Encrypted version of the web, shown by the browser padlock. Hosts provide it for free; a resource loaded over http:// on an HTTPS page is blocked.',
      ),
      e(
        'internalTrack',
        'Piste de test interne',
        'Canal privé du Play Store : seuls les testeurs invités reçoivent la version. Première étape avant la production.',
        'Private Play Store channel: only invited testers get the release. First step before production.',
        termEn: 'Internal testing track',
      ),
      e(
        'keystore',
        'Keystore',
        'Fichier contenant la clé de signature Android. Il ne doit jamais être perdu ni publié.',
        'File containing the Android signing key. It must never be lost or published.',
      ),
      e(
        'buildNumber',
        'Numéro de build',
        'Compteur interne qui doit augmenter à chaque envoi sur un store (la partie après « + » dans 1.3.0+14).',
        'Internal counter that must increase with each store upload (the part after "+" in 1.3.0+14).',
        termEn: 'Build number',
      ),
      e(
        'lighthouse',
        'Lighthouse',
        'Outil de Google qui note une page de 0 à 100 en performance, accessibilité, bonnes pratiques et SEO, avec des conseils.',
        'Google tool that scores a page from 0 to 100 for performance, accessibility, best practices and SEO, with advice.',
      ),
      e(
        'openGraph',
        'Open Graph',
        'Balises qui donnent le titre, la description et l\'image affichés quand un lien est partagé sur un réseau social ou une messagerie.',
        'Tags that provide the title, description and image shown when a link is shared on a social network or messaging app.',
      ),
      e(
        'permission',
        'Permission',
        'Accès à une fonction sensible (caméra, localisation…) que l\'application doit déclarer et justifier auprès des stores.',
        'Access to a sensitive feature (camera, location…) that the app must declare and justify to the stores.',
      ),
      e(
        'provisioning',
        'Profil de provisioning',
        'Fichier Apple qui autorise une application signée à s\'exécuter sur des appareils ou à être publiée.',
        'Apple file allowing a signed app to run on devices or be published.',
        termEn: 'Provisioning profile',
      ),
      e(
        'privacyPolicy',
        'Politique de confidentialité',
        'Document qui explique quelles données l\'application collecte, pourquoi, combien de temps et avec qui elles sont partagées. Exigée par les stores dès qu\'une donnée personnelle est traitée.',
        'Document explaining which data the app collects, why, for how long and who it is shared with. Required by stores as soon as personal data is processed.',
        termEn: 'Privacy policy',
      ),
      e(
        'pwa',
        'PWA',
        'Application web installable, capable de fonctionner hors ligne grâce à un service worker.',
        'Installable web app that can work offline thanks to a service worker.',
      ),
      e(
        'releaseMode',
        'Mode release',
        'Compilation optimisée destinée aux utilisateurs, sans outils de débogage. C\'est elle qui part sur les stores.',
        'Optimized build meant for users, without debugging tools. It is what goes to the stores.',
        termEn: 'Release mode',
      ),
      e(
        'semver',
        'Versionnage sémantique',
        'Convention MAJEUR.MINEUR.CORRECTIF : on augmente le premier chiffre pour un changement incompatible, le deuxième pour une nouveauté, le troisième pour une correction.',
        'MAJOR.MINOR.PATCH convention: bump the first number for an incompatible change, the second for a feature, the third for a fix.',
        termEn: 'Semantic versioning',
      ),
      e(
        'seo',
        'SEO',
        'Optimisation pour les moteurs de recherche : titres, descriptions, sitemap, données structurées.',
        'Search engine optimization: titles, descriptions, sitemap, structured data.',
      ),
      e(
        'serviceWorker',
        'Service worker',
        'Script exécuté en arrière-plan par le navigateur, qui gère le cache et le mode hors ligne d\'une PWA.',
        'Script run in the background by the browser, handling a PWA\'s cache and offline mode.',
      ),
      e(
        'sha256',
        'SHA-256',
        'Empreinte unique d\'un fichier. Si un seul octet change, l\'empreinte change.',
        'Unique fingerprint of a file. If a single byte changes, the fingerprint changes.',
      ),
      e(
        'sitemap',
        'Sitemap',
        'Fichier sitemap.xml listant les pages du site, pour aider les moteurs de recherche à les découvrir.',
        'sitemap.xml file listing the site\'s pages, to help search engines discover them.',
      ),
      e(
        'spa',
        'Application monopage (SPA)',
        'Site dont toutes les adresses sont servies par index.html, le JavaScript affichant ensuite la bonne page. L\'hébergeur doit être configuré pour renvoyer index.html.',
        'Site whose addresses are all served by index.html, JavaScript then showing the right page. The host must be configured to return index.html.',
        termEn: 'Single-page app (SPA)',
      ),
      e(
        'staticAnalysis',
        'Analyse statique',
        'Lecture du code sans l\'exécuter pour y trouver erreurs et mauvaises pratiques (flutter analyze, lint).',
        'Reading code without running it to find errors and bad practices (flutter analyze, lint).',
        termEn: 'Static analysis',
      ),
      e(
        'gitTag',
        'Tag Git',
        'Étiquette posée sur un commit pour marquer une version, par exemple v1.3.0.',
        'Label placed on a commit to mark a release, for example v1.3.0.',
        termEn: 'Git tag',
      ),
      e(
        'storeListing',
        'Fiche de store',
        'Page de l\'application sur un store : nom, sous-titre, descriptions, icône et captures. C\'est elle qui donne envie d\'installer.',
        'The app\'s page on a store: name, subtitle, descriptions, icon and screenshots. It is what makes people want to install.',
        termEn: 'Store listing',
      ),
      e(
        'tests',
        'Tests automatiques',
        'Programmes qui vérifient le comportement de l\'application à chaque modification. Un test qui échoue signale une régression.',
        'Programs that check the app\'s behavior after each change. A failing test signals a regression.',
        termEn: 'Automated tests',
      ),
      e(
        'testflight',
        'TestFlight',
        'Service d\'Apple pour distribuer une version de test iOS avant sa publication sur l\'App Store.',
        'Apple service for distributing an iOS test build before its App Store release.',
      ),
    ];
    entries.sort(
      (a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()),
    );
    return entries;
  }

  static GlossaryEntry? byId(List<GlossaryEntry> entries, String id) {
    for (final e in entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  static List<GlossaryEntry> search(List<GlossaryEntry> entries, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return entries;
    return entries
        .where(
          (e) =>
              e.term.toLowerCase().contains(q) ||
              e.definition.toLowerCase().contains(q),
        )
        .toList();
  }
}
