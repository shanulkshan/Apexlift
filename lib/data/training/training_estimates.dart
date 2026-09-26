/// Rough, explainable training estimates: starting weights, workout
/// duration and calories. Deliberately simple heuristics, not science; the
/// goal is a sensible starting point the user then adjusts.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../core/utils/weight.dart';
import '../../features/settings/settings_controller.dart';
import '../db/app_database.dart';
import '../profile/user_profile.dart';

// ---- Exercise classification ---------------------------------------------

enum LoadKind {
  /// Weight is logged (barbell, dumbbell, cable, machine…).
  external,

  /// Moves the lifter's own body; weight field stays empty.
  bodyweight,

  /// Conditioning (bike, rower…); tracked by time, not reps × weight.
  cardio,

  /// Bands, balls, rollers: no meaningful weight to log.
  unloaded,
}

const _barbells = {'barbell', 'ez barbell', 'olympic barbell', 'trap bar'};
const _handWeights = {'dumbbell', 'kettlebell'};
const _machines = {'leverage machine', 'smith machine', 'sled machine', 'cable'};
const _otherLoads = {'weighted', 'medicine ball'};

LoadKind loadKindOf(Exercise e) {
  if (e.bodyParts.contains('cardio')) return LoadKind.cardio;
  final eq = e.equipments.toSet();
  if (eq.any((x) =>
      _barbells.contains(x) ||
      _handWeights.contains(x) ||
      _machines.contains(x) ||
      _otherLoads.contains(x))) {
    return LoadKind.external;
  }
  if (eq.contains('body weight') || eq.contains('assisted')) {
    return LoadKind.bodyweight;
  }
  return LoadKind.unloaded;
}

/// Share of body weight actually moved in a bodyweight exercise.
double bodyweightFraction(Exercise e) {
  final n = e.name.toLowerCase();
  const table = [
    (['pull-up', 'pull up', 'chin-up', 'chin up', 'muscle up'], 1.0),
    (['dip'], 0.9),
    (['burpee'], 0.8),
    (['push-up', 'push up', 'pushup'], 0.65),
    (['squat', 'lunge', 'step-up', 'step up', 'jump'], 0.6),
    (['crunch', 'sit-up', 'sit up', 'plank', 'raise', 'twist', 'bridge'], 0.3),
  ];
  for (final (keys, fraction) in table) {
    if (keys.any(n.contains)) return fraction;
  }
  return 0.5;
}

// ---- Starting-weight suggestions -----------------------------------------

@immutable
class SetSuggestion {
  const SetSuggestion({required this.sets, this.weightKg, this.reps});

  final int sets;
  final double? weightKg;
  final int? reps;
}

/// Working weight as a fraction of body weight for an intermediate male
/// using a barbell, for ~10 reps. First matching keyword wins, so more
/// specific names come first.
const _movementRatios = <(List<String>, double)>[
  (['leg press'], 1.6),
  (['hip thrust'], 1.0),
  (['romanian', 'stiff leg'], 0.8),
  (['deadlift'], 1.0),
  (['hack squat'], 0.9),
  (['front squat'], 0.7),
  (['split squat', 'lunge', 'step-up', 'step up'], 0.4),
  (['squat'], 0.9),
  (['good morning'], 0.4),
  (['glute bridge'], 0.8),
  (['calf'], 0.8),
  (['leg curl'], 0.4),
  (['leg extension'], 0.5),
  (['incline', 'decline'], 0.6),
  (['bench press', 'chest press', 'floor press'], 0.7),
  (['overhead press', 'shoulder press', 'military', 'push press', 'arnold'], 0.45),
  (['pulldown', 'pull-down', 'pull down'], 0.6),
  (['row'], 0.6),
  (['shrug'], 0.8),
  (['pullover'], 0.25),
  (['fly', 'flye', 'crossover'], 0.25),
  (['lateral raise', 'rear delt', 'reverse fly'], 0.1),
  (['front raise', 'upright row'], 0.15),
  (['pushdown', 'push down', 'kickback'], 0.3),
  (['extension', 'skull', 'french press'], 0.25),
  (['curl'], 0.3),
  (['crunch', 'sit-up', 'twist', 'woodchop', 'wood chop'], 0.25),
];

const _largeMuscles = {
  'quads', 'glutes', 'hamstrings', 'lats', 'upper back', 'pectorals',
  'spine', 'traps',
};

