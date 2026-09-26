import 'package:flutter_test/flutter_test.dart';
import 'package:oxlift/core/utils/weight.dart';
import 'package:oxlift/data/db/app_database.dart';
import 'package:oxlift/data/profile/user_profile.dart';
import 'package:oxlift/data/training/training_estimates.dart';
import 'package:oxlift/features/settings/settings_controller.dart';

Exercise ex(String name, List<String> equipment,
        {String bodyPart = 'chest', String target = 'pectorals'}) =>
    Exercise(
      id: name,
      name: name,
      gifUrl: '',
      bodyParts: [bodyPart],
      equipments: equipment,
      targetMuscles: [target],
      secondaryMuscles: const [],
      instructions: const [],
      isCustom: false,
    );

void main() {
  const man80 = UserProfile(
    sex: Sex.male,
    age: 28,
    weightKg: 80,
    experience: Experience.intermediate,
    goal: TrainingGoal.muscle,
  );

  group('classification', () {
    test('load kinds', () {
      expect(loadKindOf(ex('barbell bench press', ['barbell'])), LoadKind.external);
      expect(loadKindOf(ex('push-up', ['body weight'])), LoadKind.bodyweight);
      expect(loadKindOf(ex('air bike', ['body weight'], bodyPart: 'cardio')), LoadKind.cardio);
      expect(loadKindOf(ex('band pull apart', ['band'])), LoadKind.unloaded);
    });
  });

  group('suggestions', () {
    test('barbell bench for an 80 kg intermediate man: 55 kg x 10', () {
      final s = suggestSets(ex('barbell bench press', ['barbell']), man80, WeightUnit.kg);
      expect((s.sets, s.reps, s.weightKg), (3, 10, 55.0)); // 80 × 0.7 = 56 → 55
    });

    test('dumbbells are per hand and round to 2 kg steps', () {
      final s = suggestSets(ex('dumbbell bench press', ['dumbbell']), man80, WeightUnit.kg);
      expect(s.weightKg, 22); // 56 × 0.4 = 22.4
    });

    test('beginners, women and older lifters start lighter', () {
      final base = suggestSets(ex('barbell full squat', ['barbell'], target: 'quads'), man80, WeightUnit.kg).weightKg!;
      final beginner = suggestSets(ex('barbell full squat', ['barbell'], target: 'quads'),
          man80.copyWith(experience: Experience.beginner), WeightUnit.kg).weightKg!;
      final woman = suggestSets(ex('barbell full squat', ['barbell'], target: 'quads'),
          man80.copyWith(sex: Sex.female, weightKg: () => 60), WeightUnit.kg).weightKg!;
      expect(beginner, lessThan(base));
      expect(woman, lessThan(beginner));
    });

    test('never below an empty bar, and rounds in lb for lb users', () {
      final tiny = const UserProfile(weightKg: 40, experience: Experience.beginner, sex: Sex.female);
      final s = suggestSets(ex('barbell curl', ['barbell'], target: 'biceps'), tiny, WeightUnit.kg);
      expect(s.weightKg, 20);
      final lb = suggestSets(ex('barbell bench press', ['barbell']), man80, WeightUnit.lb);
      final inLb = WeightUnit.lb.fromKg(lb.weightKg!);
      expect(inLb % 5, closeTo(0, 1e-6));
    });

    test('goal changes reps; strength goes heavier', () {
      final strength = suggestSets(ex('barbell bench press', ['barbell']),
          man80.copyWith(goal: TrainingGoal.strength), WeightUnit.kg);
      expect(strength.reps, 5);
      expect(strength.weightKg, greaterThan(55));
    });

    test('bodyweight has no weight and scales reps by experience', () {
      final pushUp = ex('push-up', ['body weight']);
      expect(suggestSets(pushUp, man80, WeightUnit.kg).weightKg, isNull);
      final beginner = suggestSets(pushUp, man80.copyWith(experience: Experience.beginner), WeightUnit.kg);
      expect(beginner.reps, 7);
      // Pull-ups are hard: capped lower.
      expect(suggestSets(ex('pull up', ['body weight'], bodyPart: 'back'), man80, WeightUnit.kg).reps, 8);
    });

    test('cardio: one set, no reps or weight', () {
      final s = suggestSets(ex('air bike', ['body weight'], bodyPart: 'cardio'), man80, WeightUnit.kg);
      expect((s.sets, s.reps, s.weightKg), (1, null, null));
    });

    test('unknown profile still gives a sensible number', () {
      final s = suggestSets(ex('barbell bench press', ['barbell']), const UserProfile(), WeightUnit.kg);
      expect(s.weightKg, inInclusiveRange(20, 40));
    });
  });

  group('estimates', () {
    PlannedExercise bench({double kg = 60, int reps = 10, int sets = 3, int rest = 90}) => PlannedExercise(
          exercise: ex('barbell bench press', ['barbell']),
          restSeconds: rest,
          sets: List.filled(sets, PlannedSet(weightKg: kg, reps: reps)),
        );

    test('duration counts work, rest between sets and transitions', () {
      final e = estimatePlan([bench(), bench()], man80);
      // 6 sets × 40 s work + 5 rests × 90 s + 1 transition × 45 s
      expect(e.duration, const Duration(seconds: 6 * 40 + 5 * 90 + 45));
    });

    test('a typical hour-long session lands in a realistic range', () {
      final plan = List.generate(6, (_) => bench(sets: 3, rest: 120));
      final e = estimatePlan(plan, man80);
      expect(e.duration.inMinutes, inInclusiveRange(40, 60));
      expect(e.kcal, inInclusiveRange(150, 350));
    });

    test('heavier weights burn more; heavier lifters burn more', () {
      final light = estimatePlan([bench(kg: 40)], man80).kcal;
      final heavy = estimatePlan([bench(kg: 100)], man80).kcal;
      expect(heavy, greaterThan(light));
      final bigger = estimatePlan([bench(kg: 40)], man80.copyWith(weightKg: () => 110)).kcal;
      expect(bigger, greaterThan(light));
    });

    test('empty plan is zero', () {
      expect(estimatePlan(const [], man80).kcal, 0);
    });

    test('burned calories grow with elapsed time and completed sets', () {
      final none = caloriesBurned(completed: const [], elapsed: const Duration(minutes: 10), profile: man80);
      final some = caloriesBurned(completed: [bench()], elapsed: const Duration(minutes: 10), profile: man80);
      expect(none, greaterThan(0));
      expect(some, greaterThan(none));
    });

    test('kcal display rounding', () {
      expect(roundKcal(212.4), 210);
      expect(roundKcal(213), 215);
    });
  });
}
