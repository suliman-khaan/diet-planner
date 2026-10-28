import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/common/local_date.dart';
import '../../domain/reminders/reminder_schedule.dart';
import 'providers.dart';

/// Keeps scheduled notifications in step with the meal schedule, logs and settings.
/// Called on start, on resume (catches timezone and date changes), after logging a meal,
/// and after reminder or meal-time changes.
class ReminderCoordinator {
  ReminderCoordinator(this._ref);

  final Ref _ref;
  static const _log = AppLogger('reminders');

  Future<void> reschedule() async {
    try {
      final service = _ref.read(reminderServiceProvider);
      final settings = await _ref.read(settingsRepositoryProvider).load();
      final setup = await _ref.read(profileRepositoryProvider).load();
      if (!settings.reminders.enabled || setup == null || !await service.isPermitted()) {
        await service.cancelAll();
        return;
      }
      final now = _ref.read(clockProvider).nowLocal();
      final today = LocalDate.fromDateTime(now);
      final logs = await _ref.read(foodLogRepositoryProvider).entriesFor(today);
      final occurrences = upcomingReminders(
        schedule: setup.schedule,
        prefs: settings.reminders,
        from: today,
        nowMinutes: now.hour * 60 + now.minute,
        loggedSlots: {today: {for (final l in logs) l.slot}},
      );
      await service.replaceAll(occurrences);
      final tz = _ref.read(timezoneNameProvider);
      if (settings.lastReminderTimezone != tz) {
        await _ref.read(settingsRepositoryProvider).save(settings.copyWith(lastReminderTimezone: tz));
      }
    } on Object catch (e, st) {
      // Reminders failing must never affect planning or logging.
      _log.error('reschedule_failed', e, st);
    }
  }
}

final reminderCoordinatorProvider = Provider<ReminderCoordinator>(ReminderCoordinator.new);
