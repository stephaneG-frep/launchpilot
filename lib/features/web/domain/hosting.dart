import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../core/domain/hosting.dart';
import '../../commands/domain/command_spec.dart';
import 'web_build.dart';

/// Réglages web d'un projet (aucun secret : identifiants publics).
@immutable
class WebProjectConfig {
  const WebProjectConfig({
    this.host,
    this.outputDir,
    this.siteUrl = '',
    this.firebaseProject = '',
    this.netlifySite = '',
    this.githubRepo = '',
    this.customDomain = '',
  });

  final HostingProvider? host;

  /// Dossier de sortie corrigé par l'utilisateur (sinon celui du plan).
  final String? outputDir;
  final String siteUrl;

  /// Identifiant du projet Firebase (ex. meteo-1234).
  final String firebaseProject;

  /// Identifiant ou nom du site Netlify (facultatif si le dossier est lié).
  final String netlifySite;

  /// `utilisateur/depot` pour GitHub Pages.
  final String githubRepo;
  final String customDomain;

  WebProjectConfig copyWith({
    HostingProvider? host,
    String? outputDir,
    String? siteUrl,
    String? firebaseProject,
    String? netlifySite,
    String? githubRepo,
    String? customDomain,
  }) => WebProjectConfig(
    host: host ?? this.host,
    outputDir: outputDir ?? this.outputDir,
    siteUrl: siteUrl ?? this.siteUrl,
    firebaseProject: firebaseProject ?? this.firebaseProject,
    netlifySite: netlifySite ?? this.netlifySite,
    githubRepo: githubRepo ?? this.githubRepo,
    customDomain: customDomain ?? this.customDomain,
  );

  Map<String, Object?> toJson() => {
    'host': host?.name,
    'outputDir': outputDir,
    'siteUrl': siteUrl,
    'firebaseProject': firebaseProject,
    'netlifySite': netlifySite,
    'githubRepo': githubRepo,
    'customDomain': customDomain,
  };

  factory WebProjectConfig.fromJson(Map<String, Object?> j) => WebProjectConfig(
    host: HostingProvider.values.where((h) => h.name == j['host']).firstOrNull,
    outputDir: j['outputDir'] as String?,
    siteUrl: '${j['siteUrl'] ?? ''}',
    firebaseProject: '${j['firebaseProject'] ?? ''}',
    netlifySite: '${j['netlifySite'] ?? ''}',
    githubRepo: '${j['githubRepo'] ?? ''}',
    customDomain: '${j['customDomain'] ?? ''}',
  );

