import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/macro_bars.dart';
import '../../../core/widgets/segmented_controls.dart';
import '../view_model/onboarding_view_model.dart';

/// Complete Onboarding Screen supporting all steps (welcome to target summary).
class OnboardingScreen extends StatelessWidget {
  final OnboardingViewModel vm;
  final ValueChanged<OnboardingStep>? onStepSelected;
  final ValueChanged<WeightGoal>? onGoalChanged;
  final ValueChanged<OilLevel>? onRichnessChanged;
  final ValueChanged<BiologicalSex>? onSexChanged;
  final ValueChanged<ActivityLevel>? onActivityChanged;
  final ValueChanged<double>? onHeightChanged;
  final ValueChanged<double>? onWeightChanged;
  final ValueChanged<DietType>? onDietTypeChanged;
  final ValueChanged<String>? onAllergyToggled;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final VoidCallback? onFinish;
  final VoidCallback? onSkipToDashboard;

  const OnboardingScreen({
    super.key,
    required this.vm,
    this.onStepSelected,
    this.onGoalChanged,
    this.onRichnessChanged,
    this.onSexChanged,
    this.onActivityChanged,
    this.onHeightChanged,
    this.onWeightChanged,
    this.onDietTypeChanged,
    this.onAllergyToggled,
    this.onNext,
    this.onBack,
    this.onFinish,
    this.onSkipToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with back button and multi-step progress bar
              if (vm.currentStep != OnboardingStep.welcome) _buildHeader(context),
              const SizedBox(height: 16),
              // Step content
              Expanded(
                child: SingleChildScrollView(
                  child: _buildCurrentStep(context),
                ),
              ),
              const SizedBox(height: 16),
              // Navigation actions
              if (vm.currentStep == OnboardingStep.welcome) ...[
                PrimaryButton(label: 'Get started', onPressed: onNext),
                if (onSkipToDashboard != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onSkipToDashboard,
                    child: Text(
                      'Skip directly to today\'s meals →',
                      style: AppTypography.captionStrong.copyWith(
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ],
              ] else if (vm.currentStep == OnboardingStep.targetSummary)
                PrimaryButton(label: 'Start my plan', onPressed: onFinish)
              else
                PrimaryButton(
                  label: 'Continue',
                  isLoading: vm.isLoading,
                  onPressed: onNext,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Row(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: List.generate(vm.totalSteps, (index) {
              final isDone = index < vm.currentStepIndex;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isDone
                        ? primary
                        : (isDark ? AppColors.darkBorderStrong : AppColors.lightBorderStrong),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            '${vm.currentStepIndex} / ${vm.totalSteps}',
            textAlign: TextAlign.end,
            style: AppTypography.captionStrong.copyWith(color: muted),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (vm.currentStep) {
      case OnboardingStep.welcome:
        return _buildWelcomeStep(context);
      case OnboardingStep.goal:
        return _buildGoalStep(context);
      case OnboardingStep.aboutYou:
        return _AboutYouStepWidget(
          vm: vm,
          onSexChanged: onSexChanged,
          onHeightChanged: onHeightChanged,
          onWeightChanged: onWeightChanged,
        );
      case OnboardingStep.activity:
        return _buildActivityStep(context);
      case OnboardingStep.eligibility:
        return _buildEligibilityStep(context);
      case OnboardingStep.dietary:
        return _buildDietaryStep(context);
      case OnboardingStep.cookingRichness:
        return _buildCookingRichnessStep(context);
      case OnboardingStep.targetSummary:
        return _buildTargetSummaryStep(context);
      default:
        return _buildGoalStep(context);
    }
  }

  Widget _buildWelcomeStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.restaurant_menu,
            size: 32,
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Personal diet planning with foods you actually cook',
          style: AppTypography.titleLarge.copyWith(
            color: isDark ? AppColors.darkInk : AppColors.lightInk,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'From daily family pot karahi and daal to late chai with rusk. Real portions, oil tracking, and zero guilt.',
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
        const SizedBox(height: 28),
        _buildPrivacyPledge(context),
      ],
    );
  }

  Widget _buildPrivacyPledge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 20,
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your health data stays entirely on your phone. No mandatory accounts or cloud storage.',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your primary goal?',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkInk : AppColors.lightInk,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We plan safe, slow, sustainable targets with built-in calorie floors.',
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
        const SizedBox(height: 24),
        _buildGoalOption(context, WeightGoal.loseWeight, 'Gradual weight loss', 'Healthy deficit with full nutritional variety'),
        const SizedBox(height: 12),
        _buildGoalOption(context, WeightGoal.maintain, 'Maintain current weight', 'Balance energy intake and keep portions consistent'),
        const SizedBox(height: 12),
        _buildGoalOption(context, WeightGoal.gainWeight, 'Gradual weight gain', 'Nutrient-rich meals for steady healthy progress'),
      ],
    );
  }

  Widget _buildGoalOption(BuildContext context, WeightGoal goal, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = vm.goal == goal;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => onGoalChanged?.call(goal),
      child: Row(
        children: [
          Radio<WeightGoal>(
            value: goal,
            groupValue: vm.goal,
            activeColor: primary,
            onChanged: (val) {
              if (val != null) onGoalChanged?.call(val);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.subheading.copyWith(
                    color: isDark ? AppColors.darkInk : AppColors.lightInk,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper calculations for height conversion
  static int getFeetFromCm(double cm) {
    final totalInches = (cm / 2.54).round();
    return (totalInches ~/ 12).clamp(4, 7);
  }

  static int getInchesFromCm(double cm) {
    final totalInches = (cm / 2.54).round();
    return (totalInches % 12).clamp(0, 11);
  }

  static double getCmFromFeetInches(int feet, int inches) {
    final totalInches = (feet * 12) + inches;
    return totalInches * 2.54;
  }

  Widget _buildActivityStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily activity level',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkInk : AppColors.lightInk,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the one that best reflects your typical workday routine.',
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
        const SizedBox(height: 20),
        _buildActivityOption(context, ActivityLevel.sedentary, 'Sedentary', 'Desk job, mostly sitting'),
        const SizedBox(height: 10),
        _buildActivityOption(context, ActivityLevel.lightlyActive, 'Lightly Active', 'Standing, walking around office / home'),
        const SizedBox(height: 10),
        _buildActivityOption(context, ActivityLevel.moderatelyActive, 'Moderately Active', 'Daily manual tasks, gym or active walking'),
      ],
    );
  }

  Widget _buildActivityOption(BuildContext context, ActivityLevel level, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = vm.activityLevel == level;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => onActivityChanged?.call(level),
      child: Row(
        children: [
          Radio<ActivityLevel>(
            value: level,
            groupValue: vm.activityLevel,
            activeColor: primary,
            onChanged: (val) {
              if (val != null) onActivityChanged?.call(val);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.subheading),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health & eligibility check',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkInk : AppColors.lightInk,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'To ensure safety, automated calorie targets are only generated for adults aged 18+ without restricted conditions.',
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Eligible for automated daily meal planning and targets.',
                  style: AppTypography.bodyStrong,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDietaryStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary preferences & allergies',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkInk : AppColors.lightInk,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your dietary style. Dishes with your exclusions will never be planned.',
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dietary Style', style: AppTypography.bodyStrong),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Everything (Halal)'),
                    selected: vm.dietType == DietType.everything,
                    selectedColor: isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft,
                    side: BorderSide(
                      color: vm.dietType == DietType.everything ? primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: vm.dietType == DietType.everything ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: vm.dietType == DietType.everything ? primary : (isDark ? AppColors.darkInk : AppColors.lightInk),
                      fontWeight: vm.dietType == DietType.everything ? FontWeight.w600 : FontWeight.w400,
                    ),
                    onSelected: (val) {
                      if (val) onDietTypeChanged?.call(DietType.everything);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Vegetarian'),
                    selected: vm.dietType == DietType.vegetarian,
                    selectedColor: isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft,
                    side: BorderSide(
                      color: vm.dietType == DietType.vegetarian ? primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: vm.dietType == DietType.vegetarian ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: vm.dietType == DietType.vegetarian ? primary : (isDark ? AppColors.darkInk : AppColors.lightInk),
                      fontWeight: vm.dietType == DietType.vegetarian ? FontWeight.w600 : FontWeight.w400,
                    ),
                    onSelected: (val) {
                      if (val) onDietTypeChanged?.call(DietType.vegetarian);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Vegan'),
                    selected: vm.dietType == DietType.vegan,
                    selectedColor: isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft,
                    side: BorderSide(
                      color: vm.dietType == DietType.vegan ? primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: vm.dietType == DietType.vegan ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: vm.dietType == DietType.vegan ? primary : (isDark ? AppColors.darkInk : AppColors.lightInk),
                      fontWeight: vm.dietType == DietType.vegan ? FontWeight.w600 : FontWeight.w400,
                    ),
                    onSelected: (val) {
                      if (val) onDietTypeChanged?.call(DietType.vegan);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Allergies & Sensitivities', style: AppTypography.bodyStrong),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Gluten Sensitive'),
                    selected: vm.allergies.contains('gluten'),
                    selectedColor: isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft,
                    checkmarkColor: primary,
                    side: BorderSide(
                      color: vm.allergies.contains('gluten') ? primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: vm.allergies.contains('gluten') ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: vm.allergies.contains('gluten') ? primary : (isDark ? AppColors.darkInk : AppColors.lightInk),
                      fontWeight: vm.allergies.contains('gluten') ? FontWeight.w600 : FontWeight.w400,
                    ),
                    onSelected: (_) => onAllergyToggled?.call('gluten'),
                  ),
                  FilterChip(
                    label: const Text('Dairy / Lactose Free'),
                    selected: vm.allergies.contains('dairy'),
                    selectedColor: isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft,
                    checkmarkColor: primary,
                    side: BorderSide(
                      color: vm.allergies.contains('dairy') ? primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: vm.allergies.contains('dairy') ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: vm.allergies.contains('dairy') ? primary : (isDark ? AppColors.darkInk : AppColors.lightInk),
                      fontWeight: vm.allergies.contains('dairy') ? FontWeight.w600 : FontWeight.w400,
                    ),
                    onSelected: (_) => onAllergyToggled?.call('dairy'),
                  ),
                  FilterChip(
                    label: const Text('Tree Nuts & Peanuts'),
                    selected: vm.allergies.contains('nuts'),
                    selectedColor: isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft,
                    checkmarkColor: primary,
                    side: BorderSide(
                      color: vm.allergies.contains('nuts') ? primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: vm.allergies.contains('nuts') ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: vm.allergies.contains('nuts') ? primary : (isDark ? AppColors.darkInk : AppColors.lightInk),
                      fontWeight: vm.allergies.contains('nuts') ? FontWeight.w600 : FontWeight.w400,
                    ),
                    onSelected: (_) => onAllergyToggled?.call('nuts'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cross-contact notice: commercial spice mixes and restaurant food may contain allergen traces.',
                      style: AppTypography.micro.copyWith(
                        color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCookingRichnessStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How rich is your home cooking?',
          style: AppTypography.titleMedium.copyWith(
            fontSize: 26,
            color: isDark ? AppColors.darkInk : AppColors.lightInk,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Oil and ghee add more calories than most people expect. Pick what is closest to your usual salan.',
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
        const SizedBox(height: 24),
        _buildRichnessCard(
          context: context,
          level: OilLevel.light,
          title: 'Light',
          description: 'Little oil on top. Daal and sabzi look dry-ish.',
          subtext: 'About 1 tsp oil per katori',
        ),
        const SizedBox(height: 12),
        _buildRichnessCard(
          context: context,
          level: OilLevel.normal,
          title: 'Normal',
          badgeText: 'Most common',
          description: 'A thin layer of oil shows on the salan.',
          subtext: 'About 2 tsp oil per katori',
        ),
        const SizedBox(height: 12),
        _buildRichnessCard(
          context: context,
          level: OilLevel.rich,
          title: 'Rich',
          description: 'Oil floats on top, like karahi or shadi-style food.',
          subtext: 'About 4 tsp oil per katori',
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You can change this for any single dish later. All values are estimates.',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRichnessCard({
    required BuildContext context,
    required OilLevel level,
    required String title,
    String? badgeText,
    required String description,
    required String subtext,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = vm.cookingRichness == level;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return InkWell(
      onTap: () => onRichnessChanged?.call(level),
      borderRadius: AppRadii.cardRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: AppRadii.cardRadius,
          border: Border.all(
            color: isSelected ? primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<OilLevel>(
              value: level,
              groupValue: vm.cookingRichness,
              activeColor: primary,
              onChanged: (val) {
                if (val != null) onRichnessChanged?.call(val);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.heading.copyWith(
                          color: isDark ? AppColors.darkInk : AppColors.lightInk,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: AppRadii.chipRadius,
                          ),
                          child: Text(
                            badgeText,
                            style: AppTypography.micro.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.body.copyWith(
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtext,
                    style: AppTypography.captionStrong.copyWith(color: primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSummaryStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Daily Nutrition Target',
          style: AppTypography.titleLarge.copyWith(
            color: isDark ? AppColors.darkInk : AppColors.lightInk,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Calculated using the Mifflin-St Jeor equation and standard healthy rate caps.',
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
        const SizedBox(height: 24),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated Daily Energy',
                style: AppTypography.captionStrong.copyWith(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '~${vm.recommendedCalories ?? 1850}',
                    style: AppTypography.numberLarge.copyWith(
                      color: isDark ? AppColors.darkInk : AppColors.lightInk,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'kcal / day',
                    style: AppTypography.body.copyWith(
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NutrientBar(
                      label: 'Protein',
                      currentGrams: vm.recommendedProtein ?? 95,
                      targetGrams: vm.recommendedProtein ?? 95,
                      barColor: AppColors.protein,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NutrientBar(
                      label: 'Carbs',
                      currentGrams: vm.recommendedCarbs ?? 230,
                      targetGrams: vm.recommendedCarbs ?? 230,
                      barColor: AppColors.carbs,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NutrientBar(
                      label: 'Fat',
                      currentGrams: vm.recommendedFat ?? 60,
                      targetGrams: vm.recommendedFat ?? 60,
                      barColor: AppColors.fat,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NutrientBar(
                      label: 'Fibre',
                      currentGrams: vm.recommendedFibre ?? 28,
                      targetGrams: vm.recommendedFibre ?? 28,
                      barColor: AppColors.fibre,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AboutYouStepWidget extends StatefulWidget {
  final OnboardingViewModel vm;
  final ValueChanged<BiologicalSex>? onSexChanged;
  final ValueChanged<double>? onHeightChanged;
  final ValueChanged<double>? onWeightChanged;

  const _AboutYouStepWidget({
    required this.vm,
    this.onSexChanged,
    this.onHeightChanged,
    this.onWeightChanged,
  });

  @override
  State<_AboutYouStepWidget> createState() => _AboutYouStepWidgetState();
}

class _AboutYouStepWidgetState extends State<_AboutYouStepWidget> {
  late TextEditingController _weightController;
  late FocusNode _weightFocusNode;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.vm.weightKg % 1 == 0
          ? widget.vm.weightKg.round().toString()
          : widget.vm.weightKg.toStringAsFixed(1),
    );
    _weightFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _AboutYouStepWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_weightFocusNode.hasFocus && oldWidget.vm.weightKg != widget.vm.weightKg) {
      final newText = widget.vm.weightKg % 1 == 0
          ? widget.vm.weightKg.round().toString()
          : widget.vm.weightKg.toStringAsFixed(1);
      if (_weightController.text != newText) {
        _weightController.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  void _adjustWeight(double delta) {
    final current = double.tryParse(_weightController.text.trim()) ?? widget.vm.weightKg;
    final updated = (current + delta).clamp(30.0, 250.0);
    final formatted = updated % 1 == 0 ? updated.round().toString() : updated.toStringAsFixed(1);
    _weightController.text = formatted;
    widget.onWeightChanged?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final feet = OnboardingScreen.getFeetFromCm(widget.vm.heightCm);
    final inches = OnboardingScreen.getInchesFromCm(widget.vm.heightCm);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About you',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkInk : AppColors.lightInk,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Used solely to calculate your basal metabolic rate and minimum energy requirements.',
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Biological Sex
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Biological Sex', style: AppTypography.bodyStrong),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Female'),
                        selected: widget.vm.sex == BiologicalSex.female,
                        onSelected: (_) => widget.onSexChanged?.call(BiologicalSex.female),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Male'),
                        selected: widget.vm.sex == BiologicalSex.male,
                        onSelected: (_) => widget.onSexChanged?.call(BiologicalSex.male),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              // Height Wheel Picker
              InkWell(
                onTap: () {
                  _showHeightPickerSheet(
                    context: context,
                    currentCm: widget.vm.heightCm,
                    onConfirmed: (newCm) => widget.onHeightChanged?.call(newCm),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Height', style: AppTypography.bodyStrong),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to scroll ft & in',
                            style: AppTypography.micro.copyWith(
                              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$feet ft $inches in (${widget.vm.heightCm.round()} cm)',
                              style: AppTypography.bodyStrong.copyWith(color: primary),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.unfold_more, size: 18, color: primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              // Current Weight Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Weight', style: AppTypography.bodyStrong),
                      const SizedBox(height: 2),
                      Text(
                        'Type in kg or use +/-',
                        style: AppTypography.micro.copyWith(
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: primary,
                        iconSize: 26,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        onPressed: () => _adjustWeight(-1.0),
                        tooltip: 'Decrease 1 kg',
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 76,
                        height: 40,
                        child: TextField(
                          controller: _weightController,
                          focusNode: _weightFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: AppTypography.heading.copyWith(
                            color: isDark ? AppColors.darkInk : AppColors.lightInk,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            suffixText: 'kg',
                            suffixStyle: AppTypography.captionStrong.copyWith(
                              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                            isDense: true,
                            filled: true,
                            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: primary,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            final parsed = double.tryParse(val.trim());
                            if (parsed != null && parsed >= 30 && parsed <= 250) {
                              widget.onWeightChanged?.call(parsed);
                            }
                          },
                          onEditingComplete: () {
                            final parsed = double.tryParse(_weightController.text.trim());
                            if (parsed == null || parsed < 30 || parsed > 250) {
                              _weightController.text = widget.vm.weightKg % 1 == 0
                                  ? widget.vm.weightKg.round().toString()
                                  : widget.vm.weightKg.toStringAsFixed(1);
                            }
                            _weightFocusNode.unfocus();
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: primary,
                        iconSize: 26,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        onPressed: () => _adjustWeight(1.0),
                        tooltip: 'Increase 1 kg',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showHeightPickerSheet({
  required BuildContext context,
  required double currentCm,
  required ValueChanged<double> onConfirmed,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

  int selectedFeet = OnboardingScreen.getFeetFromCm(currentCm);
  int selectedInches = OnboardingScreen.getInchesFromCm(currentCm);

  final feetController = FixedExtentScrollController(initialItem: (selectedFeet - 4).clamp(0, 3));
  final inchesController = FixedExtentScrollController(initialItem: selectedInches.clamp(0, 11));

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final computedCm = OnboardingScreen.getCmFromFeetInches(selectedFeet, selectedInches);

          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorderStrong : AppColors.lightBorderStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scroll to Set Height',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.darkInk : AppColors.lightInk,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '$selectedFeet ft $selectedInches in  ·  ${computedCm.round()} cm',
                    style: AppTypography.heading.copyWith(color: primary),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 190,
                  child: Stack(
                    children: [
                      // Selection highlight bar in center
                      Center(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Two wheel columns: Feet and Inches
                      Row(
                        children: [
                          // Feet Wheel
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Feet (ft)',
                                  style: AppTypography.captionStrong.copyWith(
                                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: ListWheelScrollView.useDelegate(
                                    controller: feetController,
                                    itemExtent: 44,
                                    physics: const FixedExtentScrollPhysics(),
                                    perspective: 0.003,
                                    overAndUnderCenterOpacity: 0.45,
                                    onSelectedItemChanged: (index) {
                                      setSheetState(() {
                                        selectedFeet = index + 4;
                                      });
                                    },
                                    childDelegate: ListWheelChildBuilderDelegate(
                                      childCount: 4, // 4, 5, 6, 7
                                      builder: (context, index) {
                                        final ft = index + 4;
                                        final isSel = ft == selectedFeet;
                                        return Center(
                                          child: Text(
                                            '$ft ft',
                                            style: (isSel ? AppTypography.heading : AppTypography.body).copyWith(
                                              color: isSel
                                                  ? (isDark ? AppColors.darkInk : AppColors.lightInk)
                                                  : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
                                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divider line
                          Container(
                            width: 1,
                            height: 120,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                          // Inches Wheel
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Inches (in)',
                                  style: AppTypography.captionStrong.copyWith(
                                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: ListWheelScrollView.useDelegate(
                                    controller: inchesController,
                                    itemExtent: 44,
                                    physics: const FixedExtentScrollPhysics(),
                                    perspective: 0.003,
                                    overAndUnderCenterOpacity: 0.45,
                                    onSelectedItemChanged: (index) {
                                      setSheetState(() {
                                        selectedInches = index;
                                      });
                                    },
                                    childDelegate: ListWheelChildBuilderDelegate(
                                      childCount: 12, // 0..11
                                      builder: (context, index) {
                                        final isSel = index == selectedInches;
                                        return Center(
                                          child: Text(
                                            '$index in',
                                            style: (isSel ? AppTypography.heading : AppTypography.body).copyWith(
                                              color: isSel
                                                  ? (isDark ? AppColors.darkInk : AppColors.lightInk)
                                                  : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
                                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Set Height',
                  onPressed: () {
                    final cm = OnboardingScreen.getCmFromFeetInches(selectedFeet, selectedInches);
                    onConfirmed(cm);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
