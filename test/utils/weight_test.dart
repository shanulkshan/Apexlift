import 'package:flutter_test/flutter_test.dart';
import 'package:oxlift/core/utils/duration.dart';
import 'package:oxlift/core/utils/weight.dart';
import 'package:oxlift/features/settings/settings_controller.dart';

void main() {
  group('units', () {
    test('kg is stored as-is; lb converts both ways', () {
      expect(WeightUnit.kg.toKg(100), 100);
      expect(WeightUnit.lb.toKg(100), closeTo(45.359, 0.001));
      expect(WeightUnit.lb.fromKg(WeightUnit.lb.toKg(135)), closeTo(135, 1e-9));
    });

    test('formatting trims zeros and snaps lb to 0.1', () {
      expect(formatWeight(80, WeightUnit.kg), '80');
      expect(formatWeight(82.5, WeightUnit.kg), '82.5');
      expect(formatWeight(20, WeightUnit.lb), '44.1');
      expect(formatVolume(12450, WeightUnit.kg), '12,450 kg');
      expect(formatVolume(0, WeightUnit.kg), '0 kg');
    });

    test('parses comma decimals', () {
      expect(parseNumber('82,5'), 82.5);
      expect(parseNumber(' 60 '), 60);
      expect(parseNumber(''), isNull);
      expect(parseNumber('abc'), isNull);
    });
  });

  group('plate calculator', () {
    test('loads heaviest plates first, per side', () {
      final p = calculatePlates(target: 100, bar: 20, plates: WeightUnit.kg.plates);
      expect(p.perSide, [25, 15]);
      expect(p.remainder, 0);
    });

    test('handles small plates without float drift', () {
      final p = calculatePlates(target: 62.5, bar: 20, plates: WeightUnit.kg.plates);
      expect(p.perSide, [20, 1.25]);
      expect(p.remainder, 0);
    });

    test('reports what cannot be loaded', () {
      final p = calculatePlates(target: 21, bar: 20, plates: WeightUnit.kg.plates);
      expect(p.perSide, isEmpty);
      expect(p.remainder, closeTo(1, 1e-9));
    });

    test('bar only or lighter needs no plates', () {
      expect(calculatePlates(target: 20, bar: 20, plates: const [25]).perSide, isEmpty);
      expect(calculatePlates(target: 10, bar: 20, plates: const [25]).perSide, isEmpty);
    });

    test('lb plates', () {
      final p = calculatePlates(target: 225, bar: 45, plates: WeightUnit.lb.plates);
      expect(p.perSide, [45, 45]);
    });
  });

  test('clock formatting', () {
    expect(formatClock(const Duration(seconds: 65)), '1:05');
    expect(formatClock(const Duration(hours: 1, minutes: 2, seconds: 5)), '1:02:05');
    expect(formatDurationShort(const Duration(minutes: 45)), '45 min');
    expect(formatDurationShort(const Duration(minutes: 72)), '1 h 12 min');
  });
}
