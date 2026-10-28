import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_widgets.dart';
import '../view_model/shopping_view_model.dart';

/// Shopping list aggregating ingredients across upcoming planned meals.
class ShoppingScreen extends StatelessWidget {
  final ShoppingViewModel vm;
  final ValueChanged<String>? onItemToggled;
  final VoidCallback? onClearCompleted;

  const ShoppingScreen({
    super.key,
    required this.vm,
    this.onItemToggled,
    this.onClearCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Shopping List',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkInk : AppColors.lightInk,
          ),
        ),
        actions: [
          if (vm.items.isNotEmpty && onClearCompleted != null)
            TextButton(
              onPressed: onClearCompleted,
              child: Text(
                'Clear checked',
                style: AppTypography.captionStrong.copyWith(
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
            ),
        ],
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (vm.items.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.shopping_basket_outlined,
        title: 'Your shopping list is clear',
        message: 'Plan meals for the week to automatically generate your ingredient shopping list.',
      );
    }

    final categories = <String, List<ShoppingItemViewModel>>{};
    for (final item in vm.items) {
      categories.putIfAbsent(item.category, () => []).add(item);
    }

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...categories.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
                  child: Text(
                    entry.key.toUpperCase(),
                    style: AppTypography.micro.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                ),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: List.generate(entry.value.length, (index) {
                      final item = entry.value[index];
                      final isLast = index == entry.value.length - 1;

                      return Column(
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: item.isPurchased,
                            activeColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                            title: Text(
                              item.name,
                              style: AppTypography.bodyStrong.copyWith(
                                decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                                color: item.isPurchased
                                    ? (isDark ? AppColors.darkMuted : AppColors.lightMuted)
                                    : (isDark ? AppColors.darkInk : AppColors.lightInk),
                              ),
                            ),
                            subtitle: Text(
                              item.amount,
                              style: AppTypography.caption.copyWith(
                                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                              ),
                            ),
                            onChanged: (_) => onItemToggled?.call(item.id),
                          ),
                          if (!isLast) const Divider(height: 1),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
}
