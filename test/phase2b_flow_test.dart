import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxlift/app.dart';
import 'package:oxlift/core/notifications/rest_alerts.dart';
import 'package:oxlift/core/providers.dart';
import 'package:oxlift/core/widgets/glass/glass_nav_bar.dart';
import 'package:oxlift/data/db/app_database.dart';
import 'package:oxlift/data/workouts/routine_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fakes.dart';

void main() {
  late AppDatabase db;

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> launch(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'profile.onboarded': true});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase(DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ));
    addTearDown(db.close);
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        gifCacheManagerProvider.overrideWithValue(OfflineCacheManager()),
        restAlertsProvider.overrideWithValue(const NoopRestAlerts()),
        exerciseDbApiProvider.overrideWithValue(fakeApi(pagedExerciseClient([
          [
            // Full body A of the bundled template.
            exerciseJson('qXTaZnJ', 'barbell full squat', bodyPart: 'upper legs'),
            exerciseJson('EIeI8Vf', 'barbell bench press'),
            exerciseJson('eZyBC3j', 'barbell bent over row', bodyPart: 'back'),
            exerciseJson('A6wtbuL', 'dumbbell standing overhead press',
                bodyPart: 'shoulders', equipment: 'dumbbell'),
            exerciseJson('TFqbd8t', 'crunch floor', bodyPart: 'waist', equipment: 'body weight'),
          ],
        ]))),
      ],
      child: const OxliftApp(),
    ));
    await settle(tester);
  }

  Future<void> openWorkoutsTab(WidgetTester tester) async {
    await tester.tap(find.descendant(
        of: find.byType(GlassNavBar), matching: find.text('Workouts')));
    await settle(tester);
  }

  testWidgets('install a template: routines appear with its exercises', (tester) async {
    await launch(tester);
    await openWorkoutsTab(tester);

    await tester.tap(find.text('Browse workout plans'));
    await settle(tester);
    expect(find.text('Push / Pull / Legs'), findsOneWidget);
    await tester.tap(find.text('Full body'));
    await settle(tester);

    // Only day A's exercises are in this (fake) catalog.
    expect(find.text('Barbell Full Squat'), findsOneWidget);
    await tester.tap(find.text('Add 1 routine'));
    await settle(tester);

    expect(find.text('Full body A'), findsOneWidget);
    final routines = (await tester.runAsync(
        () => RoutineRepository(db).watchRoutines().first))!;
    expect(routines.single.exerciseNames, hasLength(5));
    expect(routines.single.plan.first.restSeconds, 150);
  });

  testWidgets('superset: no rest between linked exercises, rest after the last',
      (tester) async {
    await launch(tester);
    await openWorkoutsTab(tester);
    await tester.tap(find.text('Start empty workout'));
    await settle(tester);

    await tester.tap(find.text('Add exercises'));
    await settle(tester);
    await tester.tap(find.text('Barbell Bench Press'));
    await tester.tap(find.text('Barbell Bent Over Row'));
    await settle(tester);
    await tester.tap(find.text('Add 2 exercises'));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded).first);
    await settle(tester);
    await tester.tap(find.text('Superset with next'));
    await settle(tester);
    expect(find.text('SUPERSET A'), findsNWidgets(2));

    // Each exercise got 3 suggested sets; tick bench set 1: no rest.
    final checks = find.byIcon(Icons.check_rounded);
    await tester.tap(checks.at(0));
    await settle(tester);
    expect(find.text('Skip'), findsNothing);

    // Tick row set 1 (4th check): the round is done, rest starts.
    await tester.tap(checks.at(3));
    await settle(tester);
    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await settle(tester);
  });

  testWidgets('create a custom exercise from the picker and select it', (tester) async {
    await launch(tester);
    await openWorkoutsTab(tester);
    await tester.tap(find.text('Start empty workout'));
    await settle(tester);
    await tester.tap(find.text('Add exercises'));
    await settle(tester);

    await tester.tap(find.text('Create'));
    await settle(tester);
    expect(find.text('New exercise'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Landmine Press');
    await tester.tap(find.text('Shoulders'));
    await settle(tester);
    await tester.tap(find.text('Save'));
    await settle(tester);

    // Back in the picker with the new exercise already selected.
    expect(find.text('Add 1 exercise'), findsOneWidget);
    await tester.tap(find.text('Add 1 exercise'));
    await settle(tester);
    expect(find.text('Landmine Press'), findsOneWidget);

    final custom = (await tester.runAsync(() => (db.select(db.exercises)
          ..where((e) => e.isCustom.equals(true)))
        .get()))!;
    expect(custom.single.name, 'landmine press');
    expect(custom.single.bodyParts, ['shoulders']);
  });
}
