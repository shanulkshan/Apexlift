import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/glass/ambient_background.dart';
import '../../core/widgets/glass/glass.dart';
import '../../data/profile/user_profile.dart';
import '../../l10n/app_localizations.dart';
import '../onboarding/profile_form.dart';
import '../settings/settings_controller.dart';
import 'user_profile_controller.dart';

/// Edit the onboarding answers later, from Profile.
class BodyEditScreen extends ConsumerStatefulWidget {
  const BodyEditScreen({super.key});

  @override
  ConsumerState<BodyEditScreen> createState() => _BodyEditScreenState();
}

class _BodyEditScreenState extends ConsumerState<BodyEditScreen> {
  late UserProfile _draft = ref.read(userProfileProvider).copyWith(
        age: () => ref.read(userProfileProvider).age ?? defaultAge,
        heightCm: () => ref.read(userProfileProvider).heightCm ?? defaultHeightCm,
        weightKg: () => ref.read(userProfileProvider).weightKg ?? defaultWeightKg,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unit = ref.watch(settingsProvider.select((s) => s.unit));

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
                    icon: Icons.close_rounded,
                    tooltip: l10n.cancel,
                    blur: false,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(l10n.profileBodyTitle,
                        style: theme.textTheme.headlineSmall),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size(84, 44)),
                    onPressed: () async {
                      await ref
                          .read(userProfileProvider.notifier)
                          .save(_draft.copyWith(onboarded: true));
                      if (context.mounted) context.pop();
                    },
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  16, 0, 16, 32 + MediaQuery.paddingOf(context).bottom),
              sliver: SliverList.list(children: [
                AboutYouForm(
                  profile: _draft,
                  onChanged: (p) => setState(() => _draft = p),
                ),
                BodyForm(
                  profile: _draft,
                  unit: unit,
                  onChanged: (p) => setState(() => _draft = p),
                  onUnitChanged: ref.read(settingsProvider.notifier).setUnit,
                ),
                TrainingForm(
                  profile: _draft,
                  onChanged: (p) => setState(() => _draft = p),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
