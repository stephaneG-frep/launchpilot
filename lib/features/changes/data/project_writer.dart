import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../core/database/watch_tables.dart';
import '../../../core/security/secret_redactor.dart';
import '../domain/change_set.dart';

enum WriteIssue {
  /// Chemin absolu, avec `..`, ou hors du projet (y compris via un lien).
  outsideProject,

  /// Fichier sensible : LaunchPilot ne l'écrit jamais.
  sensitiveFile,

  /// Le fichier a changé depuis l'aperçu : rien n'a été écrit.
  changedSincePreview,

  /// Confirmation absente, déjà utilisée ou pour un autre contenu.
  notApproved,
}

class WriteException implements Exception {
  const WriteException(this.issue, [this.path]);
  final WriteIssue issue;
  final String? path;

  @override
  String toString() => 'WriteException(${issue.name}, $path)';
}

enum RestoreOutcome {
  restored,

  /// Modifié depuis par l'utilisateur : rien n'est écrasé.
  conflict,

  /// Déjà restauré auparavant.
  alreadyRestored,

  /// Copie de sauvegarde introuvable.
  backupMissing,
}

@immutable
class WriteApproval {
  const WriteApproval._(this.id, this.digest);
  final String id;
  final String digest;
}

/// Écritures dans un projet, toujours précédées d'un aperçu confirmé. Chaque
/// fichier est sauvegardé avant d'être modifié et peut être restauré
/// individuellement, sans jamais écraser un changement ultérieur.
class ProjectWriter {
  ProjectWriter(
    this._db, {
    required this.backupRoot,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final AppDatabase _db;

  /// Dossier des copies de sauvegarde (hors du projet).
  final String backupRoot;
  final DateTime Function() _now;
  final _approvals = <String, String>{};
  final _random = Random.secure();

  /// Contenu actuel d'un fichier du projet (nul s'il n'existe pas), avec les
  /// mêmes vérifications de chemin qu'une écriture.
  String? readCurrent(String root, String relative) {
    final file = File(p.join(root, _checkPath(root, relative)));
    return file.existsSync() ? file.readAsStringSync() : null;
  }

  /// Le fichier existe-t-il (chemin vérifié comme pour une écriture) ?
  bool exists(String root, String relative) {
    try {
      return File(p.join(root, _checkPath(root, relative))).existsSync();
    } on WriteException {
      return false;
    }
  }

  /// Calcule les modifications à partir du contenu actuel des fichiers.
  Future<ChangeSet> plan(
    String root,
    String label,
    Map<String, String> newContents,
  ) async {
    final files = <PlannedFileChange>[];
    for (final e in newContents.entries) {
      final path = _checkPath(root, e.key);
      final file = File(p.join(root, path));
      files.add(
        PlannedFileChange(
          path: path,
          before: file.existsSync() ? file.readAsStringSync() : null,
          after: e.value,
        ),
      );
    }
    return ChangeSet(label: label, files: files);
  }

  /// Même chose pour des fichiers binaires (images générées…).
  Future<ChangeSet> planBinary(
    String root,
    String label,
    Map<String, Uint8List> newContents,
  ) async {
    final files = <PlannedFileChange>[];
    for (final e in newContents.entries) {
      final path = _checkPath(root, e.key);
      final file = File(p.join(root, path));
      files.add(
        PlannedFileChange.binary(
          path: path,
          beforeBytes: file.existsSync() ? file.readAsBytesSync() : null,
          afterBytes: e.value,
        ),
      );
    }
    return ChangeSet(label: label, files: files);
  }

  /// À appeler uniquement quand l'utilisateur a confirmé l'aperçu.
  WriteApproval approve(ChangeSet set) {
    final id = List.generate(
      16,
      (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    _approvals[id] = set.digest;
    return WriteApproval._(id, set.digest);
  }

  /// Écrit l'ensemble. Tout est vérifié avant la première écriture : si un
  /// fichier a changé depuis l'aperçu, rien n'est écrit.
  Future<String> apply(
    int projectId,
    String root,
    ChangeSet set,
    WriteApproval approval,
  ) async {
    final expected = _approvals.remove(approval.id);
    if (expected == null ||
        expected != set.digest ||
        approval.digest != set.digest) {
      throw const WriteException(WriteIssue.notApproved);
    }
    for (final f in set.files) {
      _checkPath(root, f.path);
      final file = File(p.join(root, f.path));
      final current = file.existsSync()
          ? bytesHash(file.readAsBytesSync())
          : null;
      final expected = f.beforeBytes == null ? null : bytesHash(f.beforeBytes!);
      if (current != expected) {
        throw WriteException(WriteIssue.changedSincePreview, f.path);
      }
    }

    final batchId = _id();
    final batchDir = Directory(p.join(backupRoot, '$projectId', batchId));
    final now = _now();
    for (final (index, f) in set.files.indexed) {
      if (!f.changes) continue;
      String? backup;
      if (f.beforeBytes != null) {
        batchDir.createSync(recursive: true);
        backup = p.join(batchDir.path, '$index.bak');
        File(backup).writeAsBytesSync(f.beforeBytes!, flush: true);
      }
      _atomicWrite(File(p.join(root, f.path)), f.afterBytes);
      await _db
          .into(_db.fileChanges)
          .insert(
            FileChangesCompanion.insert(
              projectId: projectId,
              batchId: batchId,
              label: set.label,
              path: f.path,
              existedBefore: f.beforeBytes != null,
              backupPath: Value(backup),
              beforeHash: Value(
                f.beforeBytes == null ? null : bytesHash(f.beforeBytes!),
              ),
              afterHash: bytesHash(f.afterBytes),
              appliedAt: now,
            ),
          );
    }
    return batchId;
  }

  /// Restaure un fichier tel qu'avant LaunchPilot, seulement s'il n'a pas
  /// été modifié depuis.
  Future<RestoreOutcome> restore(String root, int changeId) async {
    final change = await (_db.select(
      _db.fileChanges,
    )..where((t) => t.id.equals(changeId))).getSingle();
    if (change.restoredAt != null) return RestoreOutcome.alreadyRestored;

    _checkPath(root, change.path);
    final file = File(p.join(root, change.path));
    final current = file.existsSync() ? file.readAsBytesSync() : null;
    if (current == null || bytesHash(current) != change.afterHash) {
      return RestoreOutcome.conflict;
    }
    if (change.existedBefore) {
      final backup = File(change.backupPath!);
      if (!backup.existsSync()) return RestoreOutcome.backupMissing;
      final before = backup.readAsBytesSync();
      if (bytesHash(before) != change.beforeHash) {
        return RestoreOutcome.backupMissing;
      }
      _atomicWrite(file, before);
    } else {
      file.deleteSync();
    }
    await (_db.update(_db.fileChanges)..where((t) => t.id.equals(changeId)))
        .write(FileChangesCompanion(restoredAt: Value(_now())));
    return RestoreOutcome.restored;
  }

  Stream<List<FileChangeRecord>> watchChanges(int projectId) => watchTables(
    _db,
    [_db.fileChanges],
    () =>
        (_db.select(_db.fileChanges)
              ..where((t) => t.projectId.equals(projectId))
              ..orderBy([
                (t) => OrderingTerm.desc(t.appliedAt),
                (t) => OrderingTerm.asc(t.path),
              ]))
            .get(),
  );

  /// Supprime les sauvegardes d'un projet (ou de tous).
  Future<void> deleteBackups([int? projectId]) async {
    final dir = Directory(
      projectId == null ? backupRoot : p.join(backupRoot, '$projectId'),
    );
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }

  /// Chemin relatif normalisé, dans le projet, hors fichiers sensibles.
  static String _checkPath(String root, String relative) {
    final normalized = p.posix.normalize(relative.replaceAll(r'\', '/'));
    if (p.posix.isAbsolute(normalized) ||
        normalized == '..' ||
        normalized.startsWith('../') ||
        normalized == '.') {
      throw WriteException(WriteIssue.outsideProject, relative);
    }
    if (SecretRedactor.isSensitiveFile(normalized)) {
      throw WriteException(WriteIssue.sensitiveFile, normalized);
    }
    // Les liens symboliques ne doivent pas mener hors du projet.
    final realRoot = Directory(root).resolveSymbolicLinksSync();
    var parent = Directory(p.dirname(p.join(root, normalized)));
    while (!parent.existsSync()) {
      parent = parent.parent;
    }
    final realParent = parent.resolveSymbolicLinksSync();
    if (realParent != realRoot && !p.isWithin(realRoot, realParent)) {
      throw WriteException(WriteIssue.outsideProject, relative);
    }
    final target = p.join(root, normalized);
    if (FileSystemEntity.isLinkSync(target)) {
      throw WriteException(WriteIssue.outsideProject, relative);
    }
    return normalized;
  }

  /// Entrées/sorties synchrones : fichiers de configuration de petite taille.
  static void _atomicWrite(File file, List<int> content) {
    file.parent.createSync(recursive: true);
    final tmp = File('${file.path}.launchpilot-tmp');
    tmp.writeAsBytesSync(content, flush: true);
    tmp.renameSync(file.path);
  }

  String _id() => List.generate(
    8,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
