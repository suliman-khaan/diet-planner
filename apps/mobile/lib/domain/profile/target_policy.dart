import '../common/local_date.dart';
import 'user_profile.dart';

/// Configuration for [TargetPolicy]. Floors and rate caps are engineering placeholders
/// (blueprint §3) and must be confirmed by a nutrition professional before public
/// automated planning. Never hard-code these in UI or planner code.
class TargetPolicyConfig {
  const TargetPolicyConfig({
    required this.version,
    required this.isProvisional,
    required this.calorieFloorFemale,
    required this.calorieFloorMale,
    required this.defaultLossKgPerWeek,
    required this.maxLossKgPerWeek,
    required this.maxLossFractionOfBodyWeightPerWeek,
    required this.defaultGainKgPerWeek,
    required this.maxGainKgPerWeek,
    required this.kcalPerKgBodyWeight,
    required this.minBmiForLoss,
    required this.minAgeForAutoPlans,
    required this.activityFactors,
    required this.proteinShare,
    required this.carbShare,
    required this.fatShare,
    required this.fibreGramsPer1000Kcal,
  });

  /// Blueprint v2 starting proposal. Provisional until nutritionist sign-off (Gate A).
  static const TargetPolicyConfig v1Provisional = TargetPolicyConfig(
    version: 'target-policy-1.0-provisional',
    isProvisional: true,
    calorieFloorFemale: 1200,
    calorieFloorMale: 1500,
    defaultLossKgPerWeek: 0.5,
    maxLossKgPerWeek: 0.75,
    maxLossFractionOfBodyWeightPerWeek: 0.01,
    defaultGainKgPerWeek: 0.25,
    maxGainKgPerWeek: 0.5,
    kcalPerKgBodyWeight: 7700,
    minBmiForLoss: 18.5,
    minAgeForAutoPlans: 18,
    activityFactors: {
      ActivityLevel.sedentary: 1.2,
      ActivityLevel.light: 1.375,
      ActivityLevel.moderate: 1.55,
      ActivityLevel.veryActive: 1.725,
    },
    proteinShare: 0.20,
    carbShare: 0.50,
    fatShare: 0.30,
    fibreGramsPer1000Kcal: 14,
  );

  final String version;
  final bool isProvisional;
  final double calorieFloorFemale;
  final double calorieFloorMale;
  final double defaultLossKgPerWeek;
  final double maxLossKgPerWeek;
  final double maxLossFractionOfBodyWeightPerWeek;
  final double defaultGainKgPerWeek;
  final double maxGainKgPerWeek;
  final double kcalPerKgBodyWeight;
  final double minBmiForLoss;
  final int minAgeForAutoPlans;
  final Map<ActivityLevel, double> activityFactors;
  final double proteinShare;
  final double carbShare;
  final double fatShare;
  final double fibreGramsPer1000Kcal;

  double floorFor(Sex sex) => sex == Sex.male ? calorieFloorMale : calorieFloorFemale;
}

class NutritionTarget {
  const NutritionTarget({
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fibreG,
  });

  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fibreG;

  Map<String, Object?> toJson() => {
        'kcal': kcal,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'fibreG': fibreG,
      };

  factory NutritionTarget.fromJson(Map<String, Object?> json) => NutritionTarget(
        kcal: (json['kcal']! as num).toDouble(),
        proteinG: (json['proteinG']! as num).toDouble(),
        carbsG: (json['carbsG']! as num).toDouble(),
        fatG: (json['fatG']! as num).toDouble(),
        fibreG: (json['fibreG']! as num).toDouble(),
      );
}

/// Everything the "How we calculated this" screen shows.
class TargetExplanation {
  const TargetExplanation({
    required this.policyVersion,
    required this.isProvisional,
    required this.age,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
    required this.activityFactor,
    required this.restingKcal,
    required this.maintenanceKcal,
    required this.goal,
    required this.weeklyChangeKg,
    required this.dailyAdjustmentKcal,
    required this.floorKcal,
    required this.floorApplied,
    required this.rateCapApplied,
    required this.finalKcal,
  });

  final String policyVersion;
  final bool isProvisional;
  final int age;
  final Sex sex;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activity;
  final double activityFactor;

  /// Mifflin-St Jeor resting energy.
  final double restingKcal;
  final double maintenanceKcal;
  final Goal goal;

  /// Planned weekly change: negative for loss.
  final double weeklyChangeKg;
  final double dailyAdjustmentKcal;
  final double floorKcal;
  final bool floorApplied;
  final bool rateCapApplied;
  final double finalKcal;
}

class TargetResult {
  const TargetResult({required this.target, required this.explanation});

  final NutritionTarget target;
  final TargetExplanation explanation;
}

/// Daily energy and macro targets: Mifflin-St Jeor × activity factor, then goal adjustment,
/// limited by rate caps and never below the calorie floor.
///
/// Call only for profiles that [EligibilityChecker] allows; [Goal] must already reflect
/// any eligibility downgrade (e.g. maintenance instead of loss).
class TargetPolicy {
  const TargetPolicy([this.config = TargetPolicyConfig.v1Provisional]);

  final TargetPolicyConfig config;

  TargetResult compute(UserProfile p, LocalDate today) {
    final age = p.ageIn(today);
    final resting = 10 * p.weightKg + 6.25 * p.heightCm - 5 * age + (p.sex == Sex.male ? 5 : -161);
    final factor = config.activityFactors[p.activity]!;
    final maintenance = resting * factor;

    var weeklyChange = 0.0;
    var rateCapApplied = false;
    switch (p.goal) {
      case Goal.lose:
        final cap = _min(config.maxLossKgPerWeek, config.maxLossFractionOfBodyWeightPerWeek * p.weightKg);
        weeklyChange = -_min(config.defaultLossKgPerWeek, cap);
        rateCapApplied = config.defaultLossKgPerWeek > cap;
      case Goal.gain:
        weeklyChange = _min(config.defaultGainKgPerWeek, config.maxGainKgPerWeek);
        rateCapApplied = config.defaultGainKgPerWeek > config.maxGainKgPerWeek;
      case Goal.maintain:
        weeklyChange = 0;
    }
    final adjustment = weeklyChange * config.kcalPerKgBodyWeight / 7;
    final floor = config.floorFor(p.sex);
    final raw = maintenance + adjustment;
    final floorApplied = raw < floor;
    final kcal = _roundTo10(floorApplied ? floor : raw);

    return TargetResult(
      target: NutritionTarget(
        kcal: kcal,
        proteinG: (kcal * config.proteinShare / 4).roundToDouble(),
        carbsG: (kcal * config.carbShare / 4).roundToDouble(),
        fatG: (kcal * config.fatShare / 9).roundToDouble(),
        fibreG: (kcal / 1000 * config.fibreGramsPer1000Kcal).roundToDouble(),
      ),
      explanation: TargetExplanation(
        policyVersion: config.version,
        isProvisional: config.isProvisional,
        age: age,
        sex: p.sex,
        heightCm: p.heightCm,
        weightKg: p.weightKg,
        activity: p.activity,
        activityFactor: factor,
        restingKcal: resting,
        maintenanceKcal: maintenance,
        goal: p.goal,
        weeklyChangeKg: weeklyChange,
        dailyAdjustmentKcal: adjustment,
        floorKcal: floor,
        floorApplied: floorApplied,
        rateCapApplied: rateCapApplied,
        finalKcal: kcal,
      ),
    );
  }

  static double _min(double a, double b) => a < b ? a : b;
  static double _roundTo10(double v) => (v / 10).roundToDouble() * 10;
}
