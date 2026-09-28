import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/text.dart';
import '../../core/widgets/glass/ambient_background.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_controls.dart';
import '../../data/db/app_database.dart';
import '../../data/exercises/exercise_repository.dart';
import '../../l10n/app_localizations.dart';
import '../library/library_providers.dart';
import '../library/widgets/exercise_gif.dart';

/// Multi-select exercise picker. Pops with the chosen ids, in tap order.
class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({
    super.key,
    this.initialBodyPart,
    this.single = false,
  });

  /// Pre-selects a body-part chip (e.g. when adding "chest" exercises).
  final String? initialBodyPart;

  /// Tapping an exercise returns it immediately (replace mode).
  final bool single;

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  late ExerciseFilter _filter =
      (query: '', bodyPart: widget.initialBodyPart, equipment: null);
  final _selected = <String>[];

  void _toggle(String id) {
    HapticFeedback.selectionClick();
    if (widget.single) {
      context.pop([id]);
      return;
    }
    setState(() => _selected.contains(id) ? _selected.remove(id) : _selected.add(id));
  }

  /// Make a custom exercise and select it straight away.
  Future<void> _createCustom() async {
    final id = await context
        .push<String>(AppRoutes.newCustomExercise(bodyPart: _filter.bodyPart));
    if (id == null || !mounted) return;
    if (widget.single) {
      context.pop([id]);
    } else {
      setState(() => _selected.add(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final results = ref.watch(exerciseSearchProvider(_filter));
    final items = results.value ?? const <Exercise>[];

    return AmbientBackdrop(
      child: Scaffold(
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
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.single ? l10n.pickerReplaceTitle : l10n.pickerTitle,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _createCustom,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(l10n.pickerCreate),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(120),
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.15,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: GlassSearchField(
                          hint: l10n.librarySearchHint,
                          onChanged: (q) => setState(() => _filter = (
                                query: q,
                                bodyPart: _filter.bodyPart,
                                equipment: _filter.equipment,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 42,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            for (final part in [null, ...bodyPartOptions]) ...[
                              GlassChip(
                                label: part?.titleCase ?? l10n.libraryAll,
                                selected: _filter.bodyPart == part,
                                onTap: () => setState(() => _filter = (
                                      query: _filter.query,
                                      bodyPart: part,
                                      equipment: _filter.equipment,
                                    )),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  16, 14, 16, 110 + MediaQuery.paddingOf(context).bottom),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final e = items[i];
                  final order = _selected.indexOf(e.id);
                  return _PickerTile(
                    exercise: e,
                    order: order < 0 ? null : order + 1,
                    onTap: () => _toggle(e.id),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AnimatedSlide(
          offset: _selected.isEmpty ? const Offset(0, 2) : Offset.zero,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selected.isEmpty
                    ? null
                    : () => context.pop(List<String>.of(_selected)),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.pickerAdd(_selected.length)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.exercise,
    required this.order,
    required this.onTap,
  });

  final Exercise exercise;
  final int? order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = order != null;
    final dark = theme.brightness == Brightness.dark;
    return Glass(
      radius: 20,
      padding: const EdgeInsets.all(8),
      tint: selected ? AppColors.volt : null,
      tintStrength: dark ? 0.14 : 0.3,
      shadow: false,
      onTap: onTap,
      child: Row(
        children: [
          ExerciseGif(url: exercise.gifUrl, size: 56, radius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name.titleCase,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  [
                    if (exercise.isCustom) AppLocalizations.of(context).customBadge,
                    ...exercise.targetMuscles.take(1),
                    ...exercise.equipments.take(1),
                  ].map((s) => s.titleCase).join(' · '),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? theme.colorScheme.primary : Colors.transparent,
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                width: 1.5,
              ),
            ),
            child: selected
                ? Text('$order',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: theme.colorScheme.onPrimary))
                : null,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
