import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass/glass_sheet.dart';
import '../../core/utils/text.dart';
import '../../core/widgets/glass/ambient_background.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_controls.dart';
import '../../core/widgets/glass/glass_nav_bar.dart';
import '../../data/db/app_database.dart';
import '../../l10n/app_localizations.dart';
import 'library_providers.dart';
import 'widgets/exercise_gif.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.id});

  final String id;

  Future<void> _deleteCustom(BuildContext context, WidgetRef ref) =>
      _deleteCustomExercise(context, ref, id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final exercise = ref.watch(exerciseProvider(id));

    // Pushed over the library, so paint our own (shared-clock) backdrop to
    // stay opaque during the transition.
    return AmbientBackdrop(
      child: Scaffold(
        body: Stack(
          children: [
            exercise.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (exercise) => exercise == null
                  ? Center(child: Text(l10n.exerciseNotFound))
                  : _ExerciseDetail(exercise: exercise),
            ),
            // Floating glass back button (+ edit/delete for custom ones).
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GlassIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: l10n.back,
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    if (exercise.value?.isCustom ?? false) ...[
                      GlassIconButton(
                        icon: Icons.edit_rounded,
                        tooltip: l10n.customEdit,
                        onPressed: () => context.push(AppRoutes.editCustomExercise(id)),
                      ),
                      const SizedBox(width: 10),
                      GlassIconButton(
                        icon: Icons.delete_outline_rounded,
                        tooltip: l10n.customDelete,
                        onPressed: () => _deleteCustom(context, ref),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _deleteCustomExercise(
    BuildContext context, WidgetRef ref, String id) async {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(exerciseRepositoryProvider);
  if (await repo.isInUse(id)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.customInUse)));
    }
    return;
  }
  if (!context.mounted) return;
  final ok = await showGlassConfirm(
    context: context,
    title: l10n.customDeleteTitle,
    message: l10n.customDeleteBody,
    confirmLabel: l10n.delete,
    cancelLabel: l10n.cancel,
    destructive: true,
  );
  if (!ok || !context.mounted) return;
  context.pop();
  await repo.deleteCustom(id);
}

class _ExerciseDetail extends StatelessWidget {
  const _ExerciseDetail({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final accent = dark ? AppColors.volt : AppColors.voltDeep;
    final media = MediaQuery.of(context);
    final gifSize = (media.size.width - 40).clamp(0.0, 440.0);

    return ListView(
      padding: EdgeInsets.fromLTRB(
          20, media.padding.top + 64, 20, navBarClearance(context)),
      children: [
        // Animation in a glass frame.
        Center(
          child: Glass(
            radius: 32,
            padding: const EdgeInsets.all(6),
            child: Hero(
              tag: 'exercise-gif-${exercise.id}',
              child: ExerciseGif(
                  url: exercise.gifUrl, size: gifSize - 12, radius: 26),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(exercise.name.titleCase, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final part in exercise.bodyParts)
              _Fact(icon: Icons.accessibility_new_rounded, label: part.titleCase),
            for (final eq in exercise.equipments)
              _Fact(icon: Icons.fitness_center_rounded, label: eq.titleCase),
          ],
        ),
        SectionLabel(l10n.exerciseMuscles),
        Glass(
          radius: 24,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MuscleRow(
                label: l10n.exerciseTarget,
                muscles: exercise.targetMuscles,
                color: accent,
                filled: true,
              ),
              if (exercise.secondaryMuscles.isNotEmpty) ...[
                const SizedBox(height: 14),
                _MuscleRow(
                  label: l10n.exerciseSecondary,
                  muscles: exercise.secondaryMuscles,
                  color: theme.colorScheme.secondary,
                ),
              ],
            ],
          ),
        ),
        SectionLabel(l10n.exerciseInstructions),
        Glass(
          radius: 24,
          padding: const EdgeInsets.fromLTRB(16, 18, 18, 4),
          child: Column(
            children: [
              for (final (i, step) in exercise.instructions.indexed)
                _Step(
                  number: i + 1,
                  text: step,
                  isLast: i == exercise.instructions.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Glass(
      radius: 100,
      shadow: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _MuscleRow extends StatelessWidget {
  const _MuscleRow({
    required this.label,
    required this.muscles,
    required this.color,
    this.filled = false,
  });

  final String label;
  final List<String> muscles;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final m in muscles)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: filled ? color : color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(100),
                  border: filled
                      ? null
                      : Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    m.titleCase,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: filled
                          ? (theme.brightness == Brightness.dark
                              ? AppColors.ink
                              : Colors.white)
                          : color,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// One instruction in a vertical timeline.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text, required this.isLast});

  final int number;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text('$number',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: scheme.onPrimary)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 18),
              child: Text(text, style: theme.textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}
