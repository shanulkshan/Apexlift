import 'package:flutter/foundation.dart';

import '../db/app_database.dart';
import '../training/training_estimates.dart';

/// Editable, in-memory copy of a routine. The editor mutates a draft and
/// [RoutineRepository.save] writes it back in one transaction.
@immutable
class RoutineDraft {
  const RoutineDraft({this.id, this.name = '', this.exercises = const []});

  final int? id;
  final String name;
  final List<DraftExercise> exercises;

  RoutineDraft copyWith({String? name, List<DraftExercise>? exercises}) =>
      RoutineDraft(
        id: id,
        name: name ?? this.name,
        exercises: exercises ?? this.exercises,
      );

  @override
  bool operator ==(Object other) =>
      other is RoutineDraft &&
      other.id == id &&
      other.name == name &&
      listEquals(other.exercises, exercises);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(exercises));
}

@immutable
class DraftExercise {
  DraftExercise({
    required this.exerciseId,
    this.restSeconds = 90,
    this.notes = '',
    this.sets = const [DraftSet(), DraftSet(), DraftSet()],
    int? key,
  }) : key = key ?? _nextKey++;

  static int _nextKey = 0;

  /// Stable identity for list reordering (not persisted).
  final int key;
  final String exerciseId;
  final int restSeconds;
  final String notes;
  final List<DraftSet> sets;

  DraftExercise copyWith({
    int? restSeconds,
    String? notes,
    List<DraftSet>? sets,
  }) =>
      DraftExercise(
        key: key,
        exerciseId: exerciseId,
        restSeconds: restSeconds ?? this.restSeconds,
        notes: notes ?? this.notes,
        sets: sets ?? this.sets,
      );

  @override
  bool operator ==(Object other) =>
      other is DraftExercise &&
      other.key == key &&
      other.exerciseId == exerciseId &&
      other.restSeconds == restSeconds &&
      other.notes == notes &&
      listEquals(other.sets, sets);

  @override
  int get hashCode =>
      Object.hash(key, exerciseId, restSeconds, notes, Object.hashAll(sets));
}

@immutable
class DraftSet {
  const DraftSet({this.type = SetType.working, this.reps, this.weightKg});

  final SetType type;
  final int? reps;
  final double? weightKg;

  DraftSet copyWith({
    SetType? type,
    int? Function()? reps,
    double? Function()? weightKg,
  }) =>
      DraftSet(
        type: type ?? this.type,
        reps: reps != null ? reps() : this.reps,
        weightKg: weightKg != null ? weightKg() : this.weightKg,
      );

  @override
  bool operator ==(Object other) =>
      other is DraftSet &&
      other.type == type &&
      other.reps == reps &&
      other.weightKg == weightKg;

  @override
  int get hashCode => Object.hash(type, reps, weightKg);
}

/// Routine as shown in lists.
@immutable
class RoutineSummary {
  const RoutineSummary({
    required this.routine,
    required this.exerciseNames,
    required this.setCount,
    this.plan = const [],
  });

  final Routine routine;
  final List<String> exerciseNames;
  final int setCount;

  /// Planned sets, for time/calorie estimates.
  final List<PlannedExercise> plan;
}

/// A catalog exercise and the routines that include it.
@immutable
class PlannedExerciseUsage {
  const PlannedExerciseUsage({required this.exercise, required this.routines});

  final Exercise exercise;
  final List<Routine> routines;
}

extension DraftPlan on RoutineDraft {
  /// The draft as an estimator plan; [catalog] supplies exercise details.
  List<PlannedExercise> toPlan(Map<String, Exercise> catalog) => [
        for (final e in exercises)
          PlannedExercise(
            exercise: catalog[e.exerciseId],
            restSeconds: e.restSeconds,
            sets: [
              for (final s in e.sets)
                PlannedSet(type: s.type, weightKg: s.weightKg, reps: s.reps),
            ],
          ),
      ];
}
