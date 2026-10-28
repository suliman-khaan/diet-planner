import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Standard app text and search field with clear button and accessibility support.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppRadii.row),
            border: Border.all(
              color: errorText != null
                  ? Colors.red.shade400
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: autofocus,
                  onChanged: onChanged,
                  style: AppTypography.body.copyWith(
                    color: isDark ? AppColors.darkInk : AppColors.lightInk,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: hintText,
                    hintStyle: AppTypography.body.copyWith(
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                ),
              ),
              if (onClear != null && (controller?.text.isNotEmpty ?? false))
                Semantics(
                  label: 'Clear text',
                  button: true,
                  child: IconButton(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.clear,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                    onPressed: onClear,
                  ),
                ),
            ],
          ),
        ),
        if (helperText != null || errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              errorText ?? helperText!,
              style: AppTypography.micro.copyWith(
                color: errorText != null
                    ? Colors.red.shade400
                    : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
