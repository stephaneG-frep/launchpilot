import 'package:path/path.dart' as p;

import 'command_spec.dart';

/// Politique de sécurité des commandes. Pure et déterministe : elle ne
/// regarde que la commande et la racine du projet.
///
/// Tout ce qui n'est pas explicitement reconnu est refusé.
class CommandPolicy {
  const CommandPolicy();

  static const allowlist = {
    'git',
    'flutter',
    'dart',
    'npm',
    'pnpm',
    'yarn',
    'bun',
    'node',
    'firebase',
    'vercel',
    'netlify',
    'lighthouse',
    'fastlane',
  };

  static const _shells = {
    'sh',
    'bash',
    'zsh',
    'dash',
    'fish',
    'ksh',
    'csh',
    'tcsh',
    'pwsh',
    'powershell',
    'cmd',
    'env',
    'xargs',
    'eval',
    'exec',
  };

  static const _privileged = {'sudo', 'su', 'doas', 'pkexec', 'runas'};

  PolicyDecision evaluate(CommandSpec spec, String projectRoot) {
    final exe = spec.executable;
    if (exe.isEmpty ||
        exe.contains('/') ||
        exe.contains(r'\') ||
        exe.contains(RegExp(r'\s'))) {
      return const PolicyDecision(RiskLevel.forbidden, [
        PolicyIssue.invalidExecutable,
      ]);
    }
    if (_privileged.contains(exe)) {
      return const PolicyDecision(RiskLevel.forbidden, [
        PolicyIssue.privileged,
      ]);
    }
    if (_shells.contains(exe)) {
      return const PolicyDecision(RiskLevel.forbidden, [PolicyIssue.shell]);
    }
    if (!allowlist.contains(exe)) {
      return const PolicyDecision(RiskLevel.forbidden, [
        PolicyIssue.notAllowlisted,
      ]);
    }

    final root = p.normalize(p.absolute(projectRoot));
    final wd = p.normalize(p.absolute(spec.workingDirectory));
    if (wd != root && !p.isWithin(root, wd)) {
      return const PolicyDecision(RiskLevel.forbidden, [
        PolicyIssue.workingDirectoryOutside,
      ]);
    }

    for (final arg in spec.arguments) {
      if (arg.contains('\u0000') || arg.contains('\n') || arg.contains('\r')) {
        return const PolicyDecision(RiskLevel.forbidden, [
          PolicyIssue.invalidArgument,
        ]);
      }
      if (_escapesProject(arg, wd, root)) {
        return const PolicyDecision(RiskLevel.forbidden, [
          PolicyIssue.outsideProject,
        ]);
      }
    }

    final args = spec.arguments;
    return switch (exe) {
      'git' => _git(args),
      'flutter' => _flutter(args),
      'dart' => _dart(args),
      'node' => _node(args),
      'firebase' || 'vercel' || 'netlify' => _hosting(exe, spec),
      'lighthouse' => _lighthouse(args),
      'fastlane' => _fastlane(spec),
      _ => _packageManager(args),
    };
  }

  /// Un argument qui ressemble à un chemin et sort du projet est refusé.
  /// Les options `--x=chemin` sont examinées aussi.
  static bool _escapesProject(String arg, String wd, String root) {
    var value = arg;
    final eq = arg.indexOf('=');
    if (arg.startsWith('-') && eq > 0) value = arg.substring(eq + 1);
    if (value.startsWith('-') || value.isEmpty) return false;
    final looksLikePath =
        value.startsWith('/') ||
        value.startsWith('~') ||
        value == '..' ||
        value.startsWith('../') ||
        value.contains('/../');
    if (!looksLikePath) return false;
    if (value.startsWith('~')) return true;
    final resolved = p.normalize(
      p.isAbsolute(value) ? value : p.join(wd, value),
    );
    return resolved != root && !p.isWithin(root, resolved);
  }

  static List<String> _positional(List<String> args) =>
      args.where((a) => !a.startsWith('-')).toList();

  static bool _hasAny(List<String> args, Set<String> flags) =>
      args.any((a) => flags.contains(a.split('=').first));

  // ------------------------------------------------------------------ git

  static PolicyDecision _git(List<String> args) {
    if (args.isEmpty || (args.length == 1 && args.first == '--version')) {
      return const PolicyDecision(RiskLevel.readOnly);
    }
    final subIndex = args.indexWhere((a) => !a.startsWith('-'));
    // Options globales (avant la sous-commande) : configuration ou cible
    // modifiées, ou forme inattendue.
    if (subIndex != 0) {
      return const PolicyDecision(RiskLevel.forbidden, [
        PolicyIssue.systemChange,
      ]);
    }
    final sub = args[subIndex];
    final rest = args.sublist(subIndex + 1);

    const readOnly = {
      'status',
      'log',
      'diff',
      'show',
      'rev-parse',
      'ls-files',
      'describe',
      'check-ignore',
      'shortlog',
      'blame',
      'rev-list',
    };
    if (readOnly.contains(sub)) return const PolicyDecision(RiskLevel.readOnly);

    switch (sub) {
      case 'push':
        return const PolicyDecision(RiskLevel.forbidden, [PolicyIssue.gitPush]);
      case 'reset' ||
          'clean' ||
          'rebase' ||
          'filter-branch' ||
          'filter-repo' ||
          'gc' ||
          'prune' ||
          'reflog' ||
          'update-ref' ||
          'restore' ||
          'checkout' ||
          'rm' ||
          'mv' ||
          'revert' ||
          'merge' ||
          'cherry-pick' ||
          'pull' ||
          'am' ||
          'apply':
        // La restauration passe par le mécanisme ciblé de LaunchPilot.
        if (sub == 'checkout' && _isBranchCreation(rest, '-b')) {
          return const PolicyDecision(RiskLevel.sensitive);
        }
        return const PolicyDecision(RiskLevel.forbidden, [
          PolicyIssue.destructive,
        ]);
      case 'config' ||
          'remote' ||
          'submodule' ||
          'worktree' ||
          'init' ||
          'clone' ||
          'credential' ||
          'daemon' ||
          'fetch':
        return const PolicyDecision(RiskLevel.forbidden, [
          PolicyIssue.systemChange,
        ]);
      case 'switch':
        if (_isBranchCreation(rest, '-c')) {
          return const PolicyDecision(RiskLevel.sensitive);
        }
        return const PolicyDecision(RiskLevel.forbidden, [
          PolicyIssue.destructive,
        ]);
      case 'branch':
        if (rest.isEmpty ||
            _hasAny(rest, {
              '--show-current',
              '--list',
              '-l',
              '-a',
              '-r',
              '-v',
              '-vv',
            })) {
          return const PolicyDecision(RiskLevel.readOnly);
        }
        if (_hasAny(rest, {
          '-d',
          '-D',
          '--delete',
          '-m',
          '-M',
          '--move',
          '-f',
          '--force',
        })) {
          return const PolicyDecision(RiskLevel.forbidden, [
            PolicyIssue.destructive,
          ]);
        }
        return const PolicyDecision(RiskLevel.sensitive);
      case 'tag':
        if (rest.isEmpty || _hasAny(rest, {'-l', '--list', '-n'})) {
          return const PolicyDecision(RiskLevel.readOnly);
        }
        if (_hasAny(rest, {'-d', '--delete', '-f', '--force'})) {
          return const PolicyDecision(RiskLevel.forbidden, [
            PolicyIssue.destructive,
          ]);
        }
        return const PolicyDecision(RiskLevel.sensitive, [
          PolicyIssue.createsTag,
        ]);
      case 'stash':
        final action = _positional(rest).firstOrNull;
        if (action == 'list' || action == 'show') {
          return const PolicyDecision(RiskLevel.readOnly);
        }
        if (action == null || action == 'push' || action == 'save') {
          return const PolicyDecision(RiskLevel.sensitive);
        }
        return const PolicyDecision(RiskLevel.forbidden, [
          PolicyIssue.destructive,
        ]);
      case 'add' || 'commit':
        if (_hasAny(rest, {'--amend', '-f', '--force'})) {
          return const PolicyDecision(RiskLevel.forbidden, [
            PolicyIssue.destructive,
          ]);
        }
        return const PolicyDecision(RiskLevel.sensitive);
    }
    return const PolicyDecision(RiskLevel.forbidden, [
      PolicyIssue.unknownSubcommand,
    ]);
  }

  /// `git switch -c nom` / `git checkout -b nom` : création seule, sans
  /// point de départ ni option de forçage.
  static bool _isBranchCreation(List<String> rest, String flag) =>
      rest.length == 2 &&
      rest[0] == flag &&
      RegExp(r'^[A-Za-z0-9._/\-+]+$').hasMatch(rest[1]) &&
      !rest[1].startsWith('-');

  // -------------------------------------------------------------- flutter

  static PolicyDecision _flutter(List<String> args) {
    final pos = _positional(args);
    if (pos.isEmpty) {
      return args.every((a) => const {'--version', '-h', '--help'}.contains(a))
          ? const PolicyDecision(RiskLevel.readOnly)
          : const PolicyDecision(RiskLevel.forbidden, [
              PolicyIssue.unknownSubcommand,
            ]);
    }
    final sub = pos.first;
    switch (sub) {
      case 'doctor' || 'analyze' || 'devices' || 'emulators' || '--version':
        return const PolicyDecision(RiskLevel.readOnly);
      case 'build' || 'test' || 'gen-l10n':
        return const PolicyDecision(RiskLevel.local);
      case 'clean':
        // Supprime build/ et .dart_tool/ : fichiers générés uniquement.
        return const PolicyDecision(RiskLevel.local);
      case 'pub':
        return _pub(pos.skip(1).toList());
      case 'upgrade' || 'downgrade' || 'channel' || 'config' || 'precache':
        return const PolicyDecision(RiskLevel.forbidden, [
          PolicyIssue.systemChange,
        ]);
      case 'create':
        return const PolicyDecision(RiskLevel.sensitive);
    }
    return const PolicyDecision(RiskLevel.forbidden, [
      PolicyIssue.unknownSubcommand,
    ]);
  }

  static PolicyDecision _pub(List<String> pos) {
    final action = pos.firstOrNull;
    return switch (action) {
      'outdated' || 'deps' => const PolicyDecision(RiskLevel.readOnly),
      'get' ||
      'upgrade' ||
      'downgrade' => const PolicyDecision(RiskLevel.local),
      'publish' => const PolicyDecision(RiskLevel.forbidden, [
        PolicyIssue.publication,
      ]),
      'global' || 'cache' => const PolicyDecision(RiskLevel.forbidden, [
        PolicyIssue.globalInstall,
      ]),
      'add' || 'remove' => const PolicyDecision(RiskLevel.sensitive),
      _ => const PolicyDecision(RiskLevel.forbidden, [
        PolicyIssue.unknownSubcommand,
      ]),
    };
  }

  // ----------------------------------------------------------------- dart

  static PolicyDecision _dart(List<String> args) {
    final pos = _positional(args);
    if (pos.isEmpty) {
      return args.contains('--version')
          ? const PolicyDecision(RiskLevel.readOnly)
          : const PolicyDecision(RiskLevel.forbidden, [
              PolicyIssue.unknownSubcommand,
            ]);
    }
    switch (pos.first) {
      case 'analyze':
        return const PolicyDecision(RiskLevel.readOnly);
      case 'format':
        // Lecture seule seulement si aucune écriture n'est demandée.
        final o = args.indexOf('-o');
        final noWrite =
            args.contains('--output=none') ||
            (o >= 0 && o + 1 < args.length && args[o + 1] == 'none');
        return noWrite
            ? const PolicyDecision(RiskLevel.readOnly)
            : const PolicyDecision(RiskLevel.sensitive);
      case 'fix':
        return args.contains('--apply')
            ? const PolicyDecision(RiskLevel.sensitive)
            : const PolicyDecision(RiskLevel.readOnly);
      case 'test':
        return const PolicyDecision(RiskLevel.local);
      case 'pub':
        return _pub(pos.skip(1).toList());
      case 'run':
        return const PolicyDecision(RiskLevel.sensitive, [
          PolicyIssue.runsProjectScript,
        ]);
    }
    return const PolicyDecision(RiskLevel.forbidden, [
      PolicyIssue.unknownSubcommand,
    ]);
  }

  // ------------------------------------------------------- hébergeurs

  static final _firebaseId = RegExp(r'^[a-z0-9][a-z0-9-]{4,28}[a-z0-9]$');
  static final _siteId = RegExp(r'^[A-Za-z0-9][A-Za-z0-9-]{0,62}$');

  /// Seules les formes exactes produites par le flux de déploiement sont
  /// acceptées, et uniquement quand elles viennent de ce flux.
  static PolicyDecision _hosting(String exe, CommandSpec spec) {
    final args = spec.arguments;
    if (args.length == 1 && (args.first == '--version' || args.first == '-v')) {
      return const PolicyDecision(RiskLevel.readOnly);
    }
    const publication = PolicyDecision(RiskLevel.forbidden, [
      PolicyIssue.publication,
    ]);
    final dedicated = spec.purpose == CommandPurpose.deployment;
    PolicyDecision deploy(bool production) => dedicated
        ? PolicyDecision(RiskLevel.sensitive, [
            production
                ? PolicyIssue.productionDeploy
                : PolicyIssue.previewDeploy,
          ])
        : publication;

    switch (exe) {
      case 'firebase':
        if (args.length == 6 &&
            args[0] == 'deploy' &&
            args[1] == '--only' &&
            args[2] == 'hosting' &&
            args[3] == '--project' &&
            _firebaseId.hasMatch(args[4]) &&
            args[5] == '--non-interactive') {
          return deploy(true);
        }
        if (args.length == 5 &&
            args[0] == 'hosting:channel:deploy' &&
            args[1] == 'preview' &&
            args[2] == '--project' &&
            _firebaseId.hasMatch(args[3]) &&
            args[4] == '--non-interactive') {
          return deploy(false);
        }
        final sub = _positional(args).firstOrNull ?? '';
        if (sub == 'deploy' || sub.startsWith('hosting:')) return publication;
      case 'vercel':
        final pos = _positional(args);
        if (pos.length == 2 &&
            pos[0] == 'deploy' &&
            args.length >= 3 &&
            args[0] == 'deploy' &&
            args[1] == pos[1] &&
            args[2] == '--yes' &&
            args.skip(3).every((a) => a == '--prod') &&
            args.length <= 4) {
          return deploy(args.contains('--prod'));
        }
        // `vercel` seul déploie : refusé comme toute publication.
        if (pos.isEmpty ||
            const {'deploy', 'promote', 'redeploy'}.contains(pos.first)) {
          return publication;
        }
      case 'netlify':
        if (args.isNotEmpty &&
            args[0] == 'deploy' &&
            args.length >= 3 &&
            args[1].startsWith('--dir=') &&
            args[2] == '--no-build') {
          final rest = args.skip(3).toList();
          final site = rest.where((a) => a.startsWith('--site=')).toList();
          final ok =
              rest.every((a) => a == '--prod' || a.startsWith('--site=')) &&
              site.length <= 1 &&
              rest.where((a) => a == '--prod').length <= 1 &&
              site.every(
                (a) =>
                    _siteId.hasMatch(a.substring(7)) ||
                    RegExp(r'^[0-9a-f-]{36}$').hasMatch(a.substring(7)),
              );
          if (ok) return deploy(rest.contains('--prod'));
        }
        if (_positional(args).firstOrNull == 'deploy') return publication;
    }
    final sub = _positional(args).firstOrNull;
    if (sub == 'login' || sub == 'logout' || sub == 'link' || sub == 'init') {
      return const PolicyDecision(RiskLevel.forbidden, [
        PolicyIssue.systemChange,
      ]);
    }
    return const PolicyDecision(RiskLevel.forbidden, [
      PolicyIssue.unknownSubcommand,
    ]);
  }

  /// Fastlane : uniquement les lanes générées par LaunchPilot, avec la clé
  /// du compte de service passée en argument (`json_key:/chemin.json`).
  static PolicyDecision _fastlane(CommandSpec spec) {
    final args = spec.arguments;
    if (args.length == 1 && args.first == '--version') {
      return const PolicyDecision(RiskLevel.readOnly);
    }
    final ok =
        args.length == 2 &&
        const {'check', 'internal', 'metadata'}.contains(args[0]) &&
        RegExp(r'^json_key:/[^\s"$`\;|&<>]+\.json$').hasMatch(args[1]);
    if (!ok) {
      return const PolicyDecision(RiskLevel.forbidden, [
        PolicyIssue.unknownSubcommand,
      ]);
    }
    if (args[0] == 'check') {
      return const PolicyDecision(RiskLevel.local, [PolicyIssue.network]);
    }
    return spec.purpose == CommandPurpose.deployment
        ? const PolicyDecision(RiskLevel.sensitive, [
            PolicyIssue.storePublication,
          ])
        : const PolicyDecision(RiskLevel.forbidden, [PolicyIssue.publication]);
  }

  /// Audit Lighthouse d'une adresse, rapport écrit dans le projet.
  static PolicyDecision _lighthouse(List<String> args) {
    if (args.length == 1 && args.first == '--version') {
      return const PolicyDecision(RiskLevel.readOnly);
    }
    final url = Uri.tryParse(args.firstOrNull ?? '');
    final ok =
        args.length == 5 &&
        url != null &&
        (url.scheme == 'https' || url.scheme == 'http') &&
        url.host.isNotEmpty &&
        args[1] == '--output=json' &&
        args[2] == '--output-path=./lighthouse-report.json' &&
        args[3] == '--quiet' &&
        args[4] == '--chrome-flags=--headless=new';
    return ok
        ? const PolicyDecision(RiskLevel.local, [PolicyIssue.network])
        : const PolicyDecision(RiskLevel.forbidden, [
            PolicyIssue.unknownSubcommand,
          ]);
  }

  // ----------------------------------------------------------------- node

  static PolicyDecision _node(List<String> args) =>
      args.length == 1 && (args.first == '--version' || args.first == '-v')
      ? const PolicyDecision(RiskLevel.readOnly)
      : const PolicyDecision(RiskLevel.forbidden, [PolicyIssue.remoteCode]);

  // ------------------------------------------------- npm, pnpm, yarn, bun

  static PolicyDecision _packageManager(List<String> args) {
    if (_hasAny(args, {'-g', '--global', '--location'})) {
      return const PolicyDecision(RiskLevel.forbidden, [
        PolicyIssue.globalInstall,
      ]);
    }
    final pos = _positional(args);
    if (pos.isEmpty) {
      return args.length == 1 &&
              (args.first == '--version' || args.first == '-v')
          ? const PolicyDecision(RiskLevel.readOnly)
          : const PolicyDecision(RiskLevel.forbidden, [
              PolicyIssue.unknownSubcommand,
            ]);
    }
    final sub = pos.first;
    switch (sub) {
      case 'ls' || 'list' || 'outdated' || 'why' || 'view' || 'info':
        return const PolicyDecision(RiskLevel.readOnly);
      case 'audit':
        return pos.contains('fix')
            ? const PolicyDecision(RiskLevel.sensitive)
            : const PolicyDecision(RiskLevel.readOnly);
      case 'install' || 'i' || 'ci' when pos.length == 1:
        // Installe les dépendances déclarées par le projet.
        return const PolicyDecision(RiskLevel.local);
      case 'run' ||
          'run-script' ||
          'test' ||
          'build' ||
          'start' ||
          'dev' ||
          'preview' ||
          'lint':
        // Exécute un script dont le contenu est défini par le projet.
        return const PolicyDecision(RiskLevel.sensitive, [
          PolicyIssue.runsProjectScript,
        ]);
      case 'install' ||
          'i' ||
          'add' ||
          'remove' ||
          'uninstall' ||
          'rm' ||
          'update' ||
          'upgrade':
        // Modifie package.json et le fichier de verrouillage.
        return const PolicyDecision(RiskLevel.sensitive);
      case 'publish' || 'deploy' || 'pack' || 'version':
        return const PolicyDecision(RiskLevel.forbidden, [
          PolicyIssue.publication,
        ]);
      case 'exec' || 'x' || 'dlx' || 'create' || 'init':
        return const PolicyDecision(RiskLevel.forbidden, [
          PolicyIssue.remoteCode,
        ]);
      case 'config' || 'login' || 'logout' || 'adduser' || 'token':
        return const PolicyDecision(RiskLevel.forbidden, [
          PolicyIssue.systemChange,
        ]);
    }
    return const PolicyDecision(RiskLevel.forbidden, [
      PolicyIssue.unknownSubcommand,
    ]);
  }
}
