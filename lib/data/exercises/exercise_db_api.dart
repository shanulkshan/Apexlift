import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

import '../db/app_database.dart';

class ExercisePage {
  const ExercisePage({
    required this.items,
    required this.total,
    required this.hasNextPage,
    this.nextCursor,
  });

  final List<ExercisesCompanion> items;
  final int total;
  final bool hasNextPage;
  final String? nextCursor;
}

class ExerciseDbException implements Exception {
  ExerciseDbException(this.message);
  final String message;
  @override
  String toString() => 'ExerciseDbException: $message';
}

/// Client for the free ExerciseDB v1 dataset (no API key, 25 items per page).
///
/// The free host is flagged "not for production" by its maintainers. Before
/// launch, point [baseUrl] at a paid plan or our own mirror — nothing else in
/// the app talks to ExerciseDB directly.
class ExerciseDbApi {
  ExerciseDbApi({
    http.Client? client,
    this.baseUrl = 'https://oss.exercisedb.dev/api/v1',
    this.maxAttempts = 4,
    this.retryDelay = const Duration(seconds: 2),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final int maxAttempts;
  final Duration retryDelay;

  static const pageSize = 25;
  static final _stepPrefix = RegExp(r'^Step:\s*\d+\s*');

  Future<ExercisePage> fetchPage({String? after}) async {
    final uri = Uri.parse('$baseUrl/exercises').replace(queryParameters: {
      'limit': '$pageSize',
      'after': ?after,
    });
    final body = await _getJson(uri);
    final meta = body['meta'] as Map<String, dynamic>;
    final data = (body['data'] as List).cast<Map<String, dynamic>>();
    return ExercisePage(
      items: data.map(parseExercise).toList(),
      total: meta['total'] as int,
      hasNextPage: meta['hasNextPage'] as bool,
      nextCursor: meta['nextCursor'] as String?,
    );
  }

  static ExercisesCompanion parseExercise(Map<String, dynamic> json) {
    List<String> list(String key) =>
        ((json[key] as List?) ?? const []).cast<String>();
    return ExercisesCompanion.insert(
      id: json['exerciseId'] as String,
      name: json['name'] as String,
      gifUrl: json['gifUrl'] as String,
      bodyParts: list('bodyParts'),
      equipments: list('equipments'),
      targetMuscles: list('targetMuscles'),
      secondaryMuscles: list('secondaryMuscles'),
      instructions: list('instructions')
          .map((s) => s.replaceFirst(_stepPrefix, '').trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      isCustom: const Value(false),
    );
  }

  /// GET with exponential backoff on rate limiting and server errors.
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    for (var attempt = 1;; attempt++) {
      http.Response? res;
      Object? error;
      try {
        res = await _client.get(uri).timeout(const Duration(seconds: 20));
        if (res.statusCode == 200) {
          return jsonDecode(res.body) as Map<String, dynamic>;
        }
      } on Exception catch (e) {
        error = e;
      }
      final retryable = res == null || res.statusCode == 429 || res.statusCode >= 500;
      if (!retryable || attempt >= maxAttempts) {
        throw ExerciseDbException(
          res != null ? 'HTTP ${res.statusCode} for $uri' : 'Request failed: $error',
        );
      }
      await Future<void>.delayed(retryDelay * (1 << (attempt - 1)));
    }
  }
}
