import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/text.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_controls.dart';
import '../../core/widgets/glass/glass_nav_bar.dart';
import '../../core/widgets/ox_logo.dart';
import '../../l10n/app_localizations.dart';
import '../library/library_providers.dart';
import '../settings/settings_controller.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.todayGoodMorning;
    if (hour < 17) return l10n.todayGoodAfternoon;
    return l10n.todayGoodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, kGlassNavBarClearance),
          children: [
            Row(
              children: [
                const OxLogo(size: 40, showWordmark: true),
                const Spacer(),
                GlassIconButton(
                  icon: Icons.person_rounded,
                  tooltip: l10n.navProfile,
                  blur: false,
                  onPressed: () => context.go(AppRoutes.profile),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              _greeting(l10n),
              style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500),
            ),
            Text(l10n.todayGreeting, style: theme.textTheme.displaySmall),
            const SizedBox(height: 20),
            const _HeroCard(),
            SectionLabel(l10n.todayThisWeek),
            const _WeekStats(),
            SectionLabel(
              l10n.todayTrainByMuscle,
              trailing: TextButton(
                onPressed: () {
                  ref.read(libraryFilterProvider.notifier).setBodyPart(null);
                  context.go(AppRoutes.library);
                },
                child: Text(l10n.todaySeeAll),
              ),
            ),
            const _MuscleGrid(),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends ConsumerWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final total = ref.watch(exerciseCountProvider).value ?? 0;

    return Glass(
      radius: 30,
      tint: AppColors.volt,
      tintStrength: dark ? 0.16 : 0.35,
      onTap: () {
        ref.read(libraryFilterProvider.notifier).setBodyPart(null);
        context.go(AppRoutes.library);
      },
      child: Stack(
        children: [
          // Oversized watermark ox, bleeding off the corner.
          Positioned(
            right: -34,
            bottom: -40,
            child: Opacity(
              opacity: dark ? 0.16 : 0.12,
              child: SizedBox.square(
                dimension: 170,
                child: CustomPaint(
                  painter: OxMarkPainter(
                    color: dark ? AppColors.volt : AppColors.ink,
                    cutout: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total > 0
                      ? l10n.todayHeroTitle(total)
                      : l10n.todayHeroCta,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 240,
                  child: Text(
                    l10n.todayHeroBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 18),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 14, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.todayHeroCta,
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded,
                            size: 18, color: theme.colorScheme.onPrimary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStats extends ConsumerWidget {
  const _WeekStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final unitLabel =
        unit == WeightUnit.kg ? l10n.settingsUnitKg : l10n.settingsUnitLb;

    // Workout logging arrives in Phase 2; until then these are true zeros.
    Widget stat(IconData icon, Color accent, String value, String label) =>
        Expanded(
          child: Glass(
            radius: 22,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: accent),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: theme.textTheme.headlineSmall),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );

    final dark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            stat(Icons.fitness_center_rounded,
                dark ? AppColors.volt : AppColors.voltDeep, '0', l10n.statWorkouts),
            const SizedBox(width: 10),
            stat(Icons.stacked_bar_chart_rounded, theme.colorScheme.secondary,
                '0 $unitLabel', l10n.statVolume),
            const SizedBox(width: 10),
            stat(Icons.local_fire_department_rounded,
                theme.colorScheme.tertiary, '0', l10n.statStreak),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
          child: Text(
            l10n.todayStatsHint,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _MuscleGrid extends ConsumerWidget {
  const _MuscleGrid();

  // Accent per body part, cycling through the brand palette.
  static const _accents = [
    AppColors.volt,
    AppColors.ice,
    AppColors.ember,
    Color(0xFFB78CFF),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final counts = ref.watch(bodyPartCountsProvider).value ?? const {};

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.3,
      children: [
        for (final (i, part) in bodyPartOptions.indexed)
          Glass(
            radius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            onTap: () {
              ref.read(libraryFilterProvider.notifier).setBodyPart(part);
              context.go(AppRoutes.library);
            },
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _accents[i % _accents.length],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        part.titleCase,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        l10n.libraryCount(counts[part] ?? 0),
                        maxLines: 1,
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
    );
  }
}
