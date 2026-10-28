import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class ReminderSlotItem {
  final String id;
  final String slotName;
  final String time;
  final bool isEnabled;

  const ReminderSlotItem({
    required this.id,
    required this.slotName,
    required this.time,
    required this.isEnabled,
  });
}

class RemindersViewModel {
  final bool enabled;

  /// The OS refused notification permission; reminders cannot be shown.
  final bool permissionDenied;
  final List<ReminderSlotItem> slots;

  /// e.g. "Ramadan dates: 18 Feb – 19 Mar. Sehri and iftar reminders switch on automatically."
  final String ramadanNote;
  final String quietHours;

  const RemindersViewModel({
    this.enabled = false,
    this.permissionDenied = false,
    this.slots = const [],
    this.ramadanNote = '',
    this.quietHours = '',
  });
}

/// Reminder settings. Notifications contain timing only, never health details.
class RemindersScreen extends StatelessWidget {
  final RemindersViewModel vm;
  final ValueChanged<bool>? onEnabledChanged;
  final void Function(String slotId, bool enabled)? onSlotChanged;
  final VoidCallback? onOpenMealTimes;

  const RemindersScreen({
    super.key,
    this.vm = const RemindersViewModel(),
    this.onEnabledChanged,
    this.onSlotChanged,
    this.onOpenMealTimes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Meal Reminders',
          style: AppTypography.titleMedium.copyWith(color: ink),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gentle meal logging nudges. Notifications contain timing alerts only—never personal health data.',
              style: AppTypography.caption.copyWith(color: muted),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: primary,
                title: Text('Meal reminders',
                    style: AppTypography.bodyStrong.copyWith(color: ink)),
                subtitle: Text(
                  vm.permissionDenied
                      ? 'Notifications are turned off for this app in Android settings. Turn them on there to get reminders.'
                      : 'A reminder at each meal time you choose below.',
                  style: AppTypography.caption.copyWith(color: muted),
                ),
                value: vm.enabled,
                onChanged: onEnabledChanged,
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
                        Text('Ramadan timings',
                            style:
                                AppTypography.bodyStrong.copyWith(color: ink)),
                        Text(vm.ramadanNote,
                            style: AppTypography.caption.copyWith(color: muted)),
                      ],
                    ),
                  ),
                  if (onOpenMealTimes != null)
                    TextButton(
                        onPressed: onOpenMealTimes, child: const Text('Edit')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'MEAL SLOTS',
              style: AppTypography.micro.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: muted,
              ),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: List.generate(vm.slots.length, (index) {
                  final slot = vm.slots[index];
                  final isLast = index == vm.slots.length - 1;
                  return Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: primary,
                        title: Text(slot.slotName,
                            style:
                                AppTypography.bodyStrong.copyWith(color: ink)),
                        subtitle: Text(slot.time,
                            style: AppTypography.caption.copyWith(color: muted)),
                        value: slot.isEnabled,
                        onChanged: vm.enabled
                            ? (val) => onSlotChanged?.call(slot.id, val)
                            : null,
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
                  Icon(Icons.schedule, size: 18, color: muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${vm.quietHours} Android battery saving may delay a reminder by a few minutes.',
                      style: AppTypography.caption.copyWith(color: muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
