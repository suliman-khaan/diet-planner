import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/macro_bars.dart';
import '../../../core/widgets/steppers.dart';
import '../view_model/foods_view_model.dart';

/// Detailed food inspection and portion addition modal bottom sheet.
class FoodDetailSheet extends StatefulWidget {
  final FoodItemViewModel food;
  final ValueChanged<num>? onAddToMeal;

  const FoodDetailSheet({
    super.key,
    required this.food,
    this.onAddToMeal,
  });

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
  num _servings = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final food = widget.food;
    final totalKcal = (food.calories * _servings).round();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
      ),
      padding: AppSpacing.screenPadding,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.englishName,
                        style: AppTypography.heading.copyWith(
                          color:
                              isDark ? AppColors.darkInk : AppColors.lightInk,
                        ),
                      ),
                      Text(
                        food.urduName,
                        style: AppTypography.urduSubtitle.copyWith(
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const EstimateBadge(),
                const SizedBox(width: 8),
                ReviewStatusBadge(isReviewed: food.isReviewed),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Portion servings',
                        style: AppTypography.bodyStrong.copyWith(
                          color:
                              isDark ? AppColors.darkInk : AppColors.lightInk,
                        ),
                      ),
                      PortionStepper(
                        value: _servings,
                        itemName: 'servings',
                        onChanged: (val) {
                          if (val > 0) setState(() => _servings = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Calories',
                        style: AppTypography.captionStrong.copyWith(
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                      Text(
                        '$totalKcal kcal',
                        style: AppTypography.heading.copyWith(
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: NutrientBar(
                          label: 'Protein',
                          currentGrams: food.proteinGrams * _servings,
                          targetGrams: food.proteinGrams * _servings,
                          barColor: AppColors.protein,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NutrientBar(
                          label: 'Carbs',
                          currentGrams: food.carbsGrams * _servings,
                          targetGrams: food.carbsGrams * _servings,
                          barColor: AppColors.carbs,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NutrientBar(
                          label: 'Fat',
                          currentGrams: food.fatGrams * _servings,
                          targetGrams: food.fatGrams * _servings,
                          barColor: AppColors.fat,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NutrientBar(
                          label: 'Fibre',
                          currentGrams: food.fibreGrams * _servings,
                          targetGrams: food.fibreGrams * _servings,
                          barColor: AppColors.fibre,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 20,
                      color:
                          isDark ? AppColors.darkMuted : AppColors.lightMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.allergens.isEmpty
                              ? 'Allergens: none listed in the recipe'
                              : 'Allergens: ${food.allergens.join(', ')}',
                          style: AppTypography.captionStrong.copyWith(
                            color:
                                isDark ? AppColors.darkInk : AppColors.lightInk,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${food.isReviewed ? '' : 'This allergen list has not been reviewed yet. '}'
                          'Ingredient lists cannot rule out cross-contact in kitchens, spice mixes or restaurants.',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Add to meal ($totalKcal kcal)',
              onPressed: () {
                widget.onAddToMeal?.call(_servings);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
