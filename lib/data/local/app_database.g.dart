// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedMealsTable extends CachedMeals
    with TableInfo<$CachedMealsTable, CachedMeal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailMeta = const VerificationMeta(
    'thumbnail',
  );
  @override
  late final GeneratedColumn<String> thumbnail = GeneratedColumn<String>(
    'thumbnail',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<String> area = GeneratedColumn<String>(
    'area',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceKeyMeta = const VerificationMeta(
    'sourceKey',
  );
  @override
  late final GeneratedColumn<String> sourceKey = GeneratedColumn<String>(
    'source_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    thumbnail,
    category,
    area,
    sourceKey,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_meals';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedMeal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('thumbnail')) {
      context.handle(
        _thumbnailMeta,
        thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta),
      );
    } else if (isInserting) {
      context.missing(_thumbnailMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('area')) {
      context.handle(
        _areaMeta,
        area.isAcceptableOrUnknown(data['area']!, _areaMeta),
      );
    }
    if (data.containsKey('source_key')) {
      context.handle(
        _sourceKeyMeta,
        sourceKey.isAcceptableOrUnknown(data['source_key']!, _sourceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKeyMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id, sourceKey};
  @override
  CachedMeal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMeal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      thumbnail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      area: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area'],
      ),
      sourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_key'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CachedMealsTable createAlias(String alias) {
    return $CachedMealsTable(attachedDatabase, alias);
  }
}

class CachedMeal extends DataClass implements Insertable<CachedMeal> {
  final String id;
  final String name;
  final String thumbnail;
  final String? category;
  final String? area;
  final String sourceKey;
  final DateTime updatedAt;
  const CachedMeal({
    required this.id,
    required this.name,
    required this.thumbnail,
    this.category,
    this.area,
    required this.sourceKey,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['thumbnail'] = Variable<String>(thumbnail);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || area != null) {
      map['area'] = Variable<String>(area);
    }
    map['source_key'] = Variable<String>(sourceKey);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedMealsCompanion toCompanion(bool nullToAbsent) {
    return CachedMealsCompanion(
      id: Value(id),
      name: Value(name),
      thumbnail: Value(thumbnail),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      area: area == null && nullToAbsent ? const Value.absent() : Value(area),
      sourceKey: Value(sourceKey),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedMeal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMeal(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      thumbnail: serializer.fromJson<String>(json['thumbnail']),
      category: serializer.fromJson<String?>(json['category']),
      area: serializer.fromJson<String?>(json['area']),
      sourceKey: serializer.fromJson<String>(json['sourceKey']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'thumbnail': serializer.toJson<String>(thumbnail),
      'category': serializer.toJson<String?>(category),
      'area': serializer.toJson<String?>(area),
      'sourceKey': serializer.toJson<String>(sourceKey),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedMeal copyWith({
    String? id,
    String? name,
    String? thumbnail,
    Value<String?> category = const Value.absent(),
    Value<String?> area = const Value.absent(),
    String? sourceKey,
    DateTime? updatedAt,
  }) => CachedMeal(
    id: id ?? this.id,
    name: name ?? this.name,
    thumbnail: thumbnail ?? this.thumbnail,
    category: category.present ? category.value : this.category,
    area: area.present ? area.value : this.area,
    sourceKey: sourceKey ?? this.sourceKey,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CachedMeal copyWithCompanion(CachedMealsCompanion data) {
    return CachedMeal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      category: data.category.present ? data.category.value : this.category,
      area: data.area.present ? data.area.value : this.area,
      sourceKey: data.sourceKey.present ? data.sourceKey.value : this.sourceKey,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMeal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('category: $category, ')
          ..write('area: $area, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, thumbnail, category, area, sourceKey, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMeal &&
          other.id == this.id &&
          other.name == this.name &&
          other.thumbnail == this.thumbnail &&
          other.category == this.category &&
          other.area == this.area &&
          other.sourceKey == this.sourceKey &&
          other.updatedAt == this.updatedAt);
}

class CachedMealsCompanion extends UpdateCompanion<CachedMeal> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> thumbnail;
  final Value<String?> category;
  final Value<String?> area;
  final Value<String> sourceKey;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CachedMealsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.category = const Value.absent(),
    this.area = const Value.absent(),
    this.sourceKey = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMealsCompanion.insert({
    required String id,
    required String name,
    required String thumbnail,
    this.category = const Value.absent(),
    this.area = const Value.absent(),
    required String sourceKey,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       thumbnail = Value(thumbnail),
       sourceKey = Value(sourceKey),
       updatedAt = Value(updatedAt);
  static Insertable<CachedMeal> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? thumbnail,
    Expression<String>? category,
    Expression<String>? area,
    Expression<String>? sourceKey,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (category != null) 'category': category,
      if (area != null) 'area': area,
      if (sourceKey != null) 'source_key': sourceKey,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMealsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? thumbnail,
    Value<String?>? category,
    Value<String?>? area,
    Value<String>? sourceKey,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CachedMealsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      area: area ?? this.area,
      sourceKey: sourceKey ?? this.sourceKey,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<String>(thumbnail.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (area.present) {
      map['area'] = Variable<String>(area.value);
    }
    if (sourceKey.present) {
      map['source_key'] = Variable<String>(sourceKey.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMealsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('category: $category, ')
          ..write('area: $area, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedCategoriesTable extends CachedCategories
    with TableInfo<$CachedCategoriesTable, CachedCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [name, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  CachedCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCategory(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CachedCategoriesTable createAlias(String alias) {
    return $CachedCategoriesTable(attachedDatabase, alias);
  }
}

class CachedCategory extends DataClass implements Insertable<CachedCategory> {
  final String name;
  final DateTime updatedAt;
  const CachedCategory({required this.name, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CachedCategoriesCompanion(
      name: Value(name),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCategory(
      name: serializer.fromJson<String>(json['name']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedCategory copyWith({String? name, DateTime? updatedAt}) =>
      CachedCategory(
        name: name ?? this.name,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CachedCategory copyWithCompanion(CachedCategoriesCompanion data) {
    return CachedCategory(
      name: data.name.present ? data.name.value : this.name,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCategory(')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCategory &&
          other.name == this.name &&
          other.updatedAt == this.updatedAt);
}

class CachedCategoriesCompanion extends UpdateCompanion<CachedCategory> {
  final Value<String> name;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CachedCategoriesCompanion({
    this.name = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedCategoriesCompanion.insert({
    required String name,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<CachedCategory> custom({
    Expression<String>? name,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedCategoriesCompanion copyWith({
    Value<String>? name,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CachedCategoriesCompanion(
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCategoriesCompanion(')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedMealsTable cachedMeals = $CachedMealsTable(this);
  late final $CachedCategoriesTable cachedCategories = $CachedCategoriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedMeals,
    cachedCategories,
  ];
}

typedef $$CachedMealsTableCreateCompanionBuilder =
    CachedMealsCompanion Function({
      required String id,
      required String name,
      required String thumbnail,
      Value<String?> category,
      Value<String?> area,
      required String sourceKey,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CachedMealsTableUpdateCompanionBuilder =
    CachedMealsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> thumbnail,
      Value<String?> category,
      Value<String?> area,
      Value<String> sourceKey,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CachedMealsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedMealsTable> {
  $$CachedMealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedMealsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedMealsTable> {
  $$CachedMealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedMealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedMealsTable> {
  $$CachedMealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<String> get sourceKey =>
      $composableBuilder(column: $table.sourceKey, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedMealsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedMealsTable,
          CachedMeal,
          $$CachedMealsTableFilterComposer,
          $$CachedMealsTableOrderingComposer,
          $$CachedMealsTableAnnotationComposer,
          $$CachedMealsTableCreateCompanionBuilder,
          $$CachedMealsTableUpdateCompanionBuilder,
          (
            CachedMeal,
            BaseReferences<_$AppDatabase, $CachedMealsTable, CachedMeal>,
          ),
          CachedMeal,
          PrefetchHooks Function()
        > {
  $$CachedMealsTableTableManager(_$AppDatabase db, $CachedMealsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedMealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> thumbnail = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> area = const Value.absent(),
                Value<String> sourceKey = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMealsCompanion(
                id: id,
                name: name,
                thumbnail: thumbnail,
                category: category,
                area: area,
                sourceKey: sourceKey,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String thumbnail,
                Value<String?> category = const Value.absent(),
                Value<String?> area = const Value.absent(),
                required String sourceKey,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedMealsCompanion.insert(
                id: id,
                name: name,
                thumbnail: thumbnail,
                category: category,
                area: area,
                sourceKey: sourceKey,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedMealsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedMealsTable,
      CachedMeal,
      $$CachedMealsTableFilterComposer,
      $$CachedMealsTableOrderingComposer,
      $$CachedMealsTableAnnotationComposer,
      $$CachedMealsTableCreateCompanionBuilder,
      $$CachedMealsTableUpdateCompanionBuilder,
      (
        CachedMeal,
        BaseReferences<_$AppDatabase, $CachedMealsTable, CachedMeal>,
      ),
      CachedMeal,
      PrefetchHooks Function()
    >;
typedef $$CachedCategoriesTableCreateCompanionBuilder =
    CachedCategoriesCompanion Function({
      required String name,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CachedCategoriesTableUpdateCompanionBuilder =
    CachedCategoriesCompanion Function({
      Value<String> name,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CachedCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedCategoriesTable> {
  $$CachedCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedCategoriesTable> {
  $$CachedCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedCategoriesTable> {
  $$CachedCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedCategoriesTable,
          CachedCategory,
          $$CachedCategoriesTableFilterComposer,
          $$CachedCategoriesTableOrderingComposer,
          $$CachedCategoriesTableAnnotationComposer,
          $$CachedCategoriesTableCreateCompanionBuilder,
          $$CachedCategoriesTableUpdateCompanionBuilder,
          (
            CachedCategory,
            BaseReferences<
              _$AppDatabase,
              $CachedCategoriesTable,
              CachedCategory
            >,
          ),
          CachedCategory,
          PrefetchHooks Function()
        > {
  $$CachedCategoriesTableTableManager(
    _$AppDatabase db,
    $CachedCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedCategoriesCompanion(
                name: name,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedCategoriesCompanion.insert(
                name: name,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedCategoriesTable,
      CachedCategory,
      $$CachedCategoriesTableFilterComposer,
      $$CachedCategoriesTableOrderingComposer,
      $$CachedCategoriesTableAnnotationComposer,
      $$CachedCategoriesTableCreateCompanionBuilder,
      $$CachedCategoriesTableUpdateCompanionBuilder,
      (
        CachedCategory,
        BaseReferences<_$AppDatabase, $CachedCategoriesTable, CachedCategory>,
      ),
      CachedCategory,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedMealsTableTableManager get cachedMeals =>
      $$CachedMealsTableTableManager(_db, _db.cachedMeals);
  $$CachedCategoriesTableTableManager get cachedCategories =>
      $$CachedCategoriesTableTableManager(_db, _db.cachedCategories);
}
