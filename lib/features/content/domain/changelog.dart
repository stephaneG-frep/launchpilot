import 'package:flutter/foundation.dart';

/// Séparateur de champs choisi pour `git log --pretty=format:…`.
const logFieldSeparator = '\u001f';

@immutable
class CommitEntry {
  const CommitEntry({
    required this.hash,
    required this.subject,
    required this.author,
    this.type,
    this.scope,
    this.breaking = false,
  });

  final String hash;
  final String subject;
  final String author;

  /// Type « Conventional Commits » (feat, fix…) s'il est présent.
  final String? type;
  final String? scope;
  final bool breaking;

  /// Message sans le préfixe de type.
  String get description {
    final m = _conventional.firstMatch(subject);
    return m == null ? subject : m[4]!.trim();
  }

  static final _conventional = RegExp(
    r'^([a-zA-Z]+)(?:\(([^)]*)\))?(!)?:\s*(.+)$',
  );

  static CommitEntry fromSubject(String hash, String subject, String author) {
    final m = _conventional.firstMatch(subject);
    return CommitEntry(
      hash: hash,
      subject: subject,
      author: author,
      type: m?[1]?.toLowerCase(),
      scope: m?[2],
      breaking: m?[3] != null || subject.contains('BREAKING CHANGE'),
    );
  }
}

/// Analyse la sortie de
/// `git log --no-merges --pretty=format:%h<US>%s<US>%an`.
List<CommitEntry> parseGitLog(String output) => [
  for (final line in output.split('\n'))
    if (line.split(logFieldSeparator) case [
      final hash,
      final subject,
      final author,
      ...,
    ])
      if (subject.trim().isNotEmpty)
        CommitEntry.fromSubject(hash.trim(), subject.trim(), author.trim()),
];

enum ChangeGroup { breaking, features, fixes, performance, docs, other }

ChangeGroup groupOf(CommitEntry c) {
  if (c.breaking) return ChangeGroup.breaking;
  return switch (c.type) {
    'feat' || 'feature' => ChangeGroup.features,
    'fix' || 'bugfix' || 'hotfix' => ChangeGroup.fixes,
    'perf' => ChangeGroup.performance,
    'docs' => ChangeGroup.docs,
    _ => ChangeGroup.other,
  };
}

/// Titres de section, dans la langue du changelog.
typedef GroupTitles = String Function(ChangeGroup group);

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Changelog technique : toutes les entrées, groupées, avec leur hash.
String technicalChangelog(
  List<CommitEntry> commits,
  GroupTitles title, {
  required String heading,
}) {
  final buffer = StringBuffer('## $heading\n');
  for (final group in ChangeGroup.values) {
    final items = commits.where((c) => groupOf(c) == group).toList();
    if (items.isEmpty) continue;
    buffer.writeln('\n### ${title(group)}\n');
    for (final c in items) {
      final scope = c.scope == null ? '' : '**${c.scope}** : ';
      buffer.writeln('- $scope${_capitalize(c.description)} (${c.hash})');
    }
  }
  return buffer.toString();
}

/// Changelog grand public : nouveautés et corrections seulement, sans
/// jargon technique ni identifiants de commit.
String publicChangelog(
  List<CommitEntry> commits,
  GroupTitles title, {
  required String heading,
  required String fallback,
}) {
  final buffer = StringBuffer('## $heading\n');
  var any = false;
  for (final group in const [
    ChangeGroup.breaking,
    ChangeGroup.features,
    ChangeGroup.fixes,
    ChangeGroup.performance,
  ]) {
    final items = commits.where((c) => groupOf(c) == group).toList();
    if (items.isEmpty) continue;
    any = true;
    buffer.writeln('\n### ${title(group)}\n');
    for (final c in items) {
      buffer.writeln('- ${_capitalize(c.description)}');
    }
  }
  if (!any) buffer.writeln('\n$fallback');
  return buffer.toString();
}

/// Ajoute [section] en tête de CHANGELOG.md, sous le titre principal s'il
/// existe. Une section déjà présente pour la même version n'est pas
/// dupliquée : elle est remplacée.
String prependChangelog(
  String? current,
  String section, {
  required String title,
}) {
  final body = section.trimRight();
  if (current == null || current.trim().isEmpty) return '# $title\n\n$body\n';
  final lines = current.split('\n');
  final heading = body.split('\n').first;
  final existing = lines.indexOf(heading);
  if (existing >= 0) {
    var end = lines.length;
    for (var i = existing + 1; i < lines.length; i++) {
      if (lines[i].startsWith('## ')) {
        end = i;
        break;
      }
    }
    final rest = lines.sublist(end).join('\n');
    return [
      ...lines.sublist(0, existing),
      body,
      if (rest.isNotEmpty) '\n$rest' else '',
    ].join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }
  final insertAt = lines.isNotEmpty && lines.first.startsWith('# ') ? 1 : 0;
  final before = lines.sublist(0, insertAt).join('\n');
  final after = lines.sublist(insertAt).join('\n').trimLeft();
  return [if (before.isNotEmpty) '$before\n', body, '', after].join('\n');
}
