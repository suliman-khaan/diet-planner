import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/state_widgets.dart';
import '../view_model/history_view_model.dart';

/// History screen displaying immutable past nutrition day snapshots.
class HistoryScreen extends StatelessWidget {
  final HistoryViewModel vm;
  final ValueChanged<PastDayLogSnapshotViewModel>? onDaySelected;

  const HistoryScreen({
    super.key,
    required this.vm,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Past Days & History',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkInk : AppColors.lightInk,
          ),
        ),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (vm.isLoading) {
      return const Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            LoadingSkeleton(width: double.infinity, height: 110),
            SizedBox(height: 12),
            LoadingSkeleton(width: double.infinity, height: 110),
          ],
        ),
      );
    }

    if (vm.pastDays.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history,
        title: 'No historical days yet',
        message:
            'As you log your daily meals, permanent nutrition snapshots will be archived here.',
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Past logs store immutable nutrition snapshots. Catalogue corrections never alter past records.',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(height: 16),
          ...vm.pastDays.map((day) => _buildDayCard(context, day)),
        ],
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, PastDayLogSnapshotViewModel day) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => onDaySelected?.call(day),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day.dateTitle,
                  style: AppTypography.bodyStrong.copyWith(
                    color: isDark ? AppColors.darkInk : AppColors.lightInk,
                  ),
                ),
                const EstimateBadge(),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTypography.heading.copyWith(
                      color: isDark ? AppColors.darkInk : AppColors.lightInk,
                    ),
                    children: [
                      TextSpan(text: '${day.totalCalories.round()} '),
                      TextSpan(
                        text: '/ ~${day.targetCalories.round()} kcal',
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${day.mealsLogged} of ${day.totalMeals} meals logged',
                  style: AppTypography.captionStrong.copyWith(
                    color:
                        isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                ),
              ],
            ),
            if (day.topDishes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                day.topDishes.join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
