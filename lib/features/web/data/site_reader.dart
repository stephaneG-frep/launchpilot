import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/security/secret_redactor.dart';
import '../domain/web_audit.dart';

/// Lecture bornée d'un site sur le disque (sortie de build ou sources),
/// synchrone pour rester compatible avec le temps simulé des tests.
/// Ne suit pas les liens symboliques et ne lit jamais un fichier sensible.
class SiteReader {
  const SiteReader({this.maxFiles = 4000, this.maxTextBytes = 1 << 20});

  final int maxFiles;
  final int maxTextBytes;

  static const _skipDirs = {'node_modules', '.git', '.dart_tool', '.idea'};
  static const _textExt = {
    '.html',
    '.htm',
    '.json',
    '.webmanifest',
    '.txt',
    '.xml',
  };

  /// Null si [dir] n'existe pas.
  SiteSnapshot? read(String root, String dir) {
    final base = Directory(dir.isEmpty ? root : p.join(root, dir));
    if (!base.existsSync()) return null;
    final files = <String>{};
    final texts = <String, String>{};
    var truncated = false;
    var scripts = 0;

    void walk(Directory d, int depth) {
      if (depth > 12) {
        truncated = true;
        return;
      }
      final List<FileSystemEntity> entries;
      try {
        entries = d.listSync(followLinks: false)
          ..sort((a, b) => a.path.compareTo(b.path));
      } on FileSystemException {
        return;
      }
      for (final e in entries) {
        if (files.length >= maxFiles) {
          truncated = true;
          return;
        }
        final rel = p
            .relative(e.path, from: base.path)
            .replaceAll(p.separator, '/');
        if (e is Directory) {
          if (!_skipDirs.contains(p.basename(e.path))) walk(e, depth + 1);
          continue;
        }
        if (e is! File) continue;
        files.add(rel);
        if (SecretRedactor.isSensitiveFile(rel)) continue;
        final ext = p.extension(rel).toLowerCase();
        final isText = _textExt.contains(ext);
        // Scripts : seulement pour repérer un service worker.
        final isScript = ext == '.js' && scripts < 200;
        if (!isText && !isScript) continue;
        try {
          if (e.lengthSync() > (isScript ? 300 * 1024 : maxTextBytes)) continue;
          texts[rel] = e.readAsStringSync();
          if (isScript) scripts++;
        } on FileSystemException {
          // Fichier illisible ou non UTF-8 : ignoré.
        }
      }
    }

    walk(base, 0);
    return SiteSnapshot(files: files, texts: texts, truncated: truncated);
  }
}
