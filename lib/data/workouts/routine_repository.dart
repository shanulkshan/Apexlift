import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../training/training_estimates.dart';
import 'routine_models.dart';

class RoutineRepository {
  RoutineRepository(this._db);

  final AppDatabase _db;

  /// All routines with their exercise names and set counts, in list order.
  Stream<List<RoutineSummary>> watchRoutines() {
    final r = _db.routines;
    final re = _db.routineExercises;
    final ex = _db.exercises;
    final rs = _db.routineSets;
    final query = _db.select(r).join([
      leftOuterJoin(re, re.routineId.equalsExp(r.id)),
      leftOuterJoin(ex, ex.id.equalsExp(re.exerciseId)),
      leftOuterJoin(rs, rs.routineExerciseId.equalsExp(re.id)),
    ])
      ..orderBy([
        OrderingTerm.asc(r.position),
        OrderingTerm.asc(r.id),
        OrderingTerm.asc(re.position),
        OrderingTerm.asc(rs.position),
      ]);

    return query.watch().map((rows) {
      final routines = <int, Routine>{};
      final names = <int, List<String>>{};
      final seenExercises = <int, Set<int>>{};
      final sets = <int, Set<int>>{};
      // routine id -> entry id -> (entry, exercise, sets) in order.
      final plans = <int, Map<int, (RoutineExercise, Exercise?, List<RoutineSet>)>>{};
      for (final row in rows) {
        final routine = row.readTable(r);
        routines[routine.id] = routine;
        names.putIfAbsent(routine.id, () => []);
        sets.putIfAbsent(routine.id, () => {});
        final entry = row.readTableOrNull(re);
        if (entry != null &&
            (seenExercises[routine.id] ??= {}).add(entry.id)) {
          names[routine.id]!
              .add(row.readTableOrNull(ex)?.name ?? entry.exerciseId);
        }
        final set = row.readTableOrNull(rs);
        if (set != null) sets[routine.id]!.add(set.id);
        if (entry != null) {
          final plan = (plans[routine.id] ??= {})
              .putIfAbsent(entry.id, () => (entry, row.readTableOrNull(ex), []));
          if (set != null) plan.$3.add(set);
        }
      }
      return [
        for (final routine in routines.values)
          RoutineSummary(
            routine: routine,
            exerciseNames: names[routine.id]!,
            setCount: sets[routine.id]!.length,
            plan: [
              for (final (entry, exercise, entrySets)
                  in (plans[routine.id] ?? const {}).values)
                PlannedExercise(
                  exercise: exercise,
                  restSeconds: entry.restSeconds,
                  sets: [
                    for (final s in entrySets)
                      PlannedSet(
                        type: s.setType,
                        weightKg: s.targetWeightKg,
                        reps: s.targetReps,
                      ),
                  ],
                ),
            ],
          ),
      ];
    });
  }

  /// Distinct exercises across all routines, counted per body part (an
  /// exercise can count toward several). Updates live as routines change.
  Stream<Map<String, int>> watchPlannedBodyPartCounts() {
    final re = _db.routineExercises;
    final ex = _db.exercises;
    final query = _db.selectOnly(re, distinct: true).join([
      innerJoin(ex, ex.id.equalsExp(re.exerciseId)),
    ])
      ..addColumns([ex.id, ex.bodyParts]);
    return query.watch().map((rows) {
      final counts = <String, int>{};
      for (final row in rows) {
        final parts = ex.bodyParts.converter.fromSql(row.read(ex.bodyParts)!);
        for (final part in parts) {
          counts[part] = (counts[part] ?? 0) + 1;
        }
      }
      return counts;
    });
  }

  /// Exercises for [bodyPart] that appear in at least one routine, each with
  /// the routines using it. Sorted by exercise name.
  Stream<List<PlannedExerciseUsage>> watchPlannedExercises(String bodyPart) {
    final re = _db.routineExercises;
    final ex = _db.exercises;
    final r = _db.routines;
    final query = _db.select(re).join([
      innerJoin(ex, ex.id.equalsExp(re.exerciseId)),
      innerJoin(r, r.id.equalsExp(re.routineId)),
    ])
      ..where(ex.bodyParts.like('%"$bodyPart"%'))
      ..orderBy([
        OrderingTerm.asc(ex.name),
        OrderingTerm.asc(r.position),
        OrderingTerm.asc(r.id),
      ]);

    return query.watch().map((rows) {
      final exercises = <String, Exercise>{};
      final routines = <String, Map<int, Routine>>{};
      for (final row in rows) {
        final exercise = row.readTable(ex);
        final routine = row.readTable(r);
        exercises[exercise.id] = exercise;
        (routines[exercise.id] ??= {})[routine.id] = routine;
      }
      return [
        for (final e in exercises.values)
          PlannedExerciseUsage(
            exercise: e,
            routines: routines[e.id]!.values.toList(),
          ),
      ];
    });
  }

  /// Exercise ids in each routine (routine id -> ids).
  Future<Map<int, Set<String>>> exerciseIdsByRoutine() async {
    final rows = await _db.select(_db.routineExercises).get();
    final out = <int, Set<String>>{};
    for (final row in rows) {
      (out[row.routineId] ??= {}).add(row.exerciseId);
    }
    return out;
  }

