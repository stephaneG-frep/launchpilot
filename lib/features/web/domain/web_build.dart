import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../detection/domain/detection_report.dart';

/// Pourquoi aucune commande de build n'est proposée.
enum WebBuildGap {
  /// Aucun script « build » ni projet Flutter web : rien n'est inventé.
  noBuildScript,

  /// Rendu côté serveur (Next.js, Nuxt…) : pas de dossier statique.
  serverRendered,
}

/// Comment construire le site et où trouver ce qu'il faut mettre en ligne.
/// Tous les chemins sont relatifs à la racine du projet (vide = racine).
@immutable
class WebBuildPlan {
  const WebBuildPlan({
    required this.framework,
    required this.workingDir,
    this.executable,
    this.arguments = const [],
    required this.outputDir,
    this.outputGuessed = false,
    required this.publicDir,
    this.sourceIndex,
    this.spa = false,
    this.isFlutter = false,
    this.gap,
  });

  /// Libellé affiché (Flutter, Vite, Create React App…).
  final String framework;

  /// Dossier où lancer la commande.
  final String workingDir;
  final String? executable;
  final List<String> arguments;

  /// Dossier produit par le build (ou la racine d'un site statique).
  final String outputDir;

  /// Vrai quand le dossier de sortie est une convention du framework
  /// non confirmée par le projet : l'interface invite à le vérifier.
  final bool outputGuessed;

  /// Dossier dont le contenu est recopié tel quel dans la sortie
  /// (robots.txt, sitemap.xml, manifeste, fichiers d'hébergeur…).
  final String publicDir;

  /// Page HTML source éditable ; null quand le framework gère `<head>`
  /// lui-même (on affiche alors un extrait à recopier).
  final String? sourceIndex;

  /// Application monopage : toutes les routes renvoient vers index.html.
  final bool spa;
  final bool isFlutter;
  final WebBuildGap? gap;

  bool get hasCommand => executable != null;

  String get commandLine => [executable, ...arguments].join(' ');

  WebBuildPlan withOutputDir(String dir) => WebBuildPlan(
    framework: framework,
    workingDir: workingDir,
    executable: executable,
    arguments: arguments,
    outputDir: dir,
    publicDir: publicDir,
    sourceIndex: sourceIndex,
    spa: spa,
    isFlutter: isFlutter,
    gap: gap,
  );
}

String _join(String a, String b) => a.isEmpty || a == '.' ? b : '$a/$b';

String _dir(String manifest) {
  final d = p.posix.dirname(manifest);
  return d == '.' ? '' : d;
}

/// Déduit le plan de build du framework détecté et des scripts du projet.
/// Ne propose jamais une commande que le projet ne déclare pas.
WebBuildPlan? planWebBuild(DetectionReport r) {
  bool has(String id) => r.technologies.any((t) => t.id == id);
  final webEvidence = r.targetFor(PlatformTarget.web).evidence;

  final pub = r.packages.where((x) => x.manager == 'pub').firstOrNull;
  final flutterWeb =
      pub != null &&
      has('flutter') &&
      (webEvidence.isEmpty ||
          webEvidence.any((e) => e.path.endsWith('web/index.html')));
  if (flutterWeb) {
    final dir = _dir(pub.manifest);
    return WebBuildPlan(
      framework: 'Flutter',
      workingDir: dir,
      executable: 'flutter',
      arguments: const ['build', 'web', '--release'],
      outputDir: _join(dir, 'build/web'),
      publicDir: _join(dir, 'web'),
      sourceIndex: _join(dir, 'web/index.html'),
      spa: true,
      isFlutter: true,
    );
  }

  final node = r.packages
      .where((x) => const {'npm', 'pnpm', 'yarn', 'bun'}.contains(x.manager))
      .firstOrNull;
  if (node != null) {
    final dir = _dir(node.manifest);
    final scripts = node.scripts;
    final build = scripts['build'] ?? '';
    final generate = scripts['generate'];
    String rel(String path) => _join(dir, path);

    WebBuildPlan plan(
      String framework, {
      required String output,
      bool guessed = false,
      String public = 'public',
      String? index,
      bool spa = true,
      String script = 'build',
      WebBuildGap? gap,
    }) => WebBuildPlan(
      framework: framework,
      workingDir: dir,
      executable: scripts.containsKey(script) ? node.manager : null,
      arguments: scripts.containsKey(script) ? ['run', script] : const [],
      outputDir: rel(output),
      outputGuessed: guessed,
      publicDir: rel(public),
      sourceIndex: index == null ? null : rel(index),
      spa: spa,
      gap:
          gap ??
          (scripts.containsKey(script) ? null : WebBuildGap.noBuildScript),
    );

    if (has('nextjs')) {
      final exported = build.contains('next export');
      return plan(
        'Next.js',
        output: 'out',
        guessed: !exported,
        spa: false,
        gap: exported ? null : WebBuildGap.serverRendered,
      );
    }
    if (has('nuxt')) {
      if (generate != null) {
        return plan(
          'Nuxt',
          output: '.output/public',
          script: 'generate',
          spa: false,
        );
      }
      return plan(
        'Nuxt',
        output: '.output/public',
        guessed: true,
        spa: false,
        gap: WebBuildGap.serverRendered,
      );
    }
    if (has('astro')) return plan('Astro', output: 'dist', spa: false);
    if (has('sveltekit')) {
      return plan(
        'SvelteKit',
        output: 'build',
        guessed: true,
        public: 'static',
      );
    }
    if (has('angular')) {
      return plan(
        'Angular',
        output: 'dist',
        guessed: true,
        index: 'src/index.html',
      );
    }
    if (build.contains('react-scripts')) {
      return plan(
        'Create React App',
        output: 'build',
        index: 'public/index.html',
      );
    }
    if (has('vite') || build.contains('vite')) {
      final label = has('react')
          ? 'React + Vite'
          : has('vue')
          ? 'Vue + Vite'
          : has('svelte')
          ? 'Svelte + Vite'
          : 'Vite';
      return plan(label, output: 'dist', index: 'index.html');
    }
    if (scripts.containsKey('build')) {
      return plan('Node', output: 'dist', guessed: true);
    }
  }

  if (has('static')) {
    final index = webEvidence
        .map((e) => e.path)
        .where((f) => p.posix.basename(f) == 'index.html')
        .firstOrNull;
    final dir = index == null ? '' : _dir(index);
    return WebBuildPlan(
      framework: 'HTML',
      workingDir: dir,
      outputDir: dir,
      publicDir: dir,
      sourceIndex: _join(dir, 'index.html'),
    );
  }

  if (node != null) {
    return WebBuildPlan(
      framework: 'Node',
      workingDir: _dir(node.manifest),
      outputDir: _join(_dir(node.manifest), 'dist'),
      outputGuessed: true,
      publicDir: _join(_dir(node.manifest), 'public'),
      gap: WebBuildGap.noBuildScript,
    );
  }
  return null;
}
