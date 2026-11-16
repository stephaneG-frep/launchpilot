import '../../commands/data/process_command_runner.dart';
import '../../commands/domain/command_result.dart';
import '../../commands/domain/command_spec.dart';
import '../domain/git_status.dart';

/// Lecture de l'état Git via le [CommandRunner] : uniquement des commandes
/// en lecture seule, autorisées même en mode simulation.
class GitService {
  GitService(this._runner);

  final CommandRunner _runner;

  static List<String> statusArguments = const [
    'status',
    '--porcelain=v1',
    '-z',
    '--branch',
    '--untracked-files=all',
  ];

  Future<CommandResult> _read(String root, List<String> args) => _runner.run(
    CommandSpec(
      executable: 'git',
      arguments: args,
      workingDirectory: root,
      timeout: const Duration(seconds: 20),
    ),
    projectRoot: root,
    simulation: true,
  );

  Future<GitStatus> status(String root) async {
    final inside = await _read(root, const [
      'rev-parse',
      '--is-inside-work-tree',
    ]);
    if (!inside.succeeded || inside.text().trim() != 'true') {
      return GitStatus.notRepo;
    }
    final r = await _read(root, statusArguments);
    if (!r.succeeded) return GitStatus.notRepo;
    return parsePorcelainZ(r.text(OutputStream.stdout));
  }

  /// Parmi [paths], ceux que Git ignore déjà.
  Future<Set<String>> ignored(String root, List<String> paths) async {
    if (paths.isEmpty) return {};
    final r = await _read(root, ['check-ignore', ...paths]);
    // Code 1 : aucun chemin ignoré ; autre code : erreur.
    if (r.exitCode != 0) return {};
    return r
        .text(OutputStream.stdout)
        .split('\n')
        .where((l) => l.isNotEmpty)
        .toSet();
  }
}
