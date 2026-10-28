import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';

/// Visual household measure guide item.
class HouseholdMeasureGuide {
  final String title;
  final String urduName;
  final String description;
  final String typicalWeight;
  final IconData icon;

  const HouseholdMeasureGuide({
    required this.title,
    required this.urduName,
    required this.description,
    required this.typicalWeight,
    required this.icon,
  });
}

const List<HouseholdMeasureGuide> defaultMeasureGuides = [
  HouseholdMeasureGuide(
    title: 'Katori (Standard Bowl)',
    urduName: 'کٹوری',
    description: 'Traditional metal or ceramic curry bowl. Level portion of salan or daal.',
    typicalWeight: '~180 g (cooked)',
    icon: Icons.soup_kitchen_outlined,
  ),
  HouseholdMeasureGuide(
    title: 'Pyala (Large Bowl)',
    urduName: 'پیالہ',
    description: 'Larger serving bowl typically used for nihari, paya, or haleem.',
    typicalWeight: '~250–300 g',
    icon: Icons.rice_bowl_outlined,
  ),
  HouseholdMeasureGuide(
    title: 'Chamach (Serving / Table)',
    urduName: 'کھانے کا چمچ',
    description: 'Level tablespoon for rice, raita, chutney, or added ghee.',
    typicalWeight: '~15 g / 15 ml',
    icon: Icons.restaurant_outlined,
  ),
  HouseholdMeasureGuide(
    title: 'Roti Diameter Guide',
    urduName: 'روٹی کا سائز',
    description: 'Medium home phulka (~7 inches, 45 g atta) vs tandoori roti.',
    typicalWeight: '~120–150 kcal each',
    icon: Icons.circle_outlined,
  ),
];

/// Bottom sheet displaying visual household portion guides and 'My Katori' calibration.
class PortionPickerSheet extends StatefulWidget {
  final ValueChanged<int>? onCalibratedGrams;

  const PortionPickerSheet({
    super.key,
    this.onCalibratedGrams,
  });

  @override
  State<PortionPickerSheet> createState() => _PortionPickerSheetState();
}

class _PortionPickerSheetState extends State<PortionPickerSheet> {
  int _calibratedGrams = 180;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
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
                Text(
                  'Portion size guides',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.darkInk : AppColors.lightInk,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'No food scale needed. We estimate nutrition based on traditional Pakistani kitchenware.',
              style: AppTypography.body.copyWith(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            const SizedBox(height: 16),
            ...defaultMeasureGuides.map((guide) => _buildGuideCard(context, guide)),
            const SizedBox(height: 16),
            _buildCalibrationCard(context),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Done',
              onPressed: () {
                widget.onCalibratedGrams?.call(_calibratedGrams);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, HouseholdMeasureGuide guide) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                borderRadius: BorderRadius.circular(AppRadii.control),
              ),
              child: Icon(
                guide.icon,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        guide.title,
                        style: AppTypography.bodyStrong.copyWith(
                          color: isDark ? AppColors.darkInk : AppColors.lightInk,
                        ),
                      ),
                      Text(
                        guide.urduName,
                        style: AppTypography.urduSubtitle.copyWith(
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    guide.description,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    guide.typicalWeight,
                    style: AppTypography.captionStrong.copyWith(
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 20, color: primary),
              const SizedBox(width: 8),
              Text(
                'Calibrate "My Katori"',
                style: AppTypography.subheading.copyWith(
                  color: isDark ? AppColors.darkInk : AppColors.lightInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'If your home bowl holds more or less than 180 g, adjust it here once to recalculate all your recipes automatically.',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bowl capacity:',
                style: AppTypography.bodyStrong.copyWith(
                  color: isDark ? AppColors.darkInk : AppColors.lightInk,
                ),
              ),
              Text(
                '$_calibratedGrams g / ml',
                style: AppTypography.heading.copyWith(color: primary),
              ),
            ],
          ),
          Slider(
            value: _calibratedGrams.toDouble(),
            min: 120,
            max: 300,
            divisions: 18,
            activeColor: primary,
            onChanged: (val) {
              setState(() => _calibratedGrams = val.round());
            },
          ),
        ],
      ),
    );
  }
}