  @override
  bool operator ==(Object other) =>
      other is WebProjectConfig &&
      jsonEncode(other.toJson()) == jsonEncode(toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;
}

final _firebaseId = RegExp(r'^[a-z0-9][a-z0-9-]{4,28}[a-z0-9]$');
final _netlifySite = RegExp(r'^[A-Za-z0-9][A-Za-z0-9-]{0,62}$|^[0-9a-f-]{36}$');
final _githubRepo = RegExp(r'^[A-Za-z0-9-]{1,39}/[A-Za-z0-9._-]{1,100}$');
final _domain = RegExp(
  r'^(?=.{4,253}$)([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$',
);

bool validFirebaseProject(String v) => _firebaseId.hasMatch(v);
bool validNetlifySite(String v) => _netlifySite.hasMatch(v);
bool validGithubRepo(String v) => _githubRepo.hasMatch(v);
bool validDomain(String v) => _domain.hasMatch(v.toLowerCase());

/// Fichier de configuration proposé (chemin relatif à la racine).
typedef HostingFile = ({String path, String content});

/// Ce qui manque pour préparer ou déployer.
enum HostingGap { firebaseProject, githubRepo, buildCommand }

List<HostingGap> hostingGaps(
  HostingProvider host,
  WebProjectConfig c,
  WebBuildPlan plan,
) => [
  if (host == HostingProvider.firebase &&
      !validFirebaseProject(c.firebaseProject))
    HostingGap.firebaseProject,
  if (host == HostingProvider.githubPages && !validGithubRepo(c.githubRepo))
    HostingGap.githubRepo,
  if (host == HostingProvider.githubPages &&
      !plan.hasCommand &&
      plan.framework != 'HTML')
    HostingGap.buildCommand,
];

/// Chemin de [path] relativement à [from] (tous deux relatifs à la racine).
String _relative(String path, String from) {
  final r = p.posix.relative(
    path.isEmpty ? '.' : path,
    from: from.isEmpty ? '.' : from,
  );
  return r;
}

/// Fichiers de configuration de [host]. [existing] donne le contenu actuel
/// des fichiers (pour fusionner sans perdre les réglages de l'utilisateur).
List<HostingFile> hostingFiles(
  HostingProvider host,
  WebProjectConfig c,
  WebBuildPlan plan, {
  Map<String, String?> existing = const {},
  String nodeVersion = '20',
}) {
  final output = c.outputDir ?? plan.outputDir;
  final cacheHeaders = [
    {
      'source': '**/*.@(js|css|png|jpg|jpeg|webp|svg|woff2)',
      'headers': [
        {'key': 'Cache-Control', 'value': 'public, max-age=604800'},
      ],
    },
  ];
  switch (host) {
    case HostingProvider.firebase:
      Map<String, Object?> json = {};
      try {
        final raw = existing['firebase.json'];
        if (raw != null) json = (jsonDecode(raw) as Map).cast();
      } on Object {
        json = {};
      }
      json['hosting'] = {
        'public': output.isEmpty ? '.' : output,
        'ignore': ['firebase.json', '**/.*', '**/node_modules/**'],
        if (plan.spa)
          'rewrites': [
            {'source': '**', 'destination': '/index.html'},
          ],
        'headers': cacheHeaders,
      };
      Map<String, Object?> rc = {};
      try {
        final raw = existing['.firebaserc'];
        if (raw != null) rc = (jsonDecode(raw) as Map).cast();
      } on Object {
        rc = {};
      }
      final projects = (rc['projects'] as Map?)?.cast<String, Object?>() ?? {};
      projects['default'] = c.firebaseProject;
      rc['projects'] = projects;
      const enc = JsonEncoder.withIndent('  ');
      return [
        (path: 'firebase.json', content: '${enc.convert(json)}\n'),
        (path: '.firebaserc', content: '${enc.convert(rc)}\n'),
      ];

    case HostingProvider.vercel:
      // Placé dans le dossier public : il est recopié dans la sortie, que
      // l'on déploie telle quelle.
      final path = p.posix.join(plan.publicDir, 'vercel.json');
      final json = <String, Object?>{
        r'$schema': 'https://openapi.vercel.sh/vercel.json',
        if (plan.spa)
          'rewrites': [
            {'source': '/(.*)', 'destination': '/index.html'},
          ],
        'headers': [
          {
            'source': '/(.*)\\.(js|css|png|jpg|jpeg|webp|svg|woff2)',
            'headers': [
              {'key': 'Cache-Control', 'value': 'public, max-age=604800'},
            ],
          },
        ],
      };
      return [
        (
          path: path,
          content: '${const JsonEncoder.withIndent('  ').convert(json)}\n',
        ),
      ];

    case HostingProvider.netlify:
      final workDir = plan.workingDir;
      final toml = StringBuffer()
        ..writeln('# Généré par LaunchPilot : vérifie avant de valider.')
        ..writeln('[build]')
        ..writeln(
          '  publish = "${_relative(output, plan.hasCommand ? workDir : '')}"',
        );
      if (plan.hasCommand) {
        if (workDir.isNotEmpty) toml.writeln('  base = "$workDir"');
        toml.writeln('  command = "${plan.commandLine}"');
      }
      if (plan.spa) {
        toml
          ..writeln()
          ..writeln('[[redirects]]')
          ..writeln('  from = "/*"')
          ..writeln('  to = "/index.html"')
          ..writeln('  status = 200');
      }
      toml
        ..writeln()
        ..writeln('[[headers]]')
        ..writeln('  for = "/*.js"')
        ..writeln('  [headers.values]')
        ..writeln('    Cache-Control = "public, max-age=604800"');
      return [(path: 'netlify.toml', content: toml.toString())];

    case HostingProvider.githubPages:
      final repo = c.githubRepo.split('/').last;
      final custom = c.customDomain.trim().toLowerCase();
      final userSite = repo.toLowerCase().endsWith('.github.io');
      final basePath = custom.isNotEmpty || userSite ? '/' : '/$repo/';
      final workDir = plan.workingDir.isEmpty ? '.' : plan.workingDir;
      final buildSteps = StringBuffer();
      if (plan.isFlutter) {
        buildSteps
          ..writeln('      - uses: subosito/flutter-action@v2')
          ..writeln('        with:')
          ..writeln('          channel: stable')
          ..writeln('      - run: flutter pub get')
          ..writeln('        working-directory: $workDir')
          ..writeln(
            '      - run: flutter build web --release --base-href $basePath',
          )
          ..writeln('        working-directory: $workDir');
      } else if (plan.hasCommand) {
        final mgr = plan.executable!;
        final install = switch (mgr) {
          'pnpm' => 'pnpm install --frozen-lockfile',
          'yarn' => 'yarn install --frozen-lockfile',
          'bun' => 'bun install --frozen-lockfile',
          _ => 'npm ci',
        };
        if (mgr == 'pnpm') {
          buildSteps.writeln('      - uses: pnpm/action-setup@v4');
        }
        if (mgr == 'bun') {
          buildSteps.writeln('      - uses: oven-sh/setup-bun@v2');
        }
        buildSteps
          ..writeln('      - uses: actions/setup-node@v4')
          ..writeln('        with:')
          ..writeln("          node-version: '$nodeVersion'")
          ..writeln('      - run: $install')
          ..writeln('        working-directory: $workDir')
          ..writeln('      - run: ${plan.commandLine}')
          ..writeln('        working-directory: $workDir');
      }
      final outputPath = output.isEmpty ? '.' : output;
      if (plan.spa) {
        buildSteps
          ..writeln(
            '      # Application monopage : les routes inconnues renvoient l\'accueil.',
          )
          ..writeln(
            '      - run: cp $outputPath/index.html $outputPath/404.html',
          );
      }
      final workflow =
          '''
# Généré par LaunchPilot. Le site est publié à chaque push sur main :
# LaunchPilot ne pousse jamais lui-même.
name: Déploiement GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
$buildSteps      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with:
          path: $outputPath

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: \${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
''';
      return [
        (path: '.github/workflows/deploy-pages.yml', content: workflow),
        (path: p.posix.join(plan.publicDir, '.nojekyll'), content: ''),
        if (custom.isNotEmpty)
          (path: p.posix.join(plan.publicDir, 'CNAME'), content: '$custom\n'),
      ];
  }
}

/// Ce que devient le site après un déploiement.
enum DeployKind {
  /// Adresse temporaire de prévisualisation.
  preview,

