import 'package:path/path.dart' as p;

/// Fichiers sensibles qui méritent une entrée dans `.gitignore`. Les modèles
/// destinés à être partagés (`.env.example`…) sont exclus.
List<String> sensitiveFilesToIgnore(List<String> sensitiveFiles) => [
  for (final f in sensitiveFiles)
    if (!RegExp(
      r'(example|sample|template|dist)$',
      caseSensitive: false,
    ).hasMatch(p.posix.basename(f)))
      f,
];

const gitignoreHeader =
    '# Ajouté par LaunchPilot : fichiers sensibles à ne jamais versionner';

/// Nouveau contenu de `.gitignore` avec les entrées manquantes, ancrées à la
/// racine (`/chemin`) pour ne viser que ces fichiers précis. Les motifs
/// (`*.jks`) restent valables dans tout le projet.
String gitignoreWithEntries(String? current, List<String> paths) {
  final base = current ?? '';
  final lines = base.split('\n').map((l) => l.trim()).toSet();
  final missing = [
    for (final path in paths)
      if (!lines.contains('/$path') && !lines.contains(path))
        path.contains('*') ? path : '/$path',
  ];
  if (missing.isEmpty) return base;
  final buffer = StringBuffer(base);
  if (base.isNotEmpty && !base.endsWith('\n')) buffer.write('\n');
  if (base.trim().isNotEmpty) buffer.write('\n');
  buffer
    ..writeln(gitignoreHeader)
    ..writeAll(missing.map((m) => '$m\n'));
  return buffer.toString();
}
