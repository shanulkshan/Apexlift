import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/library/exercise_detail_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/body_edit_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/user_profile_controller.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/shell/home_shell.dart';
import '../../features/today/muscle_plan_screen.dart';
import '../../features/today/today_screen.dart';
import '../../features/workouts/exercise_picker_screen.dart';
import '../../features/workouts/routine_editor_screen.dart';
import '../../features/workouts/workout_screen.dart';
import '../../features/workouts/workout_summary_screen.dart';
import '../../features/workouts/workouts_screen.dart';

abstract final class AppRoutes {
  static const today = '/today';
  static const library = '/library';
  static const workouts = '/workouts';
  static const progress = '/progress';
  static const profile = '/profile';

  // Full-screen routes, shown above the tab bar.
  static const workout = '/workout';
  static const newRoutine = '/routine/new';
  static const pickExercises = '/pick-exercises';
  static const onboarding = '/welcome';
  static const editBody = '/profile-body';

  static String exercise(String id) => '$library/exercise/$id';
  static String muscle(String bodyPart) =>
      '$today/muscle/${Uri.encodeComponent(bodyPart)}';
  static String muscleExercise(String bodyPart, String id) =>
      '${muscle(bodyPart)}/exercise/$id';
  static String pickExercisesFor(String bodyPart) =>
      '$pickExercises?bodyPart=${Uri.encodeQueryComponent(bodyPart)}';
  static String editRoutine(int id) => '/routine/$id';
  static String workoutSummary(int id) => '/workout-summary/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>();
  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: AppRoutes.today,
    // First launch: collect the body profile before anything else.
    redirect: (context, state) {
      final onboarded = ref.read(userProfileProvider).onboarded;
      final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!onboarded && !atOnboarding) return AppRoutes.onboarding;
      if (onboarded && atOnboarding) return AppRoutes.today;
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.today,
              builder: (context, state) => const TodayScreen(),
              routes: [
                GoRoute(
                  path: 'muscle/:part',
                  builder: (context, state) =>
                      MusclePlanScreen(bodyPart: state.pathParameters['part']!),
                  routes: [
                    GoRoute(
                      path: 'exercise/:id',
                      builder: (context, state) =>
                          ExerciseDetailScreen(id: state.pathParameters['id']!),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.library,
              builder: (context, state) => const LibraryScreen(),
              routes: [
                GoRoute(
                  path: 'exercise/:id',
                  builder: (context, state) =>
                      ExerciseDetailScreen(id: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.workouts,
              builder: (context, state) => const WorkoutsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.progress,
              builder: (context, state) => const ProgressScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.editBody,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const BodyEditScreen(),
      ),
      GoRoute(
        path: AppRoutes.workout,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const WorkoutScreen(),
      ),
      GoRoute(
        path: '/workout-summary/:id',
        parentNavigatorKey: rootKey,
        builder: (context, state) => WorkoutSummaryScreen(
            workoutId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.newRoutine,
        parentNavigatorKey: rootKey,
        builder: (context, state) => RoutineEditorScreen(
          initialExerciseIds: (state.extra as List<String>?) ?? const [],
        ),
      ),
      GoRoute(
        path: '/routine/:id',
        parentNavigatorKey: rootKey,
        builder: (context, state) => RoutineEditorScreen(
            routineId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.pickExercises,
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: ExercisePickerScreen(
            initialBodyPart: state.uri.queryParameters['bodyPart'],
          ),
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
