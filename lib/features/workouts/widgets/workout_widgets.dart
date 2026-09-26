import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration.dart';
import '../../../core/widgets/glass/glass.dart';
import '../../../core/widgets/glass/glass_sheet.dart';
import '../../../data/db/app_database.dart';
import '../../../l10n/app_localizations.dart';

/// Rebuilds [builder] every [period] (for live clocks and counters).
class TickingBuilder extends StatefulWidget {
  const TickingBuilder({
    super.key,
    required this.builder,
    this.period = const Duration(seconds: 1),
  });

  final WidgetBuilder builder;
  final Duration period;

  @override
  State<TickingBuilder> createState() => _TickingBuilderState();
}

class _TickingBuilderState extends State<TickingBuilder> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.period, (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

/// "~45 min · ~210 kcal" with small icons.
class EstimateText extends StatelessWidget {
  const EstimateText({
    super.key,
    required this.duration,
    required this.kcal,
    this.style,
    this.approximate = true,
  });

  final Duration duration;
  final int kcal;
  final TextStyle? style;
  final bool approximate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final base = style ??
        theme.textTheme.labelMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final prefix = approximate ? '~' : '';
    // Wrap rather than Row so narrow cards / large text never overflow.
    return Wrap(
      spacing: 12,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 15, color: base?.color),
            const SizedBox(width: 4),
            Text('$prefix${formatDurationShort(duration)}', style: base),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded,
                size: 15, color: theme.colorScheme.tertiary),
            const SizedBox(width: 4),
            Text('$prefix${l10n.kcal(kcal)}', style: base),
          ],
        ),
      ],
    );
  }
}

/// Live-updating "time since [start]" text.
class ElapsedClock extends StatefulWidget {
  const ElapsedClock({super.key, required this.start, this.style});

  final DateTime start;
  final TextStyle? style;

  @override
  State<ElapsedClock> createState() => _ElapsedClockState();
}

class _ElapsedClockState extends State<ElapsedClock> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    // Started eagerly: a lazy `late` initializer would never run until
    // dispose, leaving the clock frozen between parent rebuilds.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(
        formatClock(DateTime.now().difference(widget.start)),
        style: widget.style,
      );
}

/// Colour for a set type's badge.
Color setTypeColor(SetType type, ColorScheme scheme) => switch (type) {
      SetType.warmup => AppColors.ember,
      SetType.working => scheme.onSurface,
      SetType.drop => AppColors.ice,
      SetType.failure => AppColors.danger,
    };

/// Label for a set: W/D/F for special sets, otherwise its working-set number.
String setLabel(SetType type, int workingNumber) => switch (type) {
      SetType.warmup => 'W',
      SetType.drop => 'D',
      SetType.failure => 'F',
      SetType.working => '$workingNumber',
    };

/// Working-set numbers for a list of set types (warm-ups etc. don't count).
List<int> workingNumbers(Iterable<SetType> types) {
  var n = 0;
  return [for (final t in types) t == SetType.working ? ++n : n];
}

/// Tappable set badge that cycles the set type.
class SetBadge extends StatelessWidget {
  const SetBadge({
    super.key,
    required this.type,
    required this.number,
    required this.onTap,
  });

  final SetType type;
  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = setTypeColor(type, theme.colorScheme);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          setLabel(type, number),
          style: theme.textTheme.labelLarge?.copyWith(color: color),
        ),
      ),
    );
  }
}

/// Compact centred number field used in set rows.
class SetNumberField extends StatelessWidget {
  const SetNumberField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint,
    this.decimal = false,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;
  final bool decimal;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Glass(
      radius: 12,
      shadow: false,
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textAlign: TextAlign.center,
          textInputAction: textInputAction,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                decimal ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]')),
            LengthLimitingTextInputFormatter(decimal ? 7 : 4),
          ],
          style: theme.textTheme.titleMedium,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            hintText: hint,
            hintStyle: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rest duration chip: "Rest 1:30", tap to change.
class RestChip extends StatelessWidget {
  const RestChip({super.key, required this.seconds, required this.onChanged});

  final int seconds;
  final ValueChanged<int> onChanged;

  static const options = [0, 30, 45, 60, 75, 90, 120, 150, 180, 240, 300];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final label = seconds == 0
        ? l10n.restOff
        : l10n.restLabel(formatClock(Duration(seconds: seconds)));
    return Glass(
      radius: 100,
      shadow: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      onTap: () async {
        final picked = await showGlassSheet<int>(
          context: context,
          builder: (context) => _RestPicker(selected: seconds),
        );
        if (picked != null) onChanged(picked);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined,
              size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _RestPicker extends StatelessWidget {
  const _RestPicker({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.restTimeTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in RestChip.options)
                ChoiceChip(
                  label: Text(s == 0
                      ? l10n.restOff
                      : formatClock(Duration(seconds: s))),
                  selected: s == selected,
                  onSelected: (_) => Navigator.pop(context, s),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