  /// Site public.
  production,
}

/// Commande de déploiement du flux dédié (null pour GitHub Pages : le
/// déploiement suit un push, que LaunchPilot ne fait jamais).
CommandSpec? deployCommand(
  HostingProvider host,
  WebProjectConfig c,
  WebBuildPlan plan,
  String root,
  DeployKind kind,
) {
  final output = c.outputDir ?? plan.outputDir;
  final prod = kind == DeployKind.production;
  final args = switch (host) {
    HostingProvider.firebase =>
      prod
          ? [
              'deploy',
              '--only',
              'hosting',
              '--project',
              c.firebaseProject,
              '--non-interactive',
            ]
          : [
              'hosting:channel:deploy',
              'preview',
              '--project',
              c.firebaseProject,
              '--non-interactive',
            ],
    HostingProvider.vercel => [
      'deploy',
      output.isEmpty ? '.' : output,
      '--yes',
      if (prod) '--prod',
    ],
    HostingProvider.netlify => [
      'deploy',
      '--dir=${output.isEmpty ? '.' : output}',
      '--no-build',
      if (c.netlifySite.isNotEmpty) '--site=${c.netlifySite}',
      if (prod) '--prod',
    ],
    HostingProvider.githubPages => null,
  };
  if (args == null) return null;
  return CommandSpec(
    executable: switch (host) {
      HostingProvider.firebase => 'firebase',
      HostingProvider.vercel => 'vercel',
      _ => 'netlify',
    },
    arguments: args,
    workingDirectory: root,
    timeout: const Duration(minutes: 10),
    purpose: CommandPurpose.deployment,
  );
}

/// Outil en ligne de commande de chaque hébergeur.
String? hostingCli(HostingProvider h) => switch (h) {
  HostingProvider.firebase => 'firebase',
  HostingProvider.vercel => 'vercel',
  HostingProvider.netlify => 'netlify',
  HostingProvider.githubPages => null,
};

/// Connexion à faire soi-même, dans son propre terminal.
String? hostingLogin(HostingProvider h) => switch (h) {
  HostingProvider.firebase => 'firebase login',
  HostingProvider.vercel => 'vercel login',
  HostingProvider.netlify => 'netlify login',
  HostingProvider.githubPages => null,
};

/// Installation suggérée (jamais lancée par LaunchPilot : installation
/// globale).
String? hostingInstall(HostingProvider h) => switch (h) {
  HostingProvider.firebase => 'npm install -g firebase-tools',
  HostingProvider.vercel => 'npm install -g vercel',
  HostingProvider.netlify => 'npm install -g netlify-cli',
  HostingProvider.githubPages => null,
};

// ------------------------------------------------------------------- DNS

@immutable
class DnsRecord {
  const DnsRecord(this.type, this.name, this.value);

