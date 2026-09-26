import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxlift/data/db/app_database.dart';
import 'package:oxlift/data/workouts/routine_models.dart';
import 'package:oxlift/data/workouts/routine_repository.dart';
import 'package:oxlift/data/workouts/workout_repository.dart';

void main() {
  late AppDatabase db;
  late RoutineRepository routines;
  late WorkoutRepository workouts;
  late DateTime now;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    routines = RoutineRepository(db);
    now = DateTime(2026, 9, 24, 18); // a Thursday
    workouts = WorkoutRepository(db, clock: () => now);
    await db.batch((b) => b.insertAll(db.exercises, [
          for (final (id, name) in [('bench', 'bench press'), ('squat', 'squat'), ('row', 'barbell row')])
            ExercisesCompanion.insert(
              id: id,
              name: name,
              gifUrl: '',
              bodyParts: const [],
              equipments: const [],
              targetMuscles: const [],
              secondaryMuscles: const [],
              instructions: const [],
            ),
        ]));
  });

  tearDown(() => db.close());

  RoutineDraft pushDay() => RoutineDraft(name: ' Push day ', exercises: [
        DraftExercise(exerciseId: 'bench', restSeconds: 120, sets: const [
          DraftSet(type: SetType.warmup, reps: 10, weightKg: 40),
          DraftSet(reps: 5, weightKg: 80),
        ]),
        DraftExercise(exerciseId: 'row', sets: const [DraftSet(reps: 8)]),
      ]);

  group('routines', () {
    test('save and load round-trips, trimming the name', () async {
      final id = await routines.save(pushDay());
      final loaded = await routines.load(id);
      expect(loaded.name, 'Push day');
      expect(loaded.exercises.map((e) => e.exerciseId), ['bench', 'row']);
      expect(loaded.exercises.first.restSeconds, 120);
      expect(loaded.exercises.first.sets,
          const [DraftSet(type: SetType.warmup, reps: 10, weightKg: 40), DraftSet(reps: 5, weightKg: 80)]);
    });

    test('re-saving replaces children instead of duplicating them', () async {
      final id = await routines.save(pushDay());
      final draft = await routines.load(id);
      await routines.save(draft.copyWith(exercises: draft.exercises.reversed.toList()));
      final reloaded = await routines.load(id);
      expect(reloaded.exercises.map((e) => e.exerciseId), ['row', 'bench']);
      expect(await db.select(db.routineSets).get(), hasLength(3));
    });

    test('list summaries include names and set counts', () async {
      await routines.save(pushDay());
      await routines.save(RoutineDraft(name: 'Legs', exercises: [DraftExercise(exerciseId: 'squat')]));
      final list = await routines.watchRoutines().first;
      expect(list.map((r) => r.routine.name), ['Push day', 'Legs']);
      expect(list.first.exerciseNames, ['bench press', 'barbell row']);
      expect(list.first.setCount, 3);
      expect(list.last.setCount, 3); // default draft has 3 sets
    });

    test('planned body-part counts: distinct exercises across routines', () async {
      Future<void> setParts(String id, List<String> parts) =>
          (db.update(db.exercises)..where((e) => e.id.equals(id)))
              .write(ExercisesCompanion(bodyParts: Value(parts)));
      await setParts('bench', ['chest']);
      await setParts('row', ['back']);
      await setParts('squat', ['upper legs', 'back']); // counts toward both

      expect(await routines.watchPlannedBodyPartCounts().first, isEmpty);

      await routines.save(pushDay()); // bench + row
      await routines.save(RoutineDraft(name: 'Legs', exercises: [
        DraftExercise(exerciseId: 'squat'),
        DraftExercise(exerciseId: 'bench'), // repeated across routines
      ]));
      expect(await routines.watchPlannedBodyPartCounts().first,
          {'chest': 1, 'back': 2, 'upper legs': 1});
    });

    test('planned exercises for a muscle list their routines', () async {
      await (db.update(db.exercises)..where((e) => e.id.equals('bench')))
          .write(const ExercisesCompanion(bodyParts: Value(['chest'])));
      final push = await routines.save(pushDay()); // bench + row
      final upper = await routines.save(RoutineDraft(name: 'Upper', exercises: [
        DraftExercise(exerciseId: 'bench'),
      ]));

      final chest = await routines.watchPlannedExercises('chest').first;
      expect(chest.single.exercise.id, 'bench');
      expect(chest.single.routines.map((r) => r.id), [push, upper]);
      expect(await routines.watchPlannedExercises('neck').first, isEmpty);
    });

    test('append adds to the end of each routine and skips duplicates', () async {
      final push = await routines.save(pushDay()); // bench, row
      final legs = await routines.save(
          RoutineDraft(name: 'Legs', exercises: [DraftExercise(exerciseId: 'squat')]));

      final added = await routines.appendExercises(
        routineIds: [push, legs],
        exerciseIds: ['squat', 'bench'],
        sets: {
          'bench': const [DraftSet(reps: 8, weightKg: 60)],
        },
      );

      expect(added, {push: ['squat'], legs: ['bench']});
      final pushDraft = await routines.load(push);
      expect(pushDraft.exercises.map((e) => e.exerciseId), ['bench', 'row', 'squat']);
      final legsDraft = await routines.load(legs);
      expect(legsDraft.exercises.map((e) => e.exerciseId), ['squat', 'bench']);
      expect(legsDraft.exercises.last.sets, const [DraftSet(reps: 8, weightKg: 60)]);
      // Squat had no provided sets: three empty ones.
      expect(pushDraft.exercises.last.sets, hasLength(3));
    });

    test('delete cascades to exercises and sets', () async {
      final id = await routines.save(pushDay());
      await routines.delete(id);
      expect(await db.select(db.routineExercises).get(), isEmpty);
      expect(await db.select(db.routineSets).get(), isEmpty);
    });

    test('duplicate copies everything under a new name', () async {
      final id = await routines.save(pushDay());
      final copyId = await routines.duplicate(id, name: 'Push day (copy)');
      final copy = await routines.load(copyId);
      expect(copyId, isNot(id));
      expect(copy.name, 'Push day (copy)');
      expect(copy.exercises.first.sets, (await routines.load(id)).exercises.first.sets);
    });
  });

  group('workouts', () {
    test('starting from a routine copies exercises, targets and rest', () async {
      final routineId = await routines.save(pushDay());
      final id = await workouts.startFromRoutine(routineId);
      final w = (await workouts.watchWorkout(id).first)!;
      expect(w.workout.name, 'Push day');
      expect(w.exercises.map((e) => e.exercise?.name), ['bench press', 'barbell row']);
      expect(w.exercises.first.entry.restSeconds, 120);
      expect(w.exercises.first.sets.map((s) => (s.setType, s.weightKg, s.reps)),
          [(SetType.warmup, 40.0, 10), (SetType.working, 80.0, 5)]);
    });

    test('only one workout can be active', () async {
      final a = await workouts.startEmpty(name: 'Workout');
      final b = await workouts.startEmpty(name: 'Another');
      expect(b, a);
      expect((await workouts.active())!.id, a);
    });

    test('add set copies the previous set', () async {
      final id = await workouts.startEmpty(name: 'W');
      await workouts.addExercises(id, ['bench']);
      var w = (await workouts.watchWorkout(id).first)!;
      final set = w.exercises.single.sets.single;
      await workouts.updateSet(set.id, weightKg: const Value(60), reps: const Value(8));
      await workouts.addSet(w.exercises.single.entry.id);
      w = (await workouts.watchWorkout(id).first)!;
      expect(w.exercises.single.sets.map((s) => (s.position, s.weightKg, s.reps)),
          [(0, 60.0, 8), (1, 60.0, 8)]);
    });

    test('completing an empty set uses the fallback values', () async {
      final id = await workouts.startEmpty(name: 'W');
      await workouts.addExercises(id, ['squat']);
      final set = (await workouts.watchWorkout(id).first)!.exercises.single.sets.single;
      await workouts.setCompleted(set, true, fallbackWeightKg: 100, fallbackReps: 5);
      final done = (await workouts.watchWorkout(id).first)!.exercises.single.sets.single;
      expect((done.completed, done.weightKg, done.reps, done.completedAt), (true, 100.0, 5, now));
    });

    test('finish drops unticked sets and empty exercises', () async {
      final id = await workouts.startFromRoutine(await routines.save(pushDay()));
      var w = (await workouts.watchWorkout(id).first)!;
      await workouts.setCompleted(w.exercises.first.sets.last, true);

      expect(await workouts.finish(id), isTrue);
      w = (await workouts.watchWorkout(id).first)!;
      expect(w.workout.finishedAt, now);
      expect(w.exercises, hasLength(1));
      expect(w.exercises.single.sets.single.weightKg, 80);
      expect(await workouts.active(), isNull);
    });

    test('finish refuses when nothing was completed', () async {
      final id = await workouts.startFromRoutine(await routines.save(pushDay()));
      expect(await workouts.finish(id), isFalse);
      expect((await workouts.active())?.id, id);
    });

    test('discard deletes the workout and its sets', () async {
      final id = await workouts.startFromRoutine(await routines.save(pushDay()));
      await workouts.discard(id);
      expect(await db.select(db.workouts).get(), isEmpty);
      expect(await db.select(db.workoutSets).get(), isEmpty);
    });

    test('previous sets come from the latest finished workout', () async {
      Future<void> logBench(double kg, DateTime at) async {
        now = at;
        final id = await workouts.startEmpty(name: 'W');
        await workouts.addExercises(id, ['bench']);
        final set = (await workouts.watchWorkout(id).first)!.exercises.single.sets.single;
        await workouts.updateSet(set.id, weightKg: Value(kg), reps: const Value(5));
        await workouts.setCompleted(set.copyWith(weightKg: Value(kg)), true);
        await workouts.finish(id);
      }

      await logBench(70, DateTime(2026, 9, 20));
      await logBench(75, DateTime(2026, 9, 22));
      final current = await workouts.startEmpty(name: 'Now');

      final prev = await workouts.previousSets('bench', excludeWorkoutId: current);
      expect(prev.single.weightKg, 75);
      expect(await workouts.previousSets('squat'), isEmpty);
    });

    test('week stats: count, volume (no warm-ups) and streak', () async {
      Future<void> logDay(DateTime at) async {
        now = at;
        final id = await workouts.startFromRoutine(await routines.save(pushDay()));
        final sets = (await workouts.watchWorkout(id).first)!.allSets;
        for (final s in sets) {
          await workouts.setCompleted(s, true);
        }
        await workouts.finish(id);
      }

      await logDay(DateTime(2026, 9, 17, 9)); // last week (Thu)
      await logDay(DateTime(2026, 9, 22, 9)); // Tue
      await logDay(DateTime(2026, 9, 23, 9)); // Wed
      now = DateTime(2026, 9, 24, 18); // Thu, rested today

      final stats = await workouts.watchWeekStats().first;
      expect(stats.workouts, 2);
      // Per workout: 80 kg × 5 (warm-up and weightless row excluded).
      expect(stats.volumeKg, 800);
      expect(stats.streakDays, 2); // Tue + Wed, still alive today
    });
  });
}
