import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/text.dart';
import '../../core/utils/weight.dart';
import '../../core/widgets/glass/ambient_background.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_sheet.dart';
import '../../data/workouts/routine_models.dart';
import '../../l10n/app_localizations.dart';
import '../library/library_providers.dart';
import '../library/widgets/exercise_gif.dart';
import '../settings/settings_controller.dart';
import '../../data/training/training_estimates.dart';
import '../profile/user_profile_controller.dart';
import 'set_defaults.dart';
import 'widgets/workout_widgets.dart';

/// Create ([routineId] null) or edit a routine. Edits stay in memory until
/// Save, which writes the whole routine in one transaction.
class RoutineEditorScreen extends ConsumerStatefulWidget {
  const RoutineEditorScreen({
    super.key,
    this.routineId,
    this.initialExerciseIds = const [],
  });

  final int? routineId;

  /// For a new routine: exercises to start with (e.g. from a muscle page).
  final List<String> initialExerciseIds;

  @override
  ConsumerState<RoutineEditorScreen> createState() =>
      _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  RoutineDraft? _initial;
  RoutineDraft _draft = const RoutineDraft();
  final _name = TextEditingController();
  bool _saving = false;

  bool get _dirty => _initial != null && _draft != _initial;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final draft = widget.routineId == null
        ? const RoutineDraft()
        : await ref.read(routineRepositoryProvider).load(widget.routineId!);
    var start = draft;
    if (widget.routineId == null && widget.initialExerciseIds.isNotEmpty) {
      final defaults = await defaultSetsFor(ref, widget.initialExerciseIds);
      start = draft.copyWith(exercises: [
        for (final id in widget.initialExerciseIds)
          DraftExercise(exerciseId: id, sets: defaults[id] ?? const [DraftSet()]),
      ]);
    }
    if (!mounted) return;
    setState(() {
      // Pre-filled exercises count as unsaved changes.
      _initial = draft;
      _draft = start;
      _name.text = start.name;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _update(RoutineDraft draft) => setState(() => _draft = draft);

  void _updateExercise(int index, DraftExercise exercise) => _update(
      _draft.copyWith(exercises: [..._draft.exercises]..[index] = exercise));

  Future<void> _addExercises() async {
    final ids = await context.push<List<String>>(AppRoutes.pickExercises);
    if (ids == null || ids.isEmpty) return;
    final defaults = await defaultSetsFor(ref, ids);
    if (!mounted) return;
    _update(_draft.copyWith(exercises: [
      ..._draft.exercises,
      for (final id in ids)
        DraftExercise(exerciseId: id, sets: defaults[id] ?? const [DraftSet()]),
    ]));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final error = _draft.name.trim().isEmpty
        ? l10n.editorNameRequired
        : _draft.exercises.isEmpty
            ? l10n.editorExercisesRequired
            : null;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _saving = true);
    final id = await ref.read(routineRepositoryProvider).save(_draft);
    if (!mounted) return;
    _initial = _draft; // allow the pop below
    context.pop(id);
  }

  Future<void> _confirmLeave() async {
    final l10n = AppLocalizations.of(context);
    final leave = await showGlassConfirm(
      context: context,
      title: l10n.editorDiscardTitle,
      message: l10n.editorDiscardBody,
      confirmLabel: l10n.discard,
      cancelLabel: l10n.keepEditing,
      destructive: true,
    );
    if (leave && mounted) {
      setState(() => _initial = _draft);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final loading = _initial == null;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: AmbientBackdrop(
        child: Scaffold(
          bottomNavigationBar: loading || _draft.exercises.isEmpty
              ? null
              : _EstimateBar(draft: _draft),
          body: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverAppBar(
                pinned: true,
                toolbarHeight: 64,
                automaticallyImplyLeading: false,
                titleSpacing: 16,
                flexibleSpace: const GlassBar(),
                title: Row(
                  children: [
                    GlassIconButton(
                      icon: Icons.close_rounded,
                      tooltip: l10n.cancel,
                      blur: false,
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.routineId == null
                            ? l10n.editorNewTitle
                            : l10n.editorEditTitle,
                        style: theme.textTheme.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(84, 44)),
                      onPressed: loading || _saving ? null : _save,
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              ),
              if (loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Glass(
                      radius: 20,
                      shadow: false,
                      child: TextField(
                        controller: _name,
                        onChanged: (v) => _update(_draft.copyWith(name: v)),
                        textCapitalization: TextCapitalization.sentences,
                        style: theme.textTheme.titleLarge,
                        decoration: InputDecoration(
                          hintText: l10n.editorNameHint,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_draft.exercises.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 8),
                      child: Text(
                        l10n.editorEmpty,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverReorderableList(
                      itemCount: _draft.exercises.length,
                      onReorder: (from, to) {
                        final list = [..._draft.exercises];
                        final item = list.removeAt(from);
                        list.insert(to > from ? to - 1 : to, item);
                        _update(_draft.copyWith(exercises: list));
                      },
                      proxyDecorator: (child, _, _) =>
                          Material(color: Colors.transparent, child: child),
                      itemBuilder: (context, i) {
                        final e = _draft.exercises[i];
                        return Padding(
                          key: ValueKey(e.key),
                          padding: const EdgeInsets.only(top: 12),
                          child: _DraftExerciseCard(
                            index: i,
                            exercise: e,
                            onChanged: (next) => _updateExercise(i, next),
                            onRemove: () => _update(_draft.copyWith(
                              exercises: [..._draft.exercises]..removeAt(i),
                            )),
                          ),
                        );
                      },
                    ),
                  ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                      16, 16, 16, 32 + MediaQuery.paddingOf(context).bottom),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _addExercises,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(l10n.workoutAddExercises),
                        ),
                        if (_draft.exercises.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            l10n.setTypeHint,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DraftExerciseCard extends ConsumerWidget {
  const _DraftExerciseCard({
    required this.index,
    required this.exercise,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final DraftExercise exercise;
  final ValueChanged<DraftExercise> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final info = ref.watch(exerciseProvider(exercise.exerciseId)).value;
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final numbers = workingNumbers(exercise.sets.map((s) => s.type));
    final header = theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1);

    void setSets(List<DraftSet> sets) => onChanged(exercise.copyWith(sets: sets));

    return Glass(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.drag_indicator_rounded),
                ),
              ),
              const SizedBox(width: 4),
              if (info != null) ExerciseGif(url: info.gifUrl, size: 44, radius: 12),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  info?.name.titleCase ?? exercise.exerciseId,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                tooltip: l10n.removeExercise,
                onPressed: onRemove,
                icon: Icon(Icons.delete_outline_rounded,
                    color: theme.colorScheme.error),
              ),
            ],
          ),
          const SizedBox(height: 6),
          RestChip(
            seconds: exercise.restSeconds,
            onChanged: (s) => onChanged(exercise.copyWith(restSeconds: s)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 40, child: Text(l10n.setColumnSet, style: header)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(unit.symbol.toUpperCase(),
                      textAlign: TextAlign.center, style: header)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(l10n.setColumnReps,
                      textAlign: TextAlign.center, style: header)),
              const SizedBox(width: 40),
            ],
          ),
          for (final (i, set) in exercise.sets.indexed)
            _DraftSetRow(
              key: ValueKey('${exercise.key}-$i-${exercise.sets.length}'),
              set: set,
              number: numbers[i],
              unit: unit,
              canRemove: exercise.sets.length > 1,
              onChanged: (next) => setSets([...exercise.sets]..[i] = next),
              onRemove: () => setSets([...exercise.sets]..removeAt(i)),
            ),
          TextButton.icon(
            onPressed: () => setSets([
              ...exercise.sets,
              exercise.sets.isEmpty ? const DraftSet() : exercise.sets.last,
            ]),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l10n.addSet),
          ),
        ],
      ),
    );
  }
}

class _DraftSetRow extends StatefulWidget {
  const _DraftSetRow({
    super.key,
    required this.set,
    required this.number,
    required this.unit,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final DraftSet set;
  final int number;
  final WeightUnit unit;
  final bool canRemove;
  final ValueChanged<DraftSet> onChanged;
  final VoidCallback onRemove;

  @override
  State<_DraftSetRow> createState() => _DraftSetRowState();
}

class _DraftSetRowState extends State<_DraftSetRow> {
  late final _weight = TextEditingController(
      text: widget.set.weightKg == null
          ? ''
          : formatWeight(widget.set.weightKg!, widget.unit));
  late final _reps =
      TextEditingController(text: widget.set.reps?.toString() ?? '');

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final set = widget.set;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SetBadge(
                type: set.type,
                number: widget.number,
                onTap: () => widget.onChanged(set.copyWith(type: set.type.next)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SetNumberField(
              controller: _weight,
              decimal: true,
              hint: '–',
              onChanged: (v) {
                final n = parseNumber(v);
                widget.onChanged(set.copyWith(
                    weightKg: () => n == null ? null : widget.unit.toKg(n)));
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SetNumberField(
              controller: _reps,
              hint: '–',
              onChanged: (v) =>
                  widget.onChanged(set.copyWith(reps: () => int.tryParse(v))),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: widget.canRemove ? widget.onRemove : null,
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky glass bar with the routine's estimated duration and calories,
/// updating as sets, weights and rest times change.
class _EstimateBar extends ConsumerWidget {
  const _EstimateBar({required this.draft});

  final RoutineDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ids = draft.exercises.map((e) => e.exerciseId).toSet().toList()..sort();
    final catalog =
        ref.watch(exercisesByIdsProvider(ids.join(','))).value ?? const {};
    final profile = ref.watch(userProfileProvider);
    final estimate = estimatePlan(draft.toPlan(catalog), profile);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Glass(
        blur: true,
        radius: 24,
        tint: theme.colorScheme.surface,
        tintStrength: 0.35,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(l10n.estimateTitle, style: theme.textTheme.titleSmall),
            ),
            EstimateText(
              duration: estimate.duration,
              kcal: roundKcal(estimate.kcal),
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
