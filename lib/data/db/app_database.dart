import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/set_type.dart';

export '../models/set_type.dart';

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

// ---- Exercise catalog -----------------------------------------------------

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

// ---- Routines (plans) -----------------------------------------------------
//
// Exercise ids are plain text, not foreign keys: catalog rows can be
// re-downloaded, and a routine must survive that.

class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class RoutineExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId =>
      integer().references(Routines, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text()();
  IntColumn get position => integer()();
  IntColumn get restSeconds => integer().withDefault(const Constant(90))();
  TextColumn get notes => text().nullable()();

  /// Adjacent exercises sharing a group number form a superset (done
  /// back-to-back, resting only after the last one). Null = not supersetted.
  IntColumn get supersetGroup => integer().nullable()();
}

class RoutineSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineExerciseId => integer()
      .references(RoutineExercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get setType =>
      textEnum<SetType>().withDefault(Constant(SetType.working.name))();
  IntColumn get targetReps => integer().nullable()();

  /// Always kilograms; converted for display.
  RealColumn get targetWeightKg => real().nullable()();
}

// ---- Workouts (logged sessions) -------------------------------------------

class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId => integer()
      .nullable()
      .references(Routines, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  DateTimeColumn get startedAt => dateTime()();

  /// Null while the workout is in progress (at most one at a time).
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
}

class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutId =>
      integer().references(Workouts, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text()();
  IntColumn get position => integer()();
  IntColumn get restSeconds => integer().withDefault(const Constant(90))();
  TextColumn get notes => text().nullable()();

  /// Adjacent exercises sharing a group number form a superset (done
  /// back-to-back, resting only after the last one). Null = not supersetted.
  IntColumn get supersetGroup => integer().nullable()();
}

class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutExerciseId => integer()
      .references(WorkoutExercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get setType =>
      textEnum<SetType>().withDefault(Constant(SetType.working.name))();

  /// Always kilograms; null for bodyweight or not yet entered.
  RealColumn get weightKg => real().nullable()();
  IntColumn get reps => integer().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

@DriftDatabase(tables: [
  Exercises,
  Routines,
  RoutineExercises,
  RoutineSets,
  Workouts,
  WorkoutExercises,
  WorkoutSets,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'oxlift'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(routines);
            await m.createTable(routineExercises);
            await m.createTable(routineSets);
            await m.createTable(workouts);
            await m.createTable(workoutExercises);
            await m.createTable(workoutSets);
          }
          if (from >= 2 && from < 3) {
            await m.addColumn(routineExercises, routineExercises.supersetGroup);
            await m.addColumn(workoutExercises, workoutExercises.supersetGroup);
          }
        },
        // SQLite leaves foreign keys (and so cascading deletes) off by default.
        beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
      );
}
