import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxlift/app.dart';
import 'package:oxlift/core/providers.dart';
import 'package:oxlift/core/widgets/glass/glass_nav_bar.dart';
import 'package:oxlift/data/db/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('log an empty workout end to end, then save it as a routine',
      (tester) async {
    SharedPreferences.setMockInitialValues({'profile.onboarded': true});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ));
    addTearDown(db.close);
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    // Taller surface so the whole workout card fits.
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
          [exerciseJson('a', 'barbell bench press')],
          [exerciseJson('b', 'pull up', bodyPart: 'back')],
        ]))),
      ],
      child: const OxliftApp(),
    ));
    await settle();

    // Workouts tab -> start empty.
    await tester.tap(find.descendant(
        of: find.byType(GlassNavBar), matching: find.text('Workouts')));
    await settle();
    expect(find.text('No routines yet'), findsOneWidget);
    await tester.tap(find.text('Start empty workout'));
    await settle();
    expect(find.text('Add your first exercise to get going.'), findsOneWidget);

    // Pick an exercise.
    await tester.tap(find.text('Add exercises'));
    await settle();
    await tester.tap(find.text('Barbell Bench Press'));
    await settle();
    await tester.tap(find.text('Add 1 exercise'));
    await settle();
    expect(find.text('Barbell Bench Press'), findsOneWidget);

    // New exercise arrives with 3 suggested sets (default profile: 72 kg,
    // beginner, muscle goal -> 25 kg x 10 on a barbell bench).
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(6));
    expect(tester.widget<TextField>(fields.at(0)).controller!.text, '25');
    expect(tester.widget<TextField>(fields.at(1)).controller!.text, '10');

    // Log 60 kg x 8 and tick the set: the rest timer appears.
    await tester.enterText(fields.at(0), '60');
    await tester.enterText(fields.at(1), '8');
    await settle();
    await tester.tap(find.byIcon(Icons.check_rounded).first);
    await settle();
    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await settle();
    expect(find.text('Skip'), findsNothing);

    // Finish -> summary.
    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    await settle();
    await tester.tap(find.widgetWithText(FilledButton, 'Finish').last);
    await settle();
    expect(find.text('Workout complete!'), findsOneWidget);
    expect(find.text('480 kg'), findsOneWidget); // 60 kg x 8
    expect(find.text('Calories'), findsOneWidget);
    expect(find.textContaining('kcal'), findsWidgets);

    final saved = (await db.select(db.workoutSets).get()).single;
    expect((saved.weightKg, saved.reps, saved.completed), (60.0, 8, true));

    await tester.tap(find.text('Save as routine'));
    await settle();
    expect(find.text('Saved to your routines'), findsOneWidget);

    // Back on the Workouts tab: the routine and history entry exist.
    await tester.tap(find.text('Done'));
    await settle();
    expect(find.text('Recent workouts'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget); // routine card's Start button
    expect(find.text('No routines yet'), findsNothing);
  });
}
