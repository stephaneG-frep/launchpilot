import 'package:flutter/foundation.dart';

/// Cibles de publication reconnues. Les identifiants sont stockés en base
/// (`project_targets.target_id`) : ne pas les renommer.
enum PlatformTarget { android, ios, web, linux, windows, macos }

enum TechKind { framework, language, runtime, backend }

enum FindingCategory {
  icon,
  screenshot,
  fastlane,
  ci,
  hosting,
  pwa,
  seo,
  legal,
  signing,
}

enum ServiceKind {
  analytics,
  ads,
  crashReporting,
  messaging,
  backend,
  payments,
}

/// Preuve d'une détection : un fichier (chemin relatif) et ce qu'il montre.
@immutable
class Evidence {
  const Evidence(this.path, [this.detail]);

  final String path;
  final String? detail;

  Map<String, Object?> toJson() => {'path': path, 'detail': detail};

  factory Evidence.fromJson(Map<String, Object?> j) =>
      Evidence(j['path'] as String, j['detail'] as String?);

  @override
  String toString() => detail == null ? path : '$path → $detail';
}

@immutable
class TechDetection {
  const TechDetection({
    required this.id,
    required this.label,
    required this.kind,
    required this.confidence,
    required this.evidence,
    this.informative = false,
  });

  final String id;
  final String label;
  final TechKind kind;

  /// Entre 0 et 1.
  final double confidence;
  final List<Evidence> evidence;

  /// Détection signalée pour information (ex. back-end Python), sans
  /// parcours de publication associé.
  final bool informative;

  Map<String, Object?> toJson() => {
    'id': id,
    'label': label,
    'kind': kind.name,
    'confidence': confidence,
    'evidence': [for (final e in evidence) e.toJson()],
    'informative': informative,
  };

  factory TechDetection.fromJson(Map<String, Object?> j) => TechDetection(
    id: j['id'] as String,
    label: j['label'] as String,
    kind: TechKind.values.byName(j['kind'] as String),
    confidence: (j['confidence'] as num).toDouble(),
    evidence: _evidenceList(j['evidence']),
    informative: j['informative'] as bool? ?? false,
  );
}

@immutable
class TargetDetection {
  const TargetDetection({
    required this.target,
    required this.confidence,
    required this.evidence,
  });

  final PlatformTarget target;
  final double confidence;
  final List<Evidence> evidence;

  /// Seuil au-delà duquel la cible est proposée par défaut.
  bool get detected => confidence >= 0.5;

  Map<String, Object?> toJson() => {
    'target': target.name,
    'confidence': confidence,
    'evidence': [for (final e in evidence) e.toJson()],
  };

  factory TargetDetection.fromJson(Map<String, Object?> j) => TargetDetection(
    target: PlatformTarget.values.byName(j['target'] as String),
    confidence: (j['confidence'] as num).toDouble(),
    evidence: _evidenceList(j['evidence']),
  );
}

@immutable
class PackageManagerInfo {
  const PackageManagerInfo({
    required this.manager,
    required this.manifest,
    this.lockFile,
    this.scripts = const {},
  });

  /// pub, npm, yarn, pnpm, bun, pip, poetry, pipenv.
  final String manager;
  final String manifest;
  final String? lockFile;
  final Map<String, String> scripts;

  Map<String, Object?> toJson() => {
    'manager': manager,
    'manifest': manifest,
    'lockFile': lockFile,
    'scripts': scripts,
  };

  factory PackageManagerInfo.fromJson(Map<String, Object?> j) =>
      PackageManagerInfo(
        manager: j['manager'] as String,
        manifest: j['manifest'] as String,
        lockFile: j['lockFile'] as String?,
        scripts: (j['scripts'] as Map? ?? const {}).map(
          (k, v) => MapEntry('$k', '$v'),
        ),
      );
}

/// Ce qui peut être lu dans `.git` sans exécuter git. Les modifications non
/// validées demandent `git status` (moteur de commandes, phase 5).
@immutable
class GitSnapshot {
  const GitSnapshot({
    required this.present,
    this.branch,
    this.detachedCommit,
    this.tags = const [],
    this.linkedWorktree = false,
  });

  static const absent = GitSnapshot(present: false);

  final bool present;
  final String? branch;
  final String? detachedCommit;
  final List<String> tags;

  /// `.git` est un fichier (worktree ou sous-module) : détails non lus.
  final bool linkedWorktree;

  Map<String, Object?> toJson() => {
    'present': present,
    'branch': branch,
    'detachedCommit': detachedCommit,
    'tags': tags,
    'linkedWorktree': linkedWorktree,
  };

  factory GitSnapshot.fromJson(Map<String, Object?> j) => GitSnapshot(
    present: j['present'] as bool,
    branch: j['branch'] as String?,
    detachedCommit: j['detachedCommit'] as String?,
    tags: (j['tags'] as List? ?? const []).cast<String>(),
    linkedWorktree: j['linkedWorktree'] as bool? ?? false,
  );
}

