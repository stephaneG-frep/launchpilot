// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  technologies = GeneratedColumn<String>(
    'technologies',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($ProjectsTable.$convertertechnologies);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    path,
    favorite,
    technologies,
    createdAt,
    lastOpenedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastOpenedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      technologies: $ProjectsTable.$convertertechnologies.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}technologies'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertechnologies =
      const StringListConverter();
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String name;
  final String path;
  final bool favorite;

  /// Technologies détectées (phase 4), en JSON.
  final List<String> technologies;
  final DateTime createdAt;
  final DateTime lastOpenedAt;
  const Project({
    required this.id,
    required this.name,
    required this.path,
    required this.favorite,
    required this.technologies,
    required this.createdAt,
    required this.lastOpenedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['path'] = Variable<String>(path);
    map['favorite'] = Variable<bool>(favorite);
    {
      map['technologies'] = Variable<String>(
        $ProjectsTable.$convertertechnologies.toSql(technologies),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      path: Value(path),
      favorite: Value(favorite),
      technologies: Value(technologies),
      createdAt: Value(createdAt),
      lastOpenedAt: Value(lastOpenedAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<String>(json['path']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      technologies: serializer.fromJson<List<String>>(json['technologies']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastOpenedAt: serializer.fromJson<DateTime>(json['lastOpenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String>(path),
      'favorite': serializer.toJson<bool>(favorite),
      'technologies': serializer.toJson<List<String>>(technologies),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastOpenedAt': serializer.toJson<DateTime>(lastOpenedAt),
    };
  }

  Project copyWith({
    int? id,
    String? name,
    String? path,
    bool? favorite,
    List<String>? technologies,
    DateTime? createdAt,
    DateTime? lastOpenedAt,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    path: path ?? this.path,
    favorite: favorite ?? this.favorite,
    technologies: technologies ?? this.technologies,
    createdAt: createdAt ?? this.createdAt,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      technologies: data.technologies.present
          ? data.technologies.value
          : this.technologies,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('favorite: $favorite, ')
          ..write('technologies: $technologies, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    path,
    favorite,
    technologies,
    createdAt,
    lastOpenedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.path == this.path &&
          other.favorite == this.favorite &&
          other.technologies == this.technologies &&
          other.createdAt == this.createdAt &&
          other.lastOpenedAt == this.lastOpenedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> path;
  final Value<bool> favorite;
  final Value<List<String>> technologies;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastOpenedAt;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.favorite = const Value.absent(),
    this.technologies = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String path,
    this.favorite = const Value.absent(),
    this.technologies = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastOpenedAt,
  }) : name = Value(name),
       path = Value(path),
       createdAt = Value(createdAt),
       lastOpenedAt = Value(lastOpenedAt);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? path,
    Expression<bool>? favorite,
    Expression<String>? technologies,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastOpenedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (favorite != null) 'favorite': favorite,
      if (technologies != null) 'technologies': technologies,
      if (createdAt != null) 'created_at': createdAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
    });
  }

  ProjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? path,
    Value<bool>? favorite,
    Value<List<String>>? technologies,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastOpenedAt,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      favorite: favorite ?? this.favorite,
      technologies: technologies ?? this.technologies,
      createdAt: createdAt ?? this.createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (technologies.present) {
      map['technologies'] = Variable<String>(
        $ProjectsTable.$convertertechnologies.toSql(technologies.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('favorite: $favorite, ')
          ..write('technologies: $technologies, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }
}

class $ProjectTargetsTable extends ProjectTargets
    with TableInfo<$ProjectTargetsTable, ProjectTarget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedMeta = const VerificationMeta(
    'detected',
  );
  @override
  late final GeneratedColumn<bool> detected = GeneratedColumn<bool>(
    'detected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("detected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _confirmedMeta = const VerificationMeta(
    'confirmed',
  );
  @override
  late final GeneratedColumn<bool> confirmed = GeneratedColumn<bool>(
    'confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> evidence =
      GeneratedColumn<String>(
        'evidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($ProjectTargetsTable.$converterevidence);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    targetId,
    detected,
    confirmed,
    confidence,
    evidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectTarget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('detected')) {
      context.handle(
        _detectedMeta,
        detected.isAcceptableOrUnknown(data['detected']!, _detectedMeta),
      );
    }
    if (data.containsKey('confirmed')) {
      context.handle(
        _confirmedMeta,
        confirmed.isAcceptableOrUnknown(data['confirmed']!, _confirmedMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {projectId, targetId},
  ];
  @override
  ProjectTarget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectTarget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      detected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}detected'],
      )!,
      confirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confirmed'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      evidence: $ProjectTargetsTable.$converterevidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}evidence'],
        )!,
      ),
    );
  }

  @override
  $ProjectTargetsTable createAlias(String alias) {
    return $ProjectTargetsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterevidence =
      const StringListConverter();
}

class ProjectTarget extends DataClass implements Insertable<ProjectTarget> {
  final int id;
  final int projectId;
  final String targetId;
  final bool detected;
  final bool confirmed;
  final double confidence;
  final List<String> evidence;
  const ProjectTarget({
    required this.id,
    required this.projectId,
    required this.targetId,
    required this.detected,
    required this.confirmed,
    required this.confidence,
    required this.evidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['target_id'] = Variable<String>(targetId);
    map['detected'] = Variable<bool>(detected);
    map['confirmed'] = Variable<bool>(confirmed);
    map['confidence'] = Variable<double>(confidence);
    {
      map['evidence'] = Variable<String>(
        $ProjectTargetsTable.$converterevidence.toSql(evidence),
      );
    }
    return map;
  }

  ProjectTargetsCompanion toCompanion(bool nullToAbsent) {
    return ProjectTargetsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      targetId: Value(targetId),
      detected: Value(detected),
      confirmed: Value(confirmed),
      confidence: Value(confidence),
      evidence: Value(evidence),
    );
  }

  factory ProjectTarget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectTarget(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      targetId: serializer.fromJson<String>(json['targetId']),
      detected: serializer.fromJson<bool>(json['detected']),
      confirmed: serializer.fromJson<bool>(json['confirmed']),
      confidence: serializer.fromJson<double>(json['confidence']),
      evidence: serializer.fromJson<List<String>>(json['evidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'targetId': serializer.toJson<String>(targetId),
      'detected': serializer.toJson<bool>(detected),
      'confirmed': serializer.toJson<bool>(confirmed),
      'confidence': serializer.toJson<double>(confidence),
      'evidence': serializer.toJson<List<String>>(evidence),
    };
  }

  ProjectTarget copyWith({
    int? id,
    int? projectId,
    String? targetId,
    bool? detected,
    bool? confirmed,
    double? confidence,
    List<String>? evidence,
  }) => ProjectTarget(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    targetId: targetId ?? this.targetId,
    detected: detected ?? this.detected,
    confirmed: confirmed ?? this.confirmed,
    confidence: confidence ?? this.confidence,
    evidence: evidence ?? this.evidence,
  );
  ProjectTarget copyWithCompanion(ProjectTargetsCompanion data) {
    return ProjectTarget(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      detected: data.detected.present ? data.detected.value : this.detected,
      confirmed: data.confirmed.present ? data.confirmed.value : this.confirmed,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      evidence: data.evidence.present ? data.evidence.value : this.evidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTarget(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('targetId: $targetId, ')
          ..write('detected: $detected, ')
          ..write('confirmed: $confirmed, ')
          ..write('confidence: $confidence, ')
          ..write('evidence: $evidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    targetId,
    detected,
    confirmed,
    confidence,
    evidence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectTarget &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.targetId == this.targetId &&
          other.detected == this.detected &&
          other.confirmed == this.confirmed &&
          other.confidence == this.confidence &&
          other.evidence == this.evidence);
}

class ProjectTargetsCompanion extends UpdateCompanion<ProjectTarget> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> targetId;
  final Value<bool> detected;
  final Value<bool> confirmed;
  final Value<double> confidence;
  final Value<List<String>> evidence;
  const ProjectTargetsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.targetId = const Value.absent(),
    this.detected = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.confidence = const Value.absent(),
    this.evidence = const Value.absent(),
  });
  ProjectTargetsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String targetId,
    this.detected = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.confidence = const Value.absent(),
    this.evidence = const Value.absent(),
  }) : projectId = Value(projectId),
       targetId = Value(targetId);
  static Insertable<ProjectTarget> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? targetId,
    Expression<bool>? detected,
    Expression<bool>? confirmed,
    Expression<double>? confidence,
    Expression<String>? evidence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (targetId != null) 'target_id': targetId,
      if (detected != null) 'detected': detected,
      if (confirmed != null) 'confirmed': confirmed,
      if (confidence != null) 'confidence': confidence,
      if (evidence != null) 'evidence': evidence,
    });
  }

  ProjectTargetsCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<String>? targetId,
    Value<bool>? detected,
    Value<bool>? confirmed,
    Value<double>? confidence,
    Value<List<String>>? evidence,
  }) {
    return ProjectTargetsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      targetId: targetId ?? this.targetId,
      detected: detected ?? this.detected,
      confirmed: confirmed ?? this.confirmed,
      confidence: confidence ?? this.confidence,
      evidence: evidence ?? this.evidence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (detected.present) {
      map['detected'] = Variable<bool>(detected.value);
    }
    if (confirmed.present) {
      map['confirmed'] = Variable<bool>(confirmed.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (evidence.present) {
      map['evidence'] = Variable<String>(
        $ProjectTargetsTable.$converterevidence.toSql(evidence.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTargetsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('targetId: $targetId, ')
          ..write('detected: $detected, ')
          ..write('confirmed: $confirmed, ')
          ..write('confidence: $confidence, ')
          ..write('evidence: $evidence')
          ..write(')'))
        .toString();
  }
}

class $ReleaseSessionsTable extends ReleaseSessions
    with TableInfo<$ReleaseSessionsTable, ReleaseSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReleaseSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionStatus>($ReleaseSessionsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<ActionLevel, String>
  currentLevel = GeneratedColumn<String>(
    'current_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ActionLevel>($ReleaseSessionsTable.$convertercurrentLevel);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    version,
    status,
    currentLevel,
    createdAt,
    updatedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'release_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReleaseSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReleaseSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReleaseSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      status: $ReleaseSessionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      currentLevel: $ReleaseSessionsTable.$convertercurrentLevel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}current_level'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $ReleaseSessionsTable createAlias(String alias) {
    return $ReleaseSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionStatus, String, String> $converterstatus =
      const EnumNameConverter<SessionStatus>(SessionStatus.values);
  static JsonTypeConverter2<ActionLevel, String, String>
  $convertercurrentLevel = const EnumNameConverter<ActionLevel>(
    ActionLevel.values,
  );
}

class ReleaseSession extends DataClass implements Insertable<ReleaseSession> {
  final int id;
  final int projectId;
  final String version;
  final SessionStatus status;
  final ActionLevel currentLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  const ReleaseSession({
    required this.id,
    required this.projectId,
    required this.version,
    required this.status,
    required this.currentLevel,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['version'] = Variable<String>(version);
    {
      map['status'] = Variable<String>(
        $ReleaseSessionsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['current_level'] = Variable<String>(
        $ReleaseSessionsTable.$convertercurrentLevel.toSql(currentLevel),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  ReleaseSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReleaseSessionsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      version: Value(version),
      status: Value(status),
      currentLevel: Value(currentLevel),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory ReleaseSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReleaseSession(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      version: serializer.fromJson<String>(json['version']),
      status: $ReleaseSessionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      currentLevel: $ReleaseSessionsTable.$convertercurrentLevel.fromJson(
        serializer.fromJson<String>(json['currentLevel']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'version': serializer.toJson<String>(version),
      'status': serializer.toJson<String>(
        $ReleaseSessionsTable.$converterstatus.toJson(status),
      ),
      'currentLevel': serializer.toJson<String>(
        $ReleaseSessionsTable.$convertercurrentLevel.toJson(currentLevel),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  ReleaseSession copyWith({
    int? id,
    int? projectId,
    String? version,
    SessionStatus? status,
    ActionLevel? currentLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => ReleaseSession(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    version: version ?? this.version,
    status: status ?? this.status,
    currentLevel: currentLevel ?? this.currentLevel,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  ReleaseSession copyWithCompanion(ReleaseSessionsCompanion data) {
    return ReleaseSession(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      version: data.version.present ? data.version.value : this.version,
      status: data.status.present ? data.status.value : this.status,
      currentLevel: data.currentLevel.present
          ? data.currentLevel.value
          : this.currentLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReleaseSession(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('version: $version, ')
          ..write('status: $status, ')
          ..write('currentLevel: $currentLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    version,
    status,
    currentLevel,
    createdAt,
    updatedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReleaseSession &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.version == this.version &&
          other.status == this.status &&
          other.currentLevel == this.currentLevel &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt);
}

class ReleaseSessionsCompanion extends UpdateCompanion<ReleaseSession> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> version;
  final Value<SessionStatus> status;
  final Value<ActionLevel> currentLevel;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  const ReleaseSessionsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.version = const Value.absent(),
    this.status = const Value.absent(),
    this.currentLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  ReleaseSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String version,
    required SessionStatus status,
    required ActionLevel currentLevel,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.completedAt = const Value.absent(),
  }) : projectId = Value(projectId),
       version = Value(version),
       status = Value(status),
       currentLevel = Value(currentLevel),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ReleaseSession> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? version,
    Expression<String>? status,
    Expression<String>? currentLevel,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (version != null) 'version': version,
      if (status != null) 'status': status,
      if (currentLevel != null) 'current_level': currentLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  ReleaseSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<String>? version,
    Value<SessionStatus>? status,
    Value<ActionLevel>? currentLevel,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? completedAt,
  }) {
    return ReleaseSessionsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      version: version ?? this.version,
      status: status ?? this.status,
      currentLevel: currentLevel ?? this.currentLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ReleaseSessionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (currentLevel.present) {
      map['current_level'] = Variable<String>(
        $ReleaseSessionsTable.$convertercurrentLevel.toSql(currentLevel.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReleaseSessionsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('version: $version, ')
          ..write('status: $status, ')
          ..write('currentLevel: $currentLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $ChecklistStepsTable extends ChecklistSteps
    with TableInfo<$ChecklistStepsTable, ChecklistStepRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChecklistStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES release_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _stepKeyMeta = const VerificationMeta(
    'stepKey',
  );
  @override
  late final GeneratedColumn<String> stepKey = GeneratedColumn<String>(
    'step_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActionLevel, String> level =
      GeneratedColumn<String>(
        'level',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ActionLevel>($ChecklistStepsTable.$converterlevel);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<StepStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<StepStatus>($ChecklistStepsTable.$converterstatus);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    stepKey,
    targetId,
    level,
    position,
    title,
    status,
    note,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checklist_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChecklistStepRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('step_key')) {
      context.handle(
        _stepKeyMeta,
        stepKey.isAcceptableOrUnknown(data['step_key']!, _stepKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_stepKeyMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, stepKey},
  ];
  @override
  ChecklistStepRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChecklistStepRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      stepKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_key'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      ),
      level: $ChecklistStepsTable.$converterlevel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}level'],
        )!,
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: $ChecklistStepsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChecklistStepsTable createAlias(String alias) {
    return $ChecklistStepsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActionLevel, String, String> $converterlevel =
      const EnumNameConverter<ActionLevel>(ActionLevel.values);
  static JsonTypeConverter2<StepStatus, String, String> $converterstatus =
      const EnumNameConverter<StepStatus>(StepStatus.values);
}

class ChecklistStepRecord extends DataClass
    implements Insertable<ChecklistStepRecord> {
  final int id;
  final int sessionId;
  final String stepKey;
  final String? targetId;
  final ActionLevel level;
  final int position;
  final String title;
  final StepStatus status;
  final String? note;
  final DateTime updatedAt;
  const ChecklistStepRecord({
    required this.id,
    required this.sessionId,
    required this.stepKey,
    this.targetId,
    required this.level,
    required this.position,
    required this.title,
    required this.status,
    this.note,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['step_key'] = Variable<String>(stepKey);
    if (!nullToAbsent || targetId != null) {
      map['target_id'] = Variable<String>(targetId);
    }
    {
      map['level'] = Variable<String>(
        $ChecklistStepsTable.$converterlevel.toSql(level),
      );
    }
    map['position'] = Variable<int>(position);
    map['title'] = Variable<String>(title);
    {
      map['status'] = Variable<String>(
        $ChecklistStepsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChecklistStepsCompanion toCompanion(bool nullToAbsent) {
    return ChecklistStepsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      stepKey: Value(stepKey),
      targetId: targetId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetId),
      level: Value(level),
      position: Value(position),
      title: Value(title),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChecklistStepRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChecklistStepRecord(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      stepKey: serializer.fromJson<String>(json['stepKey']),
      targetId: serializer.fromJson<String?>(json['targetId']),
      level: $ChecklistStepsTable.$converterlevel.fromJson(
        serializer.fromJson<String>(json['level']),
      ),
      position: serializer.fromJson<int>(json['position']),
      title: serializer.fromJson<String>(json['title']),
      status: $ChecklistStepsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'stepKey': serializer.toJson<String>(stepKey),
      'targetId': serializer.toJson<String?>(targetId),
      'level': serializer.toJson<String>(
        $ChecklistStepsTable.$converterlevel.toJson(level),
      ),
      'position': serializer.toJson<int>(position),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(
        $ChecklistStepsTable.$converterstatus.toJson(status),
      ),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChecklistStepRecord copyWith({
    int? id,
    int? sessionId,
    String? stepKey,
    Value<String?> targetId = const Value.absent(),
    ActionLevel? level,
    int? position,
    String? title,
    StepStatus? status,
    Value<String?> note = const Value.absent(),
    DateTime? updatedAt,
  }) => ChecklistStepRecord(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    stepKey: stepKey ?? this.stepKey,
    targetId: targetId.present ? targetId.value : this.targetId,
    level: level ?? this.level,
    position: position ?? this.position,
    title: title ?? this.title,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChecklistStepRecord copyWithCompanion(ChecklistStepsCompanion data) {
    return ChecklistStepRecord(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      stepKey: data.stepKey.present ? data.stepKey.value : this.stepKey,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      level: data.level.present ? data.level.value : this.level,
      position: data.position.present ? data.position.value : this.position,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistStepRecord(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('stepKey: $stepKey, ')
          ..write('targetId: $targetId, ')
          ..write('level: $level, ')
          ..write('position: $position, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    stepKey,
    targetId,
    level,
    position,
    title,
    status,
    note,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChecklistStepRecord &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.stepKey == this.stepKey &&
          other.targetId == this.targetId &&
          other.level == this.level &&
          other.position == this.position &&
          other.title == this.title &&
          other.status == this.status &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt);
}

class ChecklistStepsCompanion extends UpdateCompanion<ChecklistStepRecord> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> stepKey;
  final Value<String?> targetId;
  final Value<ActionLevel> level;
  final Value<int> position;
  final Value<String> title;
  final Value<StepStatus> status;
  final Value<String?> note;
  final Value<DateTime> updatedAt;
  const ChecklistStepsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.stepKey = const Value.absent(),
    this.targetId = const Value.absent(),
    this.level = const Value.absent(),
    this.position = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ChecklistStepsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String stepKey,
    this.targetId = const Value.absent(),
    required ActionLevel level,
    required int position,
    required String title,
    required StepStatus status,
    this.note = const Value.absent(),
    required DateTime updatedAt,
  }) : sessionId = Value(sessionId),
       stepKey = Value(stepKey),
       level = Value(level),
       position = Value(position),
       title = Value(title),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<ChecklistStepRecord> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? stepKey,
    Expression<String>? targetId,
    Expression<String>? level,
    Expression<int>? position,
    Expression<String>? title,
    Expression<String>? status,
    Expression<String>? note,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (stepKey != null) 'step_key': stepKey,
      if (targetId != null) 'target_id': targetId,
      if (level != null) 'level': level,
      if (position != null) 'position': position,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ChecklistStepsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? stepKey,
    Value<String?>? targetId,
    Value<ActionLevel>? level,
    Value<int>? position,
    Value<String>? title,
    Value<StepStatus>? status,
    Value<String?>? note,
    Value<DateTime>? updatedAt,
  }) {
    return ChecklistStepsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      stepKey: stepKey ?? this.stepKey,
      targetId: targetId ?? this.targetId,
      level: level ?? this.level,
      position: position ?? this.position,
      title: title ?? this.title,
      status: status ?? this.status,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (stepKey.present) {
      map['step_key'] = Variable<String>(stepKey.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(
        $ChecklistStepsTable.$converterlevel.toSql(level.value),
      );
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ChecklistStepsTable.$converterstatus.toSql(status.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistStepsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('stepKey: $stepKey, ')
          ..write('targetId: $targetId, ')
          ..write('level: $level, ')
          ..write('position: $position, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SessionEntriesTable extends SessionEntries
    with TableInfo<$SessionEntriesTable, SessionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES release_sessions (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionEntryKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionEntryKind>($SessionEntriesTable.$converterkind);
  static const VerificationMeta _entryKeyMeta = const VerificationMeta(
    'entryKey',
  );
  @override
  late final GeneratedColumn<String> entryKey = GeneratedColumn<String>(
    'entry_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    kind,
    entryKey,
    content,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('entry_key')) {
      context.handle(
        _entryKeyMeta,
        entryKey.isAcceptableOrUnknown(data['entry_key']!, _entryKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entryKeyMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      kind: $SessionEntriesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      entryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_key'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionEntriesTable createAlias(String alias) {
    return $SessionEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionEntryKind, String, String> $converterkind =
      const EnumNameConverter<SessionEntryKind>(SessionEntryKind.values);
}

class SessionEntry extends DataClass implements Insertable<SessionEntry> {
  final int id;
  final int sessionId;
  final SessionEntryKind kind;
  final String entryKey;
  final String content;
  final DateTime createdAt;
  const SessionEntry({
    required this.id,
    required this.sessionId,
    required this.kind,
    required this.entryKey,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    {
      map['kind'] = Variable<String>(
        $SessionEntriesTable.$converterkind.toSql(kind),
      );
    }
    map['entry_key'] = Variable<String>(entryKey);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionEntriesCompanion toCompanion(bool nullToAbsent) {
    return SessionEntriesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      kind: Value(kind),
      entryKey: Value(entryKey),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory SessionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionEntry(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      kind: $SessionEntriesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      entryKey: serializer.fromJson<String>(json['entryKey']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'kind': serializer.toJson<String>(
        $SessionEntriesTable.$converterkind.toJson(kind),
      ),
      'entryKey': serializer.toJson<String>(entryKey),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SessionEntry copyWith({
    int? id,
    int? sessionId,
    SessionEntryKind? kind,
    String? entryKey,
    String? content,
    DateTime? createdAt,
  }) => SessionEntry(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    kind: kind ?? this.kind,
    entryKey: entryKey ?? this.entryKey,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  SessionEntry copyWithCompanion(SessionEntriesCompanion data) {
    return SessionEntry(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      kind: data.kind.present ? data.kind.value : this.kind,
      entryKey: data.entryKey.present ? data.entryKey.value : this.entryKey,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionEntry(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('kind: $kind, ')
          ..write('entryKey: $entryKey, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, kind, entryKey, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionEntry &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.kind == this.kind &&
          other.entryKey == this.entryKey &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class SessionEntriesCompanion extends UpdateCompanion<SessionEntry> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<SessionEntryKind> kind;
  final Value<String> entryKey;
  final Value<String> content;
  final Value<DateTime> createdAt;
  const SessionEntriesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.kind = const Value.absent(),
    this.entryKey = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SessionEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required SessionEntryKind kind,
    required String entryKey,
    required String content,
    required DateTime createdAt,
  }) : sessionId = Value(sessionId),
       kind = Value(kind),
       entryKey = Value(entryKey),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<SessionEntry> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? kind,
    Expression<String>? entryKey,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (kind != null) 'kind': kind,
      if (entryKey != null) 'entry_key': entryKey,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SessionEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<SessionEntryKind>? kind,
    Value<String>? entryKey,
    Value<String>? content,
    Value<DateTime>? createdAt,
  }) {
    return SessionEntriesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      kind: kind ?? this.kind,
      entryKey: entryKey ?? this.entryKey,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $SessionEntriesTable.$converterkind.toSql(kind.value),
      );
    }
    if (entryKey.present) {
      map['entry_key'] = Variable<String>(entryKey.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('kind: $kind, ')
          ..write('entryKey: $entryKey, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DetectionReportsTable extends DetectionReports
    with TableInfo<$DetectionReportsTable, DetectionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetectionReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scannedAtMeta = const VerificationMeta(
    'scannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> scannedAt = GeneratedColumn<DateTime>(
    'scanned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportMeta = const VerificationMeta('report');
  @override
  late final GeneratedColumn<String> report = GeneratedColumn<String>(
    'report',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetsReviewedAtMeta = const VerificationMeta(
    'targetsReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> targetsReviewedAt =
      GeneratedColumn<DateTime>(
        'targets_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    scannedAt,
    report,
    targetsReviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detection_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<DetectionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('scanned_at')) {
      context.handle(
        _scannedAtMeta,
        scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_scannedAtMeta);
    }
    if (data.containsKey('report')) {
      context.handle(
        _reportMeta,
        report.isAcceptableOrUnknown(data['report']!, _reportMeta),
      );
    } else if (isInserting) {
      context.missing(_reportMeta);
    }
    if (data.containsKey('targets_reviewed_at')) {
      context.handle(
        _targetsReviewedAtMeta,
        targetsReviewedAt.isAcceptableOrUnknown(
          data['targets_reviewed_at']!,
          _targetsReviewedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetectionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetectionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      scannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scanned_at'],
      )!,
      report: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report'],
      )!,
      targetsReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}targets_reviewed_at'],
      ),
    );
  }

  @override
  $DetectionReportsTable createAlias(String alias) {
    return $DetectionReportsTable(attachedDatabase, alias);
  }
}

class DetectionRecord extends DataClass implements Insertable<DetectionRecord> {
  final int id;
  final int projectId;
  final DateTime scannedAt;

  /// `DetectionReport` sérialisé (chemins relatifs, aucun contenu de fichier).
  final String report;

  /// Moment où l'utilisateur a validé les cibles ; nul tant qu'il ne l'a pas
  /// fait (les cibles suivent alors la détection).
  final DateTime? targetsReviewedAt;
  const DetectionRecord({
    required this.id,
    required this.projectId,
    required this.scannedAt,
    required this.report,
    this.targetsReviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['scanned_at'] = Variable<DateTime>(scannedAt);
    map['report'] = Variable<String>(report);
    if (!nullToAbsent || targetsReviewedAt != null) {
      map['targets_reviewed_at'] = Variable<DateTime>(targetsReviewedAt);
    }
    return map;
  }

  DetectionReportsCompanion toCompanion(bool nullToAbsent) {
    return DetectionReportsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      scannedAt: Value(scannedAt),
      report: Value(report),
      targetsReviewedAt: targetsReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(targetsReviewedAt),
    );
  }

  factory DetectionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetectionRecord(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      scannedAt: serializer.fromJson<DateTime>(json['scannedAt']),
      report: serializer.fromJson<String>(json['report']),
      targetsReviewedAt: serializer.fromJson<DateTime?>(
        json['targetsReviewedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'scannedAt': serializer.toJson<DateTime>(scannedAt),
      'report': serializer.toJson<String>(report),
      'targetsReviewedAt': serializer.toJson<DateTime?>(targetsReviewedAt),
    };
  }

  DetectionRecord copyWith({
    int? id,
    int? projectId,
    DateTime? scannedAt,
    String? report,
    Value<DateTime?> targetsReviewedAt = const Value.absent(),
  }) => DetectionRecord(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    scannedAt: scannedAt ?? this.scannedAt,
    report: report ?? this.report,
    targetsReviewedAt: targetsReviewedAt.present
        ? targetsReviewedAt.value
        : this.targetsReviewedAt,
  );
  DetectionRecord copyWithCompanion(DetectionReportsCompanion data) {
    return DetectionRecord(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
      report: data.report.present ? data.report.value : this.report,
      targetsReviewedAt: data.targetsReviewedAt.present
          ? data.targetsReviewedAt.value
          : this.targetsReviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetectionRecord(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('report: $report, ')
          ..write('targetsReviewedAt: $targetsReviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, scannedAt, report, targetsReviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetectionRecord &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.scannedAt == this.scannedAt &&
          other.report == this.report &&
          other.targetsReviewedAt == this.targetsReviewedAt);
}

class DetectionReportsCompanion extends UpdateCompanion<DetectionRecord> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<DateTime> scannedAt;
  final Value<String> report;
  final Value<DateTime?> targetsReviewedAt;
  const DetectionReportsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.scannedAt = const Value.absent(),
    this.report = const Value.absent(),
    this.targetsReviewedAt = const Value.absent(),
  });
  DetectionReportsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required DateTime scannedAt,
    required String report,
    this.targetsReviewedAt = const Value.absent(),
  }) : projectId = Value(projectId),
       scannedAt = Value(scannedAt),
       report = Value(report);
  static Insertable<DetectionRecord> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<DateTime>? scannedAt,
    Expression<String>? report,
    Expression<DateTime>? targetsReviewedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (scannedAt != null) 'scanned_at': scannedAt,
      if (report != null) 'report': report,
      if (targetsReviewedAt != null) 'targets_reviewed_at': targetsReviewedAt,
    });
  }

  DetectionReportsCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<DateTime>? scannedAt,
    Value<String>? report,
    Value<DateTime?>? targetsReviewedAt,
  }) {
    return DetectionReportsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      scannedAt: scannedAt ?? this.scannedAt,
      report: report ?? this.report,
      targetsReviewedAt: targetsReviewedAt ?? this.targetsReviewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<DateTime>(scannedAt.value);
    }
    if (report.present) {
      map['report'] = Variable<String>(report.value);
    }
    if (targetsReviewedAt.present) {
      map['targets_reviewed_at'] = Variable<DateTime>(targetsReviewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetectionReportsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('report: $report, ')
          ..write('targetsReviewedAt: $targetsReviewedAt')
          ..write(')'))
        .toString();
  }
}

class $CommandLogsTable extends CommandLogs
    with TableInfo<$CommandLogsTable, CommandLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommandLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _executableMeta = const VerificationMeta(
    'executable',
  );
  @override
  late final GeneratedColumn<String> executable = GeneratedColumn<String>(
    'executable',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> arguments =
      GeneratedColumn<String>(
        'arguments',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($CommandLogsTable.$converterarguments);
  static const VerificationMeta _workingDirectoryMeta = const VerificationMeta(
    'workingDirectory',
  );
  @override
  late final GeneratedColumn<String> workingDirectory = GeneratedColumn<String>(
    'working_directory',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riskMeta = const VerificationMeta('risk');
  @override
  late final GeneratedColumn<String> risk = GeneratedColumn<String>(
    'risk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exitCodeMeta = const VerificationMeta(
    'exitCode',
  );
  @override
  late final GeneratedColumn<int> exitCode = GeneratedColumn<int>(
    'exit_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _outputMeta = const VerificationMeta('output');
  @override
  late final GeneratedColumn<String> output = GeneratedColumn<String>(
    'output',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    executable,
    arguments,
    workingDirectory,
    risk,
    status,
    exitCode,
    startedAt,
    durationMs,
    output,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'command_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommandLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('executable')) {
      context.handle(
        _executableMeta,
        executable.isAcceptableOrUnknown(data['executable']!, _executableMeta),
      );
    } else if (isInserting) {
      context.missing(_executableMeta);
    }
    if (data.containsKey('working_directory')) {
      context.handle(
        _workingDirectoryMeta,
        workingDirectory.isAcceptableOrUnknown(
          data['working_directory']!,
          _workingDirectoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workingDirectoryMeta);
    }
    if (data.containsKey('risk')) {
      context.handle(
        _riskMeta,
        risk.isAcceptableOrUnknown(data['risk']!, _riskMeta),
      );
    } else if (isInserting) {
      context.missing(_riskMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('exit_code')) {
      context.handle(
        _exitCodeMeta,
        exitCode.isAcceptableOrUnknown(data['exit_code']!, _exitCodeMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('output')) {
      context.handle(
        _outputMeta,
        output.isAcceptableOrUnknown(data['output']!, _outputMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommandLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommandLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      executable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}executable'],
      )!,
      arguments: $CommandLogsTable.$converterarguments.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}arguments'],
        )!,
      ),
      workingDirectory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}working_directory'],
      )!,
      risk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      exitCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exit_code'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      output: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output'],
      )!,
    );
  }

  @override
  $CommandLogsTable createAlias(String alias) {
    return $CommandLogsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterarguments =
      const StringListConverter();
}

class CommandLogEntry extends DataClass implements Insertable<CommandLogEntry> {
  final int id;
  final int projectId;
  final String executable;
  final List<String> arguments;
  final String workingDirectory;
  final String risk;
  final String status;
  final int? exitCode;
  final DateTime startedAt;
  final int durationMs;

  /// Dernières lignes de sortie, préfixées `1|` (stdout) ou `2|` (stderr).
  final String output;
  const CommandLogEntry({
    required this.id,
    required this.projectId,
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
    required this.risk,
    required this.status,
    this.exitCode,
    required this.startedAt,
    required this.durationMs,
    required this.output,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['executable'] = Variable<String>(executable);
    {
      map['arguments'] = Variable<String>(
        $CommandLogsTable.$converterarguments.toSql(arguments),
      );
    }
    map['working_directory'] = Variable<String>(workingDirectory);
    map['risk'] = Variable<String>(risk);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || exitCode != null) {
      map['exit_code'] = Variable<int>(exitCode);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    map['duration_ms'] = Variable<int>(durationMs);
    map['output'] = Variable<String>(output);
    return map;
  }

  CommandLogsCompanion toCompanion(bool nullToAbsent) {
    return CommandLogsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      executable: Value(executable),
      arguments: Value(arguments),
      workingDirectory: Value(workingDirectory),
      risk: Value(risk),
      status: Value(status),
      exitCode: exitCode == null && nullToAbsent
          ? const Value.absent()
          : Value(exitCode),
      startedAt: Value(startedAt),
      durationMs: Value(durationMs),
      output: Value(output),
    );
  }

  factory CommandLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommandLogEntry(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      executable: serializer.fromJson<String>(json['executable']),
      arguments: serializer.fromJson<List<String>>(json['arguments']),
      workingDirectory: serializer.fromJson<String>(json['workingDirectory']),
      risk: serializer.fromJson<String>(json['risk']),
      status: serializer.fromJson<String>(json['status']),
      exitCode: serializer.fromJson<int?>(json['exitCode']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      output: serializer.fromJson<String>(json['output']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'executable': serializer.toJson<String>(executable),
      'arguments': serializer.toJson<List<String>>(arguments),
      'workingDirectory': serializer.toJson<String>(workingDirectory),
      'risk': serializer.toJson<String>(risk),
      'status': serializer.toJson<String>(status),
      'exitCode': serializer.toJson<int?>(exitCode),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'output': serializer.toJson<String>(output),
    };
  }

  CommandLogEntry copyWith({
    int? id,
    int? projectId,
    String? executable,
    List<String>? arguments,
    String? workingDirectory,
    String? risk,
    String? status,
    Value<int?> exitCode = const Value.absent(),
    DateTime? startedAt,
    int? durationMs,
    String? output,
  }) => CommandLogEntry(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    executable: executable ?? this.executable,
    arguments: arguments ?? this.arguments,
    workingDirectory: workingDirectory ?? this.workingDirectory,
    risk: risk ?? this.risk,
    status: status ?? this.status,
    exitCode: exitCode.present ? exitCode.value : this.exitCode,
    startedAt: startedAt ?? this.startedAt,
    durationMs: durationMs ?? this.durationMs,
    output: output ?? this.output,
  );
  CommandLogEntry copyWithCompanion(CommandLogsCompanion data) {
    return CommandLogEntry(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      executable: data.executable.present
          ? data.executable.value
          : this.executable,
      arguments: data.arguments.present ? data.arguments.value : this.arguments,
      workingDirectory: data.workingDirectory.present
          ? data.workingDirectory.value
          : this.workingDirectory,
      risk: data.risk.present ? data.risk.value : this.risk,
      status: data.status.present ? data.status.value : this.status,
      exitCode: data.exitCode.present ? data.exitCode.value : this.exitCode,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      output: data.output.present ? data.output.value : this.output,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommandLogEntry(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('executable: $executable, ')
          ..write('arguments: $arguments, ')
          ..write('workingDirectory: $workingDirectory, ')
          ..write('risk: $risk, ')
          ..write('status: $status, ')
          ..write('exitCode: $exitCode, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('output: $output')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    executable,
    arguments,
    workingDirectory,
    risk,
    status,
    exitCode,
    startedAt,
    durationMs,
    output,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommandLogEntry &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.executable == this.executable &&
          other.arguments == this.arguments &&
          other.workingDirectory == this.workingDirectory &&
          other.risk == this.risk &&
          other.status == this.status &&
          other.exitCode == this.exitCode &&
          other.startedAt == this.startedAt &&
          other.durationMs == this.durationMs &&
          other.output == this.output);
}

class CommandLogsCompanion extends UpdateCompanion<CommandLogEntry> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> executable;
  final Value<List<String>> arguments;
  final Value<String> workingDirectory;
  final Value<String> risk;
  final Value<String> status;
  final Value<int?> exitCode;
  final Value<DateTime> startedAt;
  final Value<int> durationMs;
  final Value<String> output;
  const CommandLogsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.executable = const Value.absent(),
    this.arguments = const Value.absent(),
    this.workingDirectory = const Value.absent(),
    this.risk = const Value.absent(),
    this.status = const Value.absent(),
    this.exitCode = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.output = const Value.absent(),
  });
  CommandLogsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String executable,
    required List<String> arguments,
    required String workingDirectory,
    required String risk,
    required String status,
    this.exitCode = const Value.absent(),
    required DateTime startedAt,
    this.durationMs = const Value.absent(),
    this.output = const Value.absent(),
  }) : projectId = Value(projectId),
       executable = Value(executable),
       arguments = Value(arguments),
       workingDirectory = Value(workingDirectory),
       risk = Value(risk),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<CommandLogEntry> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? executable,
    Expression<String>? arguments,
    Expression<String>? workingDirectory,
    Expression<String>? risk,
    Expression<String>? status,
    Expression<int>? exitCode,
    Expression<DateTime>? startedAt,
    Expression<int>? durationMs,
    Expression<String>? output,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (executable != null) 'executable': executable,
      if (arguments != null) 'arguments': arguments,
      if (workingDirectory != null) 'working_directory': workingDirectory,
      if (risk != null) 'risk': risk,
      if (status != null) 'status': status,
      if (exitCode != null) 'exit_code': exitCode,
      if (startedAt != null) 'started_at': startedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (output != null) 'output': output,
    });
  }

  CommandLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<String>? executable,
    Value<List<String>>? arguments,
    Value<String>? workingDirectory,
    Value<String>? risk,
    Value<String>? status,
    Value<int?>? exitCode,
    Value<DateTime>? startedAt,
    Value<int>? durationMs,
    Value<String>? output,
  }) {
    return CommandLogsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      executable: executable ?? this.executable,
      arguments: arguments ?? this.arguments,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      risk: risk ?? this.risk,
      status: status ?? this.status,
      exitCode: exitCode ?? this.exitCode,
      startedAt: startedAt ?? this.startedAt,
      durationMs: durationMs ?? this.durationMs,
      output: output ?? this.output,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (executable.present) {
      map['executable'] = Variable<String>(executable.value);
    }
    if (arguments.present) {
      map['arguments'] = Variable<String>(
        $CommandLogsTable.$converterarguments.toSql(arguments.value),
      );
    }
    if (workingDirectory.present) {
      map['working_directory'] = Variable<String>(workingDirectory.value);
    }
    if (risk.present) {
      map['risk'] = Variable<String>(risk.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (exitCode.present) {
      map['exit_code'] = Variable<int>(exitCode.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (output.present) {
      map['output'] = Variable<String>(output.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommandLogsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('executable: $executable, ')
          ..write('arguments: $arguments, ')
          ..write('workingDirectory: $workingDirectory, ')
          ..write('risk: $risk, ')
          ..write('status: $status, ')
          ..write('exitCode: $exitCode, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('output: $output')
          ..write(')'))
        .toString();
  }
}

class $FileChangesTable extends FileChanges
    with TableInfo<$FileChangesTable, FileChangeRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FileChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _existedBeforeMeta = const VerificationMeta(
    'existedBefore',
  );
  @override
  late final GeneratedColumn<bool> existedBefore = GeneratedColumn<bool>(
    'existed_before',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("existed_before" IN (0, 1))',
    ),
  );
  static const VerificationMeta _backupPathMeta = const VerificationMeta(
    'backupPath',
  );
  @override
  late final GeneratedColumn<String> backupPath = GeneratedColumn<String>(
    'backup_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _beforeHashMeta = const VerificationMeta(
    'beforeHash',
  );
  @override
  late final GeneratedColumn<String> beforeHash = GeneratedColumn<String>(
    'before_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterHashMeta = const VerificationMeta(
    'afterHash',
  );
  @override
  late final GeneratedColumn<String> afterHash = GeneratedColumn<String>(
    'after_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restoredAtMeta = const VerificationMeta(
    'restoredAt',
  );
  @override
  late final GeneratedColumn<DateTime> restoredAt = GeneratedColumn<DateTime>(
    'restored_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    batchId,
    label,
    path,
    existedBefore,
    backupPath,
    beforeHash,
    afterHash,
    appliedAt,
    restoredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<FileChangeRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('existed_before')) {
      context.handle(
        _existedBeforeMeta,
        existedBefore.isAcceptableOrUnknown(
          data['existed_before']!,
          _existedBeforeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_existedBeforeMeta);
    }
    if (data.containsKey('backup_path')) {
      context.handle(
        _backupPathMeta,
        backupPath.isAcceptableOrUnknown(data['backup_path']!, _backupPathMeta),
      );
    }
    if (data.containsKey('before_hash')) {
      context.handle(
        _beforeHashMeta,
        beforeHash.isAcceptableOrUnknown(data['before_hash']!, _beforeHashMeta),
      );
    }
    if (data.containsKey('after_hash')) {
      context.handle(
        _afterHashMeta,
        afterHash.isAcceptableOrUnknown(data['after_hash']!, _afterHashMeta),
      );
    } else if (isInserting) {
      context.missing(_afterHashMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_appliedAtMeta);
    }
    if (data.containsKey('restored_at')) {
      context.handle(
        _restoredAtMeta,
        restoredAt.isAcceptableOrUnknown(data['restored_at']!, _restoredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FileChangeRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileChangeRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      existedBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}existed_before'],
      )!,
      backupPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backup_path'],
      ),
      beforeHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_hash'],
      ),
      afterHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_hash'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      )!,
      restoredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}restored_at'],
      ),
    );
  }

  @override
  $FileChangesTable createAlias(String alias) {
    return $FileChangesTable(attachedDatabase, alias);
  }
}

class FileChangeRecord extends DataClass
    implements Insertable<FileChangeRecord> {
  final int id;
  final int projectId;

  /// Regroupe les fichiers écrits ensemble.
  final String batchId;
  final String label;

  /// Chemin relatif à la racine du projet.
  final String path;
  final bool existedBefore;

  /// Copie de l'ancien contenu (nul si le fichier n'existait pas).
  final String? backupPath;
  final String? beforeHash;
  final String afterHash;
  final DateTime appliedAt;
  final DateTime? restoredAt;
  const FileChangeRecord({
    required this.id,
    required this.projectId,
    required this.batchId,
    required this.label,
    required this.path,
    required this.existedBefore,
    this.backupPath,
    this.beforeHash,
    required this.afterHash,
    required this.appliedAt,
    this.restoredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['batch_id'] = Variable<String>(batchId);
    map['label'] = Variable<String>(label);
    map['path'] = Variable<String>(path);
    map['existed_before'] = Variable<bool>(existedBefore);
    if (!nullToAbsent || backupPath != null) {
      map['backup_path'] = Variable<String>(backupPath);
    }
    if (!nullToAbsent || beforeHash != null) {
      map['before_hash'] = Variable<String>(beforeHash);
    }
    map['after_hash'] = Variable<String>(afterHash);
    map['applied_at'] = Variable<DateTime>(appliedAt);
    if (!nullToAbsent || restoredAt != null) {
      map['restored_at'] = Variable<DateTime>(restoredAt);
    }
    return map;
  }

  FileChangesCompanion toCompanion(bool nullToAbsent) {
    return FileChangesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      batchId: Value(batchId),
      label: Value(label),
      path: Value(path),
      existedBefore: Value(existedBefore),
      backupPath: backupPath == null && nullToAbsent
          ? const Value.absent()
          : Value(backupPath),
      beforeHash: beforeHash == null && nullToAbsent
          ? const Value.absent()
          : Value(beforeHash),
      afterHash: Value(afterHash),
      appliedAt: Value(appliedAt),
      restoredAt: restoredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(restoredAt),
    );
  }

  factory FileChangeRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileChangeRecord(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      label: serializer.fromJson<String>(json['label']),
      path: serializer.fromJson<String>(json['path']),
      existedBefore: serializer.fromJson<bool>(json['existedBefore']),
      backupPath: serializer.fromJson<String?>(json['backupPath']),
      beforeHash: serializer.fromJson<String?>(json['beforeHash']),
      afterHash: serializer.fromJson<String>(json['afterHash']),
      appliedAt: serializer.fromJson<DateTime>(json['appliedAt']),
      restoredAt: serializer.fromJson<DateTime?>(json['restoredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'batchId': serializer.toJson<String>(batchId),
      'label': serializer.toJson<String>(label),
      'path': serializer.toJson<String>(path),
      'existedBefore': serializer.toJson<bool>(existedBefore),
      'backupPath': serializer.toJson<String?>(backupPath),
      'beforeHash': serializer.toJson<String?>(beforeHash),
      'afterHash': serializer.toJson<String>(afterHash),
      'appliedAt': serializer.toJson<DateTime>(appliedAt),
      'restoredAt': serializer.toJson<DateTime?>(restoredAt),
    };
  }

  FileChangeRecord copyWith({
    int? id,
    int? projectId,
    String? batchId,
    String? label,
    String? path,
    bool? existedBefore,
    Value<String?> backupPath = const Value.absent(),
    Value<String?> beforeHash = const Value.absent(),
    String? afterHash,
    DateTime? appliedAt,
    Value<DateTime?> restoredAt = const Value.absent(),
  }) => FileChangeRecord(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    batchId: batchId ?? this.batchId,
    label: label ?? this.label,
    path: path ?? this.path,
    existedBefore: existedBefore ?? this.existedBefore,
    backupPath: backupPath.present ? backupPath.value : this.backupPath,
    beforeHash: beforeHash.present ? beforeHash.value : this.beforeHash,
    afterHash: afterHash ?? this.afterHash,
    appliedAt: appliedAt ?? this.appliedAt,
    restoredAt: restoredAt.present ? restoredAt.value : this.restoredAt,
  );
  FileChangeRecord copyWithCompanion(FileChangesCompanion data) {
    return FileChangeRecord(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      label: data.label.present ? data.label.value : this.label,
      path: data.path.present ? data.path.value : this.path,
      existedBefore: data.existedBefore.present
          ? data.existedBefore.value
          : this.existedBefore,
      backupPath: data.backupPath.present
          ? data.backupPath.value
          : this.backupPath,
      beforeHash: data.beforeHash.present
          ? data.beforeHash.value
          : this.beforeHash,
      afterHash: data.afterHash.present ? data.afterHash.value : this.afterHash,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      restoredAt: data.restoredAt.present
          ? data.restoredAt.value
          : this.restoredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileChangeRecord(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('batchId: $batchId, ')
          ..write('label: $label, ')
          ..write('path: $path, ')
          ..write('existedBefore: $existedBefore, ')
          ..write('backupPath: $backupPath, ')
          ..write('beforeHash: $beforeHash, ')
          ..write('afterHash: $afterHash, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('restoredAt: $restoredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    batchId,
    label,
    path,
    existedBefore,
    backupPath,
    beforeHash,
    afterHash,
    appliedAt,
    restoredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileChangeRecord &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.batchId == this.batchId &&
          other.label == this.label &&
          other.path == this.path &&
          other.existedBefore == this.existedBefore &&
          other.backupPath == this.backupPath &&
          other.beforeHash == this.beforeHash &&
          other.afterHash == this.afterHash &&
          other.appliedAt == this.appliedAt &&
          other.restoredAt == this.restoredAt);
}

class FileChangesCompanion extends UpdateCompanion<FileChangeRecord> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> batchId;
  final Value<String> label;
  final Value<String> path;
  final Value<bool> existedBefore;
  final Value<String?> backupPath;
  final Value<String?> beforeHash;
  final Value<String> afterHash;
  final Value<DateTime> appliedAt;
  final Value<DateTime?> restoredAt;
  const FileChangesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.label = const Value.absent(),
    this.path = const Value.absent(),
    this.existedBefore = const Value.absent(),
    this.backupPath = const Value.absent(),
    this.beforeHash = const Value.absent(),
    this.afterHash = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.restoredAt = const Value.absent(),
  });
  FileChangesCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String batchId,
    required String label,
    required String path,
    required bool existedBefore,
    this.backupPath = const Value.absent(),
    this.beforeHash = const Value.absent(),
    required String afterHash,
    required DateTime appliedAt,
    this.restoredAt = const Value.absent(),
  }) : projectId = Value(projectId),
       batchId = Value(batchId),
       label = Value(label),
       path = Value(path),
       existedBefore = Value(existedBefore),
       afterHash = Value(afterHash),
       appliedAt = Value(appliedAt);
  static Insertable<FileChangeRecord> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? batchId,
    Expression<String>? label,
    Expression<String>? path,
    Expression<bool>? existedBefore,
    Expression<String>? backupPath,
    Expression<String>? beforeHash,
    Expression<String>? afterHash,
    Expression<DateTime>? appliedAt,
    Expression<DateTime>? restoredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (batchId != null) 'batch_id': batchId,
      if (label != null) 'label': label,
      if (path != null) 'path': path,
      if (existedBefore != null) 'existed_before': existedBefore,
      if (backupPath != null) 'backup_path': backupPath,
      if (beforeHash != null) 'before_hash': beforeHash,
      if (afterHash != null) 'after_hash': afterHash,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (restoredAt != null) 'restored_at': restoredAt,
    });
  }

  FileChangesCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<String>? batchId,
    Value<String>? label,
    Value<String>? path,
    Value<bool>? existedBefore,
    Value<String?>? backupPath,
    Value<String?>? beforeHash,
    Value<String>? afterHash,
    Value<DateTime>? appliedAt,
    Value<DateTime?>? restoredAt,
  }) {
    return FileChangesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      batchId: batchId ?? this.batchId,
      label: label ?? this.label,
      path: path ?? this.path,
      existedBefore: existedBefore ?? this.existedBefore,
      backupPath: backupPath ?? this.backupPath,
      beforeHash: beforeHash ?? this.beforeHash,
      afterHash: afterHash ?? this.afterHash,
      appliedAt: appliedAt ?? this.appliedAt,
      restoredAt: restoredAt ?? this.restoredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (existedBefore.present) {
      map['existed_before'] = Variable<bool>(existedBefore.value);
    }
    if (backupPath.present) {
      map['backup_path'] = Variable<String>(backupPath.value);
    }
    if (beforeHash.present) {
      map['before_hash'] = Variable<String>(beforeHash.value);
    }
    if (afterHash.present) {
      map['after_hash'] = Variable<String>(afterHash.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (restoredAt.present) {
      map['restored_at'] = Variable<DateTime>(restoredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileChangesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('batchId: $batchId, ')
          ..write('label: $label, ')
          ..write('path: $path, ')
          ..write('existedBefore: $existedBefore, ')
          ..write('backupPath: $backupPath, ')
          ..write('beforeHash: $beforeHash, ')
          ..write('afterHash: $afterHash, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('restoredAt: $restoredAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ProjectTargetsTable projectTargets = $ProjectTargetsTable(this);
  late final $ReleaseSessionsTable releaseSessions = $ReleaseSessionsTable(
    this,
  );
  late final $ChecklistStepsTable checklistSteps = $ChecklistStepsTable(this);
  late final $SessionEntriesTable sessionEntries = $SessionEntriesTable(this);
  late final $DetectionReportsTable detectionReports = $DetectionReportsTable(
    this,
  );
  late final $CommandLogsTable commandLogs = $CommandLogsTable(this);
  late final $FileChangesTable fileChanges = $FileChangesTable(this);
  late final Index projectTargetsProject = Index(
    'project_targets_project',
    'CREATE INDEX project_targets_project ON project_targets (project_id)',
  );
  late final Index releaseSessionsProject = Index(
    'release_sessions_project',
    'CREATE INDEX release_sessions_project ON release_sessions (project_id)',
  );
  late final Index checklistStepsSession = Index(
    'checklist_steps_session',
    'CREATE INDEX checklist_steps_session ON checklist_steps (session_id)',
  );
  late final Index sessionEntriesSession = Index(
    'session_entries_session',
    'CREATE INDEX session_entries_session ON session_entries (session_id)',
  );
  late final Index commandLogsProject = Index(
    'command_logs_project',
    'CREATE INDEX command_logs_project ON command_logs (project_id)',
  );
  late final Index fileChangesProject = Index(
    'file_changes_project',
    'CREATE INDEX file_changes_project ON file_changes (project_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    projectTargets,
    releaseSessions,
    checklistSteps,
    sessionEntries,
    detectionReports,
    commandLogs,
    fileChanges,
    projectTargetsProject,
    releaseSessionsProject,
    checklistStepsSession,
    sessionEntriesSession,
    commandLogsProject,
    fileChangesProject,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('project_targets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('release_sessions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'release_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('checklist_steps', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'release_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('detection_reports', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('command_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('file_changes', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  required String name,
  required String path,
  Value<bool> favorite,
  Value<List<String>> technologies,
  required DateTime createdAt,
  required DateTime lastOpenedAt,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> path,
  Value<bool> favorite,
  Value<List<String>> technologies,
  Value<DateTime> createdAt,
  Value<DateTime> lastOpenedAt,
});

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectTargetsTable, List<ProjectTarget>>
  _projectTargetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.projectTargets,
    aliasName: 'projects__id__project_targets__project_id',
  );

  $$ProjectTargetsTableProcessedTableManager get projectTargetsRefs {
    final manager = $$ProjectTargetsTableTableManager(
      $_db,
      $_db.projectTargets,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectTargetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReleaseSessionsTable, List<ReleaseSession>>
  _releaseSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.releaseSessions,
    aliasName: 'projects__id__release_sessions__project_id',
  );

  $$ReleaseSessionsTableProcessedTableManager get releaseSessionsRefs {
    final manager = $$ReleaseSessionsTableTableManager(
      $_db,
      $_db.releaseSessions,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _releaseSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DetectionReportsTable, List<DetectionRecord>>
  _detectionReportsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.detectionReports,
    aliasName: 'projects__id__detection_reports__project_id',
  );

  $$DetectionReportsTableProcessedTableManager get detectionReportsRefs {
    final manager = $$DetectionReportsTableTableManager(
      $_db,
      $_db.detectionReports,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _detectionReportsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CommandLogsTable, List<CommandLogEntry>>
  _commandLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.commandLogs,
    aliasName: 'projects__id__command_logs__project_id',
  );

  $$CommandLogsTableProcessedTableManager get commandLogsRefs {
    final manager = $$CommandLogsTableTableManager(
      $_db,
      $_db.commandLogs,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_commandLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FileChangesTable, List<FileChangeRecord>>
  _fileChangesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fileChanges,
    aliasName: 'projects__id__file_changes__project_id',
  );

  $$FileChangesTableProcessedTableManager get fileChangesRefs {
    final manager = $$FileChangesTableTableManager(
      $_db,
      $_db.fileChanges,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_fileChangesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get technologies => $composableBuilder(
    column: $table.technologies,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> projectTargetsRefs(
    Expression<bool> Function($$ProjectTargetsTableFilterComposer f) f,
  ) {
    final $$ProjectTargetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectTargets,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectTargetsTableFilterComposer(
            $db: $db,
            $table: $db.projectTargets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> releaseSessionsRefs(
    Expression<bool> Function($$ReleaseSessionsTableFilterComposer f) f,
  ) {
    final $$ReleaseSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.releaseSessions,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReleaseSessionsTableFilterComposer(
            $db: $db,
            $table: $db.releaseSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> detectionReportsRefs(
    Expression<bool> Function($$DetectionReportsTableFilterComposer f) f,
  ) {
    final $$DetectionReportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detectionReports,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetectionReportsTableFilterComposer(
            $db: $db,
            $table: $db.detectionReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> commandLogsRefs(
    Expression<bool> Function($$CommandLogsTableFilterComposer f) f,
  ) {
    final $$CommandLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commandLogs,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommandLogsTableFilterComposer(
            $db: $db,
            $table: $db.commandLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fileChangesRefs(
    Expression<bool> Function($$FileChangesTableFilterComposer f) f,
  ) {
    final $$FileChangesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fileChanges,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FileChangesTableFilterComposer(
            $db: $db,
            $table: $db.fileChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get technologies => $composableBuilder(
    column: $table.technologies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get technologies =>
      $composableBuilder(
        column: $table.technologies,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  Expression<T> projectTargetsRefs<T extends Object>(
    Expression<T> Function($$ProjectTargetsTableAnnotationComposer a) f,
  ) {
    final $$ProjectTargetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectTargets,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectTargetsTableAnnotationComposer(
            $db: $db,
            $table: $db.projectTargets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> releaseSessionsRefs<T extends Object>(
    Expression<T> Function($$ReleaseSessionsTableAnnotationComposer a) f,
  ) {
    final $$ReleaseSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.releaseSessions,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReleaseSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.releaseSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> detectionReportsRefs<T extends Object>(
    Expression<T> Function($$DetectionReportsTableAnnotationComposer a) f,
  ) {
    final $$DetectionReportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detectionReports,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetectionReportsTableAnnotationComposer(
            $db: $db,
            $table: $db.detectionReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> commandLogsRefs<T extends Object>(
    Expression<T> Function($$CommandLogsTableAnnotationComposer a) f,
  ) {
    final $$CommandLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commandLogs,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommandLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.commandLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> fileChangesRefs<T extends Object>(
    Expression<T> Function($$FileChangesTableAnnotationComposer a) f,
  ) {
    final $$FileChangesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fileChanges,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FileChangesTableAnnotationComposer(
            $db: $db,
            $table: $db.fileChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({
            bool projectTargetsRefs,
            bool releaseSessionsRefs,
            bool detectionReportsRefs,
            bool commandLogsRefs,
            bool fileChangesRefs,
          })
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<List<String>> technologies = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastOpenedAt = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                path: path,
                favorite: favorite,
                technologies: technologies,
                createdAt: createdAt,
                lastOpenedAt: lastOpenedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String path,
                Value<bool> favorite = const Value.absent(),
                Value<List<String>> technologies = const Value.absent(),
                required DateTime createdAt,
                required DateTime lastOpenedAt,
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                path: path,
                favorite: favorite,
                technologies: technologies,
                createdAt: createdAt,
                lastOpenedAt: lastOpenedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectsTable, Project>(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectTargetsRefs = false,
                releaseSessionsRefs = false,
                detectionReportsRefs = false,
                commandLogsRefs = false,
                fileChangesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (projectTargetsRefs) db.projectTargets,
                    if (releaseSessionsRefs) db.releaseSessions,
                    if (detectionReportsRefs) db.detectionReports,
                    if (commandLogsRefs) db.commandLogs,
                    if (fileChangesRefs) db.fileChanges,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (projectTargetsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          ProjectTarget
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._projectTargetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).projectTargetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (releaseSessionsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          ReleaseSession
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._releaseSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).releaseSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (detectionReportsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          DetectionRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._detectionReportsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).detectionReportsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (commandLogsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          CommandLogEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._commandLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).commandLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (fileChangesRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          FileChangeRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._fileChangesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).fileChangesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({
        bool projectTargetsRefs,
        bool releaseSessionsRefs,
        bool detectionReportsRefs,
        bool commandLogsRefs,
        bool fileChangesRefs,
      })
    >;
typedef $$ProjectTargetsTableCreateCompanionBuilder =
    ProjectTargetsCompanion Function({
      Value<int> id,
      required int projectId,
      required String targetId,
      Value<bool> detected,
      Value<bool> confirmed,
      Value<double> confidence,
      Value<List<String>> evidence,
    });
typedef $$ProjectTargetsTableUpdateCompanionBuilder =
    ProjectTargetsCompanion Function({
      Value<int> id,
      Value<int> projectId,
      Value<String> targetId,
      Value<bool> detected,
      Value<bool> confirmed,
      Value<double> confidence,
      Value<List<String>> evidence,
    });

final class $$ProjectTargetsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectTargetsTable, ProjectTarget> {
  $$ProjectTargetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('project_targets__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProjectTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectTargetsTable> {
  $$ProjectTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get detected => $composableBuilder(
    column: $table.detected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get evidence => $composableBuilder(
    column: $table.evidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectTargetsTable> {
  $$ProjectTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get detected => $composableBuilder(
    column: $table.detected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidence => $composableBuilder(
    column: $table.evidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectTargetsTable> {
  $$ProjectTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<bool> get detected =>
      $composableBuilder(column: $table.detected, builder: (column) => column);

  GeneratedColumn<bool> get confirmed =>
      $composableBuilder(column: $table.confirmed, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get evidence =>
      $composableBuilder(column: $table.evidence, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectTargetsTable,
          ProjectTarget,
          $$ProjectTargetsTableFilterComposer,
          $$ProjectTargetsTableOrderingComposer,
          $$ProjectTargetsTableAnnotationComposer,
          $$ProjectTargetsTableCreateCompanionBuilder,
          $$ProjectTargetsTableUpdateCompanionBuilder,
          (ProjectTarget, $$ProjectTargetsTableReferences),
          ProjectTarget,
          PrefetchHooks Function({bool projectId})
        > {
  $$ProjectTargetsTableTableManager(
    _$AppDatabase db,
    $ProjectTargetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectTargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<bool> detected = const Value.absent(),
                Value<bool> confirmed = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<List<String>> evidence = const Value.absent(),
              }) => ProjectTargetsCompanion(
                id: id,
                projectId: projectId,
                targetId: targetId,
                detected: detected,
                confirmed: confirmed,
                confidence: confidence,
                evidence: evidence,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                required String targetId,
                Value<bool> detected = const Value.absent(),
                Value<bool> confirmed = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<List<String>> evidence = const Value.absent(),
              }) => ProjectTargetsCompanion.insert(
                id: id,
                projectId: projectId,
                targetId: targetId,
                detected: detected,
                confirmed: confirmed,
                confidence: confidence,
                evidence: evidence,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectTargetsTable, ProjectTarget>(table),
                  $$ProjectTargetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.projectId,
                        referencedTable: $$ProjectTargetsTableReferences
                            ._projectIdTable(db),
                        referencedColumn: $$ProjectTargetsTableReferences
                            ._projectIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProjectTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectTargetsTable,
      ProjectTarget,
      $$ProjectTargetsTableFilterComposer,
      $$ProjectTargetsTableOrderingComposer,
      $$ProjectTargetsTableAnnotationComposer,
      $$ProjectTargetsTableCreateCompanionBuilder,
      $$ProjectTargetsTableUpdateCompanionBuilder,
      (ProjectTarget, $$ProjectTargetsTableReferences),
      ProjectTarget,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$ReleaseSessionsTableCreateCompanionBuilder =
    ReleaseSessionsCompanion Function({
      Value<int> id,
      required int projectId,
      required String version,
      required SessionStatus status,
      required ActionLevel currentLevel,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> completedAt,
    });
typedef $$ReleaseSessionsTableUpdateCompanionBuilder =
    ReleaseSessionsCompanion Function({
      Value<int> id,
      Value<int> projectId,
      Value<String> version,
      Value<SessionStatus> status,
      Value<ActionLevel> currentLevel,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
    });

final class $$ReleaseSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReleaseSessionsTable, ReleaseSession> {
  $$ReleaseSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('release_sessions__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChecklistStepsTable, List<ChecklistStepRecord>>
  _checklistStepsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.checklistSteps,
    aliasName: 'release_sessions__id__checklist_steps__session_id',
  );

  $$ChecklistStepsTableProcessedTableManager get checklistStepsRefs {
    final manager = $$ChecklistStepsTableTableManager(
      $_db,
      $_db.checklistSteps,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_checklistStepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionEntriesTable, List<SessionEntry>>
  _sessionEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionEntries,
    aliasName: 'release_sessions__id__session_entries__session_id',
  );

  $$SessionEntriesTableProcessedTableManager get sessionEntriesRefs {
    final manager = $$SessionEntriesTableTableManager(
      $_db,
      $_db.sessionEntries,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReleaseSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReleaseSessionsTable> {
  $$ReleaseSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionStatus, SessionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ActionLevel, ActionLevel, String>
  get currentLevel => $composableBuilder(
    column: $table.currentLevel,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> checklistStepsRefs(
    Expression<bool> Function($$ChecklistStepsTableFilterComposer f) f,
  ) {
    final $$ChecklistStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checklistSteps,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChecklistStepsTableFilterComposer(
            $db: $db,
            $table: $db.checklistSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionEntriesRefs(
    Expression<bool> Function($$SessionEntriesTableFilterComposer f) f,
  ) {
    final $$SessionEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionEntriesTableFilterComposer(
            $db: $db,
            $table: $db.sessionEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReleaseSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReleaseSessionsTable> {
  $$ReleaseSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentLevel => $composableBuilder(
    column: $table.currentLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReleaseSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReleaseSessionsTable> {
  $$ReleaseSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActionLevel, String> get currentLevel =>
      $composableBuilder(
        column: $table.currentLevel,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> checklistStepsRefs<T extends Object>(
    Expression<T> Function($$ChecklistStepsTableAnnotationComposer a) f,
  ) {
    final $$ChecklistStepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checklistSteps,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChecklistStepsTableAnnotationComposer(
            $db: $db,
            $table: $db.checklistSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionEntriesRefs<T extends Object>(
    Expression<T> Function($$SessionEntriesTableAnnotationComposer a) f,
  ) {
    final $$SessionEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReleaseSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReleaseSessionsTable,
          ReleaseSession,
          $$ReleaseSessionsTableFilterComposer,
          $$ReleaseSessionsTableOrderingComposer,
          $$ReleaseSessionsTableAnnotationComposer,
          $$ReleaseSessionsTableCreateCompanionBuilder,
          $$ReleaseSessionsTableUpdateCompanionBuilder,
          (ReleaseSession, $$ReleaseSessionsTableReferences),
          ReleaseSession,
          PrefetchHooks Function({
            bool projectId,
            bool checklistStepsRefs,
            bool sessionEntriesRefs,
          })
        > {
  $$ReleaseSessionsTableTableManager(
    _$AppDatabase db,
    $ReleaseSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReleaseSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReleaseSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReleaseSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<SessionStatus> status = const Value.absent(),
                Value<ActionLevel> currentLevel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => ReleaseSessionsCompanion(
                id: id,
                projectId: projectId,
                version: version,
                status: status,
                currentLevel: currentLevel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                required String version,
                required SessionStatus status,
                required ActionLevel currentLevel,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> completedAt = const Value.absent(),
              }) => ReleaseSessionsCompanion.insert(
                id: id,
                projectId: projectId,
                version: version,
                status: status,
                currentLevel: currentLevel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReleaseSessionsTable, ReleaseSession>(table),
                  $$ReleaseSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                checklistStepsRefs = false,
                sessionEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (checklistStepsRefs) db.checklistSteps,
                    if (sessionEntriesRefs) db.sessionEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (projectId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.projectId,
                            referencedTable: $$ReleaseSessionsTableReferences
                                ._projectIdTable(db),
                            referencedColumn: $$ReleaseSessionsTableReferences
                                ._projectIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (checklistStepsRefs)
                        await $_getPrefetchedData<
                          ReleaseSession,
                          $ReleaseSessionsTable,
                          ChecklistStepRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ReleaseSessionsTableReferences
                              ._checklistStepsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReleaseSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).checklistStepsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionEntriesRefs)
                        await $_getPrefetchedData<
                          ReleaseSession,
                          $ReleaseSessionsTable,
                          SessionEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ReleaseSessionsTableReferences
                              ._sessionEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReleaseSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ReleaseSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReleaseSessionsTable,
      ReleaseSession,
      $$ReleaseSessionsTableFilterComposer,
      $$ReleaseSessionsTableOrderingComposer,
      $$ReleaseSessionsTableAnnotationComposer,
      $$ReleaseSessionsTableCreateCompanionBuilder,
      $$ReleaseSessionsTableUpdateCompanionBuilder,
      (ReleaseSession, $$ReleaseSessionsTableReferences),
      ReleaseSession,
      PrefetchHooks Function({
        bool projectId,
        bool checklistStepsRefs,
        bool sessionEntriesRefs,
      })
    >;
typedef $$ChecklistStepsTableCreateCompanionBuilder =
    ChecklistStepsCompanion Function({
      Value<int> id,
      required int sessionId,
      required String stepKey,
      Value<String?> targetId,
      required ActionLevel level,
      required int position,
      required String title,
      required StepStatus status,
      Value<String?> note,
      required DateTime updatedAt,
    });
typedef $$ChecklistStepsTableUpdateCompanionBuilder =
    ChecklistStepsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> stepKey,
      Value<String?> targetId,
      Value<ActionLevel> level,
      Value<int> position,
      Value<String> title,
      Value<StepStatus> status,
      Value<String?> note,
      Value<DateTime> updatedAt,
    });

final class $$ChecklistStepsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ChecklistStepsTable,
          ChecklistStepRecord
        > {
  $$ChecklistStepsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReleaseSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .releaseSessions
      .createAlias('checklist_steps__session_id__release_sessions__id');

  $$ReleaseSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$ReleaseSessionsTableTableManager(
      $_db,
      $_db.releaseSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChecklistStepsTableFilterComposer
    extends Composer<_$AppDatabase, $ChecklistStepsTable> {
  $$ChecklistStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepKey => $composableBuilder(
    column: $table.stepKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActionLevel, ActionLevel, String> get level =>
      $composableBuilder(
        column: $table.level,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StepStatus, StepStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ReleaseSessionsTableFilterComposer get sessionId {
    final $$ReleaseSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.releaseSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReleaseSessionsTableFilterComposer(
            $db: $db,
            $table: $db.releaseSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChecklistStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChecklistStepsTable> {
  $$ChecklistStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepKey => $composableBuilder(
    column: $table.stepKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReleaseSessionsTableOrderingComposer get sessionId {
    final $$ReleaseSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.releaseSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReleaseSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.releaseSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChecklistStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChecklistStepsTable> {
  $$ChecklistStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stepKey =>
      $composableBuilder(column: $table.stepKey, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActionLevel, String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StepStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ReleaseSessionsTableAnnotationComposer get sessionId {
    final $$ReleaseSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.releaseSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReleaseSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.releaseSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChecklistStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChecklistStepsTable,
          ChecklistStepRecord,
          $$ChecklistStepsTableFilterComposer,
          $$ChecklistStepsTableOrderingComposer,
          $$ChecklistStepsTableAnnotationComposer,
          $$ChecklistStepsTableCreateCompanionBuilder,
          $$ChecklistStepsTableUpdateCompanionBuilder,
          (ChecklistStepRecord, $$ChecklistStepsTableReferences),
          ChecklistStepRecord,
          PrefetchHooks Function({bool sessionId})
        > {
  $$ChecklistStepsTableTableManager(
    _$AppDatabase db,
    $ChecklistStepsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChecklistStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChecklistStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChecklistStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> stepKey = const Value.absent(),
                Value<String?> targetId = const Value.absent(),
                Value<ActionLevel> level = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<StepStatus> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ChecklistStepsCompanion(
                id: id,
                sessionId: sessionId,
                stepKey: stepKey,
                targetId: targetId,
                level: level,
                position: position,
                title: title,
                status: status,
                note: note,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String stepKey,
                Value<String?> targetId = const Value.absent(),
                required ActionLevel level,
                required int position,
                required String title,
                required StepStatus status,
                Value<String?> note = const Value.absent(),
                required DateTime updatedAt,
              }) => ChecklistStepsCompanion.insert(
                id: id,
                sessionId: sessionId,
                stepKey: stepKey,
                targetId: targetId,
                level: level,
                position: position,
                title: title,
                status: status,
                note: note,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChecklistStepsTable, ChecklistStepRecord>(table),
                  $$ChecklistStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$ChecklistStepsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$ChecklistStepsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChecklistStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChecklistStepsTable,
      ChecklistStepRecord,
      $$ChecklistStepsTableFilterComposer,
      $$ChecklistStepsTableOrderingComposer,
      $$ChecklistStepsTableAnnotationComposer,
      $$ChecklistStepsTableCreateCompanionBuilder,
      $$ChecklistStepsTableUpdateCompanionBuilder,
      (ChecklistStepRecord, $$ChecklistStepsTableReferences),
      ChecklistStepRecord,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SessionEntriesTableCreateCompanionBuilder =
    SessionEntriesCompanion Function({
      Value<int> id,
      required int sessionId,
      required SessionEntryKind kind,
      required String entryKey,
      required String content,
      required DateTime createdAt,
    });
typedef $$SessionEntriesTableUpdateCompanionBuilder =
    SessionEntriesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<SessionEntryKind> kind,
      Value<String> entryKey,
      Value<String> content,
      Value<DateTime> createdAt,
    });

final class $$SessionEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $SessionEntriesTable, SessionEntry> {
  $$SessionEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReleaseSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .releaseSessions
      .createAlias('session_entries__session_id__release_sessions__id');

  $$ReleaseSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$ReleaseSessionsTableTableManager(
      $_db,
      $_db.releaseSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionEntriesTable> {
  $$SessionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionEntryKind, SessionEntryKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get entryKey => $composableBuilder(
    column: $table.entryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ReleaseSessionsTableFilterComposer get sessionId {
    final $$ReleaseSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.releaseSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReleaseSessionsTableFilterComposer(
            $db: $db,
            $table: $db.releaseSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionEntriesTable> {
  $$SessionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryKey => $composableBuilder(
    column: $table.entryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReleaseSessionsTableOrderingComposer get sessionId {
    final $$ReleaseSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.releaseSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReleaseSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.releaseSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionEntriesTable> {
  $$SessionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionEntryKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get entryKey =>
      $composableBuilder(column: $table.entryKey, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ReleaseSessionsTableAnnotationComposer get sessionId {
    final $$ReleaseSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.releaseSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReleaseSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.releaseSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionEntriesTable,
          SessionEntry,
          $$SessionEntriesTableFilterComposer,
          $$SessionEntriesTableOrderingComposer,
          $$SessionEntriesTableAnnotationComposer,
          $$SessionEntriesTableCreateCompanionBuilder,
          $$SessionEntriesTableUpdateCompanionBuilder,
          (SessionEntry, $$SessionEntriesTableReferences),
          SessionEntry,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionEntriesTableTableManager(
    _$AppDatabase db,
    $SessionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<SessionEntryKind> kind = const Value.absent(),
                Value<String> entryKey = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SessionEntriesCompanion(
                id: id,
                sessionId: sessionId,
                kind: kind,
                entryKey: entryKey,
                content: content,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required SessionEntryKind kind,
                required String entryKey,
                required String content,
                required DateTime createdAt,
              }) => SessionEntriesCompanion.insert(
                id: id,
                sessionId: sessionId,
                kind: kind,
                entryKey: entryKey,
                content: content,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionEntriesTable, SessionEntry>(table),
                  $$SessionEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SessionEntriesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SessionEntriesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionEntriesTable,
      SessionEntry,
      $$SessionEntriesTableFilterComposer,
      $$SessionEntriesTableOrderingComposer,
      $$SessionEntriesTableAnnotationComposer,
      $$SessionEntriesTableCreateCompanionBuilder,
      $$SessionEntriesTableUpdateCompanionBuilder,
      (SessionEntry, $$SessionEntriesTableReferences),
      SessionEntry,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$DetectionReportsTableCreateCompanionBuilder =
    DetectionReportsCompanion Function({
      Value<int> id,
      required int projectId,
      required DateTime scannedAt,
      required String report,
      Value<DateTime?> targetsReviewedAt,
    });
typedef $$DetectionReportsTableUpdateCompanionBuilder =
    DetectionReportsCompanion Function({
      Value<int> id,
      Value<int> projectId,
      Value<DateTime> scannedAt,
      Value<String> report,
      Value<DateTime?> targetsReviewedAt,
    });

final class $$DetectionReportsTableReferences
    extends
        BaseReferences<_$AppDatabase, $DetectionReportsTable, DetectionRecord> {
  $$DetectionReportsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('detection_reports__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DetectionReportsTableFilterComposer
    extends Composer<_$AppDatabase, $DetectionReportsTable> {
  $$DetectionReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get report => $composableBuilder(
    column: $table.report,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetsReviewedAt => $composableBuilder(
    column: $table.targetsReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetectionReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $DetectionReportsTable> {
  $$DetectionReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get report => $composableBuilder(
    column: $table.report,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetsReviewedAt => $composableBuilder(
    column: $table.targetsReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetectionReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetectionReportsTable> {
  $$DetectionReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);

  GeneratedColumn<String> get report =>
      $composableBuilder(column: $table.report, builder: (column) => column);

  GeneratedColumn<DateTime> get targetsReviewedAt => $composableBuilder(
    column: $table.targetsReviewedAt,
    builder: (column) => column,
  );

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetectionReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DetectionReportsTable,
          DetectionRecord,
          $$DetectionReportsTableFilterComposer,
          $$DetectionReportsTableOrderingComposer,
          $$DetectionReportsTableAnnotationComposer,
          $$DetectionReportsTableCreateCompanionBuilder,
          $$DetectionReportsTableUpdateCompanionBuilder,
          (DetectionRecord, $$DetectionReportsTableReferences),
          DetectionRecord,
          PrefetchHooks Function({bool projectId})
        > {
  $$DetectionReportsTableTableManager(
    _$AppDatabase db,
    $DetectionReportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetectionReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetectionReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetectionReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<DateTime> scannedAt = const Value.absent(),
                Value<String> report = const Value.absent(),
                Value<DateTime?> targetsReviewedAt = const Value.absent(),
              }) => DetectionReportsCompanion(
                id: id,
                projectId: projectId,
                scannedAt: scannedAt,
                report: report,
                targetsReviewedAt: targetsReviewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                required DateTime scannedAt,
                required String report,
                Value<DateTime?> targetsReviewedAt = const Value.absent(),
              }) => DetectionReportsCompanion.insert(
                id: id,
                projectId: projectId,
                scannedAt: scannedAt,
                report: report,
                targetsReviewedAt: targetsReviewedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DetectionReportsTable, DetectionRecord>(table),
                  $$DetectionReportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.projectId,
                        referencedTable: $$DetectionReportsTableReferences
                            ._projectIdTable(db),
                        referencedColumn: $$DetectionReportsTableReferences
                            ._projectIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DetectionReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DetectionReportsTable,
      DetectionRecord,
      $$DetectionReportsTableFilterComposer,
      $$DetectionReportsTableOrderingComposer,
      $$DetectionReportsTableAnnotationComposer,
      $$DetectionReportsTableCreateCompanionBuilder,
      $$DetectionReportsTableUpdateCompanionBuilder,
      (DetectionRecord, $$DetectionReportsTableReferences),
      DetectionRecord,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$CommandLogsTableCreateCompanionBuilder =
    CommandLogsCompanion Function({
      Value<int> id,
      required int projectId,
      required String executable,
      required List<String> arguments,
      required String workingDirectory,
      required String risk,
      required String status,
      Value<int?> exitCode,
      required DateTime startedAt,
      Value<int> durationMs,
      Value<String> output,
    });
typedef $$CommandLogsTableUpdateCompanionBuilder =
    CommandLogsCompanion Function({
      Value<int> id,
      Value<int> projectId,
      Value<String> executable,
      Value<List<String>> arguments,
      Value<String> workingDirectory,
      Value<String> risk,
      Value<String> status,
      Value<int?> exitCode,
      Value<DateTime> startedAt,
      Value<int> durationMs,
      Value<String> output,
    });

final class $$CommandLogsTableReferences
    extends BaseReferences<_$AppDatabase, $CommandLogsTable, CommandLogEntry> {
  $$CommandLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('command_logs__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CommandLogsTableFilterComposer
    extends Composer<_$AppDatabase, $CommandLogsTable> {
  $$CommandLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get executable => $composableBuilder(
    column: $table.executable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get arguments => $composableBuilder(
    column: $table.arguments,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get workingDirectory => $composableBuilder(
    column: $table.workingDirectory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get risk => $composableBuilder(
    column: $table.risk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exitCode => $composableBuilder(
    column: $table.exitCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get output => $composableBuilder(
    column: $table.output,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommandLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommandLogsTable> {
  $$CommandLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get executable => $composableBuilder(
    column: $table.executable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arguments => $composableBuilder(
    column: $table.arguments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workingDirectory => $composableBuilder(
    column: $table.workingDirectory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get risk => $composableBuilder(
    column: $table.risk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exitCode => $composableBuilder(
    column: $table.exitCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get output => $composableBuilder(
    column: $table.output,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommandLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommandLogsTable> {
  $$CommandLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get executable => $composableBuilder(
    column: $table.executable,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get arguments =>
      $composableBuilder(column: $table.arguments, builder: (column) => column);

  GeneratedColumn<String> get workingDirectory => $composableBuilder(
    column: $table.workingDirectory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get risk =>
      $composableBuilder(column: $table.risk, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get exitCode =>
      $composableBuilder(column: $table.exitCode, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get output =>
      $composableBuilder(column: $table.output, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommandLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommandLogsTable,
          CommandLogEntry,
          $$CommandLogsTableFilterComposer,
          $$CommandLogsTableOrderingComposer,
          $$CommandLogsTableAnnotationComposer,
          $$CommandLogsTableCreateCompanionBuilder,
          $$CommandLogsTableUpdateCompanionBuilder,
          (CommandLogEntry, $$CommandLogsTableReferences),
          CommandLogEntry,
          PrefetchHooks Function({bool projectId})
        > {
  $$CommandLogsTableTableManager(_$AppDatabase db, $CommandLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommandLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommandLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommandLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> executable = const Value.absent(),
                Value<List<String>> arguments = const Value.absent(),
                Value<String> workingDirectory = const Value.absent(),
                Value<String> risk = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> exitCode = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> output = const Value.absent(),
              }) => CommandLogsCompanion(
                id: id,
                projectId: projectId,
                executable: executable,
                arguments: arguments,
                workingDirectory: workingDirectory,
                risk: risk,
                status: status,
                exitCode: exitCode,
                startedAt: startedAt,
                durationMs: durationMs,
                output: output,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                required String executable,
                required List<String> arguments,
                required String workingDirectory,
                required String risk,
                required String status,
                Value<int?> exitCode = const Value.absent(),
                required DateTime startedAt,
                Value<int> durationMs = const Value.absent(),
                Value<String> output = const Value.absent(),
              }) => CommandLogsCompanion.insert(
                id: id,
                projectId: projectId,
                executable: executable,
                arguments: arguments,
                workingDirectory: workingDirectory,
                risk: risk,
                status: status,
                exitCode: exitCode,
                startedAt: startedAt,
                durationMs: durationMs,
                output: output,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CommandLogsTable, CommandLogEntry>(table),
                  $$CommandLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.projectId,
                        referencedTable: $$CommandLogsTableReferences
                            ._projectIdTable(db),
                        referencedColumn: $$CommandLogsTableReferences
                            ._projectIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CommandLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommandLogsTable,
      CommandLogEntry,
      $$CommandLogsTableFilterComposer,
      $$CommandLogsTableOrderingComposer,
      $$CommandLogsTableAnnotationComposer,
      $$CommandLogsTableCreateCompanionBuilder,
      $$CommandLogsTableUpdateCompanionBuilder,
      (CommandLogEntry, $$CommandLogsTableReferences),
      CommandLogEntry,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$FileChangesTableCreateCompanionBuilder =
    FileChangesCompanion Function({
      Value<int> id,
      required int projectId,
      required String batchId,
      required String label,
      required String path,
      required bool existedBefore,
      Value<String?> backupPath,
      Value<String?> beforeHash,
      required String afterHash,
      required DateTime appliedAt,
      Value<DateTime?> restoredAt,
    });
typedef $$FileChangesTableUpdateCompanionBuilder =
    FileChangesCompanion Function({
      Value<int> id,
      Value<int> projectId,
      Value<String> batchId,
      Value<String> label,
      Value<String> path,
      Value<bool> existedBefore,
      Value<String?> backupPath,
      Value<String?> beforeHash,
      Value<String> afterHash,
      Value<DateTime> appliedAt,
      Value<DateTime?> restoredAt,
    });

final class $$FileChangesTableReferences
    extends BaseReferences<_$AppDatabase, $FileChangesTable, FileChangeRecord> {
  $$FileChangesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('file_changes__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FileChangesTableFilterComposer
    extends Composer<_$AppDatabase, $FileChangesTable> {
  $$FileChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get existedBefore => $composableBuilder(
    column: $table.existedBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beforeHash => $composableBuilder(
    column: $table.beforeHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterHash => $composableBuilder(
    column: $table.afterHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get restoredAt => $composableBuilder(
    column: $table.restoredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FileChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $FileChangesTable> {
  $$FileChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get existedBefore => $composableBuilder(
    column: $table.existedBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beforeHash => $composableBuilder(
    column: $table.beforeHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterHash => $composableBuilder(
    column: $table.afterHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get restoredAt => $composableBuilder(
    column: $table.restoredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FileChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FileChangesTable> {
  $$FileChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<bool> get existedBefore => $composableBuilder(
    column: $table.existedBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get beforeHash => $composableBuilder(
    column: $table.beforeHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterHash =>
      $composableBuilder(column: $table.afterHash, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get restoredAt => $composableBuilder(
    column: $table.restoredAt,
    builder: (column) => column,
  );

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FileChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FileChangesTable,
          FileChangeRecord,
          $$FileChangesTableFilterComposer,
          $$FileChangesTableOrderingComposer,
          $$FileChangesTableAnnotationComposer,
          $$FileChangesTableCreateCompanionBuilder,
          $$FileChangesTableUpdateCompanionBuilder,
          (FileChangeRecord, $$FileChangesTableReferences),
          FileChangeRecord,
          PrefetchHooks Function({bool projectId})
        > {
  $$FileChangesTableTableManager(_$AppDatabase db, $FileChangesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FileChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FileChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FileChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<bool> existedBefore = const Value.absent(),
                Value<String?> backupPath = const Value.absent(),
                Value<String?> beforeHash = const Value.absent(),
                Value<String> afterHash = const Value.absent(),
                Value<DateTime> appliedAt = const Value.absent(),
                Value<DateTime?> restoredAt = const Value.absent(),
              }) => FileChangesCompanion(
                id: id,
                projectId: projectId,
                batchId: batchId,
                label: label,
                path: path,
                existedBefore: existedBefore,
                backupPath: backupPath,
                beforeHash: beforeHash,
                afterHash: afterHash,
                appliedAt: appliedAt,
                restoredAt: restoredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                required String batchId,
                required String label,
                required String path,
                required bool existedBefore,
                Value<String?> backupPath = const Value.absent(),
                Value<String?> beforeHash = const Value.absent(),
                required String afterHash,
                required DateTime appliedAt,
                Value<DateTime?> restoredAt = const Value.absent(),
              }) => FileChangesCompanion.insert(
                id: id,
                projectId: projectId,
                batchId: batchId,
                label: label,
                path: path,
                existedBefore: existedBefore,
                backupPath: backupPath,
                beforeHash: beforeHash,
                afterHash: afterHash,
                appliedAt: appliedAt,
                restoredAt: restoredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FileChangesTable, FileChangeRecord>(table),
                  $$FileChangesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.projectId,
                        referencedTable: $$FileChangesTableReferences
                            ._projectIdTable(db),
                        referencedColumn: $$FileChangesTableReferences
                            ._projectIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FileChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FileChangesTable,
      FileChangeRecord,
      $$FileChangesTableFilterComposer,
      $$FileChangesTableOrderingComposer,
      $$FileChangesTableAnnotationComposer,
      $$FileChangesTableCreateCompanionBuilder,
      $$FileChangesTableUpdateCompanionBuilder,
      (FileChangeRecord, $$FileChangesTableReferences),
      FileChangeRecord,
      PrefetchHooks Function({bool projectId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ProjectTargetsTableTableManager get projectTargets =>
      $$ProjectTargetsTableTableManager(_db, _db.projectTargets);
  $$ReleaseSessionsTableTableManager get releaseSessions =>
      $$ReleaseSessionsTableTableManager(_db, _db.releaseSessions);
  $$ChecklistStepsTableTableManager get checklistSteps =>
      $$ChecklistStepsTableTableManager(_db, _db.checklistSteps);
  $$SessionEntriesTableTableManager get sessionEntries =>
      $$SessionEntriesTableTableManager(_db, _db.sessionEntries);
  $$DetectionReportsTableTableManager get detectionReports =>
      $$DetectionReportsTableTableManager(_db, _db.detectionReports);
  $$CommandLogsTableTableManager get commandLogs =>
      $$CommandLogsTableTableManager(_db, _db.commandLogs);
  $$FileChangesTableTableManager get fileChanges =>
      $$FileChangesTableTableManager(_db, _db.fileChanges);
}
