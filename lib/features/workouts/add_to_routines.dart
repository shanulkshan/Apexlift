import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_sheet.dart';
import '../../data/workouts/routine_models.dart';
import '../../l10n/app_localizations.dart';
import 'set_defaults.dart';

/// Pick exercises (optionally pre-filtered to [bodyPart]), then choose which
/// routines they go into, or start a new routine with them.
Future<void> addExercisesToRoutines(
  BuildContext context,
  WidgetRef ref, {
  String? bodyPart,
}) async {
  final l10n = AppLocalizations.of(context);
  final ids = await context.push<List<String>>(bodyPart == null
      ? AppRoutes.pickExercises
      : AppRoutes.pickExercisesFor(bodyPart));
  if (ids == null || ids.isEmpty || !context.mounted) return;

  final repo = ref.read(routineRepositoryProvider);
  final routines = await repo.watchRoutines().first;
  final contents = await repo.exerciseIdsByRoutine();
  if (!context.mounted) return;

  final choice = await showGlassSheet<_Choice>(
    context: context,
    scrollControlled: true,
    builder: (context) => _RoutineChooser(
      exerciseCount: ids.length,
      routines: routines,
      // A routine is "done" when it already has every picked exercise.
      complete: {
        for (final r in routines)
          if (ids.every((id) => contents[r.routine.id]?.contains(id) ?? false))
            r.routine.id,
      },
    ),
  );
  if (choice == null || !context.mounted) return;

  if (choice.createNew) {
    context.push(AppRoutes.newRoutine, extra: ids);
    return;
  }

  final defaults = await defaultSetsFor(ref, ids);
  final added = await repo.appendExercises(
    routineIds: choice.routineIds.toList(),
    exerciseIds: ids,
    sets: defaults,
  );
  if (!context.mounted) return;
  HapticFeedback.mediumImpact();
  final names = routines
      .where((r) => added.containsKey(r.routine.id))
      .map((r) => r.routine.name)
      .join(', ');
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(names.isEmpty ? l10n.nothingAdded : l10n.addedToRoutines(names)),
  ));
}

class _Choice {
  const _Choice({this.routineIds = const {}, this.createNew = false});

  final Set<int> routineIds;
  final bool createNew;
}

class _RoutineChooser extends StatefulWidget {
  const _RoutineChooser({
    required this.exerciseCount,
    required this.routines,
    required this.complete,
  });

  final int exerciseCount;
  final List<RoutineSummary> routines;
  final Set<int> complete;

  @override
  State<_RoutineChooser> createState() => _RoutineChooserState();
}

class _RoutineChooserState extends State<_RoutineChooser> {
  final _selected = <int>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Text(l10n.chooseRoutinesTitle, style: theme.textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              l10n.chooseRoutinesBody(widget.exerciseCount),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final r in widget.routines) ...[
                  _RoutineOption(
                    name: r.routine.name,
                    subtitle: widget.complete.contains(r.routine.id)
                        ? l10n.alreadyAdded
                        : l10n.routineSummary(r.exerciseNames.length, r.setCount),
                    selected: _selected.contains(r.routine.id),
                    enabled: !widget.complete.contains(r.routine.id),
                    onTap: () => setState(() => _selected.contains(r.routine.id)
                        ? _selected.remove(r.routine.id)
                        : _selected.add(r.routine.id)),
                  ),
                  const SizedBox(height: 8),
                ],
                Glass(
                  radius: 18,
                  shadow: false,
                  tint: AppColors.volt,
                  tintStrength: dark ? 0.12 : 0.3,
                  padding: const EdgeInsets.all(14),
                  onTap: () => Navigator.pop(context, const _Choice(createNew: true)),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_rounded, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.chooseRoutinesNew, style: theme.textTheme.titleSmall),
                            Text(
                              l10n.chooseRoutinesNewBody,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.routines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: FilledButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () => Navigator.pop(context, _Choice(routineIds: {..._selected})),
                child: Text(l10n.chooseRoutinesAdd(_selected.length)),
              ),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _RoutineOption extends StatelessWidget {
  const _RoutineOption({
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Glass(
        radius: 18,
        shadow: false,
        padding: const EdgeInsets.all(14),
        onTap: enabled ? onTap : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleSmall),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: selected || !enabled ? scheme.primary : Colors.transparent,
                border: Border.all(
                  color: selected || !enabled ? scheme.primary : scheme.onSurfaceVariant,
                  width: 1.6,
                ),
              ),
              child: selected || !enabled
                  ? Icon(Icons.check_rounded, size: 18, color: scheme.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Planned exercises for one body part (muscle plan page).
final plannedExercisesProvider =
    StreamProvider.autoDispose.family<List<PlannedExerciseUsage>, String>(
  (ref, bodyPart) =>
      ref.watch(routineRepositoryProvider).watchPlannedExercises(bodyPart),
);
