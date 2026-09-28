import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxlift/data/db/app_database.dart';
import 'package:oxlift/data/exercises/exercise_db_api.dart';
import 'package:oxlift/data/exercises/exercise_repository.dart';
import 'package:oxlift/data/templates/split_templates.dart';
import 'package:oxlift/data/templates/template_installer.dart';
import 'package:oxlift/data/workouts/routine_models.dart';
import 'package:oxlift/data/workouts/routine_repository.dart';
import 'package:oxlift/data/workouts/workout_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('superset groups', () {
    test('normalise keeps only adjacent runs of 2+ and renumbers', () {
      expect(normalizeSupersetGroups([5, 5, null, 7, 3, 3, 3, 9]),
          [1, 1, null, null, 2, 2, 2, null]);
      expect(normalizeSupersetGroups([1, null, 1]), [null, null, null]);
      expect(normalizeSupersetGroups([]), isEmpty);
    });

    RoutineDraft draft(List<int?> groups) => RoutineDraft(exercises: [
          for (final (i, g) in groups.indexed)
            DraftExercise(exerciseId: 'e$i', supersetGroup: g),
        ]);
    List<int?> groupsOf(RoutineDraft d) => [for (final e in d.exercises) e.supersetGroup];

    test('link joins neighbours and merges existing groups', () {
      expect(groupsOf(draft([null, null, null]).linkWithNext(0)), [1, 1, null]);
      expect(groupsOf(draft([1, 1, null]).linkWithNext(1)), [1, 1, 1]);
      expect(groupsOf(draft([1, 1, 2, 2]).linkWithNext(1)), [1, 1, 1, 1]);
      expect(groupsOf(draft([null, null]).linkWithNext(1)), [null, null]); // last
    });

    test('unlink splits runs and drops leftovers of one', () {
      expect(groupsOf(draft([1, 1, 1, 1]).unlink(1)), [null, null, 1, 1]);
      expect(groupsOf(draft([1, 1]).unlink(0)), [null, null]);
      expect(groupsOf(draft([1, 1, 1]).unlink(2)), [1, 1, null]);
    });

    test('letters', () {
      expect([supersetLetter(1), supersetLetter(2), supersetLetter(26)], ['A', 'B', 'Z']);
    });
  });

  group('with a database', () {
    late AppDatabase db;
    late RoutineRepository routines;
    late WorkoutRepository workouts;
    late ExerciseRepository exercises;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase(NativeDatabase.memory());
      routines = RoutineRepository(db);
      workouts = WorkoutRepository(db);
      exercises = ExerciseRepository(
          db, ExerciseDbApi(), await SharedPreferences.getInstance());
      await db.batch((b) => b.insertAll(db.exercises, [
            for (final id in ['a', 'b', 'c', 'd'])
              ExercisesCompanion.insert(
                id: id,
                name: 'exercise $id',
                gifUrl: '',
                bodyParts: const ['chest'],
                equipments: const ['barbell'],
                targetMuscles: const ['pectorals'],
                secondaryMuscles: const [],
                instructions: const [],
              ),
          ]));
    });

    tearDown(() => db.close());

    test('routine supersets persist and carry into workouts', () async {
      final id = await routines.save(RoutineDraft(name: 'SS', exercises: [
        DraftExercise(exerciseId: 'a', supersetGroup: 4),
        DraftExercise(exerciseId: 'b', supersetGroup: 4),
        DraftExercise(exerciseId: 'c', supersetGroup: 9), // lone -> cleared
      ]));
      final loaded = await routines.load(id);
      expect([for (final e in loaded.exercises) e.supersetGroup], [1, 1, null]);

      final w = await workouts.startFromRoutine(id);
      final detail = (await workouts.watchWorkout(w).first)!;
      expect([for (final e in detail.exercises) e.entry.supersetGroup], [1, 1, null]);
    });

    Future<List<(String, int?)>> order(int workoutId) async => [
          for (final e in (await workouts.watchWorkout(workoutId).first)!.exercises)
            (e.entry.exerciseId, e.entry.supersetGroup),
        ];

    test('workout: link, move (breaking the superset) and unlink', () async {
      final w = await workouts.startEmpty(name: 'W');
      await workouts.addExercises(w, ['a', 'b', 'c']);
      var d = (await workouts.watchWorkout(w).first)!;

      await workouts.linkWithNext(d.exercises[0].entry.id);
      expect(await order(w), [('a', 1), ('b', 1), ('c', null)]);

      // Moving c up splits a/b apart: the broken superset is cleared.
      await workouts.moveExercise(d.exercises[2].entry.id, -1);
      expect(await order(w), [('a', null), ('c', null), ('b', null)]);

      d = (await workouts.watchWorkout(w).first)!;
      await workouts.linkWithNext(d.exercises[1].entry.id); // c + b
      await workouts.unlinkSuperset(d.exercises[2].entry.id);
      expect(await order(w), [('a', null), ('c', null), ('b', null)]);
    });

    test('workout: replace swaps the exercise and its sets', () async {
      final w = await workouts.startEmpty(name: 'W');
      await workouts.addExercises(w, ['a']);
      final entry = (await workouts.watchWorkout(w).first)!.exercises.single.entry;

      await workouts.replaceExercise(entry.id, 'd',
          sets: const [DraftSet(reps: 5, weightKg: 100), DraftSet(reps: 5, weightKg: 100)]);
      final e = (await workouts.watchWorkout(w).first)!.exercises.single;
      expect(e.entry.exerciseId, 'd');
      expect(e.sets.map((s) => (s.weightKg, s.reps)), [(100.0, 5), (100.0, 5)]);
    });

    test('custom exercises: create, update, in-use guard, delete', () async {
      final id = await exercises.saveCustom(
        name: '  Landmine Press ',
        bodyPart: 'shoulders',
        equipment: 'barbell',
        instructions: const ['Hold the bar', '', 'Press up'],
      );
      var e = (await exercises.getByIds([id]))[id]!;
      expect(e.name, 'landmine press');
      expect(e.isCustom, isTrue);
      expect(e.targetMuscles, ['shoulders']);
      expect(e.instructions, ['Hold the bar', 'Press up']);

      await exercises.saveCustom(
          id: id, name: 'Landmine press', bodyPart: 'shoulders',
          equipment: 'barbell', targetMuscle: 'Delts');
      e = (await exercises.getByIds([id]))[id]!;
      expect(e.targetMuscles, ['delts']);

      expect(await exercises.isInUse(id), isFalse);
      await routines.save(RoutineDraft(name: 'R', exercises: [DraftExercise(exerciseId: id)]));
      expect(await exercises.isInUse(id), isTrue);

      await exercises.deleteCustom('a'); // catalog rows are protected
      expect((await exercises.getByIds(['a'])), contains('a'));
    });

    test('template install creates a routine per day, skipping unknown ids', () async {
      const template = SplitTemplate(
        key: TemplateKey.upperLower,
        daysPerWeek: 4,
        level: TemplateLevel.beginner,
        days: [
          TemplateDay('upper', [TemplateExercise('a', rest: 150), TemplateExercise('zzz')]),
          TemplateDay('lower', [TemplateExercise('zzz')]), // nothing known
        ],
      );
      final ids = await installTemplate(
        template,
        routines: routines,
        catalog: await exercises.getByIds(template.exerciseIds),
        sets: const {'a': [DraftSet(reps: 8, weightKg: 60)]},
        dayName: (k) => k.toUpperCase(),
      );
      expect(ids, hasLength(1));
      final r = await routines.load(ids.single);
      expect(r.name, 'UPPER');
      expect(r.exercises.single.restSeconds, 150);
      expect(r.exercises.single.sets, const [DraftSet(reps: 8, weightKg: 60)]);
    });
  });

  test('bundled templates have unique days and plausible ids', () {
    for (final t in splitTemplates) {
      expect(t.days, isNotEmpty);
      for (final d in t.days) {
        final ids = d.exercises.map((e) => e.id).toList();
        expect(ids.toSet().length, ids.length, reason: '${t.key}/${d.key} repeats');
        expect(ids.every((id) => RegExp(r'^[A-Za-z0-9]{7}$').hasMatch(id)), isTrue);
      }
    }
  });
}
