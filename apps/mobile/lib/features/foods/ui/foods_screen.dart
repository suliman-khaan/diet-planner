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

/// Foods search & catalogue screen with Roman Urdu aliases, category filters, and state management.
class FoodsScreen extends StatefulWidget {
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
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.vm.searchQuery);
  }

  @override
  void didUpdateWidget(covariant FoodsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vm.searchQuery != oldWidget.vm.searchQuery &&
        widget.vm.searchQuery != _searchController.text) {
      _searchController.text = widget.vm.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleClear() {
    _searchController.clear();
    widget.onSearchCleared?.call();
    widget.onSearchChanged?.call('');
  }

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
            controller: _searchController,
            hintText: 'Search foods (e.g. roti, biryani, daal)',
            helperText:
                'Type in English or Roman Urdu. Spelling does not need to be exact.',
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
            onChanged: (text) => widget.onSearchChanged?.call(text),
            onClear: _handleClear,
          ),
          const SizedBox(height: 14),
          _buildCategoryChips(context),
          const SizedBox(height: 14),
          Text(
            '${widget.vm.searchResults.length} results',
            style: AppTypography.captionStrong.copyWith(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(height: 10),
          if (widget.vm.isLoading)
            _buildLoadingSkeleton()
          else if (widget.vm.searchResults.isEmpty)
            _buildEmptyState(context)
          else
            _buildResultsList(context),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: widget.onRequestMissingFood,
              child: Text(
                'Can\'t find a food? Tell us',
                style: AppTypography.captionStrong.copyWith(
                  color:
                      isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
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
        children: widget.vm.categories.map((cat) {
          final isSelected = cat == widget.vm.selectedCategory;

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
              backgroundColor:
                  isDark ? AppColors.darkSurface : AppColors.lightSurface,
              selectedColor:
                  isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.chipRadius,
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark
                          ? AppColors.darkBorderStrong
                          : AppColors.lightBorderStrong),
                ),
              ),
              onSelected: (_) => widget.onCategorySelected?.call(cat),
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
        children: List.generate(widget.vm.searchResults.length, (index) {
          final item = widget.vm.searchResults[index];
          final isLast = index == widget.vm.searchResults.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () => widget.onFoodSelected?.call(item),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          _getCategoryIcon(item.category),
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.englishName,
                              style: AppTypography.bodyStrong.copyWith(
                                color: isDark
                                    ? AppColors.darkInk
                                    : AppColors.lightInk,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.urduName} · ${item.standardServing}',
                              style: AppTypography.caption.copyWith(
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '~${item.calories.round()} kcal',
                            style: AppTypography.captionStrong.copyWith(
                              color: isDark
                                  ? AppColors.darkInk
                                  : AppColors.lightInk,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ReviewStatusBadge(isReviewed: item.isReviewed),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 82,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
            ],
          );
        }),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Breads':
        return Icons.bakery_dining_outlined;
      case 'Rice':
        return Icons.rice_bowl_outlined;
      case 'Meat & chicken':
        return Icons.kebab_dining_outlined;
      case 'Vegetables':
        return Icons.eco_outlined;
      case 'Daal & chana':
        return Icons.soup_kitchen_outlined;
      case 'Beverages':
        return Icons.local_cafe_outlined;
      case 'Snacks':
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return const EmptyStateWidget(
      title: 'No foods match your search',
      message:
          'Try searching in English or Roman Urdu (e.g. roti, daal, chawal), or browse by category above.',
      icon: Icons.search_off_rounded,
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(
        4,
        (i) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: LoadingSkeleton(width: double.infinity, height: 72),
        ),
      ),
    );
  }
}
