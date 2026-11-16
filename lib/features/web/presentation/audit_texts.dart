import '../../settings/domain/app_settings.dart';
import '../domain/web_audit.dart';

/// Libellé d'un contrôle et conseil de correction. Contenu pédagogique
/// bilingue (comme le lexique), gardé hors des fichiers ARB.
typedef AuditText = ({String label, String fix});

AuditText auditText(AuditItem item, AppLanguage lang) {
  final fr = lang == AppLanguage.fr;
  AuditText t(String lf, String ff, String le, String fe) =>
      fr ? (label: lf, fix: ff) : (label: le, fix: fe);
  final v = item.values;
  String first() => v.isEmpty ? '' : v.first;

  return switch (item.id) {
    'noIndex' => t(
      'Page d\'accueil',
      'Aucun fichier HTML trouvé : construis le site ou choisis le bon dossier.',
      'Home page',
      'No HTML file found: build the site or pick the right folder.',
    ),
    'title' || 'titleLength' => t(
      'Titre de la page',
      item.id == 'title'
          ? 'Ajoute une balise <title> de 10 à 60 caractères.'
          : 'Le titre fait ${v.length > 1 ? v[1] : '?'} caractères : vise 10 à 60.',
      'Page title',
      item.id == 'title'
          ? 'Add a <title> tag of 10 to 60 characters.'
          : 'The title is ${v.length > 1 ? v[1] : '?'} characters: aim for 10 to 60.',
    ),
    'description' || 'descriptionLength' => t(
      'Meta description',
      item.id == 'description'
          ? 'Ajoute <meta name="description"> (50 à 160 caractères) : c\'est le texte affiché sous le titre dans les résultats.'
          : 'La description fait ${first()} caractères : vise 50 à 160.',
      'Meta description',
      item.id == 'description'
          ? 'Add <meta name="description"> (50 to 160 characters): it is the text shown under the title in results.'
          : 'The description is ${first()} characters: aim for 50 to 160.',
    ),
    'canonical' => t(
      'Adresse canonique',
      'Ajoute <link rel="canonical"> pour indiquer l\'adresse officielle et éviter les doublons.',
      'Canonical URL',
      'Add <link rel="canonical"> to state the official address and avoid duplicates.',
    ),
    'openGraph' => t(
      'Open Graph (partage)',
      'Balises manquantes : ${v.join(', ')}. Elles donnent le titre, le texte et l\'image des aperçus de partage.',
      'Open Graph (sharing)',
      'Missing tags: ${v.join(', ')}. They provide the title, text and image of share previews.',
    ),
    'twitterCard' => t(
      'Carte Twitter / X',
      'Ajoute <meta name="twitter:card">.',
      'Twitter / X card',
      'Add <meta name="twitter:card">.',
    ),
    'structuredData' => t(
      'Données structurées schema.org',
      'Ajoute un bloc JSON-LD décrivant le site.',
      'schema.org structured data',
      'Add a JSON-LD block describing the site.',
    ),
    'structuredDataInvalid' => t(
      'Données structurées schema.org',
      'Le bloc JSON-LD n\'est pas un JSON valide.',
      'schema.org structured data',
      'The JSON-LD block is not valid JSON.',
    ),
    'lang' => t(
      'Langue de la page',
      'Ajoute l\'attribut lang à <html> (ex. lang="fr") : lecteurs d\'écran et moteurs en ont besoin.',
      'Page language',
      'Add the lang attribute to <html> (e.g. lang="en"): screen readers and search engines need it.',
    ),
    'noindex' => t(
      'Indexation',
      'La page demande à ne pas être indexée (noindex) : elle n\'apparaîtra pas dans les moteurs.',
      'Indexing',
      'The page asks not to be indexed (noindex): it will not appear in search engines.',
    ),
    'robots' => t(
      'robots.txt',
      'Ajoute un robots.txt indiquant l\'adresse du sitemap.',
      'robots.txt',
      'Add a robots.txt pointing to the sitemap.',
    ),
    'robotsBlocksAll' => t(
      'robots.txt',
      '« Disallow: / » bloque tout le site pour les moteurs de recherche.',
      'robots.txt',
      '"Disallow: /" blocks the whole site for search engines.',
    ),
    'sitemap' => t(
      'Sitemap',
      item.status == AuditStatus.failure
          ? 'Le fichier ${first()} n\'est pas un sitemap XML valide.'
          : 'Ajoute un sitemap.xml listant les pages.',
      'Sitemap',
      item.status == AuditStatus.failure
          ? 'The file ${first()} is not a valid XML sitemap.'
          : 'Add a sitemap.xml listing the pages.',
    ),
    'viewport' => t(
      'Affichage mobile (viewport)',
      'Ajoute <meta name="viewport" content="width=device-width, initial-scale=1">.',
      'Mobile display (viewport)',
      'Add <meta name="viewport" content="width=device-width, initial-scale=1">.',
    ),
    'manifestLink' => t(
      'Manifeste PWA',
      'Aucun <link rel="manifest"> : le site ne peut pas être installé comme une application.',
      'PWA manifest',
      'No <link rel="manifest">: the site cannot be installed as an app.',
    ),
    'manifestMissing' => t(
      'Manifeste PWA',
      'Le manifeste ${first()} est référencé mais introuvable.',
      'PWA manifest',
      'The manifest ${first()} is referenced but missing.',
    ),
    'manifestInvalid' => t(
      'Manifeste PWA',
      'Le manifeste n\'est pas un JSON valide.',
      'PWA manifest',
      'The manifest is not valid JSON.',
    ),
    'manifestFields' => t(
      'Champs du manifeste',
      'Champs manquants : ${v.join(', ')}.',
      'Manifest fields',
      'Missing fields: ${v.join(', ')}.',
    ),
    'manifestIcons' => t(
      'Icônes du manifeste',
      'Tailles manquantes : ${v.join(', ')} (outil Icônes).',
      'Manifest icons',
      'Missing sizes: ${v.join(', ')} (Icons tool).',
    ),
    'maskable' => t(
      'Icône « maskable »',
      'Facultatif : une icône maskable s\'adapte aux formes d\'icônes d\'Android.',
      'Maskable icon',
      'Optional: a maskable icon adapts to Android icon shapes.',
    ),
    'iconFiles' => t(
      'Fichiers d\'icônes',
      'Icônes déclarées mais absentes : ${v.join(', ')}.',
      'Icon files',
      'Declared but missing icons: ${v.join(', ')}.',
    ),
    'themeColor' => t(
      'Couleur de thème',
      'Facultatif : <meta name="theme-color"> colore la barre du navigateur mobile.',
      'Theme colour',
      'Optional: <meta name="theme-color"> tints the mobile browser bar.',
    ),
    'serviceWorker' => t(
      'Service worker',
      'Aucun service worker : le site ne fonctionne pas hors ligne (facultatif selon le site).',
      'Service worker',
      'No service worker: the site does not work offline (optional depending on the site).',
    ),
    'serviceWorkerNoFetch' => t(
      'Mode hors ligne',
      'Un service worker existe mais ne gère pas les requêtes (fetch) : pas de mode hors ligne.',
      'Offline mode',
      'A service worker exists but does not handle requests (fetch): no offline mode.',
    ),
    'offline' => t(
      'Mode hors ligne',
      'Teste-le : aperçu local, outils de développement → Application → Offline, puis recharge.',
      'Offline mode',
      'Test it: local preview, developer tools → Application → Offline, then reload.',
    ),
    'imgAlt' => t(
      'Textes alternatifs des images',
      '${first()} image(s) sans attribut alt : décris-les (ou alt="" si décoratives).',
      'Image alternative texts',
      '${first()} image(s) without an alt attribute: describe them (or alt="" if decorative).',
    ),
    'labels' => t(
      'Étiquettes des champs',
      '${first()} champ(s) sans étiquette (<label for> ou aria-label).',
      'Field labels',
      '${first()} field(s) without a label (<label for> or aria-label).',
    ),
    'emptyButtons' => t(
      'Boutons sans texte',
      '${first()} bouton(s) vide(s) : ajoute un texte ou un aria-label.',
      'Buttons without text',
      '${first()} empty button(s): add text or an aria-label.',
    ),
    'broken' => t(
      'Liens internes',
      'Cibles introuvables : ${v.join(', ')}.',
      'Internal links',
      'Missing targets: ${v.join(', ')}.',
    ),
    'mixedContent' => t(
      'Contenu mixte (HTTPS)',
      'Ressources chargées en http:// (bloquées sur un site HTTPS) : ${v.join(', ')}.',
      'Mixed content (HTTPS)',
      'Resources loaded over http:// (blocked on an HTTPS site): ${v.join(', ')}.',
    ),
    'forms' => t(
      'Formulaires',
      '${first()} formulaire(s) : vérifie l\'envoi, les messages d\'erreur et la mention de confidentialité.',
      'Forms',
      '${first()} form(s): check submission, error messages and the privacy notice.',
    ),
    'insecureAction' => t(
      'Envoi de formulaire',
      'Formulaire envoyé en http:// : les données circulent en clair (${v.join(', ')}).',
      'Form submission',
      'Form sent over http://: data travels unencrypted (${v.join(', ')}).',
    ),
    'notFoundPage' => t(
      'Page d\'erreur 404',
      item.status == AuditStatus.info
          ? 'Application monopage : la configuration d\'hébergement renvoie les routes vers index.html.'
          : 'Ajoute une page 404.html utile (lien vers l\'accueil).',
      '404 error page',
      item.status == AuditStatus.info
          ? 'Single-page app: the hosting configuration sends routes to index.html.'
          : 'Add a helpful 404.html page (link to home).',
    ),
    _ => t(item.id, '', item.id, ''),
  };
}
