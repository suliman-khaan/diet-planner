import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'badges.dart';

/// Card container matching design/spec.md tokens.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkInk : AppColors.lightInk;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: border, width: 1),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: textColor),
        child: IconTheme.merge(
          data: IconThemeData(color: textColor),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardRadius,
        child: content,
      );
    }
    return content;
  }
}

/// A meal row item on the Today screen.
class MealListRow extends StatelessWidget {
  final String slotTitle;
  final String time;
  final MealStatus status;
  final String summaryText;
  final num calories;
  final VoidCallback? onLogTap;
  final VoidCallback? onRowTap;

  const MealListRow({
    super.key,
    required this.slotTitle,
    required this.time,
    required this.status,
    required this.summaryText,
    required this.calories,
    this.onLogTap,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusLabel = switch (status) {
      MealStatus.eaten => 'Eaten',
      MealStatus.planned => 'Planned',
      MealStatus.notLogged => 'Not logged',
    };

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onRowTap,
      child: Row(
        children: [
          MealStatusIndicator(status: status),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTypography.captionStrong.copyWith(
                      color: isDark ? AppColors.darkInk : AppColors.lightInk,
                    ),
                    children: [
                      TextSpan(text: slotTitle),
                      TextSpan(
                        text: ' · $time · $statusLabel',
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (status == MealStatus.planned && onLogTap != null)
            SizedBox(
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(64, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.control),
                  ),
                ),
                onPressed: onLogTap,
                child: const Text('Log'),
              ),
            )
          else
            Text(
              calories.round().toString(),
              style: AppTypography.captionStrong.copyWith(
                color: isDark ? AppColors.darkInk : AppColors.lightInk,
              ),
            ),
        ],
      ),
    );
  }
}
