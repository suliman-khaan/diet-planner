import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/state_widgets.dart';
import '../view_model/foods_view_model.dart';

/// Foods search & catalogue screen with Roman Urdu aliases and filters.
class FoodsScreen extends StatelessWidget {
  final FoodsViewModel vm;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchCleared;
  final ValueChanged<String>? onCategorySelected;
  final ValueChanged<FoodItemViewModel>? onFoodSelected;
  final VoidCallback? onRequestMissingFood;

  const FoodsScreen({
    super.key,
    required this.vm,
    this.onSearchChanged,
    this.onSearchCleared,
    this.onCategorySelected,
    this.onFoodSelected,
    this.onRequestMissingFood,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foods',
            style: AppTypography.titleLarge.copyWith(
              color: isDark ? AppColors.darkInk : AppColors.lightInk,
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            hintText: 'Search foods (e.g. chana chat, daal)',
            helperText: 'Type in English or Roman Urdu. Spelling does not need to be exact.',
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
            onChanged: onSearchChanged,
            onClear: onSearchCleared,
          ),
          const SizedBox(height: 14),
          _buildCategoryChips(context),
          const SizedBox(height: 14),
          Text(
            '${vm.searchResults.length} results',
            style: AppTypography.captionStrong.copyWith(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(height: 10),
          if (vm.isLoading)
            _buildLoadingSkeleton()
          else if (vm.searchResults.isEmpty)
            _buildEmptyState(context)
          else
            _buildResultsList(context),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: onRequestMissingFood,
              child: Text(
                'Can\'t find a food? Tell us',
                style: AppTypography.captionStrong.copyWith(
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: vm.categories.map((cat) {
          final isSelected = cat == vm.selectedCategory;
          final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              showCheckmark: false,
              labelStyle: AppTypography.captionStrong.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkInk : AppColors.lightInk),
              ),
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              selectedColor: isDark ? AppColors.darkInk : AppColors.lightInk,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.chipRadius,
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? AppColors.darkBorderStrong : AppColors.lightBorderStrong),
                ),
              ),
              onSelected: (_) => onCategorySelected?.call(cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(vm.searchResults.length, (index) {
          final item = vm.searchResults[index];
          final isLast = index == vm.searchResults.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () => onFoodSelected?.call(item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceSecondary
                              : AppColors.lightSurfaceSecondary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.englishName,
                              style: AppTypography.bodyStrong.copyWith(
                                color: isDark ? AppColors.darkInk : AppColors.lightInk,
                              ),
                            ),
                            Text(
                              item.urduName,
                              style: AppTypography.urduSubtitle.copyWith(
                                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${item.standardServing} · ',
                                  style: AppTypography.micro.copyWith(
                                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                                  ),
                                ),
                                ReviewStatusBadge(isReviewed: item.isReviewed),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.calories.round().toString(),
                            style: AppTypography.bodyStrong.copyWith(
                              color: isDark ? AppColors.darkInk : AppColors.lightInk,
                            ),
                          ),
                          Text(
                            'kcal',
                            style: AppTypography.micro.copyWith(
                              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 80,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No foods found',
      message: 'Try searching by Roman Urdu (e.g. "chana chaat", "roti", "salan").',
      actionLabel: 'Suggest missing food',
      onAction: onRequestMissingFood,
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(
        4,
        (i) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: LoadingSkeleton(width: double.infinity, height: 72),
        ),
      ),
    );
  }
}
