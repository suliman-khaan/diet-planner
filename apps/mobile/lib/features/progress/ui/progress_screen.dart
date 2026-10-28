import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_widgets.dart';
import '../view_model/progress_view_model.dart';
import 'add_weight_sheet.dart';

/// Progress screen displaying weight trends, line chart, and logged-days consistency.
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
                'Weight & Consistency',
                style: AppTypography.titleMedium.copyWith(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            context,
            label: 'Week',
            isSelected: !vm.isMonthView,
            onTap: () => onRangeToggled?.call(false),
          ),
          _buildToggleOption(
            context,
            label: 'Month',
            isSelected: vm.isMonthView,
            onTap: () => onRangeToggled?.call(true),
          ),
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        vm.currentWeightKg.toStringAsFixed(1),
                        style: AppTypography.numberLarge.copyWith(
                          fontSize: 30,
                          color: isDark ? AppColors.darkInk : AppColors.lightInk,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'kg',
                          style: AppTypography.subheading.copyWith(
                            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    vm.weightChangeSubtitle,
                    style: AppTypography.captionStrong.copyWith(
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
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
          const SizedBox(height: 18),
          // Interactive vector line chart canvas with dynamic points and guidelines
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _WeightLineChartPainter(
                points: vm.weightTrend,
                lineColor: primary,
                gridColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                labelColor: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Dynamic date labels aligned with data points
          if (vm.weightTrend.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: vm.weightTrend.map((p) {
                return Text(
                  p.dateLabel,
                  style: AppTypography.micro.copyWith(
                    fontWeight: FontWeight.w600,
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
          const SizedBox(height: 18),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: vm.weekEating.map((day) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: day.percentageOfTarget.clamp(0.12, 1.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: day.status == EatingLogStatus.fullyLogged
                                      ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                                      : (day.status == EatingLogStatus.partlyLogged
                                          ? (isDark ? const Color(0xFF43735E) : AppColors.plannedFill)
                                          : Colors.transparent),
                                  borderRadius: BorderRadius.circular(8),
                                  border: day.status == EatingLogStatus.notLogged
                                      ? Border.all(
                                          color: isDark ? AppColors.darkBorderStrong : AppColors.plannedDash,
                                          width: 2,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          day.dayLabel,
                          style: AppTypography.micro.copyWith(
                            fontWeight: FontWeight.w700,
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
                color: isDark ? const Color(0xFF43735E) : AppColors.plannedFill,
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
    required String label,
    bool isDashed = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(3),
            border: isDashed
                ? Border.all(
                    color: isDark ? AppColors.darkBorderStrong : AppColors.plannedDash,
                    width: 1.5,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.micro.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTiles(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Row(
      children: [
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Days logged',
                  style: AppTypography.micro.copyWith(
                    fontWeight: FontWeight.w700,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: AppTypography.titleMedium.copyWith(color: inkColor),
                    children: [
                      TextSpan(
                        text: '${vm.daysLoggedThisWeek} ',
                        style: TextStyle(fontWeight: FontWeight.w800, color: inkColor),
                      ),
                      TextSpan(
                        text: 'of ${vm.totalDaysInPeriod}',
                        style: AppTypography.captionStrong.copyWith(color: mutedColor),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avg. protein',
                  style: AppTypography.micro.copyWith(
                    fontWeight: FontWeight.w700,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: AppTypography.titleMedium.copyWith(color: inkColor),
                    children: [
                      TextSpan(
                        text: '${vm.averageProteinGrams.round()} ',
                        style: TextStyle(fontWeight: FontWeight.w800, color: inkColor),
                      ),
                      TextSpan(
                        text: 'g / day',
                        style: AppTypography.captionStrong.copyWith(color: mutedColor),
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

/// Custom line chart painter supporting dynamic data points, smooth Bezier curves,
/// gradient fill, horizontal reference gridlines, and labeled Y-axis values.
class _WeightLineChartPainter extends CustomPainter {
  final List<WeightPointViewModel> points;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;
  final bool isDark;

  _WeightLineChartPainter({
    required this.points,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 60 || size.height < 40) return;

    if (points.isEmpty) {
      final textSpan = TextSpan(
        text: 'No weight data logged yet',
        style: TextStyle(color: labelColor, fontSize: 13),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      textPainter.paint(
        canvas,
        Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
      );
      return;
    }

    const double yAxisWidth = 48.0;
    const double topPadding = 12.0;
    const double bottomPadding = 14.0;
    final chartWidth = size.width - yAxisWidth;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // Calculate min and max weights with breathing margin
    double minW = points.map((p) => p.weightKg).reduce(math.min);
    double maxW = points.map((p) => p.weightKg).reduce(math.max);

    if ((maxW - minW).abs() < 0.2) {
      minW -= 1.0;
      maxW += 1.0;
    } else {
      final margin = (maxW - minW) * 0.25;
      minW -= margin;
      maxW += margin;
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    // 3 horizontal reference guidelines with right-aligned weight labels
    final gridSteps = [maxW, (maxW + minW) / 2, minW];
    final yPositions = [
      topPadding,
      topPadding + chartHeight * 0.5,
      topPadding + chartHeight,
    ];

    for (var i = 0; i < gridSteps.length; i++) {
      final y = yPositions[i];
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);

      final label = '${gridSteps[i].toStringAsFixed(1)} kg';
      final textSpan = TextSpan(
        text: label,
        style: TextStyle(
          color: labelColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(chartWidth + 6, y - textPainter.height / 2));
    }

    // Map each data point to canvas pixel coordinate
    final offsets = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? chartWidth / 2
          : (i / (points.length - 1)) * chartWidth;
      final normalized = (points[i].weightKg - minW) / (maxW - minW);
      final y = topPadding + (1.0 - normalized.clamp(0.0, 1.0)) * chartHeight;
      offsets.add(Offset(x, y));
    }

    // Build smooth cubic Bezier curve path
    final curvePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      curvePath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Draw gradient fill beneath the curve
    final fillPath = Path.from(curvePath)
      ..lineTo(offsets.last.dx, size.height)
      ..lineTo(offsets.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withOpacity(isDark ? 0.35 : 0.20),
          lineColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, topPadding, chartWidth, chartHeight + bottomPadding));

    canvas.drawPath(fillPath, fillPaint);

    // Draw primary curve stroke
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(curvePath, strokePaint);

    // Draw data point dots with highlighted latest dot
    final dotPaint = Paint()..color = lineColor;
    final dotHaloPaint = Paint()..color = lineColor.withOpacity(0.25);
    final dotWhitePaint = Paint()..color = Colors.white;

    for (var i = 0; i < offsets.length; i++) {
      final isLast = i == offsets.length - 1;
      if (isLast) {
        // High-contrast pulsed dot for current weight
        canvas.drawCircle(offsets[i], 8, dotHaloPaint);
        canvas.drawCircle(offsets[i], 5, dotPaint);
        canvas.drawCircle(offsets[i], 2.5, dotWhitePaint);
      } else {
        canvas.drawCircle(offsets[i], 3.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WeightLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.isDark != isDark;
  }
}
