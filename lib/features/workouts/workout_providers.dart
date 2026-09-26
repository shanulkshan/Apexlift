import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/workouts/routine_models.dart';
import '../../data/workouts/workout_models.dart';

final routinesProvider = StreamProvider<List<RoutineSummary>>(
  (ref) => ref.watch(routineRepositoryProvider).watchRoutines(),
);

/// Exercises in the user's routines, per body part (Today's muscle grid).
final plannedBodyPartCountsProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(routineRepositoryProvider).watchPlannedBodyPartCounts(),
);

final activeWorkoutProvider = StreamProvider<Workout?>(
  (ref) => ref.watch(workoutRepositoryProvider).watchActive(),
);

final workoutDetailProvider = StreamProvider.family<WorkoutDetail?, int>(
  (ref, id) => ref.watch(workoutRepositoryProvider).watchWorkout(id),
);

/// Sets from the last finished session of an exercise, for the "previous"
/// column. Keyed by (exerciseId, current workout id).
final previousSetsProvider =
    FutureProvider.family<List<WorkoutSet>, (String, int)>(
  (ref, key) => ref
      .watch(workoutRepositoryProvider)
      .previousSets(key.$1, excludeWorkoutId: key.$2),
);

final recentWorkoutsProvider = StreamProvider<List<WorkoutSummary>>(
  (ref) => ref.watch(workoutRepositoryProvider).watchHistory(limit: 5),
);

final weekStatsProvider = StreamProvider<WeekStats>(
  (ref) => ref.watch(workoutRepositoryProvider).watchWeekStats(),
);

// ---- Rest timer -----------------------------------------------------------

class RestTimerState {
  const RestTimerState({required this.endsAt, required this.total});

  final DateTime endsAt;
  final Duration total;

  Duration get remaining {
    final left = endsAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  double get progress => total.inMilliseconds == 0
      ? 0
      : remaining.inMilliseconds / total.inMilliseconds;
}

/// Countdown after a completed set. Null state = idle. Vibrates when done.
class RestTimerController extends Notifier<RestTimerState?> {
  Timer? _ticker;

  @override
  RestTimerState? build() {
    ref.onDispose(() => _ticker?.cancel());
    return null;
  }

  void start(int seconds) {
    if (seconds <= 0) return;
    final total = Duration(seconds: seconds);
    state = RestTimerState(endsAt: DateTime.now().add(total), total: total);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  void adjust(int seconds) {
    final s = state;
    if (s == null) return;
    final endsAt = s.endsAt.add(Duration(seconds: seconds));
    if (!endsAt.isAfter(DateTime.now())) return skip();
    final total = s.total + Duration(seconds: seconds);
    state = RestTimerState(
      endsAt: endsAt,
      total: total < s.remaining ? s.remaining : total,
    );
  }

  void skip() {
    _ticker?.cancel();
    state = null;
  }

  void _tick() {
    final s = state;
    if (s == null) return _ticker?.cancel();
    if (s.remaining == Duration.zero) {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
      skip();
    } else {
      // New instance so listeners rebuild with the fresh remaining time.
      state = RestTimerState(endsAt: s.endsAt, total: s.total);
    }
  }
}

final restTimerProvider =
    NotifierProvider<RestTimerController, RestTimerState?>(
        RestTimerController.new);
