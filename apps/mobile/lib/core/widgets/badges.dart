import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Small pill badge indicating nutrient/calorie estimates.
class EstimateBadge extends StatelessWidget {
  const EstimateBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
        borderRadius: AppRadii.chipRadius,
      ),
      child: Text(
        'Estimate',
        style: AppTypography.micro.copyWith(
          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
        ),
      ),
    );
  }
}

/// Badge indicating a recipe portion taken from a family pot.
class FamilyPotBadge extends StatelessWidget {
  const FamilyPotBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.familyPotDarkBg : AppColors.familyPotBg,
        borderRadius: AppRadii.chipRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.soup_kitchen_outlined,
            size: 14,
            color: isDark ? AppColors.familyPotDarkText : AppColors.familyPotText,
          ),
          const SizedBox(width: 4),
          Text(
            'Family pot',
            style: AppTypography.micro.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.familyPotDarkText : AppColors.familyPotText,
            ),
          ),
        ],
      ),
    );
  }
}

enum MealStatus { eaten, planned, notLogged }

/// Visual meal indicator (circle with checkmark, dashed outline, or '?').
class MealStatusIndicator extends StatelessWidget {
  final MealStatus status;

  const MealStatusIndicator({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case MealStatus.eaten:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 18,
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
        );
      case MealStatus.planned:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.plannedDash,
              width: 2,
            ),
          ),
        );
      case MealStatus.notLogged:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.plannedDash,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '?',
            style: AppTypography.captionStrong.copyWith(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
        );
    }
  }
}

/// Label indicating whether a food pack item has been nutrition-reviewed.
class ReviewStatusBadge extends StatelessWidget {
  final bool isReviewed;

  const ReviewStatusBadge({
    super.key,
    required this.isReviewed,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      isReviewed ? 'Reviewed' : 'Not yet reviewed',
      style: AppTypography.micro.copyWith(
        fontWeight: FontWeight.w700,
        color: isReviewed ? AppColors.reviewedText : AppColors.unreviewedText,
      ),
    );
  }
}