@immutable
class FileFinding {
  const FileFinding(this.category, this.path, [this.detail]);

  final FindingCategory category;
  final String path;
  final String? detail;

  Map<String, Object?> toJson() => {
    'category': category.name,
    'path': path,
    'detail': detail,
  };

  factory FileFinding.fromJson(Map<String, Object?> j) => FileFinding(
    FindingCategory.values.byName(j['category'] as String),
    j['path'] as String,
    j['detail'] as String?,
  );
}

@immutable
class PermissionFinding {
  const PermissionFinding(this.target, this.name, this.path);

  final PlatformTarget target;
  final String name;
  final String path;

  Map<String, Object?> toJson() => {
    'target': target.name,
    'name': name,
    'path': path,
  };

  factory PermissionFinding.fromJson(Map<String, Object?> j) =>
      PermissionFinding(
        PlatformTarget.values.byName(j['target'] as String),
        j['name'] as String,
        j['path'] as String,
      );
}

@immutable
class ServiceFinding {
  const ServiceFinding({
    required this.id,
    required this.label,
    required this.kind,
    required this.evidence,
  });

  final String id;
  final String label;
  final ServiceKind kind;
  final Evidence evidence;

  Map<String, Object?> toJson() => {
    'id': id,
    'label': label,
    'kind': kind.name,
    'evidence': evidence.toJson(),
  };

  factory ServiceFinding.fromJson(Map<String, Object?> j) => ServiceFinding(
    id: j['id'] as String,
    label: j['label'] as String,
    kind: ServiceKind.values.byName(j['kind'] as String),
    evidence: Evidence.fromJson((j['evidence'] as Map).cast()),
  );
}

/// Résultat complet d'une analyse en lecture seule.
@immutable
class DetectionReport {
  const DetectionReport({
    required this.scannedAt,
    required this.filesScanned,
    required this.technologies,
    required this.targets,
    this.packages = const [],
    this.git = GitSnapshot.absent,
    this.findings = const [],
    this.permissions = const [],
    this.services = const [],
    this.sensitiveFiles = const [],
    this.partialReasons = const [],
  });

  static const formatVersion = 1;

  final DateTime scannedAt;
  final int filesScanned;
  final List<TechDetection> technologies;
  final List<TargetDetection> targets;
  final List<PackageManagerInfo> packages;
  final GitSnapshot git;
  final List<FileFinding> findings;
  final List<PermissionFinding> permissions;
  final List<ServiceFinding> services;

  /// Fichiers sensibles repérés et volontairement non lus.
  final List<String> sensitiveFiles;

  /// Limites atteintes : l'analyse est alors partielle.
  final List<String> partialReasons;

  bool get partial => partialReasons.isNotEmpty;

  TargetDetection targetFor(PlatformTarget t) => targets.firstWhere(
    (d) => d.target == t,
    orElse: () => TargetDetection(target: t, confidence: 0, evidence: const []),
  );

  List<FileFinding> findingsOf(FindingCategory c) =>
      findings.where((f) => f.category == c).toList();

  Map<String, Object?> toJson() => {
    'formatVersion': formatVersion,
    'scannedAt': scannedAt.toIso8601String(),
    'filesScanned': filesScanned,
    'technologies': [for (final t in technologies) t.toJson()],
    'targets': [for (final t in targets) t.toJson()],
    'packages': [for (final p in packages) p.toJson()],
    'git': git.toJson(),
    'findings': [for (final f in findings) f.toJson()],
    'permissions': [for (final p in permissions) p.toJson()],
    'services': [for (final s in services) s.toJson()],
    'sensitiveFiles': sensitiveFiles,
    'partialReasons': partialReasons,
  };

  factory DetectionReport.fromJson(Map<String, Object?> j) {
    List<T> list<T>(String key, T Function(Map<String, Object?>) f) => [
      for (final e in (j[key] as List? ?? const []))
        f((e as Map).cast<String, Object?>()),
    ];
    return DetectionReport(
      scannedAt: DateTime.parse(j['scannedAt'] as String),
      filesScanned: j['filesScanned'] as int,
      technologies: list('technologies', TechDetection.fromJson),
      targets: list('targets', TargetDetection.fromJson),
      packages: list('packages', PackageManagerInfo.fromJson),
      git: GitSnapshot.fromJson((j['git'] as Map).cast()),
      findings: list('findings', FileFinding.fromJson),
      permissions: list('permissions', PermissionFinding.fromJson),
      services: list('services', ServiceFinding.fromJson),
      sensitiveFiles: (j['sensitiveFiles'] as List? ?? const []).cast(),
      partialReasons: (j['partialReasons'] as List? ?? const []).cast(),
    );
  }
}

List<Evidence> _evidenceList(Object? raw) => [
  for (final e in (raw as List? ?? const []))
    Evidence.fromJson((e as Map).cast<String, Object?>()),
];
