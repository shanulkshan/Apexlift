import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Oxlift'**
  String get appTitle;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get navWorkouts;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @todayGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get todayGoodMorning;

  /// No description provided for @todayGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get todayGoodAfternoon;

  /// No description provided for @todayGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get todayGoodEvening;

  /// No description provided for @todayGreeting.
  ///
  /// In en, this message translates to:
  /// **'Ready to lift?'**
  String get todayGreeting;

  /// No description provided for @todayHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore {count} exercises'**
  String todayHeroTitle(int count);

  /// No description provided for @todayHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Animated demos, target muscles and step-by-step form cues.'**
  String get todayHeroBody;

  /// No description provided for @todayHeroCta.
  ///
  /// In en, this message translates to:
  /// **'Browse library'**
  String get todayHeroCta;

  /// No description provided for @todayThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get todayThisWeek;

  /// No description provided for @statWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get statWorkouts;

  /// No description provided for @statVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get statVolume;

  /// No description provided for @statStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get statStreak;

  /// No description provided for @todayStatsHint.
  ///
  /// In en, this message translates to:
  /// **'Log your first workout to start filling these in.'**
  String get todayStatsHint;

  /// No description provided for @todayTrainByMuscle.
  ///
  /// In en, this message translates to:
  /// **'Train by muscle'**
  String get todayTrainByMuscle;

  /// No description provided for @todaySeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get todaySeeAll;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get librarySearchHint;

  /// No description provided for @libraryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get libraryAll;

  /// No description provided for @libraryEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get libraryEquipment;

  /// No description provided for @libraryAnyEquipment.
  ///
  /// In en, this message translates to:
  /// **'Any equipment'**
  String get libraryAnyEquipment;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No exercises match your filters.'**
  String get libraryEmpty;

  /// No description provided for @libraryClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get libraryClearFilters;

  /// No description provided for @libraryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise} other{{count} exercises}}'**
  String libraryCount(int count);

  /// No description provided for @librarySyncing.
  ///
  /// In en, this message translates to:
  /// **'Downloading exercise library… {done}/{total}'**
  String librarySyncing(int done, int total);

  /// No description provided for @librarySyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download the exercise library. Check your connection.'**
  String get librarySyncFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @exerciseTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get exerciseTarget;

  /// No description provided for @exerciseSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get exerciseSecondary;

  /// No description provided for @exerciseMuscles.
  ///
  /// In en, this message translates to:
  /// **'Muscles worked'**
  String get exerciseMuscles;

  /// No description provided for @exerciseEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get exerciseEquipment;

  /// No description provided for @exerciseBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Body part'**
  String get exerciseBodyPart;

  /// No description provided for @exerciseInstructions.
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get exerciseInstructions;

  /// No description provided for @exerciseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Exercise not found.'**
  String get exerciseNotFound;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// No description provided for @workoutsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Build routines, set your sets, reps and weights, and run live workouts with a rest timer.'**
  String get workoutsComingSoon;

  /// No description provided for @progressComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Charts, personal records, body measurements and your training heatmap.'**
  String get progressComingSoon;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest lifter'**
  String get profileGuest;

  /// No description provided for @profileGuestBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to back up and sync your training. Coming soon.'**
  String get profileGuestBody;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsUnits.
  ///
  /// In en, this message translates to:
  /// **'Weight unit'**
  String get settingsUnits;

  /// No description provided for @settingsUnitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get settingsUnitKg;

  /// No description provided for @settingsUnitLb.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get settingsUnitLb;

  /// No description provided for @settingsCatalog.
  ///
  /// In en, this message translates to:
  /// **'Exercise library'**
  String get settingsCatalog;

  /// No description provided for @settingsCatalogResync.
  ///
  /// In en, this message translates to:
  /// **'Re-download exercise library'**
  String get settingsCatalogResync;

  /// No description provided for @settingsCatalogAttribution.
  ///
  /// In en, this message translates to:
  /// **'Exercise data and animations by ExerciseDB'**
  String get settingsCatalogAttribution;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @workoutsStartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Start empty workout'**
  String get workoutsStartEmpty;

  /// No description provided for @workoutsStartEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Pick exercises as you go.'**
  String get workoutsStartEmptyBody;

  /// No description provided for @workoutsInProgress.
  ///
  /// In en, this message translates to:
  /// **'Workout in progress'**
  String get workoutsInProgress;

  /// No description provided for @workoutsResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get workoutsResume;

  /// No description provided for @workoutsMyRoutines.
  ///
  /// In en, this message translates to:
  /// **'My routines'**
  String get workoutsMyRoutines;

  /// No description provided for @workoutsNewRoutine.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get workoutsNewRoutine;

  /// No description provided for @workoutsNoRoutines.
  ///
  /// In en, this message translates to:
  /// **'No routines yet'**
  String get workoutsNoRoutines;

  /// No description provided for @workoutsNoRoutinesBody.
  ///
  /// In en, this message translates to:
  /// **'Build your first plan: pick exercises and set your sets, reps and weights.'**
  String get workoutsNoRoutinesBody;

  /// No description provided for @workoutsCreateRoutine.
  ///
  /// In en, this message translates to:
  /// **'Create routine'**
  String get workoutsCreateRoutine;

  /// No description provided for @workoutsRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts'**
  String get workoutsRecent;

  /// No description provided for @routineStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get routineStart;

  /// No description provided for @routineEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get routineEdit;

  /// No description provided for @routineDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get routineDuplicate;

  /// No description provided for @routineDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get routineDelete;

  /// No description provided for @routineDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String routineDeleteConfirm(String name);

  /// No description provided for @routineDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Workouts you already logged from it are kept.'**
  String get routineDeleteBody;

  /// No description provided for @routineCopyName.
  ///
  /// In en, this message translates to:
  /// **'{name} (copy)'**
  String routineCopyName(String name);

  /// No description provided for @routineSummary.
  ///
  /// In en, this message translates to:
  /// **'{exercises, plural, =1{1 exercise} other{{exercises} exercises}} · {sets, plural, =1{1 set} other{{sets} sets}}'**
  String routineSummary(int exercises, int sets);

  /// No description provided for @editorNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New routine'**
  String get editorNewTitle;

  /// No description provided for @editorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit routine'**
  String get editorEditTitle;

  /// No description provided for @editorNameHint.
  ///
  /// In en, this message translates to:
  /// **'Routine name, e.g. Push day'**
  String get editorNameHint;

  /// No description provided for @editorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your routine a name.'**
  String get editorNameRequired;

  /// No description provided for @editorExercisesRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one exercise.'**
  String get editorExercisesRequired;

  /// No description provided for @editorEmpty.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet. Add some from the library.'**
  String get editorEmpty;

  /// No description provided for @editorDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get editorDiscardTitle;

  /// No description provided for @editorDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your edits to this routine will be lost.'**
  String get editorDiscardBody;

  /// No description provided for @setColumnSet.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get setColumnSet;

  /// No description provided for @setColumnPrevious.
  ///
  /// In en, this message translates to:
  /// **'PREVIOUS'**
  String get setColumnPrevious;

  /// No description provided for @setColumnReps.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get setColumnReps;

  /// No description provided for @setColumnTarget.
  ///
  /// In en, this message translates to:
  /// **'TARGET'**
  String get setColumnTarget;

  /// No description provided for @addSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get addSet;

  /// No description provided for @removeExercise.
  ///
  /// In en, this message translates to:
  /// **'Remove exercise'**
  String get removeExercise;

  /// No description provided for @exerciseNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get exerciseNotes;

  /// No description provided for @restLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest {time}'**
  String restLabel(String time);

  /// No description provided for @restOff.
  ///
  /// In en, this message translates to:
  /// **'Rest off'**
  String get restOff;

  /// No description provided for @restTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest between sets'**
  String get restTimeTitle;

  /// No description provided for @setTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the set number to switch between warm-up (W), working, drop (D) and failure (F) sets.'**
  String get setTypeHint;

  /// No description provided for @pickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add exercises'**
  String get pickerTitle;

  /// No description provided for @pickerAdd.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 exercise} other{Add {count} exercises}}'**
  String pickerAdd(int count);

  /// No description provided for @workoutDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutDefaultName;

  /// No description provided for @workoutFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get workoutFinish;

  /// No description provided for @workoutAddExercises.
  ///
  /// In en, this message translates to:
  /// **'Add exercises'**
  String get workoutAddExercises;

  /// No description provided for @workoutDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard workout'**
  String get workoutDiscard;

  /// No description provided for @workoutDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this workout?'**
  String get workoutDiscardTitle;

  /// No description provided for @workoutDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Everything logged in this session will be deleted.'**
  String get workoutDiscardBody;

  /// No description provided for @workoutNothingDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No sets completed'**
  String get workoutNothingDoneTitle;

  /// No description provided for @workoutNothingDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Tick off at least one set to finish, or discard the workout.'**
  String get workoutNothingDoneBody;

  /// No description provided for @workoutFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish workout?'**
  String get workoutFinishTitle;

  /// No description provided for @workoutFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Nice work! Your sets will be saved to your history.'**
  String get workoutFinishBody;

  /// No description provided for @workoutFinishUnticked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unticked set will be removed.} other{{count} unticked sets will be removed.}}'**
  String workoutFinishUnticked(int count);

  /// No description provided for @workoutEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add your first exercise to get going.'**
  String get workoutEmpty;

  /// No description provided for @workoutMinimize.
  ///
  /// In en, this message translates to:
  /// **'Minimise'**
  String get workoutMinimize;

  /// No description provided for @restTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get restTimerTitle;

  /// No description provided for @restTimerSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get restTimerSkip;

  /// No description provided for @alreadyActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout in progress'**
  String get alreadyActiveTitle;

  /// No description provided for @alreadyActiveBody.
  ///
  /// In en, this message translates to:
  /// **'Finish or discard your current workout before starting a new one.'**
  String get alreadyActiveBody;

  /// No description provided for @plateTitle.
  ///
  /// In en, this message translates to:
  /// **'Plate calculator'**
  String get plateTitle;

  /// No description provided for @plateTarget.
  ///
  /// In en, this message translates to:
  /// **'Target weight'**
  String get plateTarget;

  /// No description provided for @plateBar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get plateBar;

  /// No description provided for @platePerSide.
  ///
  /// In en, this message translates to:
  /// **'Per side'**
  String get platePerSide;

  /// No description provided for @plateRemainder.
  ///
  /// In en, this message translates to:
  /// **'{amount} can\'t be loaded with standard plates.'**
  String plateRemainder(String amount);

  /// No description provided for @plateBarOnly.
  ///
  /// In en, this message translates to:
  /// **'Just the bar.'**
  String get plateBarOnly;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout complete!'**
  String get summaryTitle;

  /// No description provided for @summaryDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get summaryDuration;

  /// No description provided for @summaryVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get summaryVolume;

  /// No description provided for @summarySets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get summarySets;

  /// No description provided for @summaryExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get summaryExercises;

  /// No description provided for @summaryDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get summaryDone;

  /// No description provided for @summarySaveRoutine.
  ///
  /// In en, this message translates to:
  /// **'Save as routine'**
  String get summarySaveRoutine;

  /// No description provided for @summarySavedRoutine.
  ///
  /// In en, this message translates to:
  /// **'Saved to your routines'**
  String get summarySavedRoutine;

  /// No description provided for @setsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 set} other{{count} sets}}'**
  String setsCount(int count);

  /// No description provided for @bestSet.
  ///
  /// In en, this message translates to:
  /// **'Best {set}'**
  String bestSet(String set);

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Let\'s lift'**
  String get onboardingFinish;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Oxlift'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Answer a few quick questions and we\'ll suggest starting weights and estimate your workout time and calories. You can change this anytime.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get onboardingAboutTitle;

  /// No description provided for @onboardingAboutBody.
  ///
  /// In en, this message translates to:
  /// **'Used to tune starting weights and calorie estimates.'**
  String get onboardingAboutBody;

  /// No description provided for @onboardingBodyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your body'**
  String get onboardingBodyTitle;

  /// No description provided for @onboardingBodyBody.
  ///
  /// In en, this message translates to:
  /// **'Rough numbers are fine. You can update them as you progress.'**
  String get onboardingBodyBody;

  /// No description provided for @onboardingTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your training'**
  String get onboardingTrainingTitle;

  /// No description provided for @onboardingTrainingBody.
  ///
  /// In en, this message translates to:
  /// **'This sets your default reps and how heavy we start you.'**
  String get onboardingTrainingBody;

  /// No description provided for @profileSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get profileSex;

  /// No description provided for @profileSexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profileSexMale;

  /// No description provided for @profileSexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profileSexFemale;

  /// No description provided for @profileSexUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get profileSexUnspecified;

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @profileYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get profileYears;

  /// No description provided for @profileHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get profileHeight;

  /// No description provided for @profileWeight.
  ///
  /// In en, this message translates to:
  /// **'Body weight'**
  String get profileWeight;

  /// No description provided for @profileExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get profileExperience;

  /// No description provided for @profileGoal.
  ///
  /// In en, this message translates to:
  /// **'Main goal'**
  String get profileGoal;

  /// No description provided for @profileBodyTitle.
  ///
  /// In en, this message translates to:
  /// **'Body & training'**
  String get profileBodyTitle;

  /// No description provided for @profileBodySection.
  ///
  /// In en, this message translates to:
  /// **'Body & training'**
  String get profileBodySection;

  /// No description provided for @profileBodyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add your body details for better starting weights and calorie estimates.'**
  String get profileBodyEmpty;

  /// No description provided for @profileBodyEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileBodyEdit;

  /// No description provided for @experienceBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get experienceBeginner;

  /// No description provided for @experienceBeginnerBody.
  ///
  /// In en, this message translates to:
  /// **'New to lifting, or back after a long break'**
  String get experienceBeginnerBody;

  /// No description provided for @experienceIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get experienceIntermediate;

  /// No description provided for @experienceIntermediateBody.
  ///
  /// In en, this message translates to:
  /// **'6 months to 2 years of consistent training'**
  String get experienceIntermediateBody;

  /// No description provided for @experienceAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get experienceAdvanced;

  /// No description provided for @experienceAdvancedBody.
  ///
  /// In en, this message translates to:
  /// **'2+ years, you know your numbers'**
  String get experienceAdvancedBody;

  /// No description provided for @goalMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get goalMuscle;

  /// No description provided for @goalStrength.
  ///
  /// In en, this message translates to:
  /// **'Get stronger'**
  String get goalStrength;

  /// No description provided for @goalEndurance.
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get goalEndurance;

  /// No description provided for @goalGeneral.
  ///
  /// In en, this message translates to:
  /// **'General fitness'**
  String get goalGeneral;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String kcal(int value);

  /// No description provided for @estimateLine.
  ///
  /// In en, this message translates to:
  /// **'~{duration} · ~{kcal} kcal'**
  String estimateLine(String duration, int kcal);

  /// No description provided for @estimateTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated workout'**
  String get estimateTitle;

  /// No description provided for @estimateHint.
  ///
  /// In en, this message translates to:
  /// **'Rough guide based on your body profile, sets, reps, weights and rest times.'**
  String get estimateHint;

  /// No description provided for @summaryCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get summaryCalories;

  /// No description provided for @plannedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None planned yet} =1{1 exercise planned} other{{count} exercises planned}}'**
  String plannedCount(int count);

  /// No description provided for @musclePlanned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing planned yet} =1{1 exercise in your plans} other{{count} exercises in your plans}}'**
  String musclePlanned(int count);

  /// No description provided for @muscleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No {muscle} exercises planned'**
  String muscleEmptyTitle(String muscle);

  /// No description provided for @muscleEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add some to one of your routines to start training this muscle.'**
  String get muscleEmptyBody;

  /// No description provided for @muscleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add {muscle} exercises'**
  String muscleAdd(String muscle);

  /// No description provided for @muscleUsedIn.
  ///
  /// In en, this message translates to:
  /// **'In your routines'**
  String get muscleUsedIn;

  /// No description provided for @chooseRoutinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to which routines?'**
  String get chooseRoutinesTitle;

  /// No description provided for @chooseRoutinesBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise selected} other{{count} exercises selected}}'**
  String chooseRoutinesBody(int count);

  /// No description provided for @chooseRoutinesAdd.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Choose routines} =1{Add to 1 routine} other{Add to {count} routines}}'**
  String chooseRoutinesAdd(int count);

  /// No description provided for @chooseRoutinesNew.
  ///
  /// In en, this message translates to:
  /// **'Create a new routine'**
  String get chooseRoutinesNew;

  /// No description provided for @chooseRoutinesNewBody.
  ///
  /// In en, this message translates to:
  /// **'Start a routine with these exercises'**
  String get chooseRoutinesNewBody;

  /// No description provided for @alreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get alreadyAdded;

  /// No description provided for @addedToRoutines.
  ///
  /// In en, this message translates to:
  /// **'Added to {names}'**
  String addedToRoutines(String names);

  /// No description provided for @nothingAdded.
  ///
  /// In en, this message translates to:
  /// **'Those exercises are already in the selected routines.'**
  String get nothingAdded;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
