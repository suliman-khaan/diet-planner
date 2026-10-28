import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/macro_bars.dart';
import '../../../core/widgets/segmented_controls.dart';
import '../view_model/onboarding_view_model.dart';

/// Complete Onboarding Screen supporting all steps (welcome to target summary).
class OnboardingScreen extends StatelessWidget {
  final OnboardingViewModel vm;
  final ValueChanged<OnboardingStep>? onStepSelected;
  final ValueChanged<WeightGoal>? onGoalChanged;
  final ValueChanged<OilLevel>? onRichnessChanged;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final VoidCallback? onFinish;

  const OnboardingScreen({
    super.key,
    required this.vm,
    this.onStepSelected,
    this.onGoalChanged,
    this.onRichnessChanged,
    this.onNext,
    this.onBack,
    this.onFinish,
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
              if (vm.currentStep == OnboardingStep.welcome)
                PrimaryButton(label: 'Get started', onPressed: onNext)
              else if (vm.currentStep == OnboardingStep.targetSummary)
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
      case OnboardingStep.cookingRichness:
        return _buildCookingRichnessStep(context);
      case OnboardingStep.targetSummary:
        return _buildTargetSummaryStep(context);
      case OnboardingStep.goal:
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