double _movementRatio(Exercise e) {
  final n = e.name.toLowerCase();
  for (final (keys, ratio) in _movementRatios) {
    if (keys.any(n.contains)) return ratio;
  }
  final target = e.targetMuscles.firstOrNull ?? '';
  if (target == 'abs') return 0.15;
  return _largeMuscles.contains(target) ? 0.5 : 0.2;
}

double _equipmentFactor(Set<String> eq) {
  if (eq.any(_barbells.contains)) return 1.0;
  if (eq.contains('smith machine')) return 0.9;
  if (eq.contains('leverage machine') || eq.contains('sled machine')) return 1.0;
  if (eq.contains('cable')) return 0.7;
  if (eq.any(_handWeights.contains)) return 0.4; // per dumbbell
  if (eq.contains('medicine ball')) return 0.15;
  return 0.3; // weighted vest/plate
}

/// (increment, minimum) in the display unit for rounding suggestions.
(double, double) _rounding(Set<String> eq, WeightUnit unit) {
  final kg = unit == WeightUnit.kg;
  if (eq.any(_barbells.contains)) return kg ? (2.5, 20) : (5, 45);
  if (eq.any(_machines.contains)) return kg ? (5, 5) : (10, 10);
  return kg ? (2, 2) : (5, 5);
}

int _goalReps(TrainingGoal goal) => switch (goal) {
      TrainingGoal.strength => 5,
      TrainingGoal.muscle => 10,
      TrainingGoal.general => 12,
      TrainingGoal.endurance => 15,
    };

/// Default sets/reps/weight for [e], personalised by [profile]. Weight is
/// rounded to real plate or dumbbell steps in [unit], and stored in kg.
SetSuggestion suggestSets(Exercise e, UserProfile profile, WeightUnit unit) {
  final kind = loadKindOf(e);
  final goalReps = _goalReps(profile.goal);

  switch (kind) {
    case LoadKind.cardio:
      return const SetSuggestion(sets: 1);
    case LoadKind.unloaded:
      return SetSuggestion(sets: 3, reps: goalReps);
    case LoadKind.bodyweight:
      final scale = switch (profile.experience) {
        Experience.beginner => 0.7,
        Experience.intermediate => 1.0,
        Experience.advanced => 1.4,
      };
      final hard = bodyweightFraction(e) >= 0.9; // pull-ups, dips
      final base = hard ? math.min(goalReps, 8) : goalReps;
      return SetSuggestion(sets: 3, reps: math.max(3, (base * scale).round()));
    case LoadKind.external:
      break;
  }

  final experience = switch (profile.experience) {
    Experience.beginner => 0.6,
    Experience.intermediate => 1.0,
    Experience.advanced => 1.35,
  };
  final sex = switch (profile.sex) {
    Sex.male => 1.0,
    Sex.female => 0.65,
    Sex.unspecified => 0.85,
  };
  final age = profile.age == null
      ? 1.0
      : profile.age! < 18
          ? 0.8
          : profile.age! >= 60
              ? 0.75
              : profile.age! >= 50
                  ? 0.9
                  : 1.0;
  final repsFactor = switch (profile.goal) {
    TrainingGoal.strength => 1.15,
    TrainingGoal.muscle => 1.0,
    TrainingGoal.general => 0.9,
    TrainingGoal.endurance => 0.8,
  };
  final eq = e.equipments.toSet();

  final rawKg = profile.bodyWeightKg *
      _movementRatio(e) *
      _equipmentFactor(eq) *
      experience *
      sex *
      age *
      repsFactor;

  final (step, minimum) = _rounding(eq, unit);
  final inUnit = math.max(minimum, (unit.fromKg(rawKg) / step).round() * step);
  return SetSuggestion(sets: 3, reps: goalReps, weightKg: unit.toKg(inUnit.toDouble()));
}

// ---- Duration & calories --------------------------------------------------

@immutable
class PlannedSet {
  const PlannedSet({this.type = SetType.working, this.weightKg, this.reps});

  final SetType type;
  final double? weightKg;
  final int? reps;
}

@immutable
class PlannedExercise {
  const PlannedExercise({
    required this.exercise,
    required this.restSeconds,
    required this.sets,
  });

  /// Null when the catalog entry is missing; treated as a generic lift.
  final Exercise? exercise;
  final int restSeconds;
  final List<PlannedSet> sets;
}

