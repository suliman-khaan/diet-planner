import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/logging/app_logger.dart';
import '../../domain/common/meal_slot.dart';
import '../../domain/reminders/reminder_schedule.dart';
import 'reminder_service.dart';

/// Android local notifications. No exact-alarm permission: reminders use inexact scheduling,
/// so the OS may deliver them a few minutes late (explained on the reminders screen).
/// The plugin's boot receiver restores scheduled reminders after a reboot or app update.
class FlutterReminderService implements ReminderService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const _log = AppLogger('reminders');

  @override
  Future<void> initialize({required String timezoneName, required void Function(String route) onTap}) async {
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } on Object {
      tz.setLocalLocation(tz.UTC);
    }
    await _plugin.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.startsWith('/')) onTap(route);
      },
    );
  }

  @override
  Future<String?> launchRoute() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    final route = details.notificationResponse?.payload;
    return route != null && route.startsWith('/') ? route : null;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> isPermitted() async => await _android?.areNotificationsEnabled() ?? false;

  @override
  Future<bool> requestPermission() async => await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<void> replaceAll(List<ReminderOccurrence> occurrences) async {
    await _plugin.cancelAll();
    for (final o in occurrences) {
      final at = tz.TZDateTime(tz.local, o.date.year, o.date.month, o.date.day, o.minutesOfDay ~/ 60, o.minutesOfDay % 60);
      if (at.isBefore(tz.TZDateTime.now(tz.local))) continue;
      await _plugin.zonedSchedule(
        o.id,
        _title(o.slot),
        // Never health details in notification text.
        'Tap to see your plan.',
        at,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_${o.slot.name}',
            '${_slotName(o.slot)} reminders',
            channelDescription: 'Reminders for ${_slotName(o.slot).toLowerCase()}',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: '/today?date=${o.date.toIso()}',
      );
    }
    _log.info('reminders_scheduled', {'count': occurrences.length});
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  static String _title(MealSlot s) => switch (s) {
        MealSlot.sehri => 'Time for sehri',
        MealSlot.iftar => 'Iftar time',
        MealSlot.chai => 'Chai time',
        _ => 'Time for ${_slotName(s).toLowerCase()}',
      };

  static String _slotName(MealSlot s) => switch (s) {
        MealSlot.sehri => 'Sehri',
        MealSlot.breakfast => 'Breakfast',
        MealSlot.lunch => 'Lunch',
        MealSlot.chai => 'Chai',
        MealSlot.snack => 'Snack',
        MealSlot.iftar => 'Iftar',
        MealSlot.dinner => 'Dinner',
      };
}
