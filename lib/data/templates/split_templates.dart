import 'package:flutter/foundation.dart';

/// Ready-made training splits. Exercise ids are stable ExerciseDB v1 ids;
/// anything missing from the local catalog is skipped at install time.
@immutable
class TemplateExercise {
  const TemplateExercise(this.id, {this.rest = 90});

  final String id;
  final int rest;
}

enum TemplateLevel { beginner, intermediate }

enum TemplateKey { ppl, upperLower, fullBody, broSplit, bodyweight }

@immutable
class TemplateDay {
  const TemplateDay(this.key, this.exercises);

  /// Localization key for the day (see `templateDayName`).
  final String key;
  final List<TemplateExercise> exercises;
}

@immutable
class SplitTemplate {
  const SplitTemplate({
    required this.key,
    required this.daysPerWeek,
    required this.level,
    required this.days,
  });

  final TemplateKey key;
  final int daysPerWeek;
  final TemplateLevel level;
  final List<TemplateDay> days;

  Iterable<String> get exerciseIds =>
      days.expand((d) => d.exercises).map((e) => e.id);
}

// Compound lifts rest longer than isolation work.
const _c = 150;
const _i = 90;

const splitTemplates = <SplitTemplate>[
  SplitTemplate(
    key: TemplateKey.ppl,
    daysPerWeek: 6,
    level: TemplateLevel.intermediate,
    days: [
      TemplateDay('push', [
        TemplateExercise('EIeI8Vf', rest: _c), // barbell bench press
        TemplateExercise('ns0SIbU', rest: _c), // dumbbell incline bench press
        TemplateExercise('kTbSH9h', rest: _c), // barbell seated overhead press
        TemplateExercise('DsgkuIt', rest: _i), // dumbbell lateral raise
        TemplateExercise('yz9nUhF', rest: _i), // dumbbell fly
        TemplateExercise('3ZflifB', rest: _i), // cable pushdown
      ]),
      TemplateDay('pull', [
        TemplateExercise('ila4NZS', rest: 180), // barbell deadlift
        TemplateExercise('RVwzP10', rest: _c), // cable pulldown
        TemplateExercise('eZyBC3j', rest: _c), // barbell bent over row
        TemplateExercise('fUBheHs', rest: _i), // cable seated row
        TemplateExercise('v1qBec9', rest: _i), // dumbbell rear lateral raise
        TemplateExercise('25GPyDY', rest: _i), // barbell curl
        TemplateExercise('slDvUAU', rest: _i), // dumbbell hammer curl
      ]),
      TemplateDay('legs', [
        TemplateExercise('qXTaZnJ', rest: 180), // barbell full squat
        TemplateExercise('wQ2c4XD', rest: _c), // barbell romanian deadlift
        TemplateExercise('10Z2DXU', rest: _c), // sled 45° leg press
        TemplateExercise('17lJ1kr', rest: _i), // lever lying leg curl
        TemplateExercise('my33uHU', rest: _i), // lever leg extension
        TemplateExercise('bOOdeyc', rest: _i), // lever seated calf raise
      ]),
    ],
  ),
  SplitTemplate(
    key: TemplateKey.upperLower,
    daysPerWeek: 4,
    level: TemplateLevel.beginner,
    days: [
      TemplateDay('upper', [
        TemplateExercise('EIeI8Vf', rest: _c), // barbell bench press
        TemplateExercise('eZyBC3j', rest: _c), // barbell bent over row
        TemplateExercise('A6wtbuL', rest: _c), // dumbbell standing overhead press
        TemplateExercise('RVwzP10', rest: _i), // cable pulldown
        TemplateExercise('25GPyDY', rest: _i), // barbell curl
        TemplateExercise('3ZflifB', rest: _i), // cable pushdown
      ]),
      TemplateDay('lower', [
        TemplateExercise('qXTaZnJ', rest: 180), // barbell full squat
        TemplateExercise('wQ2c4XD', rest: _c), // barbell romanian deadlift
        TemplateExercise('10Z2DXU', rest: _c), // sled 45° leg press
        TemplateExercise('17lJ1kr', rest: _i), // lever lying leg curl
        TemplateExercise('bOOdeyc', rest: _i), // lever seated calf raise
        TemplateExercise('TFqbd8t', rest: 60), // crunch floor
      ]),
    ],
  ),
  SplitTemplate(
    key: TemplateKey.fullBody,
    daysPerWeek: 3,
    level: TemplateLevel.beginner,
    days: [
      TemplateDay('fullBodyA', [
        TemplateExercise('qXTaZnJ', rest: _c), // barbell full squat
        TemplateExercise('EIeI8Vf', rest: _c), // barbell bench press
        TemplateExercise('eZyBC3j', rest: _c), // barbell bent over row
        TemplateExercise('A6wtbuL', rest: _i), // dumbbell standing overhead press
        TemplateExercise('TFqbd8t', rest: 60), // crunch floor
      ]),
      TemplateDay('fullBodyB', [
        TemplateExercise('ila4NZS', rest: 180), // barbell deadlift
        TemplateExercise('ns0SIbU', rest: _c), // dumbbell incline bench press
        TemplateExercise('lBDjFxJ', rest: _c), // pull-up
        TemplateExercise('RRWFUcw', rest: _i), // dumbbell lunge
        TemplateExercise('DsgkuIt', rest: _i), // dumbbell lateral raise
      ]),
    ],
  ),
  SplitTemplate(
    key: TemplateKey.broSplit,
    daysPerWeek: 5,
    level: TemplateLevel.intermediate,
    days: [
      TemplateDay('chest', [
        TemplateExercise('EIeI8Vf', rest: _c), // barbell bench press
        TemplateExercise('ns0SIbU', rest: _c), // dumbbell incline bench press
        TemplateExercise('yz9nUhF', rest: _i), // dumbbell fly
        TemplateExercise('9WTm7dq', rest: _i), // chest dip
      ]),
      TemplateDay('back', [
        TemplateExercise('ila4NZS', rest: 180), // barbell deadlift
        TemplateExercise('lBDjFxJ', rest: _c), // pull-up
        TemplateExercise('eZyBC3j', rest: _c), // barbell bent over row
        TemplateExercise('fUBheHs', rest: _i), // cable seated row
      ]),
      TemplateDay('shoulders', [
        TemplateExercise('kTbSH9h', rest: _c), // barbell seated overhead press
        TemplateExercise('DsgkuIt', rest: _i), // dumbbell lateral raise
        TemplateExercise('v1qBec9', rest: _i), // dumbbell rear lateral raise
        TemplateExercise('goJ6ezq', rest: _i), // cable lateral raise
      ]),
      TemplateDay('arms', [
        TemplateExercise('25GPyDY', rest: _i), // barbell curl
        TemplateExercise('h8LFzo9', rest: _i), // barbell lying triceps extension
        TemplateExercise('slDvUAU', rest: _i), // dumbbell hammer curl
        TemplateExercise('3ZflifB', rest: _i), // cable pushdown
      ]),
      TemplateDay('legs', [
        TemplateExercise('qXTaZnJ', rest: 180), // barbell full squat
        TemplateExercise('10Z2DXU', rest: _c), // sled 45° leg press
        TemplateExercise('17lJ1kr', rest: _i), // lever lying leg curl
        TemplateExercise('my33uHU', rest: _i), // lever leg extension
        TemplateExercise('bOOdeyc', rest: _i), // lever seated calf raise
      ]),
    ],
  ),
  SplitTemplate(
    key: TemplateKey.bodyweight,
    daysPerWeek: 3,
    level: TemplateLevel.beginner,
    days: [
      TemplateDay('bodyweight', [
        TemplateExercise('I4hDWkc', rest: 60), // push-up
        TemplateExercise('lBDjFxJ', rest: _i), // pull-up
        TemplateExercise('IZVHb27', rest: 60), // walking lunge
        TemplateExercise('9WTm7dq', rest: _i), // chest dip
        TemplateExercise('TFqbd8t', rest: 45), // crunch floor
      ]),
    ],
  ),
];
