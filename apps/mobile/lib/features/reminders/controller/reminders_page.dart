import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers/formatters.dart';
import '../../../app/providers/providers.dart';
import '../../../app/providers/reminder_coordinator.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../domain/common/meal_slot.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../settings/controller/meal_schedule_sheet.dart';
import '../ui/reminders_screen.dart';

class RemindersController extends AsyncNotifier<RemindersViewModel> {
  bool _permissionDenied = false;

  @override
  Future<RemindersViewModel> build() async {
    final settings = await ref.watch(appSettingsProvider.future);
    final setup = await ref.watch(userSetupProvider.future);
    final schedule = setup?.schedule;
    final prefs = settings.reminders;
    final times = <MealSlot, int>{
      for (final s in [...?schedule?.normalSlots, ...?schedule?.ramadanSlots])
        s.slot: s.minutesOfDay,
    };
    final slots = times.keys.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final fmt = DateFormat('d MMM');
    final ramadan = schedule?.ramadanStart != null &&
            schedule?.ramadanEnd != null
        ? 'Ramadan dates: ${fmt.format(schedule!.ramadanStart!.atMinutes(0))} – ${fmt.format(schedule.ramadanEnd!.atMinutes(0))}. '
            'Sehri and iftar reminders replace breakfast and lunch on those days.'
        : 'Set your Ramadan dates in Meal times and reminders switch to sehri and iftar automatically.';
    return RemindersViewModel(
      enabled: prefs.enabled,
      permissionDenied: _permissionDenied,
      ramadanNote: ramadan,
      quietHours:
          'Quiet hours ${Fmt.time(prefs.quietStartMinutes)}–${Fmt.time(prefs.quietEndMinutes)}: '
          'no reminders except sehri.',
      slots: [
        for (final s in slots)
          ReminderSlotItem(
            id: s.name,
            slotName: Fmt.slot(s),
            time: Fmt.time(times[s]!),
            isEnabled: prefs.enabledSlots.contains(s),
          ),
      ],
    );
  }

  Future<void> setEnabled(bool enabled) async {
    final repo = ref.read(settingsRepositoryProvider);
    final settings = await repo.load();
    var prefs = settings.reminders.copyWith(enabled: enabled);
    if (enabled) {
      // Ask the OS only when the user turns reminders on.
      final granted =
          await ref.read(reminderServiceProvider).requestPermission();
      _permissionDenied = !granted;
      if (!granted) prefs = prefs.copyWith(enabled: false);
      if (granted && prefs.enabledSlots.isEmpty) {
        final setup = await ref.read(profileRepositoryProvider).load();
        prefs = prefs.copyWith(enabledSlots: {
          for (final s in [
            ...?setup?.schedule.normalSlots,
            ...?setup?.schedule.ramadanSlots
          ])
            s.slot,
        });
      }
    }
    await repo.save(settings.copyWith(reminders: prefs));
    if (prefs.enabled) {
      for (final s in prefs.enabledSlots) {
        ref
            .read(analyticsServiceProvider)
            .log(AnalyticsEvent.reminderEnabled, {'slot': s});
      }
    }
    await _apply();
  }

  Future<void> setSlot(String slotId, bool enabled) async {
    final repo = ref.read(settingsRepositoryProvider);
    final settings = await repo.load();
    final slot = MealSlot.fromName(slotId);
    final slots = {...settings.reminders.enabledSlots};
    enabled ? slots.add(slot) : slots.remove(slot);
    await repo.save(settings.copyWith(
        reminders: settings.reminders.copyWith(enabledSlots: slots)));
    if (enabled)
      ref
          .read(analyticsServiceProvider)
          .log(AnalyticsEvent.reminderEnabled, {'slot': slot});
    await _apply();
  }

  Future<void> _apply() async {
    ref.invalidate(appSettingsProvider);
    await ref.read(reminderCoordinatorProvider).reschedule();
  }
}

final remindersControllerProvider =
    AsyncNotifierProvider<RemindersController, RemindersViewModel>(
        RemindersController.new);

class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(remindersControllerProvider);
    final controller = ref.read(remindersControllerProvider.notifier);
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Meal Reminders')),
        body: ErrorStateWidget(
          message: 'Reminder settings could not be loaded.',
          onRetry: () => ref.invalidate(remindersControllerProvider),
        ),
      ),
      data: (vm) => RemindersScreen(
        vm: vm,
        onEnabledChanged: controller.setEnabled,
        onSlotChanged: controller.setSlot,
        onOpenMealTimes: () => MealScheduleSheet.show(context),
      ),
    );
  }
}
