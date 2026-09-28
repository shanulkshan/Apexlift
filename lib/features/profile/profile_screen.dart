import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/weight.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_controls.dart';
import '../../core/widgets/glass/glass_nav_bar.dart';
import '../../core/widgets/glass/page_title.dart';
import '../../core/widgets/ox_logo.dart';
import '../../data/profile/user_profile.dart';
import '../../l10n/app_localizations.dart';
import '../library/library_providers.dart';
import '../settings/settings_controller.dart';
import 'user_profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final syncing = ref.watch(catalogSyncProvider) is CatalogSyncing;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(bottom: navBarClearance(context)),
          children: [
            PageTitle(title: l10n.profileTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Glass(
                    radius: 28,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.volt, Color(0xFF7FB800)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.volt.withValues(alpha: 0.35),
                                blurRadius: 18,
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: CustomPaint(
                              painter: OxMarkPainter(
                                color: AppColors.ink,
                                cutout: AppColors.volt,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.profileGuest,
                                  style: theme.textTheme.titleLarge),
                              const SizedBox(height: 2),
                              Text(
                                l10n.profileGuestBody,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SectionLabel(
                    l10n.profileBodySection,
                    trailing: TextButton.icon(
                      onPressed: () => context.push(AppRoutes.editBody),
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: Text(l10n.profileBodyEdit),
                    ),
                  ),
                  const _BodySummary(),
                  SectionLabel(l10n.settingsAppearance),
                  GlassSegmented<ThemeMode>(
                    segments: [
                      (ThemeMode.dark, l10n.settingsThemeDark),
                      (ThemeMode.light, l10n.settingsThemeLight),
                      (ThemeMode.system, l10n.settingsThemeSystem),
                    ],
                    selected: settings.themeMode,
                    onChanged: controller.setThemeMode,
                  ),
                  SectionLabel(l10n.settingsUnits),
                  GlassSegmented<WeightUnit>(
                    segments: [
                      (WeightUnit.kg, l10n.settingsUnitKg),
                      (WeightUnit.lb, l10n.settingsUnitLb),
                    ],
                    selected: settings.unit,
                    onChanged: controller.setUnit,
                  ),
                  SectionLabel(l10n.settingsCatalog),
                  Opacity(
                    opacity: syncing ? 0.5 : 1,
                    child: Glass(
                      radius: 22,
                      padding: const EdgeInsets.all(16),
                      onTap: syncing
                          ? null
                          : () => ref
                              .read(catalogSyncProvider.notifier)
                              .sync(force: true),
                      child: Row(
                        children: [
                          Glass(
                            shape: BoxShape.circle,
                            shadow: false,
                            child: const SizedBox.square(
                              dimension: 42,
                              child: Icon(Icons.sync_rounded, size: 22),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.settingsCatalogResync,
                                    style: theme.textTheme.titleSmall),
                                Text(
                                  l10n.settingsCatalogAttribution,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One-line summary of the body profile, e.g. "Male · 28 y · 178 cm · 80 kg".
class _BodySummary extends ConsumerWidget {
  const _BodySummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = ref.watch(userProfileProvider);
    final unit = ref.watch(settingsProvider.select((s) => s.unit));

    final facts = <String>[
      if (p.sex != Sex.unspecified)
        p.sex == Sex.male ? l10n.profileSexMale : l10n.profileSexFemale,
      if (p.age != null) '${p.age} ${l10n.profileYears}',
      if (p.heightCm != null) '${p.heightCm!.round()} cm',
      if (p.weightKg != null) '${formatWeight(p.weightKg!, unit)} ${unit.symbol}',
    ];
    final training = [
      switch (p.experience) {
        Experience.beginner => l10n.experienceBeginner,
        Experience.intermediate => l10n.experienceIntermediate,
        Experience.advanced => l10n.experienceAdvanced,
      },
      switch (p.goal) {
        TrainingGoal.muscle => l10n.goalMuscle,
        TrainingGoal.strength => l10n.goalStrength,
        TrainingGoal.endurance => l10n.goalEndurance,
        TrainingGoal.general => l10n.goalGeneral,
      },
    ];

    return Glass(
      radius: 22,
      padding: const EdgeInsets.all(16),
      onTap: () => context.push(AppRoutes.editBody),
      child: Row(
        children: [
          Glass(
            shape: BoxShape.circle,
            shadow: false,
            child: const SizedBox.square(
              dimension: 42,
              child: Icon(Icons.monitor_weight_outlined, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facts.isEmpty ? l10n.profileBodyEmpty : facts.join(' · '),
                  style: facts.isEmpty
                      ? theme.textTheme.bodyMedium
                      : theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  training.join(' · '),
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
