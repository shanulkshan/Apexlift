import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/ox_logo.dart';
import '../../data/profile/user_profile.dart';
import '../../l10n/app_localizations.dart';
import '../profile/user_profile_controller.dart';
import '../settings/settings_controller.dart';
import 'profile_form.dart';

/// First-launch setup: welcome, about you, body, training. Everything is
/// optional; "Skip" keeps the app's defaults.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;
  late UserProfile _draft = ref.read(userProfileProvider).copyWith(
        age: () => ref.read(userProfileProvider).age ?? defaultAge,
        heightCm: () => ref.read(userProfileProvider).heightCm ?? defaultHeightCm,
        weightKg: () => ref.read(userProfileProvider).weightKg ?? defaultWeightKg,
      );

  static const _pageCount = 4;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int page) {
    HapticFeedback.selectionClick();
    _pages.animateToPage(page,
        duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
  }

  Future<void> _finish() async {
    await ref
        .read(userProfileProvider.notifier)
        .save(_draft.copyWith(onboarded: true));
    HapticFeedback.mediumImpact();
    if (mounted) context.go(AppRoutes.today);
  }

  Future<void> _skip() async {
    await ref.read(userProfileProvider.notifier).skipOnboarding();
    if (mounted) context.go(AppRoutes.today);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unit = ref.watch(settingsProvider.select((s) => s.unit));
    final last = _page == _pageCount - 1;

    Widget step(String title, String subtitle, Widget child) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(subtitle,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            child,
          ],
        );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back, progress, skip.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  AnimatedOpacity(
                    opacity: _page == 0 ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: _page == 0,
                      child: GlassIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: l10n.back,
                        blur: false,
                        onPressed: () => _go(_page - 1),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _pageCount; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _page ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i <= _page
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton(onPressed: _skip, child: Text(l10n.onboardingSkip)),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  const _Welcome(),
                  step(
                    l10n.onboardingAboutTitle,
                    l10n.onboardingAboutBody,
                    AboutYouForm(
                      profile: _draft,
                      onChanged: (p) => setState(() => _draft = p),
                    ),
                  ),
                  step(
                    l10n.onboardingBodyTitle,
                    l10n.onboardingBodyBody,
                    BodyForm(
                      profile: _draft,
                      unit: unit,
                      onChanged: (p) => setState(() => _draft = p),
                      onUnitChanged: ref.read(settingsProvider.notifier).setUnit,
                    ),
                  ),
                  step(
                    l10n.onboardingTrainingTitle,
                    l10n.onboardingTrainingBody,
                    TrainingForm(
                      profile: _draft,
                      onChanged: (p) => setState(() => _draft = p),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: last ? _finish : () => _go(_page + 1),
                  child: Text(_page == 0
                      ? l10n.onboardingStart
                      : last
                          ? l10n.onboardingFinish
                          : l10n.onboardingContinue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppColors.volt.withValues(alpha: 0.35),
                  blurRadius: 60,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const OxLogo(size: 120),
          ),
          const SizedBox(height: 32),
          Text(l10n.onboardingWelcomeTitle,
              textAlign: TextAlign.center, style: theme.textTheme.displaySmall),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingWelcomeBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
