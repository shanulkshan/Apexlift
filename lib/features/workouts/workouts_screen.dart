import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/duration.dart';
import '../../core/utils/text.dart';
import '../../core/utils/weight.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_controls.dart';
import '../../core/widgets/glass/glass_nav_bar.dart';
import '../../core/widgets/glass/glass_sheet.dart';
import '../../core/widgets/glass/page_title.dart';
import '../../data/workouts/routine_models.dart';
import '../../data/workouts/workout_models.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_controller.dart';
import '../../data/training/training_estimates.dart';
import '../profile/user_profile_controller.dart';
import 'widgets/workout_widgets.dart';
import 'workout_actions.dart';
import 'workout_providers.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(activeWorkoutProvider).value;
    final routines = ref.watch(routinesProvider).value;
    final recent = ref.watch(recentWorkoutsProvider).value ?? const [];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(bottom: navBarClearance(context)),
          children: [
            PageTitle(title: l10n.navWorkouts),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  if (active != null)
                    _ActionCard(
                      icon: Icons.play_arrow_rounded,
                      title: l10n.workoutsInProgress,
                      subtitle: active.name,
                      trailing: ElapsedClock(
                        start: active.startedAt,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      onTap: () => context.push(AppRoutes.workout),
                    )
                  else
                    _ActionCard(
                      icon: Icons.add_rounded,
                      title: l10n.workoutsStartEmpty,
                      subtitle: l10n.workoutsStartEmptyBody,
                      onTap: () => startWorkout(context, ref),
                    ),
                  const SizedBox(height: 10),
                  Glass(
                    radius: 22,
                    padding: const EdgeInsets.all(14),
                    onTap: () => context.push(AppRoutes.templates),
                    child: Row(
                      children: [
                        Glass(
                          shape: BoxShape.circle,
                          shadow: false,
                          child: const SizedBox.square(
                            dimension: 44,
                            child: Icon(Icons.auto_awesome_rounded, size: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.templatesBrowse,
                                  style: Theme.of(context).textTheme.titleSmall),
                              Text(
                                l10n.templatesBrowseBody,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                  SectionLabel(
                    l10n.workoutsMyRoutines,
                    trailing: TextButton.icon(
                      onPressed: () => context.push(AppRoutes.newRoutine),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(l10n.workoutsNewRoutine),
                    ),
                  ),
                  if (routines == null)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (routines.isEmpty)
                    const _NoRoutines()
                  else
                    for (final r in routines) ...[
                      _RoutineCard(summary: r),
                      const SizedBox(height: 10),
                    ],
                  if (recent.isNotEmpty) ...[
                    SectionLabel(l10n.workoutsRecent),
                    for (final w in recent) ...[
                      _HistoryTile(summary: w),
                      const SizedBox(height: 8),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Glass(
      radius: 26,
      tint: AppColors.volt,
      tintStrength: dark ? 0.16 : 0.35,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _NoRoutines extends StatelessWidget {
  const _NoRoutines();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Glass(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.list_alt_rounded, size: 36),
          const SizedBox(height: 10),
          Text(l10n.workoutsNoRoutines, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.workoutsNoRoutinesBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.newRoutine),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.workoutsCreateRoutine),
          ),
        ],
      ),
    );
  }
}

class _RoutineCard extends ConsumerWidget {
  const _RoutineCard({required this.summary});

  final RoutineSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final routine = summary.routine;
    final repo = ref.read(routineRepositoryProvider);

    Future<void> delete() async {
      final ok = await showGlassConfirm(
        context: context,
        title: l10n.routineDeleteConfirm(routine.name),
        message: l10n.routineDeleteBody,
        confirmLabel: l10n.delete,
        cancelLabel: l10n.cancel,
        destructive: true,
      );
      if (ok) await repo.delete(routine.id);
    }

    return Glass(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
      onTap: () => context.push(AppRoutes.editRoutine(routine.id)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(routine.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  l10n.routineSummary(
                      summary.exerciseNames.length, summary.setCount),
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Builder(builder: (context) {
                  final estimate = estimatePlan(
                      summary.plan, ref.watch(userProfileProvider));
                  return EstimateText(
                    duration: estimate.duration,
                    kcal: roundKcal(estimate.kcal),
                  );
                }),
                const SizedBox(height: 6),
                Text(
                  summary.exerciseNames.map((n) => n.titleCase).join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 42),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => startWorkout(context, ref, routineId: routine.id),
            child: Text(l10n.routineStart),
          ),
          PopupMenuButton<void>(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => context.push(AppRoutes.editRoutine(routine.id)),
                child: Text(l10n.routineEdit),
              ),
              PopupMenuItem(
                onTap: () => repo.duplicate(routine.id,
                    name: l10n.routineCopyName(routine.name)),
                child: Text(l10n.routineDuplicate),
              ),
              PopupMenuItem(
                onTap: delete,
                child: Text(l10n.routineDelete,
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.summary});

  final WorkoutSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final w = summary.workout;
    return Glass(
      radius: 20,
      padding: const EdgeInsets.all(14),
      onTap: () => context.push(AppRoutes.workoutSummary(w.id)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat.MMM().format(w.startedAt).toUpperCase(),
                    style: theme.textTheme.labelSmall),
                Text('${w.startedAt.day}', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall),
                Text(
                  [
                    formatDurationShort(summary.duration),
                    l10n.kcal(roundKcal(caloriesBurned(
                      completed: summary.completedPlan,
                      elapsed: summary.duration,
                      profile: ref.watch(userProfileProvider),
                    ))),
                    formatVolume(summary.volumeKg, unit),
                  ].join(' · '),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
