/// Build-time configuration, injected with
/// `flutter run --dart-define-from-file=env/dev.json`.
///
/// Only public values belong here (the Supabase *publishable* key is safe to
/// ship; access is enforced by row-level security). Never add the secret key.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// False when the app was started without the env file (e.g. plain
  /// `flutter run`); cloud features stay off and the app runs offline-only.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
