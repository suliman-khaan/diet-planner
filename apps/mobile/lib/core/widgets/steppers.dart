import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Accessible +/- portion incrementer with 44x44 dp minimum touch targets.
class PortionStepper extends StatelessWidget {
  final num value;
  final num step;
  final num min;
  final num max;
  final ValueChanged<num> onChanged;
  final String itemName;

  const PortionStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.itemName,
    this.step = 1,
    this.min = 0,
    this.max = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceSecondary
            : AppColors.lightSurfaceSecondary,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.control)),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          Semantics(
            label: 'Less $itemName',
            button: true,
            child: SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Text(
                  '−',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                onPressed: value > min ? () => onChanged(value - step) : null,
              ),
            ),
          ),
          // Value readout
          Semantics(
            liveRegion: true,
            label: '$value $itemName',
            child: Container(
              constraints: const BoxConstraints(minWidth: 36),
              alignment: Alignment.center,
              child: Text(
                value.toString(),
                style: AppTypography.subheading.copyWith(
                  color: isDark ? AppColors.darkInk : AppColors.lightInk,
                ),
              ),
            ),
          ),
          // Increment button
          Semantics(
            label: 'More $itemName',
            button: true,
            child: SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Text(
                  '+',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                onPressed: value < max ? () => onChanged(value + step) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
