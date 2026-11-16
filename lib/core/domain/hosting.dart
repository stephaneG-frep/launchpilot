/// Hébergeurs web pris en charge pour la préparation et le déploiement.
enum HostingProvider {
  firebase('Firebase Hosting'),
  vercel('Vercel'),
  netlify('Netlify'),
  githubPages('GitHub Pages');

  const HostingProvider(this.label);
  final String label;
}

/// Statistiques respectueuses de la vie privée proposées pour un site.
enum AnalyticsTool {
  none(''),
  plausible('Plausible'),
  umami('Umami');

  const AnalyticsTool(this.label);
  final String label;
}
