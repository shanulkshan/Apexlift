import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/workouts/routine_models.dart';
import '../../data/training/training_estimates.dart';
import '../profile/user_profile_controller.dart';
import '../settings/settings_controller.dart';

/// Starting sets for newly added exercises, keyed by exercise id.
///
/// If the exercise was logged before, the last session's sets are reused
/// (the most honest starting point). Otherwise sets are suggested from the
/// user's body profile, experience and goal.
Future<Map<String, List<DraftSet>>> defaultSetsFor(
  WidgetRef ref,
  List<String> exerciseIds, {
  int? excludeWorkoutId,
}) async {
  final catalog = await ref.read(exerciseRepositoryProvider).getByIds(exerciseIds);
  final workouts = ref.read(workoutRepositoryProvider);
  final profile = ref.read(userProfileProvider);
  final unit = ref.read(settingsProvider).unit;

  final result = <String, List<DraftSet>>{};
  for (final id in exerciseIds) {
    final previous =
        await workouts.previousSets(id, excludeWorkoutId: excludeWorkoutId);
    if (previous.isNotEmpty) {
      result[id] = [
        for (final s in previous)
          DraftSet(type: s.setType, reps: s.reps, weightKg: s.weightKg),
      ];
      continue;
    }
    final exercise = catalog[id];
    if (exercise == null) {
      result[id] = const [DraftSet(), DraftSet(), DraftSet()];
      continue;
    }
    final s = suggestSets(exercise, profile, unit);
    result[id] = List.filled(s.sets, DraftSet(reps: s.reps, weightKg: s.weightKg));
  }
  return result;
}
