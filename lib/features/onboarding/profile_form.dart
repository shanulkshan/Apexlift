import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/weight.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_controls.dart';
import '../../data/profile/user_profile.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_controller.dart';

/// Defaults shown before the user adjusts anything.
const defaultAge = 25;
const defaultHeightCm = 170.0;
const defaultWeightKg = 70.0;

/// Sex + age.
class AboutYouForm extends StatelessWidget {
  const AboutYouForm({super.key, required this.profile, required this.onChanged});

  final UserProfile profile;
  final ValueChanged<UserProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l10n.profileSex),
        GlassSegmented<Sex>(
          segments: [
            (Sex.male, l10n.profileSexMale),
            (Sex.female, l10n.profileSexFemale),
            (Sex.unspecified, l10n.profileSexUnspecified),
          ],
          selected: profile.sex,
          onChanged: (s) => onChanged(profile.copyWith(sex: s)),
        ),
        SectionLabel(l10n.profileAge),
        NumberStepper(
          value: (profile.age ?? defaultAge).toDouble(),
          min: 13,
          max: 90,
          step: 1,
          suffix: l10n.profileYears,
          onChanged: (v) => onChanged(profile.copyWith(age: () => v.round())),
        ),
      ],
    );
  }
}

/// Height + weight, with a kg/lb switch.
class BodyForm extends StatelessWidget {
  const BodyForm({
    super.key,
    required this.profile,
    required this.unit,
    required this.onChanged,
    required this.onUnitChanged,
  });

  final UserProfile profile;
  final WeightUnit unit;
  final ValueChanged<UserProfile> onChanged;
  final ValueChanged<WeightUnit> onUnitChanged;

  static String feetInches(double cm) {
    final totalInches = (cm / 2.54).round();
    return '${totalInches ~/ 12}′${totalInches % 12}″';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final height = profile.heightCm ?? defaultHeightCm;
    final weightKg = profile.weightKg ?? defaultWeightKg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l10n.profileHeight),
        NumberStepper(
          value: height,
          min: 120,
          max: 230,
          step: 1,
          suffix: 'cm',
          caption: feetInches(height),
          onChanged: (v) => onChanged(profile.copyWith(heightCm: () => v)),
        ),
        SectionLabel(
          l10n.profileWeight,
          trailing: SizedBox(
            width: 120,
            child: GlassSegmented<WeightUnit>(
              segments: [
                (WeightUnit.kg, l10n.settingsUnitKg),
                (WeightUnit.lb, l10n.settingsUnitLb),
              ],
              selected: unit,
              onChanged: onUnitChanged,
            ),
          ),
        ),
        NumberStepper(
          // Stepped in the display unit; stored in kg.
          value: (unit.fromKg(weightKg) * 2).round() / 2,
          min: unit == WeightUnit.kg ? 30 : 66,
          max: unit == WeightUnit.kg ? 250 : 550,
          step: unit == WeightUnit.kg ? 0.5 : 1,
          suffix: unit.symbol,
          onChanged: (v) => onChanged(profile.copyWith(weightKg: () => unit.toKg(v))),
        ),
      ],
    );
  }
}

/// Experience level + goal.
class TrainingForm extends StatelessWidget {
  const TrainingForm({super.key, required this.profile, required this.onChanged});

  final UserProfile profile;
  final ValueChanged<UserProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l10n.profileExperience),
        for (final (level, title, body) in [
          (Experience.beginner, l10n.experienceBeginner, l10n.experienceBeginnerBody),
          (Experience.intermediate, l10n.experienceIntermediate, l10n.experienceIntermediateBody),
          (Experience.advanced, l10n.experienceAdvanced, l10n.experienceAdvancedBody),
        ]) ...[
          _OptionCard(
            title: title,
            body: body,
            selected: profile.experience == level,
            onTap: () => onChanged(profile.copyWith(experience: level)),
          ),
          const SizedBox(height: 8),
        ],
        SectionLabel(l10n.profileGoal),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (goal, label) in [
              (TrainingGoal.muscle, l10n.goalMuscle),
              (TrainingGoal.strength, l10n.goalStrength),
              (TrainingGoal.endurance, l10n.goalEndurance),
              (TrainingGoal.general, l10n.goalGeneral),
            ])
              GlassChip(
                label: label,
                selected: profile.goal == goal,
                onTap: () => onChanged(profile.copyWith(goal: goal)),
              ),
          ],
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Glass(
      radius: 20,
      shadow: false,
      tint: selected ? AppColors.volt : null,
      tintStrength: dark ? 0.18 : 0.4,
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(
                  body,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? theme.colorScheme.primary : Colors.transparent,
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                width: 1.6,
              ),
            ),
            child: selected
                ? Icon(Icons.check_rounded, size: 16, color: theme.colorScheme.onPrimary)
                : null,
          ),
        ],
      ),
    );
  }
}

/// Big − value + control. Hold a button to change quickly.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.suffix,
    required this.onChanged,
    this.caption,
  });

  final double value;
  final double min;
  final double max;
  final double step;
  final String suffix;
  final String? caption;
  final ValueChanged<double> onChanged;

  void _nudge(double direction) {
    final next = (value + step * direction).clamp(min, max).toDouble();
    if (next != value) {
      HapticFeedback.selectionClick();
      onChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Glass(
      radius: 22,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          _RepeatButton(icon: Icons.remove_rounded, onStep: () => _nudge(-1)),
          Expanded(
            child: Column(
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: formatNumber(value),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    TextSpan(
                      text: ' $suffix',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ]),
                ),
                if (caption != null)
                  Text(caption!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          _RepeatButton(icon: Icons.add_rounded, onStep: () => _nudge(1)),
        ],
      ),
    );
  }
}

/// Glass circle button that repeats while held.
class _RepeatButton extends StatefulWidget {
  const _RepeatButton({required this.icon, required this.onStep});

  final IconData icon;
  final VoidCallback onStep;

  @override
  State<_RepeatButton> createState() => _RepeatButtonState();
}

class _RepeatButtonState extends State<_RepeatButton> {
  Timer? _repeat;

  void _stop() {
    _repeat?.cancel();
    _repeat = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPressStart: (_) {
          _repeat = Timer.periodic(
              const Duration(milliseconds: 80), (_) => widget.onStep());
        },
        onLongPressEnd: (_) => _stop(),
        onLongPressCancel: _stop,
        child: Glass(
          shape: BoxShape.circle,
          shadow: false,
          onTap: widget.onStep,
          child: SizedBox.square(dimension: 52, child: Icon(widget.icon)),
        ),
      );
}
