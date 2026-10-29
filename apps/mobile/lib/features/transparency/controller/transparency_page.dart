import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/formatters.dart';
import '../../../app/providers/providers.dart';
import '../../../domain/profile/eligibility.dart';
import '../../../domain/profile/user_profile.dart';
import '../../onboarding/controller/onboarding_controller.dart';
import '../../onboarding/view_model/onboarding_view_model.dart' as ovm;
import '../ui/transparency_screen.dart';

/// Builds "How we calculated this" from the user's saved profile and the active policy.
final transparencyProvider = FutureProvider<TransparencyViewModel>((ref) async {
  final setup = await ref.watch(userSetupProvider.future);
  final policy = ref.watch(targetPolicyProvider);
  final checker = ref.watch(eligibilityCheckerProvider);
  final today = ref.watch(todayProvider);
  final c = policy.config;
  final provisional = c.isProvisional
      ? 'These safety values are starting proposals and are being confirmed by a nutrition professional.'
      : 'Reviewed by a nutrition professional.';
  final rules = TransparencySection(
    icon: Icons.shield_outlined,
    title: 'Safety limits',
    body:
        'Automatic targets never go below ${Fmt.kcal(c.calorieFloorFemale)} kcal a day for women or '
        '${Fmt.kcal(c.calorieFloorMale)} kcal for men. Weight loss is limited to about '
        '${c.defaultLossKgPerWeek} kg a week, never more than ${c.maxLossKgPerWeek} kg or '
        '${(c.maxLossFractionOfBodyWeightPerWeek * 100).round()}% of body weight. No weight-loss plan below BMI '
        '${c.minBmiForLoss}. $provisional',
  );
  var p = setup?.profile;
  if (p == null) {
    try {
      final ob = ref.read(onboardingControllerProvider(false)).valueOrNull ??
          ref.read(onboardingControllerProvider(true)).valueOrNull;
      if (ob != null && ob.birthYear > 0) {
        final conditions = <HealthCondition>{};
        for (final name in ob.healthConditions) {
          try {
            conditions.add(HealthCondition.values.byName(name));
          } catch (_) {}
        }
        p = UserProfile(
          goal: switch (ob.goal) {
            ovm.WeightGoal.loseWeight => Goal.lose,
            ovm.WeightGoal.maintain => Goal.maintain,
            ovm.WeightGoal.gainWeight => Goal.gain,
          },
          birthYear: ob.birthYear,
          sex: ob.sex == ovm.BiologicalSex.male ? Sex.male : Sex.female,
          heightCm: ob.heightCm,
          weightKg: ob.weightKg,
          activity: switch (ob.activityLevel) {
            ovm.ActivityLevel.sedentary => ActivityLevel.sedentary,
            ovm.ActivityLevel.lightlyActive => ActivityLevel.light,
            ovm.ActivityLevel.moderatelyActive => ActivityLevel.moderate,
            ovm.ActivityLevel.veryActive => ActivityLevel.veryActive,
          },
          conditions: conditions,
          cookingRichness: Fmt.fromUiOil(ob.cookingRichness),
        );
      }
    } catch (_) {}
  }

  if (p == null) {
    return TransparencyViewModel(
        intro: 'Finish setting up to see your own numbers.',
        sections: [rules],
        policyLine: 'Policy ${c.version}');
  }
  final e = checker.check(p, today);
  if (e is ManualOnly) {
    return TransparencyViewModel(
      intro: 'Automatic targets are off for you. ${Fmt.manualOnly(e)}',
      sections: [rules],
      policyLine: 'Policy ${c.version}',
    );
  }
  final x = policy
      .compute(p.copyWith(goal: checker.effectiveGoal(p, e)), today)
      .explanation;
  final sexTerm = p.sex == Sex.male ? '+ 5' : '− 161';
  return TransparencyViewModel(
    intro:
        'Every number is an estimate made by a fixed, versioned set of rules. Here is how yours was made.',
    sections: [
      TransparencySection(
        icon: Icons.functions,
        title: 'Resting energy (Mifflin-St Jeor)',
        body:
            '10 × ${p.weightKg.toStringAsFixed(1)} kg + 6.25 × ${p.heightCm.round()} cm − 5 × ${x.age} years '
            '$sexTerm = ${Fmt.kcal(x.restingKcal)} kcal a day.',
      ),
      TransparencySection(
        icon: Icons.directions_walk,
        title: 'Your activity',
        body:
            '${Fmt.kcal(x.restingKcal)} × ${x.activityFactor} = ${Fmt.kcal(x.maintenanceKcal)} kcal to stay at your current weight.',
      ),
      TransparencySection(
        icon: Icons.flag_outlined,
        title: 'Your goal',
        body: switch (x.goal) {
              Goal.maintain => 'Keep your weight steady: no change.',
              Goal.lose =>
                'Lose about ${(-x.weeklyChangeKg).toStringAsFixed(2)} kg a week: '
                    '${Fmt.kcal(-x.dailyAdjustmentKcal)} kcal less each day.',
              Goal.gain =>
                'Gain about ${x.weeklyChangeKg.toStringAsFixed(2)} kg a week: '
                    '${Fmt.kcal(x.dailyAdjustmentKcal)} kcal more each day.',
            } +
            (e is MaintenanceOnly
                ? ' A loss plan is not offered at your BMI, so we plan for maintenance.'
                : '') +
            (x.rateCapApplied
                ? ' The pace was limited by the safety cap.'
                : '') +
            (x.floorApplied
                ? ' Your target was raised to the safety floor.'
                : ''),
      ),
      TransparencySection(
        icon: Icons.restaurant,
        title: 'Your daily target',
        body:
            'About ${Fmt.kcal(x.finalKcal)} kcal, rounded to the nearest 10. Protein, carbs and fat are '
            '${(c.proteinShare * 100).round()}%, ${(c.carbShare * 100).round()}% and ${(c.fatShare * 100).round()}% of '
            'that energy, and fibre ${c.fibreGramsPer1000Kcal.round()} g per 1,000 kcal. Food values include the oil level you choose.',
      ),
      rules,
    ],
    policyLine:
        'Policy ${x.policyVersion}${x.isProvisional ? ' · provisional' : ''}',
  );
});

class TransparencyPage extends ConsumerWidget {
  const TransparencyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(transparencyProvider).valueOrNull ??
        const TransparencyViewModel();
    return TransparencyScreen(vm: vm);
  }
}
