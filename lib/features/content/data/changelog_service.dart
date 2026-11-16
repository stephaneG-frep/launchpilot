import '../../commands/data/process_command_runner.dart';
import '../../commands/domain/command_result.dart';
import '../../commands/domain/command_spec.dart';
import '../domain/changelog.dart';

/// Commits à résumer : depuis le dernier tag, sinon les plus récents.
class CommitRange {
  const CommitRange({
    required this.commits,
    this.sinceTag,
    this.limited = false,
  });

  final List<CommitEntry> commits;
  final String? sinceTag;

  /// Aucun tag trouvé : seuls les [ChangelogService.fallbackCount] derniers.
  final bool limited;
}

/// Lecture de l'historique Git via le runner (lecture seule uniquement).
class ChangelogService {
  ChangelogService(this._runner);

  final CommandRunner _runner;

  static const fallbackCount = 50;

  Future<CommandResult> _git(String root, List<String> args) => _runner.run(
    CommandSpec(
      executable: 'git',
      arguments: args,
      workingDirectory: root,
      timeout: const Duration(seconds: 20),
    ),
    projectRoot: root,
    simulation: true,
  );

  Future<String?> lastTag(String root) async {
    final r = await _git(root, const ['describe', '--tags', '--abbrev=0']);
    final tag = r.text(OutputStream.stdout).trim();
    return r.succeeded && tag.isNotEmpty ? tag : null;
  }

  Future<CommitRange> commits(String root) async {
    final tag = await lastTag(root);
    final r = await _git(root, [
      'log',
      if (tag != null) '$tag..HEAD' else '-n',
      if (tag == null) '$fallbackCount',
      '--no-merges',
      '--pretty=format:%h%x1f%s%x1f%an',
    ]);
    return CommitRange(
      commits: r.succeeded
          ? parseGitLog(r.text(OutputStream.stdout))
          : const [],
      sinceTag: tag,
      limited: tag == null,
    );
  }
}
