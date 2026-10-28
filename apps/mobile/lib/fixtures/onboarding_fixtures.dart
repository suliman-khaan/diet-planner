import '../../core/widgets/segmented_controls.dart';
import '../features/onboarding/view_model/onboarding_view_model.dart';

/// Previews and test fixtures for Onboarding flow.
abstract class OnboardingFixtures {
  static const welcome = OnboardingViewModel(
    currentStep: OnboardingStep.welcome,
    currentStepIndex: 1,
    totalSteps: 8,
  );

  static const goal = OnboardingViewModel(
    currentStep: OnboardingStep.goal,
    currentStepIndex: 2,
    totalSteps: 8,
    goal: WeightGoal.loseWeight,
  );

  static const cookingRichness = OnboardingViewModel(
    currentStep: OnboardingStep.cookingRichness,
    currentStepIndex: 6,
    totalSteps: 8,
    cookingRichness: OilLevel.normal,
  );

  static const targetSummary = OnboardingViewModel(
    currentStep: OnboardingStep.targetSummary,
    currentStepIndex: 8,
    totalSteps: 8,
    recommendedCalories: 1850,
    recommendedProtein: 95,
    recommendedCarbs: 230,
    recommendedFat: 60,
    recommendedFibre: 28,
  );

  static const loading = OnboardingViewModel(
    currentStep: OnboardingStep.cookingRichness,
    currentStepIndex: 6,
    totalSteps: 8,
    isLoading: true,
  );

  static const error = OnboardingViewModel(
    currentStep: OnboardingStep.cookingRichness,
    currentStepIndex: 6,
    totalSteps: 8,
    errorMessage: 'Sample error: could not compute target policy.',
  );
}
