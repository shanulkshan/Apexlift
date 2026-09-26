import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_nav_bar.dart';
import '../../l10n/app_localizations.dart';
import '../library/library_providers.dart';
import '../workouts/widgets/workout_widgets.dart';
import '../workouts/workout_providers.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    // Fetch the exercise catalog in the background on first launch (and
    // resume it if a previous download was interrupted).
    Future.microtask(() => ref.read(catalogSyncProvider.notifier).sync());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shell = widget.navigationShell;
    return Scaffold(
      extendBody: true, // content scrolls behind the floating glass bar
      body: shell,
      bottomNavigationBar: GlassNavBar(
        header: const _ActiveWorkoutBanner(),
        selectedIndex: shell.currentIndex,
        onSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        items: [
          GlassNavItem(
            icon: Icons.bolt_outlined,
            selectedIcon: Icons.bolt_rounded,
            label: l10n.navToday,
          ),
          GlassNavItem(
            icon: Icons.menu_book_outlined,
            selectedIcon: Icons.menu_book_rounded,
            label: l10n.navLibrary,
          ),
          GlassNavItem(
            icon: Icons.fitness_center_outlined,
            selectedIcon: Icons.fitness_center_rounded,
            label: l10n.navWorkouts,
          ),
          GlassNavItem(
            icon: Icons.insights_outlined,
            selectedIcon: Icons.insights_rounded,
            label: l10n.navProgress,
          ),
          GlassNavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}

/// "Workout in progress" pill above the tab bar; tap to resume.
class _ActiveWorkoutBanner extends ConsumerWidget {
  const _ActiveWorkoutBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final active = ref.watch(activeWorkoutProvider).value;
    final dark = theme.brightness == Brightness.dark;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: active == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Glass(
                blur: true,
                radius: 22,
                tint: AppColors.volt,
                tintStrength: dark ? 0.22 : 0.45,
                padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                onTap: () => context.push(AppRoutes.workout),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center_rounded,
                      size: 20,
                      color: dark ? AppColors.volt : AppColors.ink,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        active.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    ElapsedClock(
                      start: active.startedAt,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        child: Text(
                          l10n.workoutsResume,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
