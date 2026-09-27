import '../db/app_database.dart';
import '../workouts/routine_models.dart';
import '../workouts/routine_repository.dart';
import 'split_templates.dart';

/// Creates one routine per template day. Exercises missing from [catalog]
/// are skipped (and so are days left empty). [sets] supplies starting sets
/// per exercise id; [dayName] localises the day key. Returns new routine ids.
Future<List<int>> installTemplate(
  SplitTemplate template, {
  required RoutineRepository routines,
  required Map<String, Exercise> catalog,
  required Map<String, List<DraftSet>> sets,
  required String Function(String dayKey) dayName,
}) async {
  final ids = <int>[];
  for (final day in template.days) {
    final exercises = [
      for (final e in day.exercises)
        if (catalog.containsKey(e.id))
          DraftExercise(
            exerciseId: e.id,
            restSeconds: e.rest,
            sets: sets[e.id] ?? const [DraftSet(), DraftSet(), DraftSet()],
          ),
    ];
    if (exercises.isEmpty) continue;
    ids.add(await routines.save(
        RoutineDraft(name: dayName(day.key), exercises: exercises)));
  }
  return ids;
}
