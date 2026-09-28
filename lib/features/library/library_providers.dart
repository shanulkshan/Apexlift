import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/exercises/exercise_repository.dart';

// ---- Catalog download -----------------------------------------------------

sealed class CatalogSyncState {
  const CatalogSyncState();
}

class CatalogIdle extends CatalogSyncState {
  const CatalogIdle();
}

class CatalogSyncing extends CatalogSyncState {
  const CatalogSyncing(this.done, this.total);
  final int done;
  final int total;
}

class CatalogReady extends CatalogSyncState {
  const CatalogReady();
}

class CatalogFailed extends CatalogSyncState {
  const CatalogFailed(this.error);
  final Object error;
}

class CatalogSyncController extends Notifier<CatalogSyncState> {
  @override
  CatalogSyncState build() =>
      ref.read(exerciseRepositoryProvider).isCatalogComplete
          ? const CatalogReady()
          : const CatalogIdle();

  Future<void> sync({bool force = false}) async {
    if (state is CatalogSyncing) return;
    if (state is CatalogReady && !force) return;
    state = const CatalogSyncing(0, 0);
    try {
      final repo = ref.read(exerciseRepositoryProvider);
      await for (final p in repo.syncCatalog(force: force)) {
        if (!ref.mounted) return;
        state = CatalogSyncing(p.done, p.total);
      }
      if (ref.mounted) state = const CatalogReady();
    } catch (e) {
      if (ref.mounted) state = CatalogFailed(e);
    }
  }
}

final catalogSyncProvider =
    NotifierProvider<CatalogSyncController, CatalogSyncState>(
        CatalogSyncController.new);

// ---- Library browsing -----------------------------------------------------

class LibraryFilterController extends Notifier<ExerciseFilter> {
  @override
  ExerciseFilter build() => (query: '', bodyPart: null, equipment: null);

  void setQuery(String query) => state = (
        query: query,
        bodyPart: state.bodyPart,
        equipment: state.equipment,
      );

  void setBodyPart(String? bodyPart) => state = (
        query: state.query,
        bodyPart: bodyPart,
        equipment: state.equipment,
      );

  void setEquipment(String? equipment) => state = (
        query: state.query,
        bodyPart: state.bodyPart,
        equipment: equipment,
      );
}

final libraryFilterProvider =
    NotifierProvider<LibraryFilterController, ExerciseFilter>(
        LibraryFilterController.new);

final exerciseListProvider = StreamProvider<List<Exercise>>((ref) {
  final filter = ref.watch(libraryFilterProvider);
  return ref.watch(exerciseRepositoryProvider).watchExercises(filter);
});

/// Exercises matching an arbitrary filter (used by the picker, which keeps
/// its own filter separate from the Library tab's).
final exerciseSearchProvider =
    StreamProvider.autoDispose.family<List<Exercise>, ExerciseFilter>(
  (ref, filter) => ref.watch(exerciseRepositoryProvider).watchExercises(filter),
);

/// Catalog rows for a set of ids, keyed by the ids joined with commas.
final exercisesByIdsProvider =
    StreamProvider.autoDispose.family<Map<String, Exercise>, String>(
  (ref, joinedIds) => ref
      .watch(exerciseRepositoryProvider)
      .watchByIds(joinedIds.isEmpty ? const [] : joinedIds.split(',')),
);

final exerciseCountProvider = StreamProvider<int>(
  (ref) => ref.watch(exerciseRepositoryProvider).watchCount(),
);

final bodyPartCountsProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(exerciseRepositoryProvider).watchBodyPartCounts(),
);

final exerciseProvider = StreamProvider.family<Exercise?, String>(
  (ref, id) => ref.watch(exerciseRepositoryProvider).watchExercise(id),
);

/// Body parts and equipment in the ExerciseDB dataset. Kept static so the
/// filter chips render instantly and offline.
const bodyPartOptions = [
  'chest', 'back', 'shoulders', 'upper arms', 'lower arms',
  'upper legs', 'lower legs', 'waist', 'neck', 'cardio',
];

const equipmentOptions = [
  'barbell', 'dumbbell', 'cable', 'body weight', 'leverage machine',
  'smith machine', 'kettlebell', 'ez barbell', 'band', 'resistance band',
  'medicine ball', 'stability ball', 'bosu ball', 'olympic barbell',
  'trap bar', 'weighted', 'assisted', 'rope', 'roller', 'wheel roller',
  'sled machine', 'stationary bike', 'elliptical machine', 'stepmill machine',
  'skierg machine', 'upper body ergometer', 'tire', 'hammer',
];
