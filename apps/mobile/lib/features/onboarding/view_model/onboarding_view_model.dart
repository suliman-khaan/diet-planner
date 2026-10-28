import 'package:flutter/foundation.dart';
import '../../../core/widgets/segmented_controls.dart';

enum OnboardingStep {
  welcome,
  privacy,
  goal,
  aboutYou,
  activity,
  eligibility,
  dietary,
  mealSchedule,
  cookingRichness,
  targetSummary,
}

enum WeightGoal { loseWeight, maintain, gainWeight }

enum BiologicalSex { female, male }

enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive }

enum DietType { everything, vegetarian, vegan, pescatarian }

@immutable
class OnboardingViewModel {
  final OnboardingStep currentStep;
  final int totalSteps;
  final int currentStepIndex;

  // Form values
  final WeightGoal goal;
  final int birthYear;
  final BiologicalSex sex;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final bool isEligibleForAutoPlan;
  final String? eligibilityNotice;
  final DietType dietType;
  final List<String> allergies;
  final int mealSlotsCount;
  final OilLevel cookingRichness;

  // Target summary result
  final num? recommendedCalories;
  final num? recommendedProtein;
  final num? recommendedCarbs;
  final num? recommendedFat;
  final num? recommendedFibre;

  final bool isLoading;
  final String? errorMessage;

  const OnboardingViewModel({
    this.currentStep = OnboardingStep.welcome,
    this.totalSteps = 8,
    this.currentStepIndex = 1,
    this.goal = WeightGoal.loseWeight,
    this.birthYear = 1995,
    this.sex = BiologicalSex.female,
    this.heightCm = 162.0,
    this.weightKg = 72.0,
    this.activityLevel = ActivityLevel.lightlyActive,
    this.isEligibleForAutoPlan = true,
    this.eligibilityNotice,
    this.dietType = DietType.everything,
    this.allergies = const [],
    this.mealSlotsCount = 4,
    this.cookingRichness = OilLevel.normal,
    this.recommendedCalories,
    this.recommendedProtein,
    this.recommendedCarbs,
    this.recommendedFat,
    this.recommendedFibre,
    this.isLoading = false,
    this.errorMessage,
  });

  OnboardingViewModel copyWith({
    OnboardingStep? currentStep,
    int? totalSteps,
    int? currentStepIndex,
    WeightGoal? goal,
    int? birthYear,
    BiologicalSex? sex,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    bool? isEligibleForAutoPlan,
    String? eligibilityNotice,
    DietType? dietType,
    List<String>? allergies,
    int? mealSlotsCount,
    OilLevel? cookingRichness,
    num? recommendedCalories,
    num? recommendedProtein,
    num? recommendedCarbs,
    num? recommendedFat,
    num? recommendedFibre,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingViewModel(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      goal: goal ?? this.goal,
      birthYear: birthYear ?? this.birthYear,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      isEligibleForAutoPlan:
          isEligibleForAutoPlan ?? this.isEligibleForAutoPlan,
      eligibilityNotice: eligibilityNotice ?? this.eligibilityNotice,
      dietType: dietType ?? this.dietType,
      allergies: allergies ?? this.allergies,
      mealSlotsCount: mealSlotsCount ?? this.mealSlotsCount,
      cookingRichness: cookingRichness ?? this.cookingRichness,
      recommendedCalories: recommendedCalories ?? this.recommendedCalories,
      recommendedProtein: recommendedProtein ?? this.recommendedProtein,
      recommendedCarbs: recommendedCarbs ?? this.recommendedCarbs,
      recommendedFat: recommendedFat ?? this.recommendedFat,
      recommendedFibre: recommendedFibre ?? this.recommendedFibre,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
