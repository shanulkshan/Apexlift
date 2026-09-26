import '../../features/settings/settings_controller.dart';

const kgPerLb = 0.45359237;

extension WeightUnitConversion on WeightUnit {
  /// Kilograms (storage) -> this unit (display).
  double fromKg(double kg) => this == WeightUnit.kg ? kg : kg / kgPerLb;

  /// This unit (user input) -> kilograms (storage).
  double toKg(double value) => this == WeightUnit.kg ? value : value * kgPerLb;

  String get symbol => name; // "kg" / "lb"

  /// Standard bar weight in this unit.
  double get barWeight => this == WeightUnit.kg ? 20 : 45;

  /// Commonly available plates in this unit, heaviest first.
  List<double> get plates => this == WeightUnit.kg
      ? const [25, 20, 15, 10, 5, 2.5, 1.25]
      : const [45, 35, 25, 10, 5, 2.5];
}

/// "82.5", "80", "0.25" — at most two decimals, no trailing zeros.
String formatNumber(double value) {
  final fixed = value.toStringAsFixed(2);
  return fixed.contains('.')
      ? fixed.replaceFirst(RegExp(r'\.?0+$'), '')
      : fixed;
}

/// Formats stored kilograms in [unit], e.g. "82.5".
String formatWeight(double kg, WeightUnit unit) {
  // Snap lb display to 0.1 so 20 kg shows as 44.1, not 44.09.
  final v = unit.fromKg(kg);
  return formatNumber(unit == WeightUnit.lb ? (v * 10).round() / 10 : v);
}

/// Large volumes: "12,450" / "1.2 t" style is overkill here; use grouping.
String formatVolume(double kg, WeightUnit unit) {
  final v = unit.fromKg(kg).round();
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '$buf ${unit.symbol}';
}

/// Parses user input ("82,5" or "82.5") into a number, or null.
double? parseNumber(String input) {
  final cleaned = input.trim().replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

class PlateBreakdown {
  const PlateBreakdown({required this.perSide, required this.remainder});

  /// Plates to load on EACH side, heaviest first.
  final List<double> perSide;

  /// Weight that couldn't be made with available plates (0 when exact).
  final double remainder;
}

/// Greedy plate loading for [target] total on a [bar], using [plates]
/// (all in the same unit). Assumes unlimited pairs of each plate.
PlateBreakdown calculatePlates({
  required double target,
  required double bar,
  required List<double> plates,
}) {
  var perSide = (target - bar) / 2;
  if (perSide <= 0) return const PlateBreakdown(perSide: [], remainder: 0);
  final result = <double>[];
  for (final plate in plates) {
    // Epsilon guards against float drift (e.g. 2.5 * n).
    while (perSide + 1e-9 >= plate) {
      result.add(plate);
      perSide -= plate;
    }
  }
  final remainder = perSide * 2;
  return PlateBreakdown(
    perSide: result,
    remainder: remainder.abs() < 1e-6 ? 0 : remainder,
  );
}
