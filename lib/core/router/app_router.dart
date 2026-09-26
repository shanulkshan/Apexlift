import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/library/exercise_detail_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/shell/home_shell.dart';
import '../../features/today/today_screen.dart';
import '../../features/workouts/workouts_screen.dart';

abstract final class AppRoutes {
  static const today = '/today';
  static const library = '/library';
  static const workouts = '/workouts';
  static const progress = '/progress';
  static const profile = '/profile';

  static String exercise(String id) => '$library/exercise/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.today,
              builder: (context, state) => const TodayScreen(),
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
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
