import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../training/training_estimates.dart';
import 'routine_models.dart';
import 'workout_models.dart';

/// Live workout sessions and history. Every edit is written straight to the
/// database, so an in-progress workout survives the app being killed.
class WorkoutRepository {
  WorkoutRepository(this._db, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static const defaultRestSeconds = 90;

  // ---- Active workout ----------------------------------------------------

  Stream<Workout?> watchActive() => (_db.select(_db.workouts)
        ..where((t) => t.finishedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
        ..limit(1))
      .watchSingleOrNull();

  Future<Workout?> active() => (_db.select(_db.workouts)
        ..where((t) => t.finishedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
        ..limit(1))
      .getSingleOrNull();

  /// Starts an empty workout, or returns the one already in progress.
  Future<int> startEmpty({required String name}) async {
    final existing = await active();
    if (existing != null) return existing.id;
    return _db.into(_db.workouts).insert(
        WorkoutsCompanion.insert(name: name, startedAt: _now()));
  }

  /// Starts a workout pre-filled from a routine's exercises and targets, or
  /// returns the one already in progress.
  Future<int> startFromRoutine(int routineId) => _db.transaction(() async {
        final existing = await active();
        if (existing != null) return existing.id;

        final routine = await (_db.select(_db.routines)
              ..where((t) => t.id.equals(routineId)))
            .getSingle();
        final workoutId = await _db.into(_db.workouts).insert(
              WorkoutsCompanion.insert(
                routineId: Value(routineId),
                name: routine.name,
                startedAt: _now(),
              ),
            );
        final entries = await (_db.select(_db.routineExercises)
              ..where((t) => t.routineId.equals(routineId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
        for (final e in entries) {
          final weId = await _db.into(_db.workoutExercises).insert(
                WorkoutExercisesCompanion.insert(
                  workoutId: workoutId,
                  exerciseId: e.exerciseId,
                  position: e.position,
                  restSeconds: Value(e.restSeconds),
                  notes: Value(e.notes),
                ),
              );
          final sets = await (_db.select(_db.routineSets)
                ..where((t) => t.routineExerciseId.equals(e.id))
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();
          await _db.batch((b) => b.insertAll(_db.workoutSets, [
                for (final s in sets)
                  WorkoutSetsCompanion.insert(
                    workoutExerciseId: weId,
                    position: s.position,
                    setType: Value(s.setType),
                    weightKg: Value(s.targetWeightKg),
                    reps: Value(s.targetReps),
                  ),
              ]));
        }
        return workoutId;
      });

  Stream<WorkoutDetail?> watchWorkout(int id) {
    final w = _db.workouts;
    final we = _db.workoutExercises;
    final ex = _db.exercises;
    final ws = _db.workoutSets;
    final query = _db.select(w).join([
      leftOuterJoin(we, we.workoutId.equalsExp(w.id)),
      leftOuterJoin(ex, ex.id.equalsExp(we.exerciseId)),
      leftOuterJoin(ws, ws.workoutExerciseId.equalsExp(we.id)),
    ])
      ..where(w.id.equals(id))
      ..orderBy([OrderingTerm.asc(we.position), OrderingTerm.asc(ws.position)]);

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final workout = rows.first.readTable(w);
      final entries = <int, WorkoutExercise>{};
      final exercises = <int, Exercise?>{};
      final sets = <int, List<WorkoutSet>>{};
      for (final row in rows) {
        final entry = row.readTableOrNull(we);
        if (entry == null) continue;
        entries[entry.id] = entry;
        exercises[entry.id] = row.readTableOrNull(ex);
        final list = sets.putIfAbsent(entry.id, () => []);
        final set = row.readTableOrNull(ws);
        if (set != null) list.add(set);
      }
      return WorkoutDetail(
        workout: workout,
        exercises: [
          for (final entry in entries.values)
            WorkoutExerciseDetail(
              entry: entry,
              exercise: exercises[entry.id],
              sets: sets[entry.id]!,
            ),
        ],
      );
    });
  }

  // ---- Editing -----------------------------------------------------------

  /// Appends exercises. Each gets [initialSets] for its id when given
  /// (e.g. last session or suggested numbers), otherwise one empty set.
  Future<void> addExercises(
    int workoutId,
    List<String> exerciseIds, {
    Map<String, List<DraftSet>> initialSets = const {},
  }) =>
      _db.transaction(() async {
        var position = await _nextExercisePosition(workoutId);
        for (final exerciseId in exerciseIds) {
          final weId = await _db.into(_db.workoutExercises).insert(
                WorkoutExercisesCompanion.insert(
                  workoutId: workoutId,
                  exerciseId: exerciseId,
                  position: position++,
                ),
              );
          final sets = initialSets[exerciseId] ?? const [DraftSet()];
          await _db.batch((b) => b.insertAll(_db.workoutSets, [
                for (final (i, s) in sets.indexed)
                  WorkoutSetsCompanion.insert(
                    workoutExerciseId: weId,
                    position: i,
                    setType: Value(s.type),
                    weightKg: Value(s.weightKg),
                    reps: Value(s.reps),
                  ),
              ]));
        }
      });

  Future<void> removeExercise(int workoutExerciseId) =>
      (_db.delete(_db.workoutExercises)
            ..where((t) => t.id.equals(workoutExerciseId)))
          .go();

  Future<void> setRest(int workoutExerciseId, int seconds) =>
      (_db.update(_db.workoutExercises)
            ..where((t) => t.id.equals(workoutExerciseId)))
          .write(WorkoutExercisesCompanion(restSeconds: Value(seconds)));

  /// Adds a set, copying the type and numbers of the last one.
  Future<void> addSet(int workoutExerciseId) => _db.transaction(() async {
        final last = await (_db.select(_db.workoutSets)
              ..where((t) => t.workoutExerciseId.equals(workoutExerciseId))
              ..orderBy([(t) => OrderingTerm.desc(t.position)])
              ..limit(1))
            .getSingleOrNull();
        await _db.into(_db.workoutSets).insert(WorkoutSetsCompanion.insert(
              workoutExerciseId: workoutExerciseId,
              position: (last?.position ?? -1) + 1,
              setType: Value(last?.setType ?? SetType.working),
              weightKg: Value(last?.weightKg),
              reps: Value(last?.reps),
            ));
      });

  Future<void> removeSet(int setId) =>
      (_db.delete(_db.workoutSets)..where((t) => t.id.equals(setId))).go();

  Future<void> updateSet(
    int setId, {
    Value<double?> weightKg = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    SetType? type,
  }) =>
      (_db.update(_db.workoutSets)..where((t) => t.id.equals(setId))).write(
        WorkoutSetsCompanion(
          weightKg: weightKg,
          reps: reps,
          setType: type == null ? const Value.absent() : Value(type),
        ),
      );

  /// Ticks a set on or off. When ticking on, empty fields are filled from
  /// [fallbackWeightKg]/[fallbackReps] (the "previous" hint the user saw).
  Future<void> setCompleted(
    WorkoutSet set,
    bool completed, {
    double? fallbackWeightKg,
    int? fallbackReps,
  }) =>
      (_db.update(_db.workoutSets)..where((t) => t.id.equals(set.id))).write(
        WorkoutSetsCompanion(
          completed: Value(completed),
          completedAt: Value(completed ? _now() : null),
          weightKg: completed && set.weightKg == null
              ? Value(fallbackWeightKg)
              : const Value.absent(),
          reps: completed && set.reps == null
              ? Value(fallbackReps)
              : const Value.absent(),
        ),
      );

  /// Finishes the workout: drops unticked sets and empty exercises, then
  /// stamps the finish time. Returns false (and changes nothing) when no set
  /// was completed.
  Future<bool> finish(int workoutId) => _db.transaction(() async {
        final entryIds = _db.selectOnly(_db.workoutExercises)
          ..addColumns([_db.workoutExercises.id])
          ..where(_db.workoutExercises.workoutId.equals(workoutId));
        final completed = await (_db.select(_db.workoutSets)
              ..where((t) =>
                  t.workoutExerciseId.isInQuery(entryIds) &
                  t.completed.equals(true)))
            .get();
        if (completed.isEmpty) return false;

        await (_db.delete(_db.workoutSets)
              ..where((t) =>
                  t.workoutExerciseId.isInQuery(entryIds) &
                  t.completed.equals(false)))
            .go();
        final withSets = completed.map((s) => s.workoutExerciseId).toSet();
        await (_db.delete(_db.workoutExercises)
              ..where((t) =>
                  t.workoutId.equals(workoutId) & t.id.isNotIn(withSets)))
            .go();
        await (_db.update(_db.workouts)..where((t) => t.id.equals(workoutId)))
            .write(WorkoutsCompanion(finishedAt: Value(_now())));
        return true;
      });

  Future<void> discard(int workoutId) =>
      (_db.delete(_db.workouts)..where((t) => t.id.equals(workoutId))).go();

  // ---- History -----------------------------------------------------------

  /// Sets from the most recent finished workout containing [exerciseId]
  /// (the "previous" column), excluding [excludeWorkoutId].
  Future<List<WorkoutSet>> previousSets(
    String exerciseId, {
    int? excludeWorkoutId,
  }) async {
    final w = _db.workouts;
    final we = _db.workoutExercises;
    final latest = await (_db.select(we).join([
      innerJoin(w, w.id.equalsExp(we.workoutId)),
    ])
          ..where(we.exerciseId.equals(exerciseId) &
              w.finishedAt.isNotNull() &
              (excludeWorkoutId == null
                  ? const Constant(true)
                  : w.id.equals(excludeWorkoutId).not()))
          ..orderBy([OrderingTerm.desc(w.finishedAt)])
          ..limit(1))
        .map((row) => row.readTable(we))
        .getSingleOrNull();
    if (latest == null) return const [];
    return (_db.select(_db.workoutSets)
          ..where((t) => t.workoutExerciseId.equals(latest.id))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
  }

  /// Finished workouts, newest first.
  Stream<List<WorkoutSummary>> watchHistory({int? limit}) {
    final w = _db.workouts;
    final we = _db.workoutExercises;
    final ws = _db.workoutSets;
    final recent = _db.selectOnly(w)
      ..addColumns([w.id])
      ..where(w.finishedAt.isNotNull())
      ..orderBy([OrderingTerm.desc(w.finishedAt)]);
    if (limit != null) recent.limit(limit);

    final ex = _db.exercises;
    final query = _db.select(w).join([
      leftOuterJoin(we, we.workoutId.equalsExp(w.id)),
      leftOuterJoin(ex, ex.id.equalsExp(we.exerciseId)),
      leftOuterJoin(ws, ws.workoutExerciseId.equalsExp(we.id)),
    ])
      ..where(w.id.isInQuery(recent))
      ..orderBy([
        OrderingTerm.desc(w.finishedAt),
        OrderingTerm.asc(we.position),
        OrderingTerm.asc(ws.position),
      ]);

    return query.watch().map((rows) {
      final workouts = <int, Workout>{};
      final exercises = <int, Set<int>>{};
      final sets = <int, List<WorkoutSet>>{};
      final plans =
          <int, Map<int, (WorkoutExercise, Exercise?, List<WorkoutSet>)>>{};
      for (final row in rows) {
        final workout = row.readTable(w);
        workouts[workout.id] = workout;
        final entry = row.readTableOrNull(we);
        if (entry != null) (exercises[workout.id] ??= {}).add(entry.id);
        final set = row.readTableOrNull(ws);
        if (set != null) (sets[workout.id] ??= []).add(set);
        if (entry != null) {
          final plan = (plans[workout.id] ??= {})
              .putIfAbsent(entry.id, () => (entry, row.readTableOrNull(ex), []));
          if (set != null && set.completed) plan.$3.add(set);
        }
      }
      return [
        for (final workout in workouts.values)
          WorkoutSummary(
            workout: workout,
            exerciseCount: exercises[workout.id]?.length ?? 0,
            setCount: sets[workout.id]?.length ?? 0,
            volumeKg: volumeOf(sets[workout.id] ?? const []),
            completedPlan: [
              for (final (entry, exercise, entrySets)
                  in (plans[workout.id] ?? const {}).values)
                PlannedExercise(
                  exercise: exercise,
                  restSeconds: entry.restSeconds,
                  sets: [
                    for (final s in entrySets)
                      PlannedSet(
                          type: s.setType, weightKg: s.weightKg, reps: s.reps),
                  ],
                ),
            ],
          ),
      ];
    });
  }

  /// This week's workouts (Monday start) and volume, plus the day streak.
  Stream<WeekStats> watchWeekStats() => watchHistory().map((history) {
        final now = _now();
        final today = DateTime(now.year, now.month, now.day);
        final weekStart = today.subtract(Duration(days: now.weekday - 1));

        final thisWeek =
            history.where((h) => !h.workout.finishedAt!.isBefore(weekStart));

        final trainedDays = {
          for (final h in history) _day(h.workout.finishedAt!),
        };
        var cursor = trainedDays.contains(today)
            ? today
            : today.subtract(const Duration(days: 1));
        var streak = 0;
        while (trainedDays.contains(cursor)) {
          streak++;
          cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
        }

        return WeekStats(
          workouts: thisWeek.length,
          volumeKg: thisWeek.fold(0.0, (sum, h) => sum + h.volumeKg),
          streakDays: streak,
        );
      }).distinct();

  static DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

  Future<int> _nextExercisePosition(int workoutId) async {
    final max = _db.workoutExercises.position.max();
    final last = await (_db.selectOnly(_db.workoutExercises)
          ..addColumns([max])
          ..where(_db.workoutExercises.workoutId.equals(workoutId)))
        .map((row) => row.read(max))
        .getSingle();
    return (last ?? -1) + 1;
  }
}
