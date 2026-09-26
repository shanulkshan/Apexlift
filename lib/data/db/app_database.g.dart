// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _gifUrlMeta = const VerificationMeta('gifUrl');
  @override
  late final GeneratedColumn<String> gifUrl = GeneratedColumn<String>(
    'gif_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> bodyParts =
      GeneratedColumn<String>(
        'body_parts',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($ExercisesTable.$converterbodyParts);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> equipments =
      GeneratedColumn<String>(
        'equipments',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($ExercisesTable.$converterequipments);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  targetMuscles = GeneratedColumn<String>(
    'target_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ExercisesTable.$convertertargetMuscles);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  secondaryMuscles = GeneratedColumn<String>(
    'secondary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ExercisesTable.$convertersecondaryMuscles);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ExercisesTable.$converterinstructions);
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    gifUrl,
    bodyParts,
    equipments,
    targetMuscles,
    secondaryMuscles,
    instructions,
    isCustom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
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
    if (data.containsKey('gif_url')) {
      context.handle(
        _gifUrlMeta,
        gifUrl.isAcceptableOrUnknown(data['gif_url']!, _gifUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_gifUrlMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      gifUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gif_url'],
      )!,
      bodyParts: $ExercisesTable.$converterbodyParts.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}body_parts'],
        )!,
      ),
      equipments: $ExercisesTable.$converterequipments.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}equipments'],
        )!,
      ),
      targetMuscles: $ExercisesTable.$convertertargetMuscles.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}target_muscles'],
        )!,
      ),
      secondaryMuscles: $ExercisesTable.$convertersecondaryMuscles.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}secondary_muscles'],
        )!,
      ),
      instructions: $ExercisesTable.$converterinstructions.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}instructions'],
        )!,
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterbodyParts =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterequipments =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertertargetMuscles =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertersecondaryMuscles =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterinstructions =
      const StringListConverter();
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final String id;
  final String name;
  final String gifUrl;
  final List<String> bodyParts;
  final List<String> equipments;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  /// True for exercises the user created themselves (not from the catalog).
  final bool isCustom;
  const Exercise({
    required this.id,
    required this.name,
    required this.gifUrl,
    required this.bodyParts,
    required this.equipments,
    required this.targetMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.isCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['gif_url'] = Variable<String>(gifUrl);
    {
      map['body_parts'] = Variable<String>(
        $ExercisesTable.$converterbodyParts.toSql(bodyParts),
      );
    }
    {
      map['equipments'] = Variable<String>(
        $ExercisesTable.$converterequipments.toSql(equipments),
      );
    }
    {
      map['target_muscles'] = Variable<String>(
        $ExercisesTable.$convertertargetMuscles.toSql(targetMuscles),
      );
    }
    {
      map['secondary_muscles'] = Variable<String>(
        $ExercisesTable.$convertersecondaryMuscles.toSql(secondaryMuscles),
      );
    }
    {
      map['instructions'] = Variable<String>(
        $ExercisesTable.$converterinstructions.toSql(instructions),
      );
    }
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      gifUrl: Value(gifUrl),
      bodyParts: Value(bodyParts),
      equipments: Value(equipments),
      targetMuscles: Value(targetMuscles),
      secondaryMuscles: Value(secondaryMuscles),
      instructions: Value(instructions),
      isCustom: Value(isCustom),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      gifUrl: serializer.fromJson<String>(json['gifUrl']),
      bodyParts: serializer.fromJson<List<String>>(json['bodyParts']),
      equipments: serializer.fromJson<List<String>>(json['equipments']),
      targetMuscles: serializer.fromJson<List<String>>(json['targetMuscles']),
      secondaryMuscles: serializer.fromJson<List<String>>(
        json['secondaryMuscles'],
      ),
      instructions: serializer.fromJson<List<String>>(json['instructions']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'gifUrl': serializer.toJson<String>(gifUrl),
      'bodyParts': serializer.toJson<List<String>>(bodyParts),
      'equipments': serializer.toJson<List<String>>(equipments),
      'targetMuscles': serializer.toJson<List<String>>(targetMuscles),
      'secondaryMuscles': serializer.toJson<List<String>>(secondaryMuscles),
      'instructions': serializer.toJson<List<String>>(instructions),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? gifUrl,
    List<String>? bodyParts,
    List<String>? equipments,
    List<String>? targetMuscles,
    List<String>? secondaryMuscles,
    List<String>? instructions,
    bool? isCustom,
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    gifUrl: gifUrl ?? this.gifUrl,
    bodyParts: bodyParts ?? this.bodyParts,
    equipments: equipments ?? this.equipments,
    targetMuscles: targetMuscles ?? this.targetMuscles,
    secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
    instructions: instructions ?? this.instructions,
    isCustom: isCustom ?? this.isCustom,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      gifUrl: data.gifUrl.present ? data.gifUrl.value : this.gifUrl,
      bodyParts: data.bodyParts.present ? data.bodyParts.value : this.bodyParts,
      equipments: data.equipments.present
          ? data.equipments.value
          : this.equipments,
      targetMuscles: data.targetMuscles.present
          ? data.targetMuscles.value
          : this.targetMuscles,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('gifUrl: $gifUrl, ')
          ..write('bodyParts: $bodyParts, ')
          ..write('equipments: $equipments, ')
          ..write('targetMuscles: $targetMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('instructions: $instructions, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    gifUrl,
    bodyParts,
    equipments,
    targetMuscles,
    secondaryMuscles,
    instructions,
    isCustom,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.gifUrl == this.gifUrl &&
          other.bodyParts == this.bodyParts &&
          other.equipments == this.equipments &&
          other.targetMuscles == this.targetMuscles &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.instructions == this.instructions &&
          other.isCustom == this.isCustom);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> gifUrl;
  final Value<List<String>> bodyParts;
  final Value<List<String>> equipments;
  final Value<List<String>> targetMuscles;
  final Value<List<String>> secondaryMuscles;
  final Value<List<String>> instructions;
  final Value<bool> isCustom;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.gifUrl = const Value.absent(),
    this.bodyParts = const Value.absent(),
    this.equipments = const Value.absent(),
    this.targetMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.instructions = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    required String name,
    required String gifUrl,
    required List<String> bodyParts,
    required List<String> equipments,
    required List<String> targetMuscles,
    required List<String> secondaryMuscles,
    required List<String> instructions,
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       gifUrl = Value(gifUrl),
       bodyParts = Value(bodyParts),
       equipments = Value(equipments),
       targetMuscles = Value(targetMuscles),
       secondaryMuscles = Value(secondaryMuscles),
       instructions = Value(instructions);
  static Insertable<Exercise> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? gifUrl,
    Expression<String>? bodyParts,
    Expression<String>? equipments,
    Expression<String>? targetMuscles,
    Expression<String>? secondaryMuscles,
    Expression<String>? instructions,
    Expression<bool>? isCustom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (gifUrl != null) 'gif_url': gifUrl,
      if (bodyParts != null) 'body_parts': bodyParts,
      if (equipments != null) 'equipments': equipments,
      if (targetMuscles != null) 'target_muscles': targetMuscles,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (instructions != null) 'instructions': instructions,
      if (isCustom != null) 'is_custom': isCustom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? gifUrl,
    Value<List<String>>? bodyParts,
    Value<List<String>>? equipments,
    Value<List<String>>? targetMuscles,
    Value<List<String>>? secondaryMuscles,
    Value<List<String>>? instructions,
    Value<bool>? isCustom,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      gifUrl: gifUrl ?? this.gifUrl,
      bodyParts: bodyParts ?? this.bodyParts,
      equipments: equipments ?? this.equipments,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      instructions: instructions ?? this.instructions,
      isCustom: isCustom ?? this.isCustom,
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
    if (gifUrl.present) {
      map['gif_url'] = Variable<String>(gifUrl.value);
    }
    if (bodyParts.present) {
      map['body_parts'] = Variable<String>(
        $ExercisesTable.$converterbodyParts.toSql(bodyParts.value),
      );
    }
    if (equipments.present) {
      map['equipments'] = Variable<String>(
        $ExercisesTable.$converterequipments.toSql(equipments.value),
      );
    }
    if (targetMuscles.present) {
      map['target_muscles'] = Variable<String>(
        $ExercisesTable.$convertertargetMuscles.toSql(targetMuscles.value),
      );
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(
        $ExercisesTable.$convertersecondaryMuscles.toSql(
          secondaryMuscles.value,
        ),
      );
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(
        $ExercisesTable.$converterinstructions.toSql(instructions.value),
      );
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('gifUrl: $gifUrl, ')
          ..write('bodyParts: $bodyParts, ')
          ..write('equipments: $equipments, ')
          ..write('targetMuscles: $targetMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('instructions: $instructions, ')
          ..write('isCustom: $isCustom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [exercises];
}

typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      required String id,
      required String name,
      required String gifUrl,
      required List<String> bodyParts,
      required List<String> equipments,
      required List<String> targetMuscles,
      required List<String> secondaryMuscles,
      required List<String> instructions,
      Value<bool> isCustom,
      Value<int> rowid,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> gifUrl,
      Value<List<String>> bodyParts,
      Value<List<String>> equipments,
      Value<List<String>> targetMuscles,
      Value<List<String>> secondaryMuscles,
      Value<List<String>> instructions,
      Value<bool> isCustom,
      Value<int> rowid,
    });

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
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

  ColumnFilters<String> get gifUrl => $composableBuilder(
    column: $table.gifUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get bodyParts => $composableBuilder(
    column: $table.bodyParts,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get equipments => $composableBuilder(
    column: $table.equipments,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get targetMuscles => $composableBuilder(
    column: $table.targetMuscles,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
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

  ColumnOrderings<String> get gifUrl => $composableBuilder(
    column: $table.gifUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyParts => $composableBuilder(
    column: $table.bodyParts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipments => $composableBuilder(
    column: $table.equipments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetMuscles => $composableBuilder(
    column: $table.targetMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
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

  GeneratedColumn<String> get gifUrl =>
      $composableBuilder(column: $table.gifUrl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get bodyParts =>
      $composableBuilder(column: $table.bodyParts, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get equipments =>
      $composableBuilder(
        column: $table.equipments,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get targetMuscles =>
      $composableBuilder(
        column: $table.targetMuscles,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get secondaryMuscles =>
      $composableBuilder(
        column: $table.secondaryMuscles,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get instructions =>
      $composableBuilder(
        column: $table.instructions,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, BaseReferences<_$AppDatabase, $ExercisesTable, Exercise>),
          Exercise,
          PrefetchHooks Function()
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> gifUrl = const Value.absent(),
                Value<List<String>> bodyParts = const Value.absent(),
                Value<List<String>> equipments = const Value.absent(),
                Value<List<String>> targetMuscles = const Value.absent(),
                Value<List<String>> secondaryMuscles = const Value.absent(),
                Value<List<String>> instructions = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                gifUrl: gifUrl,
                bodyParts: bodyParts,
                equipments: equipments,
                targetMuscles: targetMuscles,
                secondaryMuscles: secondaryMuscles,
                instructions: instructions,
                isCustom: isCustom,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String gifUrl,
                required List<String> bodyParts,
                required List<String> equipments,
                required List<String> targetMuscles,
                required List<String> secondaryMuscles,
                required List<String> instructions,
                Value<bool> isCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                gifUrl: gifUrl,
                bodyParts: bodyParts,
                equipments: equipments,
                targetMuscles: targetMuscles,
                secondaryMuscles: secondaryMuscles,
                instructions: instructions,
                isCustom: isCustom,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, BaseReferences<_$AppDatabase, $ExercisesTable, Exercise>),
      Exercise,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
}
