# Oxlift

Get strong as an ox. A Flutter gym app for Android and iOS.

See [docs/ROADMAP.md](docs/ROADMAP.md) for features, phases and launch blockers.

## Getting started

```sh
flutter pub get
cp env/example.json env/dev.json   # then fill in the Supabase URL + publishable key
flutter run --dart-define-from-file=env/dev.json
```

After changing Drift tables (`lib/data/db/`), regenerate code:

```sh
dart run build_runner build
```

Strings live in `lib/l10n/app_en.arb`. `flutter run` and `flutter gen-l10n` regenerate `AppLocalizations`.

## Project layout

```
lib/
  app.dart, main.dart
  core/        theme, router, shared widgets, top-level providers
  data/        Drift database, ExerciseDB client, repositories
  features/    one folder per screen area (library, today, workouts, ...)
  l10n/        ARB translation files
test/          unit tests (API, repository) and an app-level widget test
```

## Credits
- Exercise data and animations: [ExerciseDB](https://github.com/ExerciseDB/exercisedb-api) (free tier, development only; see the roadmap)
- Fonts: Barlow and Barlow Condensed (SIL Open Font License, `assets/fonts/OFL.txt`)

## App icon
The placeholder ox mark is drawn in code (`lib/core/widgets/ox_logo.dart`). To regenerate the launcher icons after changing it:

```sh
flutter test tool/render_icon_test.dart   # writes assets/brand/icon*.png
dart run flutter_launcher_icons
```
