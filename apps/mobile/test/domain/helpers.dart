import 'dart:io';

import 'package:mobile/domain/common/local_date.dart';
import 'package:mobile/domain/common/meal_slot.dart';
import 'package:mobile/domain/food/food.dart';
import 'package:mobile/domain/food/food_pack_parser.dart';
import 'package:mobile/domain/plan/seeded_random.dart';
import 'package:mobile/domain/profile/user_profile.dart';

final LocalDate testToday = LocalDate(2026, 10, 29);

FoodPack? _pack;

/// The real bundled Pakistan pack (draft data).
FoodPack loadBundledPack() => _pack ??=
    FoodPackParser.parse(File('assets/packs/pk-core.json').readAsStringSync());

UserProfile profile({
  Goal goal = Goal.lose,
  int birthYear = 1995,
  Sex sex = Sex.female,
  double heightCm = 162,
  double weightKg = 72,
  ActivityLevel activity = ActivityLevel.light,
  Set<HealthCondition> conditions = const {},
  OilLevel richness = OilLevel.normal,
}) =>
    UserProfile(
      goal: goal,
      birthYear: birthYear,
      sex: sex,
      heightCm: heightCm,
      weightKg: weightKg,
      activity: activity,
      conditions: conditions,
      cookingRichness: richness,
    );

/// Synthetic adult profiles within the onboarding ranges, reproducible from [seed].
List<UserProfile> generatedProfiles(int count, {int seed = 42}) {
  final rng = SeededRandom(seed);
  T pick<T>(List<T> xs) => xs[(rng.nextDouble() * xs.length).floor()];
  double between(double lo, double hi) => lo + rng.nextDouble() * (hi - lo);
  return [
    for (var i = 0; i < count; i++)
      () {
        final sex = pick(Sex.values);
        final height = sex == Sex.male ? between(155, 195) : between(145, 180);
        // BMI between 19 and 38 so every profile is eligible for its goal.
        final bmi = between(19, 38);
        return profile(
          goal: pick(Goal.values),
          birthYear: testToday.year - between(19, 65).round(),
          sex: sex,
          heightCm: height,
          weightKg: bmi * (height / 100) * (height / 100),
          activity: pick(ActivityLevel.values),
          richness: pick(OilLevel.values),
        );
      }(),
  ];
}
