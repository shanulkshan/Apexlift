import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/db/app_database.dart';
import '../data/exercises/exercise_db_api.dart';
import '../data/exercises/exercise_repository.dart';
import '../data/workouts/routine_repository.dart';
import '../data/workouts/workout_repository.dart';

/// Overridden in `main()` with the instance loaded before `runApp`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final exerciseDbApiProvider = Provider<ExerciseDbApi>((ref) => ExerciseDbApi());

/// Disk cache for exercise animations. Sized for the whole catalog and kept
/// for a year so the library works offline once each GIF has been viewed.
final gifCacheManagerProvider = Provider<BaseCacheManager>(
  (ref) => CacheManager(Config(
    'exerciseGifs',
    stalePeriod: const Duration(days: 365),
    maxNrOfCacheObjects: 2500,
  )),
);

final routineRepositoryProvider =
    Provider<RoutineRepository>((ref) => RoutineRepository(ref.watch(databaseProvider)));

final workoutRepositoryProvider =
    Provider<WorkoutRepository>((ref) => WorkoutRepository(ref.watch(databaseProvider)));

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => ExerciseRepository(
    ref.watch(databaseProvider),
    ref.watch(exerciseDbApiProvider),
    ref.watch(sharedPreferencesProvider),
  ),
);
