import 'package:flutter/foundation.dart';

@immutable
class GitChange {
  const GitChange(this.path, this.index, this.worktree, {this.originalPath});

  final String path;

  /// Codes `git status --porcelain` : index (indexé) et copie de travail.
  final String index;
  final String worktree;
  final String? originalPath;

  bool get untracked => index == '?';
  bool get staged => index != ' ' && index != '?';
}

@immutable
class GitStatus {
  const GitStatus({
    required this.isRepo,
    this.branch,
    this.upstream,
    this.ahead = 0,
    this.behind = 0,
    this.changes = const [],
  });

  static const notRepo = GitStatus(isRepo: false);

  final bool isRepo;

  /// Nul si HEAD est détachée.
  final String? branch;
  final String? upstream;
  final int ahead;
  final int behind;
  final List<GitChange> changes;

  bool get clean => changes.isEmpty;
}

/// Analyse `git status --porcelain=v1 -z --branch --untracked-files=all`.
GitStatus parsePorcelainZ(String output) {
  final parts = output.split('\u0000');
  String? branch;
  String? upstream;
  var ahead = 0;
  var behind = 0;
  final changes = <GitChange>[];

  for (var i = 0; i < parts.length; i++) {
    final entry = parts[i];
    if (entry.isEmpty) continue;
    if (entry.startsWith('## ')) {
      final header = entry.substring(3);
      final m = RegExp(
        r'^(?:No commits yet on |Initial commit on )?(.+?)(?:\.\.\.(\S+))?(?: \[(.+)\])?$',
      ).firstMatch(header);
      if (m != null) {
        final name = m[1]!;
        branch = name.startsWith('HEAD (no branch)') ? null : name;
        upstream = m[2];
        final tracking = m[3] ?? '';
        ahead =
            int.tryParse(
              RegExp(r'ahead (\d+)').firstMatch(tracking)?[1] ?? '',
            ) ??
            0;
        behind =
            int.tryParse(
              RegExp(r'behind (\d+)').firstMatch(tracking)?[1] ?? '',
            ) ??
            0;
      }
      continue;
    }
    if (entry.length < 4) continue;
    final x = entry[0];
    final y = entry[1];
    final path = entry.substring(3);
    String? original;
    // Renommage ou copie : le chemin d'origine suit dans l'entrée suivante.
    if ((x == 'R' || x == 'C') && i + 1 < parts.length) {
      original = parts[++i];
    }
    changes.add(GitChange(path, x, y, originalPath: original));
  }
  return GitStatus(
    isRepo: true,
    branch: branch,
    upstream: upstream,
    ahead: ahead,
    behind: behind,
    changes: changes,
  );
}

/// Nom de branche proposé pour préparer une version.
String releaseBranchName(String version) =>
    'launchpilot/release-${version.replaceAll(RegExp(r'[^A-Za-z0-9._\-]'), '-')}';
