import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_controls.dart';
import '../../core/widgets/glass/glass_nav_bar.dart';
import '../../core/widgets/glass/page_title.dart';
import '../../core/widgets/ox_logo.dart';
import '../../l10n/app_localizations.dart';
import '../library/library_providers.dart';
import '../settings/settings_controller.dart';

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
          padding: const EdgeInsets.only(bottom: kGlassNavBarClearance),
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
