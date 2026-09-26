import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/text.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_controls.dart';
import '../../core/widgets/glass/glass_sheet.dart';
import '../../core/widgets/glass/glass_nav_bar.dart';
import '../../data/db/app_database.dart';
import '../../l10n/app_localizations.dart';
import 'library_providers.dart';
import 'widgets/exercise_gif.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  late final _search = TextEditingController(
    text: ref.read(libraryFilterProvider).query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // Search + chips; kept fixed so the pinned header has a stable height.
  static const _headerHeight = 124.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final exercises = ref.watch(exerciseListProvider);
    final items = exercises.value ?? const <Exercise>[];

    return Scaffold(
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            titleSpacing: 20,
            toolbarHeight: 60,
            title: Text(
              l10n.libraryTitle,
              style: theme.textTheme.headlineMedium,
            ),
            flexibleSpace: const GlassBar(),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(_headerHeight),
              // Header height is fixed, so cap text scaling inside it.
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.15,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: GlassSearchField(
                        controller: _search,
                        hint: l10n.librarySearchHint,
                        onChanged: ref
                            .read(libraryFilterProvider.notifier)
                            .setQuery,
                      ),
                    ),
                    const _FilterBar(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _SyncBanner()),
          if (exercises.isLoading && items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                onClear: () {
                  _search.clear();
                  ref.read(libraryFilterProvider.notifier)
                    ..setQuery('')
                    ..setBodyPart(null)
                    ..setEquipment(null);
                },
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  l10n.libraryCount(items.length),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, navBarClearance(context)),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _ExerciseTile(exercise: items[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(libraryFilterProvider);
    final notifier = ref.read(libraryFilterProvider.notifier);

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          GlassChip(
            icon: Icons.tune_rounded,
            label: filter.equipment?.titleCase ?? l10n.libraryEquipment,
            selected: filter.equipment != null,
            onTap: () => _pickEquipment(context, ref),
          ),
          const SizedBox(width: 8),
          GlassChip(
            label: l10n.libraryAll,
            selected: filter.bodyPart == null,
            onTap: () => notifier.setBodyPart(null),
          ),
          for (final part in bodyPartOptions) ...[
            const SizedBox(width: 8),
            GlassChip(
              label: part.titleCase,
              selected: filter.bodyPart == part,
              onTap: () => notifier.setBodyPart(part),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickEquipment(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(libraryFilterProvider).equipment;
    // Wrapped so "Any equipment" (null) is distinguishable from a dismiss.
    final picked = await showGlassSheet<({String? value})>(
      context: context,
      scrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (context, controller) {
          final theme = Theme.of(context);
          return ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Text(
                  l10n.libraryEquipment,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              for (final option in [null, ...equipmentOptions])
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  title: Text(option?.titleCase ?? l10n.libraryAnyEquipment),
                  trailing: option == current
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: theme.brightness == Brightness.dark
                              ? AppColors.volt
                              : AppColors.voltDeep,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, (value: option)),
                ),
            ],
          );
        },
      ),
    );
    if (picked != null) {
      ref.read(libraryFilterProvider.notifier).setEquipment(picked.value);
    }
  }
}

class _SyncBanner extends ConsumerWidget {
  const _SyncBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(catalogSyncProvider);

    return switch (state) {
      CatalogSyncing(:final done, :final total) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Glass(
          radius: 18,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_download_rounded, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.librarySyncing(done, total),
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: total == 0 ? null : done / total,
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
      CatalogFailed() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Glass(
          radius: 18,
          tint: theme.colorScheme.error,
          tintStrength: 0.15,
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Icon(Icons.cloud_off_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.librarySyncFailed)),
              TextButton(
                onPressed: () => ref.read(catalogSyncProvider.notifier).sync(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(32, 32, 32, navBarClearance(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Glass(
            shape: BoxShape.circle,
            child: const SizedBox.square(
              dimension: 76,
              child: Icon(Icons.search_off_rounded, size: 34),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.libraryEmpty,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.filter_alt_off_rounded),
            label: Text(l10n.libraryClearFilters),
          ),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final target = exercise.targetMuscles.firstOrNull;
    final equipment = exercise.equipments.firstOrNull;

    return Glass(
      radius: 24,
      padding: const EdgeInsets.all(10),
      onTap: () => context.go(AppRoutes.exercise(exercise.id)),
      child: Row(
        children: [
          Hero(
            tag: 'exercise-gif-${exercise.id}',
            child: ExerciseGif(url: exercise.gifUrl, size: 72, radius: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name.titleCase,
                  style: theme.textTheme.titleMedium?.copyWith(height: 1.25),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (target != null)
                      _MiniTag(
                        label: target.titleCase,
                        color: dark ? AppColors.volt : AppColors.voltDeep,
                      ),
                    if (equipment != null)
                      _MiniTag(
                        label: equipment.titleCase,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(100),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
