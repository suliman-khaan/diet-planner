import '../common/local_date.dart';
import '../common/meal_slot.dart';
import '../profile/user_profile.dart';

class ReminderPreferences {
  const ReminderPreferences({
    this.enabled = false,
    this.enabledSlots = const {},
    this.quietStartMinutes = 23 * 60,
    this.quietEndMinutes = 7 * 60,
  });

  final bool enabled;
  final Set<MealSlot> enabledSlots;

  /// Quiet hours, possibly crossing midnight (23:00 → 07:00).
  final int quietStartMinutes;
  final int quietEndMinutes;

  bool isQuiet(int minutesOfDay) {
    if (quietStartMinutes == quietEndMinutes) return false;
    if (quietStartMinutes < quietEndMinutes) {
      return minutesOfDay >= quietStartMinutes &&
          minutesOfDay < quietEndMinutes;
    }
    return minutesOfDay >= quietStartMinutes || minutesOfDay < quietEndMinutes;
  }

  ReminderPreferences copyWith({
    bool? enabled,
    Set<MealSlot>? enabledSlots,
    int? quietStartMinutes,
    int? quietEndMinutes,
  }) =>
      ReminderPreferences(
        enabled: enabled ?? this.enabled,
        enabledSlots: enabledSlots ?? this.enabledSlots,
        quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
        quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
      );

  Map<String, Object?> toJson() => {
        'enabled': enabled,
        'slots': enabledSlots.map((s) => s.name).toList()..sort(),
        'quietStart': quietStartMinutes,
        'quietEnd': quietEndMinutes,
      };

  factory ReminderPreferences.fromJson(Map<String, Object?> json) =>
      ReminderPreferences(
        enabled: json['enabled'] == true,
        enabledSlots: ((json['slots'] as List<Object?>?) ?? const [])
            .map((s) => MealSlot.fromName(s! as String))
            .toSet(),
        quietStartMinutes: (json['quietStart'] as int?) ?? 23 * 60,
        quietEndMinutes: (json['quietEnd'] as int?) ?? 7 * 60,
      );
}

class ReminderOccurrence {
  const ReminderOccurrence(
      {required this.id,
      required this.date,
      required this.slot,
      required this.minutesOfDay});

  /// Stable per date and slot, so rescheduling replaces instead of duplicating.
  final int id;
  final LocalDate date;
  final MealSlot slot;
  final int minutesOfDay;
}

/// Reminder id for a date and slot: yyyymmdd × 10 + slot index. Fits in a 32-bit int.
int reminderIdFor(LocalDate date, MealSlot slot) =>
    date.yyyymmdd * 10 + slot.index;

/// Upcoming reminders for [days] days starting at [from]. Pure; the platform service turns
/// these into notifications.
///
/// - Uses the Ramadan schedule on Ramadan dates, so reminders switch automatically.
/// - Skips slots already logged ([loggedSlots] per date) and times already past [nowMinutes] today.
/// - Quiet hours skip reminders, except sehri, which the user enables deliberately.
List<ReminderOccurrence> upcomingReminders({
  required MealSchedule schedule,
  required ReminderPreferences prefs,
  required LocalDate from,
  required int nowMinutes,
  int days = 7,
  Map<LocalDate, Set<MealSlot>> loggedSlots = const {},
}) {
  if (!prefs.enabled) return const [];
  final result = <ReminderOccurrence>[];
  for (var d = 0; d < days; d++) {
    final date = from.addDays(d);
    final logged = loggedSlots[date] ?? const {};
    for (final s in schedule.slotsFor(date)) {
      if (!prefs.enabledSlots.contains(s.slot)) continue;
      if (logged.contains(s.slot)) continue;
      if (d == 0 && s.minutesOfDay <= nowMinutes) continue;
      if (s.slot != MealSlot.sehri && prefs.isQuiet(s.minutesOfDay)) continue;
      result.add(ReminderOccurrence(
        id: reminderIdFor(date, s.slot),
        date: date,
        slot: s.slot,
        minutesOfDay: s.minutesOfDay,
      ));
    }
  }
  return result;
}
