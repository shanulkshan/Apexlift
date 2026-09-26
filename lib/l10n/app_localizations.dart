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
