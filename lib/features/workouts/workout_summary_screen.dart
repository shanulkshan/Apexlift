import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/duration.dart';
import '../../core/utils/text.dart';
import '../../core/utils/weight.dart';
import '../../core/widgets/glass/ambient_background.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_controls.dart';
import '../../data/db/app_database.dart';
import '../../data/workouts/routine_models.dart';
import '../../data/workouts/workout_models.dart';
import '../../l10n/app_localizations.dart';
import '../library/widgets/exercise_gif.dart';
import '../settings/settings_controller.dart';
import '../../data/training/training_estimates.dart';
import '../profile/user_profile_controller.dart';
import 'workout_providers.dart';

class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  const WorkoutSummaryScreen({super.key, required this.workoutId});

  final int workoutId;

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends ConsumerState<WorkoutSummaryScreen> {
  bool _savedAsRoutine = false;

  Future<void> _saveAsRoutine(WorkoutDetail detail) async {
    await ref.read(routineRepositoryProvider).save(RoutineDraft(
          name: detail.workout.name,
          exercises: [
            for (final e in detail.exercises)
              DraftExercise(
                exerciseId: e.entry.exerciseId,
                restSeconds: e.entry.restSeconds,
                sets: [
                  for (final s in e.sets)
                    DraftSet(type: s.setType, reps: s.reps, weightKg: s.weightKg),
                ],
              ),
          ],
        ));
    HapticFeedback.mediumImpact();
    setState(() => _savedAsRoutine = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final detail = ref.watch(workoutDetailProvider(widget.workoutId)).value;
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final dark = theme.brightness == Brightness.dark;
    final accent = dark ? AppColors.volt : AppColors.voltDeep;

    return AmbientBackdrop(
      child: Scaffold(
        body: detail == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  children: [
                    Center(
                      child: Glass(
                        shape: BoxShape.circle,
                        tint: AppColors.volt,
                        tintStrength: dark ? 0.3 : 0.55,
                        child: SizedBox.square(
                          dimension: 96,
                          child: Icon(Icons.emoji_events_rounded,
                              size: 48, color: dark ? AppColors.volt : AppColors.ink),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(l10n.summaryTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${detail.workout.name} · ${DateFormat.MMMEd().format(detail.workout.startedAt)}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 22),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.9,
                      children: [
                        _Stat(
                          icon: Icons.timer_outlined,
                          color: accent,
                          value: formatDurationShort((detail.workout.finishedAt ??
                                  DateTime.now())
                              .difference(detail.workout.startedAt)),
                          label: l10n.summaryDuration,
                        ),
                        _Stat(
                          icon: Icons.stacked_bar_chart_rounded,
                          color: theme.colorScheme.secondary,
                          value: formatVolume(detail.volumeKg, unit),
                          label: l10n.summaryVolume,
                        ),
                        _Stat(
                          icon: Icons.check_circle_outline_rounded,
                          color: theme.colorScheme.tertiary,
                          value: '${detail.completedSets}',
                          label: l10n.summarySets,
                        ),
                        _Stat(
                          icon: Icons.local_fire_department_rounded,
                          color: const Color(0xFFB78CFF),
                          value: l10n.kcal(roundKcal(caloriesBurned(
                            completed: detail.completedPlan,
                            elapsed: (detail.workout.finishedAt ?? DateTime.now())
                                .difference(detail.workout.startedAt),
                            profile: ref.watch(userProfileProvider),
                          ))),
                          label: l10n.summaryCalories,
                        ),
                      ],
                    ),
                    SectionLabel(l10n.summaryExercises),
                    for (final e in detail.exercises) ...[
                      _ExerciseResult(detail: e, unit: unit),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 12),
                    if (detail.workout.routineId == null)
                      OutlinedButton.icon(
                        onPressed: _savedAsRoutine ? null : () => _saveAsRoutine(detail),
                        icon: Icon(_savedAsRoutine
                            ? Icons.check_rounded
                            : Icons.bookmark_add_outlined),
                        label: Text(_savedAsRoutine
                            ? l10n.summarySavedRoutine
                            : l10n.summarySaveRoutine),
                      ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: () => context.go(AppRoutes.workouts),
                      child: Text(l10n.summaryDone),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Glass(
      radius: 22,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: theme.textTheme.headlineSmall),
          ),
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ExerciseResult extends StatelessWidget {
  const _ExerciseResult({required this.detail, required this.unit});

  final WorkoutExerciseDetail detail;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sets = detail.sets.where((s) => s.completed).toList();
    // Best set = heaviest weight, then most reps.
    WorkoutSet? best;
    for (final s in sets) {
      if (best == null ||
          (s.weightKg ?? 0) > (best.weightKg ?? 0) ||
          ((s.weightKg ?? 0) == (best.weightKg ?? 0) &&
              (s.reps ?? 0) > (best.reps ?? 0))) {
        best = s;
      }
    }
    final bestText = best == null
        ? null
        : best.weightKg == null
            ? '× ${best.reps ?? 0}'
            : '${formatWeight(best.weightKg!, unit)} ${unit.symbol} × ${best.reps ?? 0}';

    return Glass(
      radius: 20,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          if (detail.exercise != null)
            ExerciseGif(url: detail.exercise!.gifUrl, size: 48, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.exercise?.name.titleCase ?? detail.entry.exerciseId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  [
                    l10n.setsCount(sets.length),
                    if (bestText != null) l10n.bestSet(bestText),
                  ].join(' · '),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
