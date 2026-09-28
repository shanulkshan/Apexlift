import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';

enum WeightUnit { kg, lb }

@immutable
class AppSettings {
  const AppSettings({required this.themeMode, required this.unit});

  final ThemeMode themeMode;
  final WeightUnit unit;

  AppSettings copyWith({ThemeMode? themeMode, WeightUnit? unit}) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        unit: unit ?? this.unit,
      );
}

class SettingsController extends Notifier<AppSettings> {
  static const _themeKey = 'settings.themeMode';
  static const _unitKey = 'settings.unit';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      // Dark-first: gyms are dim and most lifters prefer it.
      themeMode: ThemeMode.values.asNameMap()[prefs.getString(_themeKey)] ??
          ThemeMode.dark,
      unit: WeightUnit.values.asNameMap()[prefs.getString(_unitKey)] ??
          WeightUnit.kg,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_themeKey, mode.name);
  }

  Future<void> setUnit(WeightUnit unit) async {
    state = state.copyWith(unit: unit);
    await _prefs.setString(_unitKey, unit.name);
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
