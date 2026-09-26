import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxlift/app.dart';
import 'package:oxlift/core/providers.dart';
import 'package:oxlift/data/db/app_database.dart';
import 'package:oxlift/data/workouts/routine_models.dart';
import 'package:oxlift/data/workouts/routine_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fakes.dart';

void main() {
  testWidgets(
      'muscle page lists only planned exercises and adds new ones to chosen routines',
      (tester) async {
    SharedPreferences.setMockInitialValues({'profile.onboarded': true});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ));
    addTearDown(db.close);
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    Future<void> settle() async {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
    }

    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        gifCacheManagerProvider.overrideWithValue(OfflineCacheManager()),
        exerciseDbApiProvider.overrideWithValue(fakeApi(pagedExerciseClient([
          [
            exerciseJson('a', 'barbell bench press'),
            exerciseJson('b', 'pull up', bodyPart: 'back'),
            exerciseJson('c', 'dumbbell fly', equipment: 'dumbbell'),
          ],
        ]))),
      ],
      child: const OxliftApp(),
    ));
    await settle();

    // One routine with the bench press.
    final routines = RoutineRepository(db);
    final pushId = (await tester.runAsync(() => routines.save(RoutineDraft(
          name: 'Push',
          exercises: [DraftExercise(exerciseId: 'a')],
        ))))!;
    await settle();
    expect(find.text('1 exercise planned'), findsOneWidget); // Chest tile

    // Chest page: only the planned exercise, with its routine.
    await tester.tap(find.text('Chest'));
    await settle();
    expect(find.text('1 exercise in your plans'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('Dumbbell Fly'), findsNothing);
    expect(find.widgetWithText(ActionChip, 'Push'), findsOneWidget);

    // Add a chest exercise: picker opens filtered to chest.
    await tester.tap(find.text('Add chest exercises'));
    await settle();
    expect(find.text('Pull Up'), findsNothing);
    await tester.tap(find.text('Dumbbell Fly'));
    await settle();
    await tester.tap(find.text('Add 1 exercise'));
    await settle();

    // Choose the routine.
    expect(find.text('Add to which routines?'), findsOneWidget);
    await tester.tap(find.text('Push').last);
    await settle();
    await tester.tap(find.text('Add to 1 routine'));
    await settle();

    expect(find.text('Added to Push'), findsOneWidget);
    expect(find.text('2 exercises in your plans'), findsOneWidget);
    expect(find.text('Dumbbell Fly'), findsOneWidget);

    final draft = (await tester.runAsync(() => routines.load(pushId)))!;
    expect(draft.exercises.map((e) => e.exerciseId), ['a', 'c']);
    // New exercise got suggested dumbbell sets (not blank).
    expect(draft.exercises.last.sets.first.weightKg, isNotNull);
    expect(draft.exercises.last.sets.first.reps, 10);
  });
}
