import 'package:flutter/material.dart';

import '../../../core/utils/weight.dart';
import '../../../core/widgets/glass/glass.dart';
import '../../../core/widgets/glass/glass_controls.dart';
import '../../../core/widgets/glass/glass_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/settings_controller.dart';

Future<void> showPlateCalculator(BuildContext context, WeightUnit unit) =>
    showGlassSheet(
      context: context,
      scrollControlled: true,
      builder: (context) => _PlateCalculator(unit: unit),
    );

class _PlateCalculator extends StatefulWidget {
  const _PlateCalculator({required this.unit});

  final WeightUnit unit;

  @override
  State<_PlateCalculator> createState() => _PlateCalculatorState();
}

class _PlateCalculatorState extends State<_PlateCalculator> {
  late double _bar = widget.unit.barWeight;
  double? _target;

  List<double> get _bars =>
      widget.unit == WeightUnit.kg ? const [20, 15, 10] : const [45, 35, 15];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unit = widget.unit;
    final result = _target == null
        ? null
        : calculatePlates(target: _target!, bar: _bar, plates: unit.plates);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.plateTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 14),
          Glass(
            radius: 18,
            shadow: false,
            child: TextField(
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
              onChanged: (v) => setState(() => _target = parseNumber(v)),
              decoration: InputDecoration(
                hintText: l10n.plateTarget,
                suffixText: unit.symbol,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
          ),
          SectionLabel(l10n.plateBar),
          GlassSegmented<double>(
            segments: [for (final b in _bars) (b, '${formatNumber(b)} ${unit.symbol}')],
            selected: _bar,
            onChanged: (b) => setState(() => _bar = b),
          ),
          if (result != null) ...[
            SectionLabel(l10n.platePerSide),
            if (result.perSide.isEmpty && result.remainder == 0)
              Text(l10n.plateBarOnly, style: theme.textTheme.bodyLarge)
            else ...[
              _BarDiagram(plates: result.perSide, unit: unit),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in _grouped(result.perSide))
                    Chip(label: Text('${entry.$2} × ${formatNumber(entry.$1)} ${unit.symbol}')),
                ],
              ),
            ],
            if (result.remainder > 0) ...[
              const SizedBox(height: 10),
              Text(
                l10n.plateRemainder('${formatNumber(result.remainder)} ${unit.symbol}'),
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static List<(double, int)> _grouped(List<double> plates) {
    final out = <(double, int)>[];
    for (final p in plates) {
      if (out.isNotEmpty && out.last.$1 == p) {
        out[out.length - 1] = (p, out.last.$2 + 1);
      } else {
        out.add((p, 1));
      }
    }
    return out;
  }
}

/// One side of a loaded barbell: sleeve with plates sized by weight.
class _BarDiagram extends StatelessWidget {
  const _BarDiagram({required this.plates, required this.unit});

  final List<double> plates;
  final WeightUnit unit;

  // Competition-style colours by rank (heaviest first).
  static const _colors = [
    Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFFFDD835),
    Color(0xFF43A047), Color(0xFFECEFF1), Color(0xFF424242), Color(0xFFB0BEC5),
  ];

  @override
  Widget build(BuildContext context) {
    final all = unit.plates;
    final heaviest = all.first;
    return SizedBox(
      height: 110,
      child: Row(
        children: [
          Container(width: 34, height: 12, color: Colors.grey.shade500),
          Container(width: 10, height: 34, color: Colors.grey.shade400),
          for (final p in plates)
            Container(
              width: 14,
              height: 40 + 70 * (p / heaviest),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: _colors[all.indexOf(p).clamp(0, _colors.length - 1)],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black26),
              ),
            ),
          Expanded(child: Container(height: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
