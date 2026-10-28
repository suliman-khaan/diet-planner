import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/profile/eligibility.dart';
import 'package:mobile/domain/profile/target_policy.dart';
import 'package:mobile/domain/profile/user_profile.dart';

import 'helpers.dart';

void main() {
  const policy = TargetPolicy();
  const checker = EligibilityChecker();
  const config = TargetPolicyConfig.v1Provisional;

  group('TargetPolicy', () {
    test('Mifflin-St Jeor × activity for maintenance', () {
      // Female, 31, 162 cm, 72 kg: 10*72 + 6.25*162 - 5*31 - 161 = 1416.5; × 1.375 = 1947.7
      final r = policy.compute(profile(goal: Goal.maintain), testToday);
      expect(r.explanation.restingKcal, closeTo(1416.5, 0.01));
      expect(r.explanation.maintenanceKcal, closeTo(1947.69, 0.01));
      expect(r.target.kcal, 1950);
      expect(r.explanation.dailyAdjustmentKcal, 0);
      expect(r.explanation.policyVersion, config.version);
      expect(r.explanation.isProvisional, isTrue);
    });

    test('male formula adds 5 instead of subtracting 161', () {
      final r = policy.compute(
          profile(goal: Goal.maintain, sex: Sex.male), testToday);
      expect(r.explanation.restingKcal, closeTo(1582.5, 0.01));
    });

    test('loss uses the default rate when under the caps', () {
      final r = policy.compute(profile(weightKg: 90), testToday);
      expect(r.explanation.weeklyChangeKg, -0.5);
      expect(r.explanation.dailyAdjustmentKcal, closeTo(-550, 0.01));
      expect(r.explanation.rateCapApplied, isFalse);
    });

    test('loss is capped at 1% of body weight per week', () {
      final r = policy.compute(profile(weightKg: 45, heightCm: 150), testToday);
      expect(r.explanation.weeklyChangeKg, closeTo(-0.45, 1e-9));
      expect(r.explanation.rateCapApplied, isTrue);
    });

    test('loss never exceeds the absolute weekly cap', () {
      for (final p in generatedProfiles(300)) {
        final r = policy.compute(p.copyWith(goal: Goal.lose), testToday);
        expect(-r.explanation.weeklyChangeKg,
            lessThanOrEqualTo(config.maxLossKgPerWeek));
        expect(-r.explanation.weeklyChangeKg,
            lessThanOrEqualTo(p.weightKg * 0.01 + 1e-9));
      }
    });

    test('gain uses a capped surplus', () {
      final r = policy.compute(profile(goal: Goal.gain), testToday);
      expect(r.explanation.weeklyChangeKg, 0.25);
      expect(r.explanation.dailyAdjustmentKcal, closeTo(275, 0.01));
      final capped = TargetPolicy(TargetPolicyConfig(
        version: 't',
        isProvisional: true,
        calorieFloorFemale: 1200,
        calorieFloorMale: 1500,
        defaultLossKgPerWeek: 0.5,
        maxLossKgPerWeek: 0.75,
        maxLossFractionOfBodyWeightPerWeek: 0.01,
        defaultGainKgPerWeek: 1.0,
        maxGainKgPerWeek: 0.5,
        kcalPerKgBodyWeight: 7700,
        minBmiForLoss: 18.5,
        minAgeForAutoPlans: 18,
        activityFactors: config.activityFactors,
        proteinShare: 0.2,
        carbShare: 0.5,
        fatShare: 0.3,
        fibreGramsPer1000Kcal: 14,
      )).compute(profile(goal: Goal.gain), testToday);
      expect(capped.explanation.weeklyChangeKg, 0.5);
      expect(capped.explanation.rateCapApplied, isTrue);
    });

    test('never below the calorie floor (women)', () {
      final r = policy.compute(
        profile(
            heightCm: 150,
            weightKg: 48,
            birthYear: 1960,
            activity: ActivityLevel.sedentary),
        testToday,
      );
      expect(r.target.kcal, config.calorieFloorFemale);
      expect(r.explanation.floorApplied, isTrue);
    });

    test('never below the calorie floor (men)', () {
      final r = policy.compute(
        profile(
            sex: Sex.male,
            heightCm: 158,
            weightKg: 52,
            birthYear: 1958,
            activity: ActivityLevel.sedentary),
        testToday,
      );
      expect(r.target.kcal, config.calorieFloorMale);
    });

    test('property: no generated profile gets a target below its floor', () {
      for (final p in generatedProfiles(1000, seed: 7)) {
        final r = policy.compute(p, testToday);
        expect(r.target.kcal, greaterThanOrEqualTo(config.floorFor(p.sex)),
            reason: '${p.toJson()}');
      }
    });

    test('macros follow the configured split and fibre per 1000 kcal', () {
      final r = policy.compute(profile(goal: Goal.maintain), testToday);
      expect(r.target.proteinG, (1950 * 0.2 / 4).roundToDouble());
      expect(r.target.carbsG, (1950 * 0.5 / 4).roundToDouble());
      expect(r.target.fatG, (1950 * 0.3 / 9).roundToDouble());
      expect(r.target.fibreG, (1950 / 1000 * 14).roundToDouble());
      final json = NutritionTarget.fromJson(r.target.toJson());
      expect(json.kcal, r.target.kcal);
      expect(json.fibreG, r.target.fibreG);
    });
  });

  group('Eligibility', () {
    test('adult with no conditions is eligible', () {
      expect(checker.check(profile(), testToday), isA<EligibleForPlans>());
    });

    test('under 18 gets manual mode, including the birthday ambiguity at 18',
        () {
      final seventeen =
          checker.check(profile(birthYear: testToday.year - 17), testToday);
      expect(seventeen, isA<ManualOnly>());
      expect((seventeen as ManualOnly).reasons, {ManualOnlyReason.underAge});
      // Born 18 years ago by year, but may still be 17 today.
      expect(checker.check(profile(birthYear: testToday.year - 18), testToday),
          isA<ManualOnly>());
      expect(checker.check(profile(birthYear: testToday.year - 19), testToday),
          isA<EligibleForPlans>());
    });

    test('pregnancy, breastfeeding and medical diets get manual mode', () {
      final r = checker.check(
        profile(conditions: {
          HealthCondition.pregnant,
          HealthCondition.breastfeeding,
          HealthCondition.diabetes,
        }),
        testToday,
      ) as ManualOnly;
      expect(r.reasons, {
        ManualOnlyReason.pregnant,
        ManualOnlyReason.breastfeeding,
        ManualOnlyReason.medicalCondition,
      });
      expect(
          checker.check(
              profile(conditions: {HealthCondition.kidneyDisease}), testToday),
          isA<ManualOnly>());
      expect(
          checker.check(profile(conditions: {HealthCondition.otherMedicalDiet}),
              testToday),
          isA<ManualOnly>());
    });

    test('BMI below 18.5 with a loss goal gets maintenance only', () {
      final thin = profile(heightCm: 175, weightKg: 54); // BMI 17.6
      final r = checker.check(thin, testToday);
      expect(r, isA<MaintenanceOnly>());
      expect((r as MaintenanceOnly).bmi, closeTo(17.63, 0.01));
      expect(checker.effectiveGoal(thin, r), Goal.maintain);
      // Same person wanting to maintain or gain is fine.
      expect(checker.check(thin.copyWith(goal: Goal.gain), testToday),
          isA<EligibleForPlans>());
      expect(checker.effectiveGoal(profile(), const EligibleForPlans()),
          Goal.lose);
    });
  });

  group('Profile validation', () {
    test('accepts normal values and flags out-of-range fields', () {
      expect(validateProfile(profile(), testToday), isEmpty);
      expect(validateProfile(profile(heightCm: 90), testToday),
          {ProfileFieldError.heightOutOfRange});
      expect(validateProfile(profile(weightKg: 400), testToday),
          {ProfileFieldError.weightOutOfRange});
      expect(validateProfile(profile(birthYear: 2030), testToday),
          {ProfileFieldError.birthYearOutOfRange});
      expect(validateProfile(profile(birthYear: 1900), testToday),
          {ProfileFieldError.birthYearOutOfRange});
    });

    test('profile and preferences survive JSON round trips', () {
      final p = profile(conditions: {HealthCondition.diabetes});
      final back = UserProfile.fromJson(p.toJson());
      expect(back.toJson(), p.toJson());
      expect(back.bmi, closeTo(27.43, 0.01));
      expect(back.ageIn(testToday), 31);
    });
  });
}
