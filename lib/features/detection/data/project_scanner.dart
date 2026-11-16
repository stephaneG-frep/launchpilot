import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../core/security/secret_redactor.dart';
import '../domain/scan_snapshot.dart';

export '../domain/scan_snapshot.dart';

@immutable
class ScanLimits {
  const ScanLimits({
    this.maxFiles = 20000,
    this.maxDepth = 12,
    this.maxFileBytes = 512 * 1024,
    this.maxTotalBytes = 8 * 1024 * 1024,
    this.maxDuration = const Duration(seconds: 20),
    this.maxHtmlFiles = 20,
  });

  final int maxFiles;
  final int maxDepth;
  final int maxFileBytes;
  final int maxTotalBytes;
  final Duration maxDuration;
  final int maxHtmlFiles;
}

/// Parcours en lecture seule, borné et sans suivre les liens symboliques
/// (impossible de sortir du dossier du projet). Synchrone : à exécuter dans
/// un isolat.
abstract final class ProjectScanner {
  static const ignoredDirectories = {
    '.git',
    'node_modules',
    'build',
    '.dart_tool',
    '.next',
    '.nuxt',
    '.output',
    '.svelte-kit',
    '.astro',
    '.angular',
    'dist',
    'out',
    'coverage',
    '.cache',
    '.parcel-cache',
    '.turbo',
    '.gradle',
    '.idea',
    '.vscode',
    'Pods',
    'DerivedData',
    'ephemeral',
    '.symlinks',
    '.fvm',
    '.pub-cache',
    '__pycache__',
    '.venv',
    'venv',
    '.pytest_cache',
    '.mypy_cache',
    'target',
    // Données de test : d'autres « projets » y sont souvent rangés.
    'fixtures',
    '__fixtures__',
    '__mocks__',
    'testdata',
  };

  static const _binaryExtensions = {
    '.png',
    '.jpg',
    '.jpeg',
    '.gif',
    '.webp',
    '.ico',
    '.icns',
    '.bmp',
    '.svg',
    '.pdf',
    '.zip',
    '.gz',
    '.tgz',
    '.xz',
    '.7z',
    '.rar',
    '.jar',
    '.aar',
    '.apk',
    '.aab',
    '.ipa',
    '.so',
    '.dylib',
    '.dll',
    '.exe',
    '.class',
    '.o',
    '.a',
    '.woff',
    '.woff2',
    '.ttf',
    '.otf',
    '.mp3',
    '.mp4',
    '.mov',
    '.wav',
    '.db',
    '.sqlite',
    '.bin',
    '.lockb',
  };

  static const _namedFiles = {
    'pubspec.yaml',
    'package.json',
    'angular.json',
    'AndroidManifest.xml',
    'Info.plist',
    'build.gradle',
    'build.gradle.kts',
    'requirements.txt',
    'pyproject.toml',
    'Pipfile',
    'manifest.json',
    'manifest.webmanifest',
    'site.webmanifest',
    'robots.txt',
    'firebase.json',
    'vercel.json',
    'netlify.toml',
    'Fastfile',
    'Appfile',
    'main.py',
    'app.py',
    'asgi.py',
    'wsgi.py',
  };

  static const _configPrefixes = [
    'next.config.',
    'nuxt.config.',
    'astro.config.',
    'svelte.config.',
    'vite.config.',
  ];

  /// Fichiers dont le contenu sert aux détecteurs (les autres ne sont que
  /// listés).
  static bool shouldRead(String relative) {
    final name = p.posix.basename(relative);
    if (_namedFiles.contains(name)) return true;
    if (_configPrefixes.any(name.startsWith)) return true;
    return false;
  }

  static ScanSnapshot scan(
    String root, {
    ScanLimits limits = const ScanLimits(),
  }) {
    final watch = Stopwatch()..start();
    final files = <String>[];
    final contents = <String, String>{};
    final sensitive = <String>[];
    final reasons = <String>{};
    var readBytes = 0;
    var htmlRead = 0;
    GitRaw git = const GitRaw();

    // Parcours en largeur : les fichiers proches de la racine d'abord.
    final queue = <(Directory, int)>[(Directory(root), 0)];
    var index = 0;
    outer:
    while (index < queue.length) {
      final (dir, depth) = queue[index++];
      List<FileSystemEntity> entries;
      try {
        entries = dir.listSync(followLinks: false)
          ..sort((a, b) => a.path.compareTo(b.path));
      } on FileSystemException {
        reasons.add(PartialReason.unreadable);
        continue;
      }
      for (final entity in entries) {
        if (watch.elapsed > limits.maxDuration) {
          reasons.add(PartialReason.timeout);
          break outer;
        }
        final name = p.basename(entity.path);
        final relative = p
            .relative(entity.path, from: root)
            .replaceAll(r'\', '/');

        if (entity is Link) continue;
        if (entity is Directory) {
          if (depth == 0 && name == '.git') {
            git = _readGit(entity, limits);
            continue;
          }
          if (ignoredDirectories.contains(name)) continue;
          if (depth + 1 > limits.maxDepth) {
            reasons.add(PartialReason.maxDepth);
            continue;
          }
          queue.add((entity, depth + 1));
          continue;
        }
        if (entity is! File) continue;

        if (depth == 0 && name == '.git') {
          git = const GitRaw(present: true, isFile: true);
          continue;
        }
        if (files.length >= limits.maxFiles) {
          reasons.add(PartialReason.maxFiles);
          break outer;
        }
        files.add(relative);

        if (SecretRedactor.isSensitiveFile(relative)) {
          sensitive.add(relative);
          continue;
        }
        final ext = p.extension(name).toLowerCase();
        if (_binaryExtensions.contains(ext)) continue;
        final isHtml = (ext == '.html' || ext == '.htm') && depth <= 2;
        if (!shouldRead(relative) && !isHtml) continue;
        if (isHtml && htmlRead >= limits.maxHtmlFiles) continue;

        final text = _readSmall(entity, limits.maxFileBytes);
        if (text == null) continue;
        if (readBytes + text.length > limits.maxTotalBytes) {
          reasons.add(PartialReason.readBudget);
          continue;
        }
        readBytes += text.length;
        if (isHtml) htmlRead++;
        contents[relative] = text;
      }
    }

    return ScanSnapshot(
      files: files,
      contents: contents,
      sensitiveFiles: sensitive,
      partialReasons: reasons.toList()..sort(),
      git: git,
    );
  }

  static String? _readSmall(File file, int maxBytes) {
    try {
      if (file.lengthSync() > maxBytes) return null;
      return utf8.decode(file.readAsBytesSync(), allowMalformed: true);
    } on FileSystemException {
      return null;
    }
  }

  static GitRaw _readGit(Directory gitDir, ScanLimits limits) {
    String? read(String name) =>
        _readSmall(File(p.join(gitDir.path, name)), limits.maxFileBytes);

    final tags = <String>[];
    final tagsDir = Directory(p.join(gitDir.path, 'refs', 'tags'));
    try {
      if (tagsDir.existsSync()) {
        for (final e in tagsDir.listSync(recursive: true, followLinks: false)) {
          if (e is File) {
            tags.add(
              p.relative(e.path, from: tagsDir.path).replaceAll(r'\', '/'),
            );
          }
        }
      }
    } on FileSystemException {
      // Tags non listables : on garde ceux de packed-refs.
    }
    return GitRaw(
      present: true,
      head: read('HEAD'),
      packedRefs: read('packed-refs'),
      looseTags: tags..sort(),
    );
  }
}
