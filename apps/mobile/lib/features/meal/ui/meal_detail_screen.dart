import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/segmented_controls.dart';
import '../../../core/widgets/steppers.dart';
import '../view_model/meal_view_model.dart';

/// Meal Detail Screen for adjusting family pot portions, oil levels, and side dishes.
class MealDetailScreen extends StatelessWidget {
  final MealViewModel vm;
  final VoidCallback? onBack;
  final ValueChanged<num>? onKatoriCountChanged;
  final ValueChanged<OilLevel>? onOilLevelChanged;
  final void Function(String sideId, num newCount)? onSideCountChanged;
  final ValueChanged<String>? onRemoveSideItem;
  final VoidCallback? onAddFood;
  final VoidCallback? onReplaceDish;
  final VoidCallback? onToggleEaten;

  const MealDetailScreen({
    super.key,
    required this.vm,
    this.onBack,
    this.onKatoriCountChanged,
    this.onOilLevelChanged,
    this.onSideCountChanged,
    this.onRemoveSideItem,
    this.onAddFood,
    this.onReplaceDish,
    this.onToggleEaten,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFamilyPotCard(context),
                      const SizedBox(height: 16),
                      if (vm.sideItems.isNotEmpty) ...[
                        _buildSideItemsCard(context),
                        const SizedBox(height: 16),
                      ],
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: vm.isEaten
                    ? 'Mark as planned'
                    : 'Mark ${vm.slotTitle.toLowerCase()} as eaten',
                onPressed: onToggleEaten,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vm.slotTitle,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.darkInk : AppColors.lightInk,
                ),
              ),
              Text(
                vm.timeLabel,
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              vm.totalCalories.round().toString(),
              style: AppTypography.titleMedium.copyWith(
                fontSize: 22,
                color: isDark ? AppColors.darkInk : AppColors.lightInk,
              ),
            ),
            Text(
              'kcal · estimate',
              style: AppTypography.micro.copyWith(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFamilyPotCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FamilyPotBadge(),
                    const SizedBox(height: 6),
                    Text(
                      vm.mainDishName,
                      style: AppTypography.heading.copyWith(
                        color: isDark ? AppColors.darkInk : AppColors.lightInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vm.mainDishDescription,
                      style: AppTypography.caption.copyWith(
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${vm.mainDishCalories.round()} kcal',
                style: AppTypography.bodyStrong.copyWith(
                  color: isDark ? AppColors.darkInk : AppColors.lightInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Katori',
                style: AppTypography.bodyStrong.copyWith(
                  color: isDark ? AppColors.darkInk : AppColors.lightInk,
                ),
              ),
              PortionStepper(
                value: vm.mainDishKatoriCount,
                itemName: 'katori',
                onChanged: (val) => onKatoriCountChanged?.call(val),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Oil in this dish',
            style: AppTypography.bodyStrong.copyWith(
              color: isDark ? AppColors.darkInk : AppColors.lightInk,
            ),
          ),
          const SizedBox(height: 8),
          OilLevelSelector(
            selected: vm.oilRichness,
            onChanged: (val) => onOilLevelChanged?.call(val),
          ),
          const SizedBox(height: 6),
          Text(
            _getOilDescription(vm.oilRichness),
            style: AppTypography.micro.copyWith(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _getOilDescription(OilLevel level) {
    switch (level) {
      case OilLevel.light:
        return 'About 1 tsp oil per katori · light cooking';
      case OilLevel.normal:
        return 'About 2 tsp oil per katori · your usual setting';
      case OilLevel.rich:
        return 'About 4 tsp oil per katori · shadi or karahi richness';
    }
  }

  Widget _buildSideItemsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: List.generate(vm.sideItems.length, (index) {
          final item = vm.sideItems[index];
          final isLast = index == vm.sideItems.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppTypography.bodyStrong.copyWith(
                              color: isDark
                                  ? AppColors.darkInk
                                  : AppColors.lightInk,
                            ),
                          ),
                          Text(
                            '${item.portionDescription} · ${item.calories.round()} kcal',
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.hasStepper)
                      PortionStepper(
                        value: item.count,
                        itemName: item.name,
                        onChanged: (val) =>
                            onSideCountChanged?.call(item.id, val),
                      )
                    else
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                          onPressed: () => onRemoveSideItem?.call(item.id),
                        ),
                      ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(
                  color: isDark
                      ? AppColors.darkBorderStrong
                      : AppColors.lightBorderStrong,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.control),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add food'),
              onPressed: onAddFood,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(
                  color: isDark
                      ? AppColors.darkBorderStrong
                      : AppColors.lightBorderStrong,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.control),
                ),
              ),
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('Replace dish'),
              onPressed: onReplaceDish,
            ),
          ),
        ),
      ],
    );
  }
}