  final String type;

  /// `@` pour le domaine racine.
  final String name;
  final String value;

  @override
  String toString() => '$type $name $value';
}

/// Domaine racine (exemple.fr) ou sous-domaine (www.exemple.fr). Les
/// suffixes à deux niveaux courants (co.uk…) sont pris en compte.
bool isApexDomain(String domain) {
  final labels = domain.toLowerCase().split('.');
  const twoLevel = {'co.uk', 'org.uk', 'com.au', 'co.nz', 'com.br', 'co.jp'};
  final suffix = labels.length >= 2
      ? labels.sublist(labels.length - 2).join('.')
      : '';
  return labels.length == 2 ||
      (labels.length == 3 && twoLevel.contains(suffix));
}

/// Enregistrements recommandés, à saisir chez le gestionnaire du domaine.
/// Vide pour Firebase : la console fournit des valeurs propres au projet.
List<DnsRecord> dnsRecords(
  HostingProvider host,
  String domain, {
  String githubUser = '',
  String netlifySite = '',
}) {
  final apex = isApexDomain(domain);
  final sub = apex ? null : domain.split('.').first;
  switch (host) {
    case HostingProvider.firebase:
      return const [];
    case HostingProvider.vercel:
      return [
        if (apex) const DnsRecord('A', '@', '76.76.21.21'),
        DnsRecord('CNAME', sub ?? 'www', 'cname.vercel-dns-0.com'),
      ];
    case HostingProvider.netlify:
      final target = netlifySite.isEmpty
          ? '<site>.netlify.app'
          : '$netlifySite.netlify.app';
      return [
        if (apex) const DnsRecord('A', '@', '75.2.60.5'),
        DnsRecord('CNAME', sub ?? 'www', target),
      ];
    case HostingProvider.githubPages:
      final target = githubUser.isEmpty
          ? '<utilisateur>.github.io'
          : '${githubUser.toLowerCase()}.github.io';
      return [
        if (apex) ...[
          for (final n in const [108, 109, 110, 111])
            DnsRecord('A', '@', '185.199.$n.153'),
          for (final n in const [0, 1, 2, 3])
            DnsRecord('AAAA', '@', '2606:50c0:800$n::153'),
          DnsRecord('CNAME', 'www', target),
        ] else
          DnsRecord('CNAME', sub!, target),
      ];
  }
}

// ------------------------------------------------------------ Lighthouse

/// Fichier de rapport écrit par Lighthouse à la racine du projet.
const lighthouseReportFile = 'lighthouse-report.json';

CommandSpec lighthouseCommand(String url, String root) => CommandSpec(
  executable: 'lighthouse',
  arguments: [
    url,
    '--output=json',
    '--output-path=./$lighthouseReportFile',
    '--quiet',
    '--chrome-flags=--headless=new',
  ],
  workingDirectory: root,
  timeout: const Duration(minutes: 3),
);

/// Scores (0–100) par catégorie d'un rapport Lighthouse JSON.
Map<String, int>? parseLighthouse(String json) {
  try {
    final data = (jsonDecode(json) as Map).cast<String, Object?>();
    final categories = (data['categories'] as Map).cast<String, Object?>();
    return {
      for (final e in categories.entries)
        if ((e.value as Map)['score'] case final num score)
          e.key: (score * 100).round(),
    };
  } on Object {
    return null;
  }
}
