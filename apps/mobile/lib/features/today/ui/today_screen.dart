import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/macro_bars.dart';
import '../../../core/widgets/state_widgets.dart';
import '../view_model/today_view_model.dart';

/// Complete Today Screen supporting standard mode, Ramadan mode, and manual mode.
class TodayScreen extends StatelessWidget {
  final TodayViewModel vm;
  final VoidCallback? onInfoTap;
  final VoidCallback? onMarkNextMealEaten;
  final VoidCallback? onChangeNextMeal;
  final ValueChanged<String>? onMealRowTap;
  final ValueChanged<String>? onMealLogTap;
  final VoidCallback? onRetry;
  final VoidCallback? onGeneratePlan;

  const TodayScreen({
    super.key,
    required this.vm,
    this.onInfoTap,
    this.onMarkNextMealEaten,
    this.onChangeNextMeal,
    this.onMealRowTap,
    this.onMealLogTap,
    this.onRetry,
    this.onGeneratePlan,
  });

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return _buildLoadingState(context);
    }
    if (vm.errorMessage != null && onRetry != null) {
      return ErrorStateWidget(
        message: vm.errorMessage!,
        onRetry: onRetry!,
      );
    }
    if (vm.hasNoPlan) {
      return _buildNoPlanState(context);
    }

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildCalorieCard(context),
          const SizedBox(height: 16),
          if (vm.nextMeal != null) ...[
            _buildNextMealCard(context),
            const SizedBox(height: 20),
          ],
          _buildMealsSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vm.dateDisplay,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Today',
              style: AppTypography.titleLarge.copyWith(
                color: isDark ? AppColors.darkInk : AppColors.lightInk,
              ),
            ),
          ],
        ),
        if (vm.isRamadanMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.ramadanBackground,
              borderRadius: AppRadii.chipRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.nightlight_round, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'Ramadan · Day ${vm.ramadanDay ?? 1}',
                  style: AppTypography.micro.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              style: IconButton.styleFrom(
                shape: const CircleBorder(),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              icon: Icon(
                Icons.info_outline,
                size: 20,
                color: isDark ? AppColors.darkInk : AppColors.lightInk,
              ),
              onPressed: onInfoTap,
            ),
          ),
      ],
    );
  }

  Widget _buildCalorieCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    vm.eatenKcal.round().toString(),
                    style: AppTypography.numberLarge.copyWith(
                      color: isDark ? AppColors.darkInk : AppColors.lightInk,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'kcal eaten',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                ],
              ),
              const EstimateBadge(),
            ],
          ),
          const SizedBox(height: 12),
          CalorieSplitBar(
            eatenKcal: vm.eatenKcal,
            plannedKcal: vm.plannedKcal,
            targetKcal: vm.targetKcal,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  colorDot: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  label: 'Eaten',
                  value: vm.eatenKcal.round().toString(),
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  context,
                  colorDot: AppColors.plannedFill,
                  label: 'Still planned',
                  value: vm.plannedKcal.round().toString(),
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'Daily target',
                  value: '~${vm.targetKcal.round()}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: NutrientBar(
                  label: 'Protein',
                  currentGrams: vm.proteinCurrent,
                  targetGrams: vm.proteinTarget,
                  barColor: AppColors.protein,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NutrientBar(
                  label: 'Carbs',
                  currentGrams: vm.carbsCurrent,
                  targetGrams: vm.carbsTarget,
                  barColor: AppColors.carbs,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NutrientBar(
                  label: 'Fat',
                  currentGrams: vm.fatCurrent,
                  targetGrams: vm.fatTarget,
                  barColor: AppColors.fat,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NutrientBar(
                  label: 'Fibre',
                  currentGrams: vm.fibreCurrent,
                  targetGrams: vm.fibreTarget,
                  barColor: AppColors.fibre,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    Color? colorDot,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (colorDot != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorDot,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTypography.micro.copyWith(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.subheading.copyWith(
            color: isDark ? AppColors.darkInk : AppColors.lightInk,
          ),
        ),
      ],
    );
  }

  Widget _buildNextMealCard(BuildContext context) {
    final next = vm.nextMeal!;
    final isRamadan = vm.isRamadanMode;
    final cardBg = isRamadan ? AppColors.ramadanBackground : AppColors.lightPrimary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadii.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                next.slotLabel.toUpperCase(),
                style: AppTypography.micro.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isRamadan ? AppColors.ramadanSoft : const Color(0xFFCFE6DB),
                ),
              ),
              Text(
                '~${next.estimatedCalories.round()} kcal',
                style: AppTypography.captionStrong.copyWith(
                  color: isRamadan ? AppColors.ramadanSoft : const Color(0xFFCFE6DB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            next.mainDishTitle,
            style: AppTypography.heading.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            next.familyPotDetail,
            style: AppTypography.body.copyWith(
              fontSize: 14,
              color: const Color(0xFFDCEDE5),
            ),
          ),
          Text(
            next.sidesDetail,
            style: AppTypography.body.copyWith(
              fontSize: 14,
              color: const Color(0xFFDCEDE5),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.control),
                      ),
                    ),
                    onPressed: onMarkNextMealEaten,
                    child: Text(
                      'Mark as eaten',
                      style: AppTypography.bodyStrong.copyWith(color: cardBg),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: isRamadan ? AppColors.ramadanBorder : const Color(0xFF6FA58E),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.control),
                    ),
                  ),
                  onPressed: onChangeNextMeal,
                  child: const Text('Change'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          vm.isRamadanMode ? 'Ramadan meals' : "Today's meals",
          style: AppTypography.subheading.copyWith(
            color: isDark ? AppColors.darkInk : AppColors.lightInk,
          ),
        ),
        const SizedBox(height: 10),
        if (vm.meals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No meals scheduled for today yet.',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
            ),
          )
        else
          ...vm.meals.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MealListRow(
              slotTitle: m.slotTitle,
              time: m.time,
              status: m.status,
              summaryText: m.summaryText,
              calories: m.calories,
              onLogTap: () => onMealLogTap?.call(m.id),
              onRowTap: () => onMealRowTap?.call(m.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoadingSkeleton(width: 140, height: 28),
          const SizedBox(height: 16),
          const LoadingSkeleton(width: double.infinity, height: 200, borderRadius: AppRadii.cardRadius),
          const SizedBox(height: 16),
          const LoadingSkeleton(width: double.infinity, height: 160, borderRadius: AppRadii.cardRadius),
          const SizedBox(height: 16),
          const LoadingSkeleton(width: double.infinity, height: 72),
          const SizedBox(height: 8),
          const LoadingSkeleton(width: double.infinity, height: 72),
        ],
      ),
    );
  }

  Widget _buildNoPlanState(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.calendar_today_outlined,
      title: 'No plan for today yet',
      message: vm.noPlanReason ??
          'Generate your personalized Pakistani meals aligned with your calories and cooking style.',
      actionLabel: 'Generate plan',
      onAction: onGeneratePlan,
    );
  }
}
