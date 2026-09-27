import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/text.dart';
import '../../core/widgets/glass/ambient_background.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_controls.dart';
import '../../data/db/app_database.dart';
import '../../data/templates/split_templates.dart';
import '../../data/templates/template_installer.dart';
import '../../l10n/app_localizations.dart';
import '../library/library_providers.dart';
import '../library/widgets/exercise_gif.dart';
import 'set_defaults.dart';

extension TemplateText on AppLocalizations {
  String templateTitle(TemplateKey key) => switch (key) {
        TemplateKey.ppl => templatePplTitle,
        TemplateKey.upperLower => templateUpperLowerTitle,
        TemplateKey.fullBody => templateFullBodyTitle,
        TemplateKey.broSplit => templateBroSplitTitle,
        TemplateKey.bodyweight => templateBodyweightTitle,
      };

  String templateBody(TemplateKey key) => switch (key) {
        TemplateKey.ppl => templatePplBody,
        TemplateKey.upperLower => templateUpperLowerBody,
        TemplateKey.fullBody => templateFullBodyBody,
        TemplateKey.broSplit => templateBroSplitBody,
        TemplateKey.bodyweight => templateBodyweightBody,
      };

  String templateDayName(String key) => switch (key) {
        'push' => dayPush,
        'pull' => dayPull,
        'legs' => dayLegs,
        'upper' => dayUpper,
        'lower' => dayLower,
        'fullBodyA' => dayFullBodyA,
        'fullBodyB' => dayFullBodyB,
        'chest' => dayChest,
        'back' => dayBack,
        'shoulders' => dayShoulders,
        'arms' => dayArms,
        'bodyweight' => dayBodyweight,
        _ => key,
      };

  String templateLevel(TemplateLevel level) => switch (level) {
        TemplateLevel.beginner => templateLevelBeginner,
        TemplateLevel.intermediate => templateLevelIntermediate,
      };
}

/// All bundled plans.
class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AmbientBackdrop(
      child: Scaffold(
        body: CustomScrollView(
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
                    icon: Icons.arrow_back_rounded,
                    tooltip: l10n.back,
                    blur: false,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 14),
                  Text(l10n.templatesTitle, style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, 32 + MediaQuery.paddingOf(context).bottom),
              sliver: SliverList.separated(
                itemCount: splitTemplates.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _TemplateCard(template: splitTemplates[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template});

  final SplitTemplate template;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Glass(
      radius: 26,
      padding: const EdgeInsets.all(18),
      onTap: () => context.push(AppRoutes.template(template.key.name)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.templateTitle(template.key),
                    style: theme.textTheme.titleLarge),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.templateBody(template.key),
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                icon: Icons.calendar_month_rounded,
                label: l10n.templateDays(template.daysPerWeek),
                color: dark ? AppColors.volt : AppColors.voltDeep,
              ),
              _Pill(
                icon: Icons.signal_cellular_alt_rounded,
                label: l10n.templateLevel(template.level),
                color: theme.colorScheme.secondary,
              ),
              _Pill(
                icon: Icons.list_alt_rounded,
                label: l10n.templateRoutines(template.days.length),
                color: theme.colorScheme.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

/// One plan: its days and exercises, and a button to install it.
class TemplateDetailScreen extends ConsumerStatefulWidget {
  const TemplateDetailScreen({super.key, required this.templateKey});

  final String templateKey;

  @override
  ConsumerState<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends ConsumerState<TemplateDetailScreen> {
  bool _installing = false;

  SplitTemplate get _template =>
      splitTemplates.firstWhere((t) => t.key.name == widget.templateKey);

  Future<void> _install(Map<String, Exercise> catalog) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _installing = true);
    final ids = catalog.keys.toList();
    final sets = await defaultSetsFor(ref, ids);
    final created = await installTemplate(
      _template,
      routines: ref.read(routineRepositoryProvider),
      catalog: catalog,
      sets: sets,
      dayName: l10n.templateDayName,
    );
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.templateAdded(created.length))));
    context.go(AppRoutes.workouts);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final template = _template;
    final ids = template.exerciseIds.toSet().toList()..sort();
    final catalog = ref.watch(exercisesByIdsProvider(ids.join(','))).value;
    final available = catalog?.length ?? 0;
    final days = template.days
        .where((d) => d.exercises.any((e) => catalog?.containsKey(e.id) ?? false))
        .length;

    return AmbientBackdrop(
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: FilledButton.icon(
            onPressed: catalog == null || available == 0 || _installing
                ? null
                : () => _install(catalog),
            icon: const Icon(Icons.playlist_add_rounded),
            label: Text(available == 0
                ? l10n.templateCatalogMissing
                : l10n.templateAdd(days)),
          ),
        ),
        body: CustomScrollView(
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
                    icon: Icons.arrow_back_rounded,
                    tooltip: l10n.back,
                    blur: false,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(l10n.templateTitle(template.key),
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.templateBody(template.key), style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 6),
                    Text(
                      l10n.templateSetsNote,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            for (final day in template.days) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: SectionLabel(l10n.templateDayName(day.key)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Glass(
                    radius: 22,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        for (final e in day.exercises)
                          if (catalog?[e.id] case final exercise?)
                            ListTile(
                              leading: ExerciseGif(url: exercise.gifUrl, size: 44, radius: 10),
                              title: Text(exercise.name.titleCase,
                                  style: theme.textTheme.titleSmall),
                              subtitle: Text(
                                exercise.targetMuscles.firstOrNull?.titleCase ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
