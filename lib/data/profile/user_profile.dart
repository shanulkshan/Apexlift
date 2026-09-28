import 'package:flutter/foundation.dart';

enum Sex { male, female, unspecified }

enum Experience { beginner, intermediate, advanced }

enum TrainingGoal { muscle, strength, endurance, general }

/// Body and training profile collected at onboarding. Used only for rough
/// estimates (starting weights, calories); every field has a sensible
/// default so the app works if the user skips.
@immutable
class UserProfile {
  const UserProfile({
    this.sex = Sex.unspecified,
    this.age,
    this.heightCm,
    this.weightKg,
    this.experience = Experience.beginner,
    this.goal = TrainingGoal.muscle,
    this.onboarded = false,
  });

  final Sex sex;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final Experience experience;
  final TrainingGoal goal;

  /// True once the user finished or skipped onboarding.
  final bool onboarded;

  /// Body weight for estimates; an average adult when unknown.
  double get bodyWeightKg => weightKg ?? (sex == Sex.female ? 62 : 72);

  bool get hasBodyData => weightKg != null;

  UserProfile copyWith({
    Sex? sex,
    int? Function()? age,
    double? Function()? heightCm,
    double? Function()? weightKg,
    Experience? experience,
    TrainingGoal? goal,
    bool? onboarded,
  }) =>
      UserProfile(
        sex: sex ?? this.sex,
        age: age != null ? age() : this.age,
        heightCm: heightCm != null ? heightCm() : this.heightCm,
        weightKg: weightKg != null ? weightKg() : this.weightKg,
        experience: experience ?? this.experience,
        goal: goal ?? this.goal,
        onboarded: onboarded ?? this.onboarded,
      );

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.sex == sex &&
      other.age == age &&
      other.heightCm == heightCm &&
      other.weightKg == weightKg &&
      other.experience == experience &&
      other.goal == goal &&
      other.onboarded == onboarded;

  @override
  int get hashCode =>
      Object.hash(sex, age, heightCm, weightKg, experience, goal, onboarded);
}
