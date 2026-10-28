import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Single nutrient bar showing label, current / target numbers, and progress track.
class NutrientBar extends StatelessWidget {
  final String label;
  final num currentGrams;
  final num targetGrams;
  final Color barColor;

  const NutrientBar({
    super.key,
    required this.label,
    required this.currentGrams,
    required this.targetGrams,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = targetGrams > 0 ? (currentGrams / targetGrams).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.micro.copyWith(
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            style: AppTypography.captionStrong.copyWith(
              color: isDark ? AppColors.darkInk : AppColors.lightInk,
            ),
            children: [
              TextSpan(text: currentGrams.round().toString()),
              TextSpan(
                text: ' / ${targetGrams.round()} g',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: progress.toDouble(),
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dual-fill bar representing eaten vs planned calories.
class CalorieSplitBar extends StatelessWidget {
  final num eatenKcal;
  final num plannedKcal;
  final num targetKcal;

  const CalorieSplitBar({
    super.key,
    required this.eatenKcal,
    required this.plannedKcal,
    required this.targetKcal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = targetKcal > 0 ? targetKcal : 1;
    final eatenRatio = (eatenKcal / total).clamp(0.0, 1.0);
    final plannedRatio = ((eatenKcal + plannedKcal) / total).clamp(0.0, 1.0);

    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          // Planned portion
          FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: plannedRatio.toDouble(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.plannedFill,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          // Eaten portion
          FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: eatenRatio.toDouble(),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
