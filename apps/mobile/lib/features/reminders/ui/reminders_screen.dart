import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class ReminderSlotItem {
  final String slotName;
  final String time;
  final bool isEnabled;

  const ReminderSlotItem({
    required this.slotName,
    required this.time,
    required this.isEnabled,
  });
}

/// Reminders configuration screen with Ramadan automatic timing shifts.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _ramadanAutoShift = true;
  final List<ReminderSlotItem> _slots = [
    const ReminderSlotItem(slotName: 'Breakfast', time: '8:00 am', isEnabled: true),
    const ReminderSlotItem(slotName: 'Lunch', time: '1:30 pm', isEnabled: true),
    const ReminderSlotItem(slotName: 'Evening Chai', time: '5:30 pm', isEnabled: true),
    const ReminderSlotItem(slotName: 'Dinner', time: '9:00 pm', isEnabled: true),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminders',
            style: AppTypography.titleLarge.copyWith(
              color: isDark ? AppColors.darkInk : AppColors.lightInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Gentle meal logging nudges. Notifications contain timing alerts only—never personal health data.',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.nightlight_round, color: primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Follow Ramadan timings',
                        style: AppTypography.bodyStrong.copyWith(
                          color: isDark ? AppColors.darkInk : AppColors.lightInk,
                        ),
                      ),
                      Text(
                        'Switches automatically to Sehri and Iftar alert times during Ramadan.',
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _ramadanAutoShift,
                  activeColor: primary,
                  onChanged: (val) => setState(() => _ramadanAutoShift = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'MEAL SLOTS',
            style: AppTypography.micro.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: List.generate(_slots.length, (index) {
                final slot = _slots[index];
                final isLast = index == _slots.length - 1;

                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        slot.slotName,
                        style: AppTypography.bodyStrong.copyWith(
                          color: isDark ? AppColors.darkInk : AppColors.lightInk,
                        ),
                      ),
                      subtitle: Text(
                        slot.time,
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                      ),
                      trailing: Switch(
                        value: slot.isEnabled,
                        activeColor: primary,
                        onChanged: (_) {},
                      ),
                    ),
                    if (!isLast) const Divider(height: 1),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Android battery optimization may occasionally delay notifications by a few minutes depending on OS sleep state.',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
