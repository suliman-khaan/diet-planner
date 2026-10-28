import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';

/// Modal sheet for entering a new weight record.
class AddWeightSheet extends StatefulWidget {
  final ValueChanged<double>? onWeightSaved;

  const AddWeightSheet({
    super.key,
    this.onWeightSaved,
  });

  @override
  State<AddWeightSheet> createState() => _AddWeightSheetState();
}

class _AddWeightSheetState extends State<AddWeightSheet> {
  final _weightController = TextEditingController(text: '78.4');
  String? _error;

  void _handleSave() {
    final text = _weightController.text.trim();
    final weight = double.tryParse(text);

    if (weight == null || weight < 30 || weight > 300) {
      setState(() {
        _error = 'Please enter a valid weight in kg (30–300 kg).';
      });
      return;
    }

    widget.onWeightSaved?.call(weight);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorderStrong
                        : AppColors.lightBorderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Record weight',
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
                'Weigh yourself in the morning before breakfast for the most reliable trend.',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _weightController,
                hintText: 'Weight in kg (e.g. 78.4)',
                errorText: _error,
                autofocus: false,
                prefixIcon: Icon(
                  Icons.monitor_weight_outlined,
                  color:
                      isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save weight',
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
