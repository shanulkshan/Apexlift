import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import '../../data/profile/user_profile.dart';

/// Persists the [UserProfile] in shared preferences. (Moves to the cloud
/// profile when accounts arrive in Phase 4.)
class UserProfileController extends Notifier<UserProfile> {
  static const _prefix = 'profile.';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  UserProfile build() {
    final p = ref.watch(sharedPreferencesProvider);
    T? byName<T extends Enum>(List<T> values, String key) =>
        values.asNameMap()[p.getString('$_prefix$key')];
    return UserProfile(
      sex: byName(Sex.values, 'sex') ?? Sex.unspecified,
      age: p.getInt('${_prefix}age'),
      heightCm: p.getDouble('${_prefix}heightCm'),
      weightKg: p.getDouble('${_prefix}weightKg'),
      experience: byName(Experience.values, 'experience') ?? Experience.beginner,
      goal: byName(TrainingGoal.values, 'goal') ?? TrainingGoal.muscle,
      onboarded: p.getBool('${_prefix}onboarded') ?? false,
    );
  }

  Future<void> save(UserProfile profile) async {
    state = profile;
    final p = _prefs;
    Future<void> setOrRemove<T>(String key, T? value) async {
      final k = '$_prefix$key';
      if (value == null) {
        await p.remove(k);
      } else if (value is int) {
        await p.setInt(k, value);
      } else if (value is double) {
        await p.setDouble(k, value);
      }
    }

    await p.setString('${_prefix}sex', profile.sex.name);
    await setOrRemove('age', profile.age);
    await setOrRemove('heightCm', profile.heightCm);
    await setOrRemove('weightKg', profile.weightKg);
    await p.setString('${_prefix}experience', profile.experience.name);
    await p.setString('${_prefix}goal', profile.goal.name);
    await p.setBool('${_prefix}onboarded', profile.onboarded);
  }

  Future<void> skipOnboarding() => save(state.copyWith(onboarded: true));
}

final userProfileProvider =
    NotifierProvider<UserProfileController, UserProfile>(
        UserProfileController.new);
