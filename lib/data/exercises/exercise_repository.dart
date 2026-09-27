import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/app_database.dart';
import 'exercise_db_api.dart';

typedef ExerciseFilter = ({String query, String? bodyPart, String? equipment});

class CatalogSyncProgress {
  const CatalogSyncProgress(this.done, this.total);
  final int done;
  final int total;
}

class ExerciseRepository {
  ExerciseRepository(this._db, this._api, this._prefs);

  final AppDatabase _db;
  final ExerciseDbApi _api;
  final SharedPreferences _prefs;

  static const _cursorKey = 'catalog.cursor';
  static const _completedKey = 'catalog.completedAt';

  /// Pause between pages so a first-run sync stays polite to the free API.
  Duration pageDelay = const Duration(milliseconds: 250);

  bool get isCatalogComplete => _prefs.getString(_completedKey) != null;

  Stream<List<Exercise>> watchExercises(ExerciseFilter filter) {
    final q = _db.select(_db.exercises);
    final query = filter.query.trim().toLowerCase();
    if (query.isNotEmpty) {
      // Every word must appear somewhere in the name, so "db press" style
      // partial searches still work.
      for (final word in query.split(RegExp(r'\s+'))) {
        q.where((e) => e.name.lower().like('%${_escape(word)}%', escapeChar: r'\'));
      }
    }
    if (filter.bodyPart != null) {
      q.where((e) => e.bodyParts.like('%"${filter.bodyPart}"%'));
    }
    if (filter.equipment != null) {
      q.where((e) => e.equipments.like('%"${filter.equipment}"%'));
    }
    q.orderBy([(e) => OrderingTerm.asc(e.name)]);
    return q.watch();
  }

  Stream<int> watchCount() {
    final count = _db.exercises.id.count();
    return (_db.selectOnly(_db.exercises)..addColumns([count]))
        .watchSingle()
        .map((row) => row.read(count) ?? 0);
  }

  /// Number of exercises per body part (an exercise can count toward
  /// several). Updates live while the catalog downloads.
  Stream<Map<String, int>> watchBodyPartCounts() {
    final column = _db.exercises.bodyParts;
    final q = _db.selectOnly(_db.exercises)..addColumns([column]);
    return q.watch().map((rows) {
      final counts = <String, int>{};
      for (final row in rows) {
        final parts = column.converter.fromSql(row.read(column)!);
        for (final part in parts) {
          counts[part] = (counts[part] ?? 0) + 1;
        }
      }
      return counts;
    });
  }

  Stream<Exercise?> watchExercise(String id) =>
      (_db.select(_db.exercises)..where((e) => e.id.equals(id)))
          .watchSingleOrNull();

  // ---- Custom exercises ---------------------------------------------------

  /// Creates (no [id]) or updates a user-made exercise. Returns its id.
  Future<String> saveCustom({
    String? id,
    required String name,
    required String bodyPart,
    required String equipment,
    String? targetMuscle,
    List<String> instructions = const [],
  }) async {
    final exerciseId = id ?? 'custom-${DateTime.now().microsecondsSinceEpoch}';
    await _db.into(_db.exercises).insertOnConflictUpdate(ExercisesCompanion.insert(
          id: exerciseId,
          name: name.trim().toLowerCase(),
          gifUrl: '',
          bodyParts: [bodyPart],
          equipments: [equipment],
          targetMuscles: [
            (targetMuscle?.trim().isNotEmpty ?? false)
                ? targetMuscle!.trim().toLowerCase()
                : bodyPart,
          ],
          secondaryMuscles: const [],
          instructions: [
            for (final line in instructions)
              if (line.trim().isNotEmpty) line.trim(),
          ],
          isCustom: const Value(true),
        ));
    return exerciseId;
  }

  /// Whether any routine or logged workout uses [id].
  Future<bool> isInUse(String id) async {
    final inRoutine = await (_db.select(_db.routineExercises)
          ..where((t) => t.exerciseId.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (inRoutine != null) return true;
    final inWorkout = await (_db.select(_db.workoutExercises)
          ..where((t) => t.exerciseId.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return inWorkout != null;
  }

  /// Deletes a custom exercise (catalog exercises are never deleted).
  Future<void> deleteCustom(String id) => (_db.delete(_db.exercises)
        ..where((t) => t.id.equals(id) & t.isCustom.equals(true)))
      .go();

  Future<Map<String, Exercise>> getByIds(Iterable<String> ids) async {
    final rows = await (_db.select(_db.exercises)
          ..where((e) => e.id.isIn(ids.toSet())))
        .get();
    return {for (final e in rows) e.id: e};
  }

  Stream<Map<String, Exercise>> watchByIds(Iterable<String> ids) =>
      (_db.select(_db.exercises)..where((e) => e.id.isIn(ids.toSet())))
          .watch()
          .map((rows) => {for (final e in rows) e.id: e});

  /// Downloads the catalog page by page, saving each page as it arrives so
  /// an interrupted sync resumes where it stopped. Emits progress per page.
  Stream<CatalogSyncProgress> syncCatalog({bool force = false}) async* {
    if (force) {
      await _prefs.remove(_cursorKey);
      await _prefs.remove(_completedKey);
    }
    if (isCatalogComplete) return;

    var cursor = _prefs.getString(_cursorKey);
    while (true) {
      final page = await _api.fetchPage(after: cursor);
      await _db.batch((b) => b.insertAllOnConflictUpdate(_db.exercises, page.items));
      final done = await _db.managers.exercises
          .filter((f) => f.isCustom.equals(false))
          .count();
      yield CatalogSyncProgress(done.clamp(0, page.total), page.total);

      if (!page.hasNextPage || page.nextCursor == null) break;
      cursor = page.nextCursor;
      await _prefs.setString(_cursorKey, cursor!);
      await Future<void>.delayed(pageDelay);
    }
    await _prefs.remove(_cursorKey);
    await _prefs.setString(_completedKey, DateTime.now().toIso8601String());
  }

  static String _escape(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
