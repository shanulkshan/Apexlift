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

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get discard => 'Discard';

  @override
  String get ok => 'OK';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get workoutsStartEmpty => 'Start empty workout';

  @override
  String get workoutsStartEmptyBody => 'Pick exercises as you go.';

  @override
  String get workoutsInProgress => 'Workout in progress';

  @override
  String get workoutsResume => 'Resume';

  @override
  String get workoutsMyRoutines => 'My routines';

  @override
  String get workoutsNewRoutine => 'New';

  @override
  String get workoutsNoRoutines => 'No routines yet';

  @override
  String get workoutsNoRoutinesBody =>
      'Build your first plan: pick exercises and set your sets, reps and weights.';

  @override
  String get workoutsCreateRoutine => 'Create routine';

  @override
  String get workoutsRecent => 'Recent workouts';

  @override
  String get routineStart => 'Start';

  @override
  String get routineEdit => 'Edit';

  @override
  String get routineDuplicate => 'Duplicate';

  @override
  String get routineDelete => 'Delete';

  @override
  String routineDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get routineDeleteBody =>
      'Workouts you already logged from it are kept.';

  @override
  String routineCopyName(String name) {
    return '$name (copy)';
  }

  @override
  String routineSummary(int exercises, int sets) {
    String _temp0 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercises exercises',
      one: '1 exercise',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets sets',
      one: '1 set',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get editorNewTitle => 'New routine';

  @override
  String get editorEditTitle => 'Edit routine';

  @override
  String get editorNameHint => 'Routine name, e.g. Push day';

  @override
  String get editorNameRequired => 'Give your routine a name.';

  @override
  String get editorExercisesRequired => 'Add at least one exercise.';

  @override
  String get editorEmpty => 'No exercises yet. Add some from the library.';

  @override
  String get editorDiscardTitle => 'Discard changes?';

  @override
  String get editorDiscardBody => 'Your edits to this routine will be lost.';

  @override
  String get setColumnSet => 'SET';

  @override
  String get setColumnPrevious => 'PREVIOUS';

  @override
  String get setColumnReps => 'REPS';

  @override
  String get setColumnTarget => 'TARGET';

  @override
  String get addSet => 'Add set';

  @override
  String get removeExercise => 'Remove exercise';

  @override
  String get exerciseNotes => 'Notes';

  @override
  String restLabel(String time) {
    return 'Rest $time';
  }

  @override
  String get restOff => 'Rest off';

  @override
  String get restTimeTitle => 'Rest between sets';

  @override
  String get setTypeHint =>
      'Tap the set number to switch between warm-up (W), working, drop (D) and failure (F) sets.';

  @override
  String get pickerTitle => 'Add exercises';

  @override
  String pickerAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count exercises',
      one: 'Add 1 exercise',
    );
    return '$_temp0';
  }

  @override
  String get workoutDefaultName => 'Workout';

  @override
  String get workoutFinish => 'Finish';

  @override
  String get workoutAddExercises => 'Add exercises';

  @override
  String get workoutDiscard => 'Discard workout';

  @override
  String get workoutDiscardTitle => 'Discard this workout?';

  @override
  String get workoutDiscardBody =>
      'Everything logged in this session will be deleted.';

  @override
  String get workoutNothingDoneTitle => 'No sets completed';

  @override
  String get workoutNothingDoneBody =>
      'Tick off at least one set to finish, or discard the workout.';

  @override
  String get workoutFinishTitle => 'Finish workout?';

  @override
  String get workoutFinishBody =>
      'Nice work! Your sets will be saved to your history.';

  @override
  String workoutFinishUnticked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unticked sets will be removed.',
      one: '1 unticked set will be removed.',
    );
    return '$_temp0';
  }

  @override
  String get workoutEmpty => 'Add your first exercise to get going.';

  @override
  String get workoutMinimize => 'Minimise';

  @override
  String get restTimerTitle => 'Rest';

  @override
  String get restTimerSkip => 'Skip';

  @override
  String get alreadyActiveTitle => 'Workout in progress';

  @override
  String get alreadyActiveBody =>
      'Finish or discard your current workout before starting a new one.';

  @override
  String get plateTitle => 'Plate calculator';

  @override
  String get plateTarget => 'Target weight';

  @override
  String get plateBar => 'Bar';

  @override
  String get platePerSide => 'Per side';

  @override
  String plateRemainder(String amount) {
    return '$amount can\'t be loaded with standard plates.';
  }

  @override
  String get plateBarOnly => 'Just the bar.';

  @override
  String get summaryTitle => 'Workout complete!';

  @override
  String get summaryDuration => 'Duration';

  @override
  String get summaryVolume => 'Volume';

  @override
  String get summarySets => 'Sets';

  @override
  String get summaryExercises => 'Exercises';

  @override
  String get summaryDone => 'Done';

  @override
  String get summarySaveRoutine => 'Save as routine';

  @override
  String get summarySavedRoutine => 'Saved to your routines';

  @override
  String setsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
    );
    return '$_temp0';
  }

  @override
  String bestSet(String set) {
    return 'Best $set';
  }

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingFinish => 'Let\'s lift';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Oxlift';

  @override
  String get onboardingWelcomeBody =>
      'Answer a few quick questions and we\'ll suggest starting weights and estimate your workout time and calories. You can change this anytime.';

  @override
  String get onboardingAboutTitle => 'About you';

  @override
  String get onboardingAboutBody =>
      'Used to tune starting weights and calorie estimates.';

  @override
  String get onboardingBodyTitle => 'Your body';

  @override
  String get onboardingBodyBody =>
      'Rough numbers are fine. You can update them as you progress.';

  @override
  String get onboardingTrainingTitle => 'Your training';

  @override
  String get onboardingTrainingBody =>
      'This sets your default reps and how heavy we start you.';

  @override
  String get profileSex => 'Sex';

  @override
  String get profileSexMale => 'Male';

  @override
  String get profileSexFemale => 'Female';

  @override
  String get profileSexUnspecified => 'Other';

  @override
  String get profileAge => 'Age';

  @override
  String get profileYears => 'years';

  @override
  String get profileHeight => 'Height';

  @override
  String get profileWeight => 'Body weight';

  @override
  String get profileExperience => 'Experience';

  @override
  String get profileGoal => 'Main goal';

  @override
  String get profileBodyTitle => 'Body & training';

  @override
  String get profileBodySection => 'Body & training';

  @override
  String get profileBodyEmpty =>
      'Add your body details for better starting weights and calorie estimates.';

  @override
  String get profileBodyEdit => 'Edit';

  @override
  String get experienceBeginner => 'Beginner';

  @override
  String get experienceBeginnerBody =>
      'New to lifting, or back after a long break';

  @override
  String get experienceIntermediate => 'Intermediate';

  @override
  String get experienceIntermediateBody =>
      '6 months to 2 years of consistent training';

  @override
  String get experienceAdvanced => 'Advanced';

  @override
  String get experienceAdvancedBody => '2+ years, you know your numbers';

  @override
  String get goalMuscle => 'Build muscle';

  @override
  String get goalStrength => 'Get stronger';

  @override
  String get goalEndurance => 'Endurance';

  @override
  String get goalGeneral => 'General fitness';

  @override
  String kcal(int value) {
    return '$value kcal';
  }

  @override
  String estimateLine(String duration, int kcal) {
    return '~$duration · ~$kcal kcal';
  }

  @override
  String get estimateTitle => 'Estimated workout';

  @override
  String get estimateHint =>
      'Rough guide based on your body profile, sets, reps, weights and rest times.';

  @override
  String get summaryCalories => 'Calories';

  @override
  String plannedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises planned',
      one: '1 exercise planned',
      zero: 'None planned yet',
    );
    return '$_temp0';
  }

  @override
  String musclePlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises in your plans',
      one: '1 exercise in your plans',
      zero: 'Nothing planned yet',
    );
    return '$_temp0';
  }

  @override
  String muscleEmptyTitle(String muscle) {
    return 'No $muscle exercises planned';
  }

  @override
  String get muscleEmptyBody =>
      'Add some to one of your routines to start training this muscle.';

  @override
  String muscleAdd(String muscle) {
    return 'Add $muscle exercises';
  }

  @override
  String get muscleUsedIn => 'In your routines';

  @override
  String get chooseRoutinesTitle => 'Add to which routines?';

  @override
  String chooseRoutinesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises selected',
      one: '1 exercise selected',
    );
    return '$_temp0';
  }

  @override
  String chooseRoutinesAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add to $count routines',
      one: 'Add to 1 routine',
      zero: 'Choose routines',
    );
    return '$_temp0';
  }

  @override
  String get chooseRoutinesNew => 'Create a new routine';

  @override
  String get chooseRoutinesNewBody => 'Start a routine with these exercises';

  @override
  String get alreadyAdded => 'Already added';

  @override
  String addedToRoutines(String names) {
    return 'Added to $names';
  }

  @override
  String get nothingAdded =>
      'Those exercises are already in the selected routines.';
}
