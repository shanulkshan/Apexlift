import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxlift/app.dart';
import 'package:oxlift/core/providers.dart';
import 'package:oxlift/data/db/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fakes.dart';

void main() {
  late SharedPreferences prefs;

  Future<void> launch(WidgetTester tester) async {
    prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(DatabaseConnection(
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
        exerciseDbApiProvider.overrideWithValue(fakeApi(pagedExerciseClient([
          [exerciseJson('a', 'barbell bench press')],
        ]))),
      ],
      child: const OxliftApp(),
    ));
    await settle(tester);
  }

  testWidgets('first launch walks through onboarding and saves the profile',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await launch(tester);

    expect(find.text('Welcome to Oxlift'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await settle(tester);

    // About you: male, age +2.
    expect(find.text('About you'), findsOneWidget);
    await tester.tap(find.text('Male'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await settle(tester);
    expect(find.text('27 years'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await settle(tester);

    // Body: weight 70 -> 71 kg (two half-kg steps).
    expect(find.text('Your body'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await settle(tester);
    await tester.tap(find.text('Continue'));
    await settle(tester);

    // Training: intermediate, strength.
    await tester.tap(find.text('Intermediate'));
    await tester.pump();
    await tester.tap(find.text('Get stronger'));
    await settle(tester);
    await tester.tap(find.text("Let's lift"));
    await settle(tester);

    expect(find.text('Ready to lift?'), findsOneWidget);
    expect(prefs.getBool('profile.onboarded'), isTrue);
    expect(prefs.getString('profile.sex'), 'male');
    expect(prefs.getInt('profile.age'), 27);
    expect(prefs.getDouble('profile.weightKg'), 71);
    expect(prefs.getDouble('profile.heightCm'), 170);
    expect(prefs.getString('profile.experience'), 'intermediate');
    expect(prefs.getString('profile.goal'), 'strength');
  });

  testWidgets('skipping keeps defaults and never shows onboarding again',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await launch(tester);
    await tester.tap(find.text('Skip'));
    await settle(tester);

    expect(find.text('Ready to lift?'), findsOneWidget);
    expect(prefs.getBool('profile.onboarded'), isTrue);
    expect(prefs.getDouble('profile.weightKg'), isNull);
  });
}

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}
