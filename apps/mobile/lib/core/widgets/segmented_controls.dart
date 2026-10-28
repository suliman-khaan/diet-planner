import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

enum OilLevel { light, normal, rich }

/// Oil level 3-segment control: Light (1 tsp), Normal (2 tsp), Rich (4 tsp).
class OilLevelSelector extends StatelessWidget {
  final OilLevel selected;
  final ValueChanged<OilLevel> onChanged;

  const OilLevelSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.control)),
      ),
      child: Row(
        children: OilLevel.values.map((level) {
          final isCurrent = level == selected;
          final title = switch (level) {
            OilLevel.light => 'Light',
            OilLevel.normal => 'Normal',
            OilLevel.rich => 'Rich',
          };

          return Expanded(
            child: Semantics(
              checked: isCurrent,
              button: true,
              label: '$title oil level',
              child: GestureDetector(
                onTap: () => onChanged(level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isCurrent
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
                    title,
                    style: AppTypography.captionStrong.copyWith(
                      color: isCurrent
                          ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                          : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
