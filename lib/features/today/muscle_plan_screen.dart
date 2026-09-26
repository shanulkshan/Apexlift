import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/text.dart';
import '../../core/widgets/glass/ambient_background.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_nav_bar.dart';
import '../../data/workouts/routine_models.dart';
import '../../l10n/app_localizations.dart';
import '../library/widgets/exercise_gif.dart';
import '../workouts/add_to_routines.dart';

/// One muscle group, seen through the user's plans: the exercises from
/// their routines that train it, which routines use each, and a way to add
/// more.
class MusclePlanScreen extends ConsumerWidget {
  const MusclePlanScreen({super.key, required this.bodyPart});

  final String bodyPart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final planned = ref.watch(plannedExercisesProvider(bodyPart));
    final items = planned.value ?? const <PlannedExerciseUsage>[];
    final muscle = bodyPart.titleCase;

    Future<void> add() => addExercisesToRoutines(context, ref, bodyPart: bodyPart);

    return AmbientBackdrop(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverSafeArea(
              bottom: false,
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      GlassIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: l10n.back,
                        blur: false,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(muscle, style: theme.textTheme.displaySmall),
                    Text(
                      l10n.musclePlanned(items.length),
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            if (planned.isLoading && items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _Empty(muscle: muscle, onAdd: add),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _PlannedExerciseTile(usage: items[i], bodyPart: bodyPart),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, navBarClearance(context)),
                sliver: SliverToBoxAdapter(
                  child: FilledButton.icon(
                    onPressed: add,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.muscleAdd(muscle.toLowerCase())),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlannedExerciseTile extends StatelessWidget {
  const _PlannedExerciseTile({required this.usage, required this.bodyPart});

  final PlannedExerciseUsage usage;
  final String bodyPart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final e = usage.exercise;

    return Glass(
      radius: 24,
      padding: const EdgeInsets.all(12),
      onTap: () => context.push(AppRoutes.muscleExercise(bodyPart, e.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'exercise-gif-${e.id}',
                child: ExerciseGif(url: e.gifUrl, size: 60, radius: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.name.titleCase,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      [
                        ...e.targetMuscles.take(1),
                        ...e.equipments.take(1),
                      ].map((s) => s.titleCase).join(' · '),
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
          const SizedBox(height: 10),
          Text(
            l10n.muscleUsedIn.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.1),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final r in usage.routines)
                ActionChip(
                  avatar: Icon(Icons.list_alt_rounded,
                      size: 16, color: dark ? AppColors.volt : AppColors.voltDeep),
                  label: Text(r.name),
                  onPressed: () => context.push(AppRoutes.editRoutine(r.id)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.muscle, required this.onAdd});

  final String muscle;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.fromLTRB(28, 24, 28, navBarClearance(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Glass(
            shape: BoxShape.circle,
            tint: AppColors.volt,
            tintStrength: dark ? 0.2 : 0.4,
            child: const SizedBox.square(
              dimension: 80,
              child: Icon(Icons.playlist_add_rounded, size: 36),
            ),
          ),
          const SizedBox(height: 18),
          Text(l10n.muscleEmptyTitle(muscle.toLowerCase()),
              textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            l10n.muscleEmptyBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.muscleAdd(muscle.toLowerCase())),
          ),
        ],
      ),
    );
  }
}
