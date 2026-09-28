import 'package:oxlift/app.dart';
import 'package:oxlift/core/providers.dart';
import 'package:oxlift/core/widgets/glass/glass_controls.dart';
import 'package:oxlift/data/db/app_database.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('downloads the catalog and browses the library', (tester) async {
    SharedPreferences.setMockInitialValues({'profile.onboarded': true});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true, // no pending timers at teardown
    ));
    addTearDown(db.close);
    // Runs first (LIFO): unmount so drift's stream queries are cancelled
    // before the DB closes, even when an expectation fails.
    addTearDown(() => tester.pumpWidget(const SizedBox()));

    // DB and HTTP work is real async, so let it run, then advance past
    // route transitions. (pumpAndSettle would wait forever on the GIF
    // loading spinners.)
    Future<void> settle() async {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
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
    expect(find.text('Ready to lift?'), findsOneWidget);

    await tester.tap(find.text('Library'));
    await settle();
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('Pull Up'), findsOneWidget);
    expect(find.text('2 exercises'), findsOneWidget);

    await tester.tap(find.widgetWithText(GlassChip, 'Back'));
    await settle();
    expect(find.text('Barbell Bench Press'), findsNothing);
    expect(find.text('Pull Up'), findsOneWidget);

    await tester.tap(find.text('Pull Up'));
    await settle();
    await tester.scrollUntilVisible(find.text('Press up.'), 200);
    expect(find.text('How to do it'), findsOneWidget);
    expect(find.text('Lie down.'), findsOneWidget);
  });
}
