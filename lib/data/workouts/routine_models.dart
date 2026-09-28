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
    this.supersetGroup,
    int? key,
  }) : key = key ?? _nextKey++;

  static int _nextKey = 0;

  /// Stable identity for list reordering (not persisted).
  final int key;
  final String exerciseId;
  final int restSeconds;
  final String notes;
  final List<DraftSet> sets;
  final int? supersetGroup;

  DraftExercise copyWith({
    int? restSeconds,
    String? notes,
    List<DraftSet>? sets,
    int? Function()? supersetGroup,
  }) =>
      DraftExercise(
        key: key,
        exerciseId: exerciseId,
        restSeconds: restSeconds ?? this.restSeconds,
        notes: notes ?? this.notes,
        sets: sets ?? this.sets,
        supersetGroup:
            supersetGroup != null ? supersetGroup() : this.supersetGroup,
      );

  @override
  bool operator ==(Object other) =>
      other is DraftExercise &&
      other.key == key &&
      other.exerciseId == exerciseId &&
      other.restSeconds == restSeconds &&
      other.notes == notes &&
      other.supersetGroup == supersetGroup &&
      listEquals(other.sets, sets);

  @override
  int get hashCode => Object.hash(
      key, exerciseId, restSeconds, notes, supersetGroup, Object.hashAll(sets));
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

/// Keeps superset groups valid: a group must be a run of 2+ adjacent
/// exercises. Anything else is cleared, and groups are renumbered 1..n in
/// order. Run after every reorder/link/unlink/remove.
List<int?> normalizeSupersetGroups(List<int?> groups) {
  final out = List<int?>.filled(groups.length, null);
  var next = 0;
  var i = 0;
  while (i < groups.length) {
    final g = groups[i];
    if (g == null) {
      i++;
      continue;
    }
    var j = i;
    while (j + 1 < groups.length && groups[j + 1] == g) {
      j++;
    }
    if (j > i) {
      next++;
      for (var k = i; k <= j; k++) {
        out[k] = next;
      }
    }
    i = j + 1;
  }
  return out;
}

/// "A", "B", … for superset group numbers (1-based).
String supersetLetter(int group) => String.fromCharCode(64 + ((group - 1) % 26) + 1);

extension DraftSupersets on RoutineDraft {
  RoutineDraft withNormalizedSupersets() {
    final groups =
        normalizeSupersetGroups([for (final e in exercises) e.supersetGroup]);
    return copyWith(exercises: [
      for (final (i, e) in exercises.indexed)
        e.supersetGroup == groups[i] ? e : e.copyWith(supersetGroup: () => groups[i]),
    ]);
  }

  /// Links exercise [index] with the one after it (joining existing groups).
  RoutineDraft linkWithNext(int index) {
    if (index + 1 >= exercises.length) return this;
    final list = [...exercises];
    final group = list[index].supersetGroup ??
        list[index + 1].supersetGroup ??
        (list.map((e) => e.supersetGroup ?? 0).fold(0, (a, b) => a > b ? a : b) + 1);
    final old = list[index + 1].supersetGroup;
    for (var i = 0; i < list.length; i++) {
      final joins = i == index ||
          i == index + 1 ||
          (old != null && list[i].supersetGroup == old);
      if (joins) list[i] = list[i].copyWith(supersetGroup: () => group);
    }
    return copyWith(exercises: list).withNormalizedSupersets();
  }

  /// Takes exercise [index] out of its superset.
  RoutineDraft unlink(int index) {
    final list = [...exercises];
    list[index] = list[index].copyWith(supersetGroup: () => null);
    // Splitting the middle of a run leaves two separate runs.
    final g = exercises[index].supersetGroup;
    if (g != null) {
      final fresh =
          list.map((e) => e.supersetGroup ?? 0).fold(0, (a, b) => a > b ? a : b) + 1;
      for (var i = index + 1; i < list.length && list[i].supersetGroup == g; i++) {
        list[i] = list[i].copyWith(supersetGroup: () => fresh);
      }
    }
    return copyWith(exercises: list).withNormalizedSupersets();
  }
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
