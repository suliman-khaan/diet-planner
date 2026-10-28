import '../../domain/reminders/reminder_schedule.dart';

/// Local meal reminders. The platform implementation lives in
/// flutter_reminder_service.dart; everything else depends on this interface.
abstract interface class ReminderService {
  /// [onTap] receives the payload (an in-app route) when a reminder is tapped.
  Future<void> initialize({required String timezoneName, required void Function(String route) onTap});

  /// Route from the reminder that cold-started the app, if any.
  Future<String?> launchRoute();

  Future<bool> isPermitted();

  /// Asks the OS. Called only when the user turns reminders on.
  Future<bool> requestPermission();

  /// Replaces every scheduled reminder with [occurrences]. Safe to call repeatedly:
  /// ids are stable per date and slot, so nothing is duplicated.
  Future<void> replaceAll(List<ReminderOccurrence> occurrences);

  Future<void> cancelAll();
}

/// Used in tests and before the platform service is ready.
class NoopReminderService implements ReminderService {
  final List<ReminderOccurrence> scheduled = [];
  bool permitted = true;

  @override
  Future<void> initialize({required String timezoneName, required void Function(String route) onTap}) async {}

  @override
  Future<String?> launchRoute() async => null;

  @override
  Future<bool> isPermitted() async => permitted;

  @override
  Future<bool> requestPermission() async => permitted;

  @override
  Future<void> replaceAll(List<ReminderOccurrence> occurrences) async {
    scheduled
      ..clear()
      ..addAll(occurrences);
  }

  @override
  Future<void> cancelAll() async => scheduled.clear();
}
