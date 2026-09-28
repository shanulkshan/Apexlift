import 'package:oxlift/data/exercises/exercise_db_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../support/fakes.dart';

void main() {
  test('parses exercises and strips "Step:N" prefixes', () {
    final e = ExerciseDbApi.parseExercise(exerciseJson('a1', 'bench press'));
    expect(e.id.value, 'a1');
    expect(e.name.value, 'bench press');
    expect(e.instructions.value, ['Lie down.', 'Press up.']);
    expect(e.bodyParts.value, ['chest']);
  });

  test('passes the cursor as `after` and reports the next cursor', () async {
    final requests = <Uri>[];
    final api = fakeApi(pagedExerciseClient([
      [exerciseJson('a', 'one')],
      [exerciseJson('b', 'two')],
    ], requests: requests));

    final first = await api.fetchPage();
    expect(first.hasNextPage, isTrue);
    expect(first.nextCursor, 'b');
    expect(first.total, 2);

    final second = await api.fetchPage(after: first.nextCursor);
    expect(second.hasNextPage, isFalse);
    expect(second.items.single.id.value, 'b');
    expect(requests.first.queryParameters.containsKey('after'), isFalse);
    expect(requests.last.queryParameters['after'], 'b');
    expect(requests.last.queryParameters['limit'], '25');
  });

  test('retries when rate limited, then succeeds', () async {
    var calls = 0;
    final ok = pagedExerciseClient([
      [exerciseJson('a', 'one')],
    ]);
    final api = fakeApi(MockClient((req) async {
      calls++;
      return calls < 3 ? http.Response('slow down', 429) : ok.get(req.url);
    }));

    final page = await api.fetchPage();
    expect(calls, 3);
    expect(page.items, hasLength(1));
  });

  test('does not retry client errors', () async {
    var calls = 0;
    final api = fakeApi(MockClient((_) async {
      calls++;
      return http.Response('nope', 404);
    }));

    await expectLater(api.fetchPage(), throwsA(isA<ExerciseDbException>()));
    expect(calls, 1);
  });
}
