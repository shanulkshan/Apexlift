import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/duration.dart';
import '../../core/utils/text.dart';
import '../../core/utils/weight.dart';
import '../../core/widgets/glass/ambient_background.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_sheet.dart';
import '../../data/db/app_database.dart';
import '../../data/workouts/workout_models.dart';
import '../../l10n/app_localizations.dart';
import '../library/widgets/exercise_gif.dart';
import '../settings/settings_controller.dart';
import '../../data/training/training_estimates.dart';
import '../../data/workouts/routine_models.dart';
import '../profile/user_profile_controller.dart';
import 'set_defaults.dart';
import 'widgets/plate_calculator.dart';
import 'widgets/workout_widgets.dart';
import 'workout_providers.dart';

/// The in-progress workout. Keeps the screen awake while open.
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable().ignore();
  }

  @override
  void dispose() {
    WakelockPlus.disable().ignore();
    super.dispose();
  }

  Future<void> _addExercises(int workoutId) async {
    final ids = await context.push<List<String>>(AppRoutes.pickExercises);
    if (ids == null || ids.isEmpty) return;
    final defaults =
        await defaultSetsFor(ref, ids, excludeWorkoutId: workoutId);
    await ref
        .read(workoutRepositoryProvider)
        .addExercises(workoutId, ids, initialSets: defaults);
  }

  Future<void> _finish(WorkoutDetail detail) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(workoutRepositoryProvider);
    FocusScope.of(context).unfocus();

    if (detail.completedSets == 0) {
      await showGlassConfirm(
        context: context,
        title: l10n.workoutNothingDoneTitle,
        message: l10n.workoutNothingDoneBody,
        confirmLabel: l10n.ok,
      );
      return;
    }
    final unticked = detail.allSets.where((s) => !s.completed).length;
    final ok = await showGlassConfirm(
      context: context,
      title: l10n.workoutFinishTitle,
      message: unticked == 0
          ? l10n.workoutFinishBody
          : '${l10n.workoutFinishBody} ${l10n.workoutFinishUnticked(unticked)}',
      confirmLabel: l10n.workoutFinish,
      cancelLabel: l10n.cancel,
    );
    if (!ok || !mounted) return;

    final id = detail.workout.id;
    if (await repo.finish(id)) {
      ref.read(restTimerProvider.notifier).skip();
      HapticFeedback.heavyImpact();
      if (mounted) context.pushReplacement(AppRoutes.workoutSummary(id));
    }
  }

  Future<void> _discard(int workoutId) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showGlassConfirm(
      context: context,
      title: l10n.workoutDiscardTitle,
      message: l10n.workoutDiscardBody,
      confirmLabel: l10n.discard,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    ref.read(restTimerProvider.notifier).skip();
    await ref.read(workoutRepositoryProvider).discard(workoutId);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final active = ref.watch(activeWorkoutProvider);
    final workoutId = active.value?.id;
    final detail =
        workoutId == null ? null : ref.watch(workoutDetailProvider(workoutId)).value;
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final dark = theme.brightness == Brightness.dark;

    return AmbientBackdrop(
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 68,
                  automaticallyImplyLeading: false,
                  titleSpacing: 12,
                  flexibleSpace: const GlassBar(),
                  title: Row(
                    children: [
                      GlassIconButton(
                        icon: Icons.keyboard_arrow_down_rounded,
                        tooltip: l10n.workoutMinimize,
                        blur: false,
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail?.workout.name ?? l10n.workoutDefaultName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium,
                            ),
                            if (detail != null)
                              TickingBuilder(builder: (context) {
                                final elapsed = DateTime.now()
                                    .difference(detail.workout.startedAt);
                                final kcal = caloriesBurned(
                                  completed: detail.completedPlan,
                                  elapsed: elapsed,
                                  profile: ref.watch(userProfileProvider),
                                );
                                return Text(
                                  '${formatClock(elapsed)}  ·  ${l10n.kcal(kcal.round())}',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: dark ? AppColors.volt : AppColors.voltDeep,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.plateTitle,
                        onPressed: () => showPlateCalculator(context, unit),
                        icon: const Icon(Icons.calculate_outlined),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 42),
                            padding: const EdgeInsets.symmetric(horizontal: 18)),
                        onPressed: detail == null ? null : () => _finish(detail),
                        child: Text(l10n.workoutFinish),
                      ),
                    ],
                  ),
                ),
                if (detail == null)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  if (detail.exercises.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
                        child: Column(
                          children: [
                            Glass(
                              shape: BoxShape.circle,
                              tint: AppColors.volt,
                              tintStrength: dark ? 0.2 : 0.4,
                              child: const SizedBox.square(
                                dimension: 76,
                                child: Icon(Icons.fitness_center_rounded, size: 34),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.workoutEmpty,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    sliver: SliverList.separated(
                      itemCount: detail.exercises.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final list = detail.exercises;
                        final group = list[i].entry.supersetGroup;
                        return _WorkoutExerciseCard(
                          key: ValueKey(list[i].entry.id),
                          detail: list[i],
                          workoutId: detail.workout.id,
                          unit: unit,
                          isFirst: i == 0,
                          isLast: i == list.length - 1,
                          // In a superset, rest only after the last exercise.
                          chainedToNext: group != null &&
                              i + 1 < list.length &&
                              list[i + 1].entry.supersetGroup == group,
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                        16, 16, 16, 150 + MediaQuery.paddingOf(context).bottom),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _addExercises(detail.workout.id),
                            icon: const Icon(Icons.add_rounded),
                            label: Text(l10n.workoutAddExercises),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _discard(detail.workout.id),
                            style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.error),
                            child: Text(l10n.workoutDiscard),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: RestTimerBar(),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutExerciseCard extends ConsumerWidget {
  const _WorkoutExerciseCard({
    super.key,
    required this.detail,
    required this.workoutId,
    required this.unit,
    required this.isFirst,
    required this.isLast,
    required this.chainedToNext,
  });

  final WorkoutExerciseDetail detail;
  final int workoutId;
  final WeightUnit unit;
  final bool isFirst;
  final bool isLast;
  final bool chainedToNext;

  Future<void> _replace(BuildContext context, WidgetRef ref) async {
    final ids = await context.push<List<String>>(AppRoutes.pickOneExercise(
        bodyPart: detail.exercise?.bodyParts.firstOrNull));
    if (ids == null || ids.isEmpty) return;
    final sets = await defaultSetsFor(ref, ids, excludeWorkoutId: workoutId);
    await ref.read(workoutRepositoryProvider).replaceExercise(
          detail.entry.id,
          ids.single,
          sets: sets[ids.single] ?? const [DraftSet()],
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = ref.read(workoutRepositoryProvider);
    final entry = detail.entry;
    final previous = ref
            .watch(previousSetsProvider((entry.exerciseId, workoutId)))
            .value ??
        const <WorkoutSet>[];
    final numbers = workingNumbers(detail.sets.map((s) => s.setType));
    final header = theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.8);

    final group = entry.supersetGroup;
    return Glass(
      radius: 24,
      tint: group == null ? null : theme.colorScheme.secondary,
      tintStrength: 0.1,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (group != null) SupersetBadge(group: group),
          Row(
            children: [
              if (detail.exercise != null)
                ExerciseGif(url: detail.exercise!.gifUrl, size: 46, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  detail.exercise?.name.titleCase ?? entry.exerciseId,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              PopupMenuButton<void>(
                icon: const Icon(Icons.more_horiz_rounded),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () => _replace(context, ref),
                    child: Text(l10n.replaceExercise),
                  ),
                  if (!isFirst)
                    PopupMenuItem(
                      onTap: () => repo.moveExercise(entry.id, -1),
                      child: Text(l10n.moveUp),
                    ),
                  if (!isLast)
                    PopupMenuItem(
                      onTap: () => repo.moveExercise(entry.id, 1),
                      child: Text(l10n.moveDown),
                    ),
                  if (!isLast)
                    PopupMenuItem(
                      onTap: () => repo.linkWithNext(entry.id),
                      child: Text(l10n.supersetWithNext),
                    ),
                  if (group != null)
                    PopupMenuItem(
                      onTap: () => repo.unlinkSuperset(entry.id),
                      child: Text(l10n.supersetRemove),
                    ),
                  PopupMenuItem(
                    onTap: () => repo.removeExercise(entry.id),
                    child: Text(l10n.removeExercise,
                        style: TextStyle(color: theme.colorScheme.error)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          RestChip(
            seconds: entry.restSeconds,
            onChanged: (s) => repo.setRest(entry.id, s),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 38, child: Text(l10n.setColumnSet, style: header)),
              Expanded(
                flex: 5,
                child: Text(l10n.setColumnPrevious,
                    textAlign: TextAlign.center, style: header),
              ),
              Expanded(
                flex: 4,
                child: Text(unit.symbol.toUpperCase(),
                    textAlign: TextAlign.center, style: header),
              ),
              Expanded(
                flex: 4,
                child: Text(l10n.setColumnReps,
                    textAlign: TextAlign.center, style: header),
              ),
              const SizedBox(width: 44),
            ],
          ),
          for (final (i, set) in detail.sets.indexed)
            _LiveSetRow(
              key: ValueKey(set.id),
              set: set,
              number: numbers[i],
              previous: i < previous.length ? previous[i] : null,
              restSeconds: chainedToNext ? 0 : entry.restSeconds,
              unit: unit,
            ),
          TextButton.icon(
            onPressed: () => repo.addSet(entry.id),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l10n.addSet),
          ),
        ],
      ),
    );
  }
}

class _LiveSetRow extends ConsumerStatefulWidget {
  const _LiveSetRow({
    super.key,
    required this.set,
    required this.number,
    required this.previous,
    required this.restSeconds,
    required this.unit,
  });

  final WorkoutSet set;
  final int number;
  final WorkoutSet? previous;
  final int restSeconds;
  final WeightUnit unit;

  @override
  ConsumerState<_LiveSetRow> createState() => _LiveSetRowState();
}

class _LiveSetRowState extends ConsumerState<_LiveSetRow> {
  late final _weight = TextEditingController(text: _weightText(widget.set));
  late final _reps = TextEditingController(text: _repsText(widget.set));
  final _weightFocus = FocusNode();
  final _repsFocus = FocusNode();

  String _weightText(WorkoutSet s) =>
      s.weightKg == null ? '' : formatWeight(s.weightKg!, widget.unit);
  String _repsText(WorkoutSet s) => s.reps?.toString() ?? '';

  @override
  void didUpdateWidget(_LiveSetRow old) {
    super.didUpdateWidget(old);
    // Reflect changes made elsewhere (e.g. auto-fill on completion, unit
    // switch) without fighting the user's typing.
    if (!_weightFocus.hasFocus) {
      final text = _weightText(widget.set);
      if (parseNumber(text) != parseNumber(_weight.text)) _weight.text = text;
    }
    if (!_repsFocus.hasFocus && _repsText(widget.set) != _reps.text) {
      _reps.text = _repsText(widget.set);
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    _weightFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  Future<void> _toggleCompleted() async {
    final set = widget.set;
    final completing = !set.completed;
    FocusScope.of(context).unfocus();
    if (completing) {
      HapticFeedback.mediumImpact();
      ref.read(restTimerProvider.notifier).start(widget.restSeconds);
    }
    await ref.read(workoutRepositoryProvider).setCompleted(
          set,
          completing,
          fallbackWeightKg: widget.previous?.weightKg,
          fallbackReps: widget.previous?.reps,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final repo = ref.read(workoutRepositoryProvider);
    final set = widget.set;
    final prev = widget.previous;
    final dark = theme.brightness == Brightness.dark;
    final accent = dark ? AppColors.volt : AppColors.voltDeep;

    final prevText = prev == null || prev.reps == null
        ? '—'
        : prev.weightKg == null
            ? '× ${prev.reps}'
            : '${formatWeight(prev.weightKg!, widget.unit)} × ${prev.reps}';

    return Dismissible(
      key: ValueKey('dismiss-${set.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => repo.removeSet(set.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          color: scheme.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline_rounded, color: scheme.onError),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: set.completed ? accent.withValues(alpha: 0.13) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              child: SetBadge(
                type: set.setType,
                number: widget.number,
                onTap: () => repo.updateSet(set.id, type: set.setType.next),
              ),
            ),
            Expanded(
              flex: 5,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                // Tap "previous" to copy it into this set.
                onTap: prev == null
                    ? null
                    : () => repo.updateSet(
                          set.id,
                          weightKg: Value(prev.weightKg),
                          reps: Value(prev.reps),
                        ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    prevText,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: SetNumberField(
                  controller: _weight,
                  focusNode: _weightFocus,
                  decimal: true,
                  hint: prev?.weightKg == null
                      ? '–'
                      : formatWeight(prev!.weightKg!, widget.unit),
                  onChanged: (v) {
                    final n = parseNumber(v);
                    repo.updateSet(set.id,
                        weightKg: Value(n == null ? null : widget.unit.toKg(n)));
                  },
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: SetNumberField(
                  controller: _reps,
                  focusNode: _repsFocus,
                  hint: prev?.reps?.toString() ?? '–',
                  textInputAction: TextInputAction.done,
                  onChanged: (v) =>
                      repo.updateSet(set.id, reps: Value(int.tryParse(v))),
                ),
              ),
            ),
            SizedBox(
              width: 44,
              child: Center(
                child: GestureDetector(
                  onTap: _toggleCompleted,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: set.completed ? accent : Colors.transparent,
                      border: Border.all(
                        color: set.completed ? accent : scheme.onSurfaceVariant,
                        width: 1.6,
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: set.completed
                          ? (dark ? AppColors.ink : Colors.white)
                          : scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating rest countdown shown after completing a set.
class RestTimerBar extends ConsumerWidget {
  const RestTimerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(restTimerProvider);
    final timer = ref.read(restTimerProvider.notifier);
    final dark = theme.brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween(begin: const Offset(0, 1.2), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutBack))
            .animate(anim),
        child: child,
      ),
      child: state == null
          ? const SizedBox.shrink()
          : SafeArea(
              key: const ValueKey('rest'),
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Glass(
                blur: true,
                radius: 30,
                tint: theme.colorScheme.surface,
                tintStrength: 0.4,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 52,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: state.progress,
                            strokeWidth: 4,
                            color: dark ? AppColors.volt : AppColors.voltDeep,
                            backgroundColor:
                                theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                          const Center(child: Icon(Icons.timer_outlined, size: 22)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.restTimerTitle,
                              style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                          Text(
                            formatClock(state.remaining +
                                const Duration(milliseconds: 999)),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _TimerButton(label: '−15', onTap: () => timer.adjust(-15)),
                    const SizedBox(width: 6),
                    _TimerButton(label: '+15', onTap: () => timer.adjust(15)),
                    const SizedBox(width: 6),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: timer.skip,
                      child: Text(l10n.restTimerSkip),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Glass(
        radius: 14,
        shadow: false,
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 44,
          child: Center(
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
        ),
      );
}
