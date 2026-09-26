import 'package:oxlift/data/db/app_database.dart';
import 'package:oxlift/data/exercises/exercise_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fakes.dart';

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  final pages = [
    [
      exerciseJson('a', 'barbell bench press'),
      exerciseJson('b', 'dumbbell bench press', equipment: 'dumbbell'),
    ],
    [
      exerciseJson('c', 'barbell squat', bodyPart: 'upper legs'),
      exerciseJson('d', 'pull up', bodyPart: 'back', equipment: 'body weight'),
    ],
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  ExerciseRepository repo(http.Client client) =>
      ExerciseRepository(db, fakeApi(client), prefs)..pageDelay = Duration.zero;

  ExerciseFilter filter({String query = '', String? bodyPart, String? equipment}) =>
      (query: query, bodyPart: bodyPart, equipment: equipment);

  test('syncs every page, reports progress, and marks the catalog complete', () async {
    final r = repo(pagedExerciseClient(pages));

    final progress = await r.syncCatalog().map((p) => (p.done, p.total)).toList();

    expect(progress, [(2, 4), (4, 4)]);
    expect(r.isCatalogComplete, isTrue);
    expect(await r.watchExercises(filter()).first, hasLength(4));
  });

  test('skips the network once complete', () async {
    await repo(pagedExerciseClient(pages)).syncCatalog().drain<void>();

    var calls = 0;
    final r = repo(MockClient((_) async {
      calls++;
      return http.Response('', 500);
    }));
    await r.syncCatalog().drain<void>();
    expect(calls, 0);
  });

  test('resumes from the saved cursor after an interruption', () async {
    final requests = <Uri>[];
    var served = 0;
    final inner = pagedExerciseClient(pages, requests: requests);
    // Second page fails the first time around.
    final flaky = MockClient((req) async {
      if (req.url.queryParameters['after'] != null && served++ == 0) {
        return http.Response('down', 404);
      }
      return inner.get(req.url);
    });

    final r = repo(flaky);
    await expectLater(r.syncCatalog().drain<void>(), throwsA(anything));
    expect(r.isCatalogComplete, isFalse);

    await r.syncCatalog().drain<void>();
    expect(r.isCatalogComplete, isTrue);
    expect(requests.last.queryParameters['after'], 'c');
    expect(await r.watchExercises(filter()).first, hasLength(4));
  });

  group('search and filters', () {
    late ExerciseRepository r;
    setUp(() async {
      r = repo(pagedExerciseClient(pages));
      await r.syncCatalog().drain<void>();
    });

    Future<List<String>> ids(ExerciseFilter f) async =>
        (await r.watchExercises(f).first).map((e) => e.id).toList();

    test('matches every search word, in any order, case-insensitively', () async {
      expect(await ids(filter(query: 'BENCH')), ['a', 'b']);
      expect(await ids(filter(query: 'press dumbbell')), ['b']);
      expect(await ids(filter(query: '100%')), isEmpty);
    });

    test('filters by body part and equipment', () async {
      expect(await ids(filter(bodyPart: 'back')), ['d']);
      expect(await ids(filter(equipment: 'barbell')), ['a', 'c']);
      expect(await ids(filter(bodyPart: 'chest', equipment: 'dumbbell')), ['b']);
    });

    test('results are sorted by name', () async {
      final names = (await r.watchExercises(filter()).first).map((e) => e.name);
      expect(names, [...names]..sort());
    });
  });
}