@immutable
class WorkoutEstimate {
  const WorkoutEstimate({required this.duration, required this.kcal});

  static const zero = WorkoutEstimate(duration: Duration.zero, kcal: 0);

  final Duration duration;
  final double kcal;
}

const _liftMet = 5.0; // vigorous resistance training while under load
const _cardioMet = 7.0;
const _restMet = 1.8; // standing, walking between sets
const _transitionSeconds = 45; // moving between exercises

/// kcal of metabolic energy per kg lifted per rep: ~0.5 m of travel at
/// ~20 % muscular efficiency (9.81 × 0.5 / 0.2 / 4184).
const _kcalPerKgRep = 0.00586;
const _afterburn = 1.1; // modest EPOC allowance

int _workSeconds(PlannedSet s, LoadKind kind) {
  if (kind == LoadKind.cardio) return 60;
  final reps = s.reps;
  if (reps == null || reps <= 0) return 40;
  return math.min(120, 10 + reps * 3); // setup + ~3 s per rep
}

double _setLoadKcal(PlannedSet s, Exercise? e, LoadKind kind, double bodyKg) {
  final reps = s.reps ?? 0;
  if (reps <= 0) return 0;
  final load = switch (kind) {
    LoadKind.external => () {
        final w = s.weightKg ?? 0;
        final eq = e?.equipments ?? const <String>[];
        final name = e?.name.toLowerCase() ?? '';
        // Dumbbell weights are logged per hand; most moves use two.
        final twoHands = eq.any(_handWeights.contains) &&
            !name.contains('one arm') &&
            !name.contains('single');
        return twoHands ? w * 2 : w;
      }(),
    LoadKind.bodyweight => bodyKg * (e == null ? 0.5 : bodyweightFraction(e)),
    _ => 0.0,
  };
  return load * reps * _kcalPerKgRep;
}

double _kcal(double met, double bodyKg, int seconds) =>
    met * bodyKg * seconds / 3600;

/// Expected duration and calories for doing every set in [plan].
WorkoutEstimate estimatePlan(List<PlannedExercise> plan, UserProfile profile) {
  final body = profile.bodyWeightKg;
  final exercises = plan.where((e) => e.sets.isNotEmpty).toList();
  if (exercises.isEmpty) return WorkoutEstimate.zero;

  var seconds = 0;
  var kcal = 0.0;
  final totalSets = exercises.fold<int>(0, (n, e) => n + e.sets.length);
  var setIndex = 0;

  for (final e in exercises) {
    final kind = e.exercise == null ? LoadKind.external : loadKindOf(e.exercise!);
    for (final s in e.sets) {
      setIndex++;
      final work = _workSeconds(s, kind);
      seconds += work;
      kcal += _kcal(kind == LoadKind.cardio ? _cardioMet : _liftMet, body, work);
      kcal += _setLoadKcal(s, e.exercise, kind, body);
      if (setIndex < totalSets) {
        seconds += e.restSeconds;
        kcal += _kcal(_restMet, body, e.restSeconds);
      }
    }
  }
  final transitions = (exercises.length - 1) * _transitionSeconds;
  seconds += transitions;
  kcal += _kcal(_restMet, body, transitions);

  return WorkoutEstimate(duration: Duration(seconds: seconds), kcal: kcal * _afterburn);
}

/// Calories for a (possibly unfinished) session: [completed] holds only the
/// sets actually done; everything else in [elapsed] counts as rest.
double caloriesBurned({
  required List<PlannedExercise> completed,
  required Duration elapsed,
  required UserProfile profile,
}) {
  final body = profile.bodyWeightKg;
  var workSeconds = 0;
  var kcal = 0.0;
  for (final e in completed) {
    final kind = e.exercise == null ? LoadKind.external : loadKindOf(e.exercise!);
    for (final s in e.sets) {
      final work = _workSeconds(s, kind);
      workSeconds += work;
      kcal += _kcal(kind == LoadKind.cardio ? _cardioMet : _liftMet, body, work);
      kcal += _setLoadKcal(s, e.exercise, kind, body);
    }
  }
  final restSeconds = math.max(0, elapsed.inSeconds - workSeconds);
  kcal += _kcal(_restMet, body, restSeconds);
  return kcal * _afterburn;
}

/// Calories rounded to 5 for display ("~215 kcal").
int roundKcal(double kcal) => (kcal / 5).round() * 5;
