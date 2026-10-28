import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_widgets.dart';
import '../view_model/progress_view_model.dart';
import 'add_weight_sheet.dart';

/// Progress screen displaying weight trends and logged-days summary.
class ProgressScreen extends StatelessWidget {
  final ProgressViewModel vm;
  final ValueChanged<bool>? onRangeToggled; // false = week, true = month
  final VoidCallback? onAddWeightTap;

  const ProgressScreen({
    super.key,
    required this.vm,
    this.onRangeToggled,
    this.onAddWeightTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (vm.isLoading) {
      return Padding(
        padding: AppSpacing.screenPadding,
        child: const Column(
          children: [
            LoadingSkeleton(width: double.infinity, height: 220),
            SizedBox(height: 16),
            LoadingSkeleton(width: double.infinity, height: 200),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark ? AppColors.darkInk : AppColors.lightInk,
                ),
              ),
              _buildRangeToggle(context),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeightCard(context),
          const SizedBox(height: 16),
          _buildEatingConsistencyCard(context),
          const SizedBox(height: 16),
          _buildMetricTiles(context),
        ],
      ),
    );
  }

  Widget _buildRangeToggle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _buildToggleOption(context, label: 'Week', isSelected: !vm.isMonthView, onTap: () => onRangeToggled?.call(false)),
          _buildToggleOption(context, label: 'Month', isSelected: vm.isMonthView, onTap: () => onRangeToggled?.call(true)),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.captionStrong.copyWith(
            color: isSelected
                ? (isDark ? AppColors.darkInk : AppColors.lightInk)
                : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weight',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        vm.currentWeightKg.toStringAsFixed(1),
                        style: AppTypography.numberLarge.copyWith(
                          fontSize: 30,
                          color: isDark ? AppColors.darkInk : AppColors.lightInk,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'kg',
                        style: AppTypography.subheading.copyWith(
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    vm.weightChangeSubtitle,
                    style: AppTypography.captionStrong.copyWith(
                      color: isDark ? AppColors.darkInk : AppColors.lightInk,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.control),
                    ),
                  ),
                  onPressed: onAddWeightTap ?? () => _openAddWeightSheet(context),
                  child: const Text('Add weight'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Clean vector line chart canvas
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: CustomPaint(
              painter: _WeightLineChartPainter(
                lineColor: primary,
                gridColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['30 Sep', '7 Oct', '14 Oct', '21 Oct', '28 Oct'].map((d) {
              return Text(
                d,
                style: AppTypography.micro.copyWith(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEatingConsistencyCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This week\'s eating',
                style: AppTypography.subheading.copyWith(
                  color: isDark ? AppColors.darkInk : AppColors.lightInk,
                ),
              ),
              Text(
                'kcal · estimates',
                style: AppTypography.micro.copyWith(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: vm.weekEating.map((day) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: FractionallySizedBox(
                            alignment: Alignment.bottomCenter,
                            heightFactor: day.percentageOfTarget.clamp(0.1, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: day.status == EatingLogStatus.fullyLogged
                                    ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                                    : (day.status == EatingLogStatus.partlyLogged
                                        ? AppColors.plannedFill
                                        : Colors.transparent),
                                borderRadius: BorderRadius.circular(8),
                                border: day.status == EatingLogStatus.notLogged
                                    ? Border.all(color: AppColors.plannedDash, width: 2)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          day.dayLabel,
                          style: AppTypography.micro.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegend(
                context,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                label: 'Fully logged',
              ),
              _buildLegend(
                context,
                color: AppColors.plannedFill,
                label: 'Partly logged',
              ),
              _buildLegend(
                context,
                isDashed: true,
                label: 'Not logged',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
    BuildContext context, {
    Color? color,
    bool isDashed = false,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(3),
            border: isDashed ? Border.all(color: AppColors.plannedDash, width: 2) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.micro.copyWith(
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTiles(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Days logged',
                  style: AppTypography.micro.copyWith(color: AppColors.lightMuted),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: AppTypography.titleMedium,
                    children: [
                      TextSpan(text: '${vm.daysLoggedThisWeek} '),
                      TextSpan(
                        text: 'of ${vm.totalDaysInPeriod}',
                        style: AppTypography.captionStrong.copyWith(color: AppColors.lightMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avg. protein',
                  style: AppTypography.micro.copyWith(color: AppColors.lightMuted),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: AppTypography.titleMedium,
                    children: [
                      TextSpan(text: '${vm.averageProteinGrams.round()} '),
                      TextSpan(
                        text: 'g / day',
                        style: AppTypography.captionStrong.copyWith(color: AppColors.lightMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openAddWeightSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddWeightSheet(),
    );
  }
}

class _WeightLineChartPainter extends CustomPainter {
  final Color lineColor;
  final Color gridColor;

  _WeightLineChartPainter({
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // Horizontal guideline
    canvas.drawLine(Offset(0, size.height * 0.33), Offset(size.width, size.height * 0.33), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.66), Offset(size.width, size.height * 0.66), gridPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()..color = lineColor;
    final dotWhitePaint = Paint()..color = Colors.white;

    final points = [
      Offset(size.width * 0.05, size.height * 0.2),
      Offset(size.width * 0.28, size.height * 0.35),
      Offset(size.width * 0.52, size.height * 0.5),
      Offset(size.width * 0.76, size.height * 0.68),
      Offset(size.width * 0.95, size.height * 0.8),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, linePaint);

    for (var i = 0; i < points.length; i++) {
      if (i == points.length - 1) {
        canvas.drawCircle(points[i], 6, dotPaint);
        canvas.drawCircle(points[i], 3, dotWhitePaint);
      } else {
        canvas.drawCircle(points[i], 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
