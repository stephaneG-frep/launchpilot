import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/domain/cancellation.dart';
import 'package:launchpilot/features/commands/data/process_command_runner.dart';
import 'package:launchpilot/features/commands/domain/command_line.dart';
import 'package:launchpilot/features/commands/domain/command_policy.dart';
import 'package:launchpilot/features/commands/domain/command_result.dart';
import 'package:launchpilot/features/commands/domain/command_spec.dart';

const root = '/home/testeur/projet';

PolicyDecision evaluate(String line, {String wd = root}) {
  final tokens = splitCommandLine(line)!;
  return const CommandPolicy().evaluate(
    CommandSpec(
      executable: tokens.first,
      arguments: tokens.skip(1).toList(),
      workingDirectory: wd,
    ),
    root,
  );
}

/// Autorise tout en lecture seule : pour tester le runner avec des outils
/// système (sleep, printf, ls) sans affaiblir la vraie politique.
class PermissivePolicy extends CommandPolicy {
  const PermissivePolicy();
  @override
  PolicyDecision evaluate(CommandSpec spec, String projectRoot) =>
      const PolicyDecision(RiskLevel.readOnly);
}

void main() {
  group('splitCommandLine', () {
    test('groupe avec les guillemets, sans aucune interprétation', () {
      expect(splitCommandLine('git log -n 5'), ['git', 'log', '-n', '5']);
      expect(splitCommandLine('git commit -m "première version"'), [
        'git',
        'commit',
        '-m',
        'première version',
      ]);
      expect(splitCommandLine(r"echo '$HOME' \*"), ['echo', r'$HOME', '*']);
      expect(splitCommandLine('a ""'), ['a', '']);
      expect(splitCommandLine('git "non fermé'), isNull);
    });

    test('repère les opérateurs de shell (sans effet ici)', () {
      expect(
        containsShellOperators(splitCommandLine('git log | less')!),
        isTrue,
      );
      expect(containsShellOperators(splitCommandLine('git log')!), isFalse);
    });
  });

  group('CommandPolicy', () {
    final cases = <String, RiskLevel>{
      // Lecture seule
      'git status --porcelain': RiskLevel.readOnly,
      'git log -n 10': RiskLevel.readOnly,
      'git diff': RiskLevel.readOnly,
      'git branch --show-current': RiskLevel.readOnly,
      'git tag': RiskLevel.readOnly,
      'git check-ignore -q .env': RiskLevel.readOnly,
      'flutter doctor -v': RiskLevel.readOnly,
      'flutter analyze': RiskLevel.readOnly,
      'flutter --version': RiskLevel.readOnly,
      'flutter pub outdated': RiskLevel.readOnly,
      'dart format --output=none --set-exit-if-changed .': RiskLevel.readOnly,
      'npm ls': RiskLevel.readOnly,
      'npm audit': RiskLevel.readOnly,
      'node --version': RiskLevel.readOnly,
      // Local : fichiers générés
      'flutter build appbundle --release': RiskLevel.local,
      'flutter test': RiskLevel.local,
      'flutter pub get': RiskLevel.local,
      'npm ci': RiskLevel.local,
      'pnpm install': RiskLevel.local,
      // Sensible : confirmation obligatoire
      'git switch -c launchpilot/release-1.3.0': RiskLevel.sensitive,
      'git checkout -b launchpilot/release-1.3.0': RiskLevel.sensitive,
      'git add pubspec.yaml': RiskLevel.sensitive,
      'git commit -m version': RiskLevel.sensitive,
      'git tag v1.3.0': RiskLevel.sensitive,
      'git stash': RiskLevel.sensitive,
      'npm run build': RiskLevel.sensitive,
      'yarn build': RiskLevel.sensitive,
      'npm install lodash': RiskLevel.sensitive,
      'dart format .': RiskLevel.sensitive,
      'npm audit fix': RiskLevel.sensitive,
      // Interdit
      'git push origin main': RiskLevel.forbidden,
      'git reset --hard HEAD': RiskLevel.forbidden,
      'git clean -fdx': RiskLevel.forbidden,
      'git checkout -- .': RiskLevel.forbidden,
      'git restore lib/main.dart': RiskLevel.forbidden,
      'git switch main': RiskLevel.forbidden,
      'git branch -D feature': RiskLevel.forbidden,
      'git tag -d v1.0.0': RiskLevel.forbidden,
      'git commit --amend': RiskLevel.forbidden,
      'git stash drop': RiskLevel.forbidden,
      'git config user.email x': RiskLevel.forbidden,
      'git -c core.hooksPath=/tmp status': RiskLevel.forbidden,
      'git remote add o url': RiskLevel.forbidden,
      'flutter upgrade': RiskLevel.forbidden,
      'flutter pub publish': RiskLevel.forbidden,
      'dart pub global activate x': RiskLevel.forbidden,
      'npm publish': RiskLevel.forbidden,
      'npm install -g vercel': RiskLevel.forbidden,
      'npm exec cowsay': RiskLevel.forbidden,
      'pnpm dlx create-app': RiskLevel.forbidden,
      'npm config set x y': RiskLevel.forbidden,
      'node script.js': RiskLevel.forbidden,
      'npx vercel --prod': RiskLevel.forbidden,
      'vercel deploy': RiskLevel.forbidden,
      'firebase deploy': RiskLevel.forbidden,
      'rm -rf build': RiskLevel.forbidden,
      'bash -c "flutter build"': RiskLevel.forbidden,
      'sh script.sh': RiskLevel.forbidden,
      'sudo flutter doctor': RiskLevel.forbidden,
      '/usr/bin/git status': RiskLevel.forbidden,
      'git frobnicate': RiskLevel.forbidden,
    };

    cases.forEach((line, risk) {
      test('$line → ${risk.name}', () {
        expect(evaluate(line).risk, risk);
      });
    });

    test('raisons explicites pour les refus importants', () {
      expect(evaluate('git push').issues, [PolicyIssue.gitPush]);
      expect(evaluate('bash -c x').issues, [PolicyIssue.shell]);
      expect(evaluate('sudo ls').issues, [PolicyIssue.privileged]);
      expect(evaluate('npm publish').issues, [PolicyIssue.publication]);
      expect(evaluate('npm i -g x').issues, [PolicyIssue.globalInstall]);
      expect(evaluate('curl x').issues, [PolicyIssue.notAllowlisted]);
      expect(evaluate('git tag v1').reinforced, isTrue);
      expect(evaluate('npm run build').issues, [PolicyIssue.runsProjectScript]);
    });

    test('aucun chemin hors du projet', () {
      expect(evaluate('git diff --output=/tmp/fuite.txt').issues, [
        PolicyIssue.outsideProject,
      ]);
      expect(evaluate('git log ../../autre').issues, [
        PolicyIssue.outsideProject,
      ]);
      expect(evaluate('git add ~/.bashrc').issues, [
        PolicyIssue.outsideProject,
      ]);
      expect(evaluate('git add lib/../pubspec.yaml').risk, RiskLevel.sensitive);
      expect(evaluate('git status', wd: '/home/testeur').issues, [
        PolicyIssue.workingDirectoryOutside,
      ]);
      expect(evaluate('flutter analyze', wd: '$root/../voisin').issues, [
        PolicyIssue.workingDirectoryOutside,
      ]);
    });
  });

  group('ProcessCommandRunner', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('lp_runner_'));
    tearDown(() => dir.deleteSync(recursive: true));

    CommandSpec spec(
      String exe,
      List<String> args, {
      Duration timeout = const Duration(seconds: 20),
    }) => CommandSpec(
      executable: exe,
      arguments: args,
      workingDirectory: dir.path,
      timeout: timeout,
    );

    test('exécute une commande en lecture seule, sortie capturée', () async {
      final runner = ProcessCommandRunner();
      final streamed = <OutputLine>[];
      final r = await runner.run(
        spec('git', ['--version']),
        projectRoot: dir.path,
        simulation: true,
        onLine: streamed.add,
      );
      expect(r.status, RunStatus.succeeded);
      expect(r.exitCode, 0);
      expect(r.text(OutputStream.stdout), startsWith('git version'));
      expect(streamed, hasLength(r.lines.length));
    });

    test('commande interdite : bloquée sans lancer de processus', () async {
      final r = await ProcessCommandRunner().run(
        spec('git', ['push']),
        projectRoot: dir.path,
        simulation: false,
      );
      expect(r.status, RunStatus.blocked);
      expect(r.exitCode, isNull);
    });

    test('commande sensible : confirmation obligatoire et unique', () async {
      final runner = ProcessCommandRunner();
      final s = spec('git', ['switch', '-c', 'launchpilot/test']);
      expect(
        (await runner.run(s, projectRoot: dir.path, simulation: true)).status,
        RunStatus.blocked,
      );
      final approval = runner.approve(s);
      expect(
        (await runner.run(
          s,
          projectRoot: dir.path,
          simulation: true,
          approval: approval,
        )).status,
        RunStatus.simulated,
      );
      // Déjà consommée.
      expect(
        (await runner.run(
          s,
          projectRoot: dir.path,
          simulation: true,
          approval: approval,
        )).status,
        RunStatus.blocked,
      );
      // Valable pour cette commande seulement.
      final other = runner.approve(spec('git', ['switch', '-c', 'autre']));
      expect(
        (await runner.run(
          s,
          projectRoot: dir.path,
          simulation: true,
          approval: other,
        )).status,
        RunStatus.blocked,
      );
    });

    test('stdout et stderr séparés, code de sortie conservé', () async {
      final runner = ProcessCommandRunner(policy: const PermissivePolicy());
      final r = await runner.run(
        spec('ls', ['.', 'introuvable-xyz']),
        projectRoot: dir.path,
        simulation: false,
      );
      expect(r.status, RunStatus.failed);
      expect(r.exitCode, isNot(0));
      expect(r.text(OutputStream.stderr), contains('introuvable-xyz'));
    });

    test('les secrets sont masqués dans la sortie', () async {
      final runner = ProcessCommandRunner(policy: const PermissivePolicy());
      final r = await runner.run(
        spec('printf', [
          r'token=abcdef1234567890\nsk-ant-api03-AAAAAAAAAAAAAAAA\n',
        ]),
        projectRoot: dir.path,
        simulation: false,
      );
      expect(r.text(), isNot(contains('abcdef1234567890')));
      expect(r.text(), isNot(contains('AAAAAAAAAAAAAAAA')));
      expect(r.text(), contains('[SECRET MASQUÉ]'));
    });

    test('délai dépassé : processus arrêté', () async {
      final runner = ProcessCommandRunner(policy: const PermissivePolicy());
      final r = await runner.run(
        spec('sleep', ['30'], timeout: const Duration(milliseconds: 300)),
        projectRoot: dir.path,
        simulation: false,
      );
      expect(r.status, RunStatus.timedOut);
      expect(r.duration, lessThan(const Duration(seconds: 10)));
    });

    test('annulation : processus arrêté', () async {
      final runner = ProcessCommandRunner(policy: const PermissivePolicy());
      final cancel = CancellationToken();
      final future = runner.run(
        spec('sleep', ['30']),
        projectRoot: dir.path,
        simulation: false,
        cancel: cancel,
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
      cancel.cancel();
      expect((await future).status, RunStatus.cancelled);
    });

    test('exécutable introuvable : échec de lancement explicite', () async {
      final runner = ProcessCommandRunner(policy: const PermissivePolicy());
      final r = await runner.run(
        spec('commande-inexistante-lp', const []),
        projectRoot: dir.path,
        simulation: false,
      );
      expect(r.status, RunStatus.startFailed);
    });

    test('un lien symbolique ne permet pas de sortir du projet', () async {
      final outside = Directory.systemTemp.createTempSync('lp_outside_');
      addTearDown(() => outside.deleteSync(recursive: true));
      final link = Link('${dir.path}/sortie')..createSync(outside.path);
      final r = await ProcessCommandRunner().run(
        CommandSpec(
          executable: 'git',
          arguments: const ['--version'],
          workingDirectory: link.path,
        ),
        projectRoot: dir.path,
        simulation: false,
      );
      expect(r.status, RunStatus.blocked);
    });
  });
}
