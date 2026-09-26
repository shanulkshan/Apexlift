# Oxlift roadmap

Flutter app for gym-goers, shipping to Google Play and the App Store.

**Stack:** Flutter · Riverpod 3 · go_router · Drift (offline-first local DB) · Supabase (Auth, Postgres sync, Storage) · Sentry (crashes) · FCM (push only) · ExerciseDB for exercise content.

**Principle:** everything works offline, because gyms have bad signal. The local Drift database is the source of truth. Supabase syncs it in the background.

---

## Phase 1: Foundation ✅ (current)
- Project setup, Volt dark/light theme, bundled Barlow fonts, placeholder logo
- 5-tab navigation: Today, Library, Workouts, Progress, Profile
- **Exercise library**
  - 1,500 exercises from ExerciseDB, downloaded once and cached. The download resumes if interrupted.
  - Search (multi-word), body-part chips, equipment filter
  - Detail page: animated GIF, target and secondary muscles, equipment, step-by-step instructions
  - GIFs cached on disk for a year
- Settings: theme (dark/light/system), weight unit (kg/lb)
- English strings in ARB files, ready for translation

## Phase 2: Workouts (next)
- **Routines:** create, rename, reorder and duplicate. Add exercises from the library.
- **Per-exercise targets:** sets × reps × weight, rest time, notes. Set types: warm-up, working, drop set, failure. Supersets.
- **Split templates:** PPL, Upper/Lower, Full Body, Bro split
- **Live workout:**
  - Tick off sets, with last session's numbers shown inline
  - Auto rest timer with vibration and a notification
  - Keep-awake, plate calculator, add or swap exercises mid-workout
  - Finish summary
- **Custom exercises:** users can add their own (the `isCustom` column already exists)

## Phase 3: Progress
- Workout history calendar and streaks
- Per-exercise charts: top weight, estimated 1RM (Epley), volume
- Automatic PR detection with a celebration
- Weekly sets per muscle group and a front/back muscle heatmap
- Body tracking: weight, body-fat %, measurements, progress photos with a compare slider

## Phase 4: Accounts and cloud
- Supabase Auth: Google, Apple (required on iOS when other social logins exist), email
- Supabase Postgres sync of routines, workouts and body data (row-level security, last-write-wins per record, offline queue); progress photos in Supabase Storage
- Sentry crash reporting; analytics TBD

## Phase 5: Smart and motivation
- Progressive overload suggestions (e.g. "hit 3×10 → try +2.5 kg")
- Warm-up set generator
- Achievements and badges, challenges
- Share a workout summary card (Instagram/WhatsApp)
- Reminders ("Leg day 🦵") via local notifications; FCM only for server push

## Phase 6: Polish and localisation
- Sinhala (si) and Tamil (ta) translations, reviewed by native speakers
- Final logo, app icon, splash screen, store screenshots
- Accessibility pass (text scale, contrast, screen readers)

## Phase 7: Coach mode (from feature list #22)
- Coach and client roles. Coach assigns programs and sees client logs.
- Likely a Pro/paid tier

## Monetisation (freemium, to decide before Phase 4)
- Free: library, unlimited logging, basic charts
- Pro: advanced analytics, AI program generator, coach features, unlimited custom routines. In-app purchases via RevenueCat or `in_app_purchase`.

---

## ⚠️ Must fix before public launch
1. **Exercise data source.** The free ExerciseDB host (`oss.exercisedb.dev`) is marked "not for production" by its maintainers and has strict rate limits. Before launch, either:
   - buy a paid ExerciseDB/AscendAPI plan and proxy it through a Supabase Edge Function, so the API key isn't in the app; or
   - license a dataset and serve it from our own storage (Supabase Storage + CDN).

   Only [`exercise_db_api.dart`](../lib/data/exercises/exercise_db_api.dart) needs to change. Confirm redistribution and commercial terms in writing.
2. **Upgrade Flutter** (`flutter upgrade`), then lift the `drift`/`drift_flutter` version pins in `pubspec.yaml`.
3. The bundle ID is `com.shanuka.oxlift` (Android and iOS). It can't be changed after the first store upload, so confirm it before then.
4. Set up release signing for Android (keystore) and iOS (Apple Developer account, $99/yr). A Mac is required to build and upload iOS.
5. Write a privacy policy. Both stores require one, especially for health data and photos.
6. **Name: Oxlift** (chosen 2026-09-26). Before launch, check the stores, the `oxlift.app`/`.com` domains, `@oxlift` social handles and trademarks (NIPO Sri Lanka, WIPO Global Brand Database).
7. Move Supabase to the Pro plan before launch, because free projects pause after 7 days of inactivity.
