import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';

/// Quick Add sheet for direct manual calorie and macro logging.
class QuickAddSheet extends StatefulWidget {
  final void Function(String label, num calories, String slot)? onQuickAddSubmitted;

  const QuickAddSheet({
    super.key,
    this.onQuickAddSubmitted,
  });

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _caloriesController = TextEditingController();
  final _labelController = TextEditingController();
  String _selectedSlot = 'Dinner';
  String? _error;

  final List<String> _slots = ['Breakfast', 'Lunch', 'Chai', 'Dinner', 'Snack'];

  void _handleSubmit() {
    final text = _caloriesController.text.trim();
    final kcal = num.tryParse(text);

    if (kcal == null || kcal <= 0 || kcal > 4000) {
      setState(() {
        _error = 'Please enter a valid calorie amount (1–4000 kcal).';
      });
      return;
    }

    final label = _labelController.text.trim().isEmpty ? 'Quick add' : _labelController.text.trim();
    widget.onQuickAddSubmitted?.call(label, kcal, _selectedSlot);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _labelController.dispose();
    super.dispose();
  }

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
                  'Quick add calories',
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
            const SizedBox(height: 6),
            Text(
              'Log food eaten outside or custom dishes without searching the catalogue.',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _caloriesController,
              hintText: 'Calories (kcal) *',
              errorText: _error,
              autofocus: true,
              prefixIcon: Icon(
                Icons.local_fire_department_outlined,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _labelController,
              hintText: 'What did you eat? (optional)',
              helperText: 'e.g. Wedding biryani, Chai at dhabba',
              prefixIcon: Icon(
                Icons.edit_note,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Meal Slot',
              style: AppTypography.captionStrong.copyWith(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _slots.map((slot) {
                final isSelected = slot == _selectedSlot;
                final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  selectedColor: isDark ? AppColors.darkPrimarySoft : AppColors.lightPrimarySoft,
                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  labelStyle: AppTypography.captionStrong.copyWith(
                    color: isSelected
                        ? primary
                        : (isDark ? AppColors.darkInk : AppColors.lightInk),
                  ),
                  onSelected: (_) => setState(() => _selectedSlot = slot),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Add to today',
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
