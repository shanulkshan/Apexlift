// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Oxlift';

  @override
  String get navToday => 'Today';

  @override
  String get navLibrary => 'Library';

  @override
  String get navWorkouts => 'Workouts';

  @override
  String get navProgress => 'Progress';

  @override
  String get navProfile => 'Profile';

  @override
  String get back => 'Back';

  @override
  String get todayGoodMorning => 'Good morning';

  @override
  String get todayGoodAfternoon => 'Good afternoon';

  @override
  String get todayGoodEvening => 'Good evening';

  @override
  String get todayGreeting => 'Ready to lift?';

  @override
  String todayHeroTitle(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Explore $countString exercises';
  }

  @override
  String get todayHeroBody =>
      'Animated demos, target muscles and step-by-step form cues.';

  @override
  String get todayHeroCta => 'Browse library';

  @override
  String get todayThisWeek => 'This week';

  @override
  String get statWorkouts => 'Workouts';

  @override
  String get statVolume => 'Volume';

  @override
  String get statStreak => 'Day streak';

  @override
  String get todayStatsHint =>
      'Log your first workout to start filling these in.';

  @override
  String get todayTrainByMuscle => 'Train by muscle';

  @override
  String get todaySeeAll => 'See all';

  @override
  String get libraryTitle => 'Library';

  @override
  String get librarySearchHint => 'Search exercises';

  @override
  String get libraryAll => 'All';

  @override
  String get libraryEquipment => 'Equipment';

  @override
  String get libraryAnyEquipment => 'Any equipment';

  @override
  String get libraryEmpty => 'No exercises match your filters.';

  @override
  String get libraryClearFilters => 'Clear filters';

  @override
  String libraryCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String librarySyncing(int done, int total) {
    return 'Downloading exercise library… $done/$total';
  }

  @override
  String get librarySyncFailed =>
      'Couldn\'t download the exercise library. Check your connection.';

  @override
  String get retry => 'Retry';

  @override
  String get exerciseTarget => 'Target';

  @override
  String get exerciseSecondary => 'Secondary';

  @override
  String get exerciseMuscles => 'Muscles worked';

  @override
  String get exerciseEquipment => 'Equipment';

  @override
  String get exerciseBodyPart => 'Body part';

  @override
  String get exerciseInstructions => 'How to do it';

  @override
  String get exerciseNotFound => 'Exercise not found.';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get workoutsComingSoon =>
      'Build routines, set your sets, reps and weights, and run live workouts with a rest timer.';

  @override
  String get progressComingSoon =>
      'Charts, personal records, body measurements and your training heatmap.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileGuest => 'Guest lifter';

  @override
  String get profileGuestBody =>
      'Sign in to back up and sync your training. Coming soon.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsUnits => 'Weight unit';

  @override
  String get settingsUnitKg => 'kg';

  @override
  String get settingsUnitLb => 'lb';

  @override
  String get settingsCatalog => 'Exercise library';

  @override
  String get settingsCatalogResync => 'Re-download exercise library';

  @override
  String get settingsCatalogAttribution =>
      'Exercise data and animations by ExerciseDB';
}