  /// Appends [exerciseIds] (with their starting [sets]) to the end of each
  /// routine in [routineIds], skipping exercises a routine already has.
  /// Returns what was actually added per routine.
  Future<Map<int, List<String>>> appendExercises({
    required List<int> routineIds,
    required List<String> exerciseIds,
    Map<String, List<DraftSet>> sets = const {},
  }) =>
      _db.transaction(() async {
        final existing = await exerciseIdsByRoutine();
        final added = <int, List<String>>{};
        for (final routineId in routineIds) {
          final have = existing[routineId] ?? const <String>{};
          final max = _db.routineExercises.position.max();
          final last = await (_db.selectOnly(_db.routineExercises)
                ..addColumns([max])
                ..where(_db.routineExercises.routineId.equals(routineId)))
              .map((row) => row.read(max))
              .getSingle();
          var position = (last ?? -1) + 1;
          for (final id in exerciseIds) {
            if (have.contains(id)) continue;
            final entryId = await _db.into(_db.routineExercises).insert(
                  RoutineExercisesCompanion.insert(
                    routineId: routineId,
                    exerciseId: id,
                    position: position++,
                  ),
                );
            final entrySets = sets[id] ?? const [DraftSet(), DraftSet(), DraftSet()];
            await _db.batch((b) => b.insertAll(_db.routineSets, [
                  for (final (j, s) in entrySets.indexed)
                    RoutineSetsCompanion.insert(
                      routineExerciseId: entryId,
                      position: j,
                      setType: Value(s.type),
                      targetReps: Value(s.reps),
                      targetWeightKg: Value(s.weightKg),
                    ),
                ]));
            (added[routineId] ??= []).add(id);
          }
          if (added.containsKey(routineId)) {
            await (_db.update(_db.routines)
                  ..where((t) => t.id.equals(routineId)))
                .write(RoutinesCompanion(updatedAt: Value(DateTime.now())));
          }
        }
        return added;
      });

  Future<RoutineDraft> load(int id) async {
    final routine = await (_db.select(_db.routines)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    final entries = await (_db.select(_db.routineExercises)
          ..where((t) => t.routineId.equals(id))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    final exercises = <DraftExercise>[];
    for (final e in entries) {
      final sets = await (_db.select(_db.routineSets)
            ..where((t) => t.routineExerciseId.equals(e.id))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();
      exercises.add(DraftExercise(
        exerciseId: e.exerciseId,
        restSeconds: e.restSeconds,
        notes: e.notes ?? '',
        sets: [
          for (final s in sets)
            DraftSet(
                type: s.setType, reps: s.targetReps, weightKg: s.targetWeightKg),
        ],
      ));
    }
    return RoutineDraft(id: id, name: routine.name, exercises: exercises);
  }

  /// Inserts or replaces the routine and all its children. Returns its id.
  Future<int> save(RoutineDraft draft) => _db.transaction(() async {
        final name = draft.name.trim();
        int id;
        if (draft.id == null) {
          final last = await (_db.selectOnly(_db.routines)
                ..addColumns([_db.routines.position.max()]))
              .map((row) => row.read(_db.routines.position.max()))
              .getSingle();
          id = await _db.into(_db.routines).insert(RoutinesCompanion.insert(
                name: name,
                position: Value((last ?? -1) + 1),
              ));
        } else {
          id = draft.id!;
          await (_db.update(_db.routines)..where((t) => t.id.equals(id)))
              .write(RoutinesCompanion(
            name: Value(name),
            updatedAt: Value(DateTime.now()),
          ));
          // Children are rewritten wholesale; sets cascade.
          await (_db.delete(_db.routineExercises)
                ..where((t) => t.routineId.equals(id)))
              .go();
        }

        for (final (i, e) in draft.exercises.indexed) {
          final entryId = await _db.into(_db.routineExercises).insert(
                RoutineExercisesCompanion.insert(
                  routineId: id,
                  exerciseId: e.exerciseId,
                  position: i,
                  restSeconds: Value(e.restSeconds),
                  notes: Value(e.notes.trim().isEmpty ? null : e.notes.trim()),
                ),
              );
          await _db.batch((b) => b.insertAll(_db.routineSets, [
                for (final (j, s) in e.sets.indexed)
                  RoutineSetsCompanion.insert(
                    routineExerciseId: entryId,
                    position: j,
                    setType: Value(s.type),
                    targetReps: Value(s.reps),
                    targetWeightKg: Value(s.weightKg),
                  ),
              ]));
        }
        return id;
      });

  Future<void> delete(int id) =>
      (_db.delete(_db.routines)..where((t) => t.id.equals(id))).go();

  Future<int> duplicate(int id, {required String name}) async {
    final draft = await load(id);
    return save(RoutineDraft(
      name: name,
      exercises: [
        for (final e in draft.exercises)
          DraftExercise(
            exerciseId: e.exerciseId,
            restSeconds: e.restSeconds,
            notes: e.notes,
            sets: e.sets,
          ),
      ],
    ));
  }
}
