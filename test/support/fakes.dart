import 'dart:convert';

import 'package:oxlift/data/exercises/exercise_db_api.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> exerciseJson(String id, String name,
        {String bodyPart = 'chest', String equipment = 'barbell'}) =>
    {
      'exerciseId': id,
      'name': name,
      'gifUrl': 'https://example.com/$id.gif',
      'bodyParts': [bodyPart],
      'equipments': [equipment],
      'targetMuscles': ['pectorals'],
      'secondaryMuscles': ['triceps'],
      'instructions': ['Step:1 Lie down.', 'Step:2 Press up.'],
    };

/// Serves [pages] of exercises using ExerciseDB's `after` cursor paging.
/// Records every requested URI in [requests].
MockClient pagedExerciseClient(
  List<List<Map<String, dynamic>>> pages, {
  List<Uri>? requests,
}) {
  final total = pages.fold<int>(0, (n, p) => n + p.length);
  return MockClient((req) async {
    requests?.add(req.url);
    final after = req.url.queryParameters['after'];
    final index = after == null
        ? 0
        : pages.indexWhere((p) => p.isNotEmpty && p.first['exerciseId'] == after);
    final page = pages[index];
    final hasNext = index < pages.length - 1;
    return http.Response(
      jsonEncode({
        'success': true,
        'meta': {
          'total': total,
          'hasNextPage': hasNext,
          'nextCursor': hasNext ? pages[index + 1].first['exerciseId'] : null,
        },
        'data': page,
      }),
      200,
    );
  });
}

ExerciseDbApi fakeApi(http.Client client) =>
    ExerciseDbApi(client: client, retryDelay: Duration.zero);

/// Image cache that never touches disk or network (widget tests have no
/// path_provider/sqflite plugins). Every image resolves to an error.
class OfflineCacheManager extends Fake implements BaseCacheManager {
  @override
  Stream<FileResponse> getFileStream(String url,
          {String? key, Map<String, String>? headers, bool withProgress = false}) =>
      Stream.error(const HttpExceptionWithStatus(404, 'offline test'));
}
