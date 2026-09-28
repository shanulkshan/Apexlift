import 'package:flutter/foundation.dart';

import '../db/app_database.dart';
import '../training/training_estimates.dart';

/// A workout with its exercises and sets, as shown on the live screen.
@immutable
class WorkoutDetail {
  const WorkoutDetail({required this.workout, required this.exercises});

  final Workout workout;
  final List<WorkoutExerciseDetail> exercises;

  Iterable<WorkoutSet> get allSets => exercises.expand((e) => e.sets);
  int get completedSets => allSets.where((s) => s.completed).length;
  double get volumeKg => volumeOf(allSets);

  /// Completed sets only, for calorie counting.
  List<PlannedExercise> get completedPlan => [
        for (final e in exercises)
          PlannedExercise(
            exercise: e.exercise,
            restSeconds: e.entry.restSeconds,
            sets: [
              for (final s in e.sets.where((s) => s.completed))
                PlannedSet(type: s.setType, weightKg: s.weightKg, reps: s.reps),
            ],
          ),
      ];
}

@immutable
class WorkoutExerciseDetail {
  const WorkoutExerciseDetail({
    required this.entry,
    required this.exercise,
    required this.sets,
  });

  final WorkoutExercise entry;

  /// Null if the catalog entry is missing (e.g. not downloaded yet).
  final Exercise? exercise;
  final List<WorkoutSet> sets;
}

/// Finished workout as shown in history lists.
@immutable
class WorkoutSummary {
  const WorkoutSummary({
    required this.workout,
    required this.exerciseCount,
    required this.setCount,
    required this.volumeKg,
    this.completedPlan = const [],
  });

  final Workout workout;
  final int exerciseCount;
  final int setCount;
  final double volumeKg;

  /// Logged sets (all completed once finished), for calorie counting.
  final List<PlannedExercise> completedPlan;

  Duration get duration =>
      (workout.finishedAt ?? DateTime.now()).difference(workout.startedAt);
}

@immutable
class WeekStats {
  const WeekStats({
    required this.workouts,
    required this.volumeKg,
    required this.streakDays,
  });

  static const empty = WeekStats(workouts: 0, volumeKg: 0, streakDays: 0);

  final int workouts;
  final double volumeKg;

  /// Consecutive days with a finished workout, ending today or yesterday.
  final int streakDays;

  @override
  bool operator ==(Object other) =>
      other is WeekStats &&
      other.workouts == workouts &&
      other.volumeKg == volumeKg &&
      other.streakDays == streakDays;

  @override
  int get hashCode => Object.hash(workouts, volumeKg, streakDays);
}

/// Total load moved: weight × reps over completed, non-warm-up sets.
/// Bodyweight sets (no weight) count as zero.
double volumeOf(Iterable<WorkoutSet> sets) => sets
    .where((s) => s.completed && s.setType.countsTowardVolume)
    .fold(0.0, (sum, s) => sum + (s.weightKg ?? 0) * (s.reps ?? 0));
