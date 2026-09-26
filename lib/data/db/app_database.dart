import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Stores a `List<String>` as a JSON array in a TEXT column.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

@DataClassName('Exercise')
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get gifUrl => text()();
  TextColumn get bodyParts => text().map(const StringListConverter())();
  TextColumn get equipments => text().map(const StringListConverter())();
  TextColumn get targetMuscles => text().map(const StringListConverter())();
  TextColumn get secondaryMuscles => text().map(const StringListConverter())();
  TextColumn get instructions => text().map(const StringListConverter())();

  /// True for exercises the user created themselves (not from the catalog).
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Exercises])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'oxlift'));

  @override
  int get schemaVersion => 1;
}
