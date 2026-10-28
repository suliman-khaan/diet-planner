import '../common/local_date.dart';
import '../common/meal_slot.dart';
import '../common/nutrition.dart';
import '../food/food.dart';
import '../plan/daily_plan.dart';

enum LogSource { planned, manual, quickAdd }

/// What was eaten, with the nutrition frozen at the time of logging. Later catalogue
/// corrections or plan edits never change past logs.
class FoodLogEntry {
  const FoodLogEntry({
    required this.id,
    required this.date,
    required this.slot,
    required this.source,
    required this.label,
    required this.nutrition,
    required this.loggedAtUtc,
    this.planItemId,
    this.foodId,
    this.foodRevision,
    this.packVersion,
    this.grams,
    this.oilLevel,
  });

  final String id;
  final LocalDate date;
  final MealSlot slot;
  final LogSource source;
  final String label;
  final Nutrition nutrition;
  final DateTime loggedAtUtc;

  /// Set when logged from a planned item.
  final String? planItemId;
  final String? foodId;
  final int? foodRevision;
  final String? packVersion;
  final double? grams;
  final OilLevel? oilLevel;
}

/// Builds log entries for "mark as eaten" on a planned meal.
List<FoodLogEntry> logEntriesForMeal({
  required PlannedMeal meal,
  required LocalDate date,
  required FoodPack pack,
  required DateTime nowUtc,
  required String Function() newId,
}) =>
    [
      for (final item in meal.items)
        FoodLogEntry(
          id: newId(),
          date: date,
          slot: meal.slot,
          source: LogSource.planned,
          label: pack.food(item.foodId)?.nameEn ?? item.foodId,
          nutrition: item.nutrition,
          loggedAtUtc: nowUtc,
          planItemId: item.id,
          foodId: item.foodId,
          foodRevision: item.foodRevision,
          packVersion: pack.packVersion,
          grams: item.grams,
          oilLevel: item.oilLevel,
        ),
    ];

enum DayLogStatus { complete, partial, notLogged }

class DaySummary {
  const DaySummary({
    required this.date,
    required this.status,
    required this.eaten,
    required this.mealsLogged,
    required this.mealsPlanned,
  });

  final LocalDate date;
  final DayLogStatus status;

  /// Null when nothing was logged: a missed day is "not logged", never 0 kcal.
  final Nutrition? eaten;
  final int mealsLogged;
  final int mealsPlanned;
}

/// A meal counts as logged when anything was logged for its slot that day.
DaySummary summarizeDay(LocalDate date, DailyPlan? plan, List<FoodLogEntry> logs) {
  final dayLogs = logs.where((l) => l.date == date).toList();
  final loggedSlots = {for (final l in dayLogs) l.slot};
  final plannedSlots = plan == null ? <MealSlot>{} : {for (final m in plan.meals) m.slot};
  final mealsLogged = plannedSlots.isEmpty ? loggedSlots.length : plannedSlots.where(loggedSlots.contains).length;
  final DayLogStatus status;
  if (dayLogs.isEmpty) {
    status = DayLogStatus.notLogged;
  } else if (plannedSlots.isNotEmpty && mealsLogged < plannedSlots.length) {
    status = DayLogStatus.partial;
  } else {
    status = DayLogStatus.complete;
  }
  return DaySummary(
    date: date,
    status: status,
    eaten: dayLogs.isEmpty ? null : Nutrition.sum(dayLogs.map((l) => l.nutrition)),
    mealsLogged: mealsLogged,
    mealsPlanned: plannedSlots.isEmpty ? loggedSlots.length : plannedSlots.length,
  );
}

/// True when the slot already has entries from this plan item, so a second tap does not
/// log the same meal twice.
bool isPlanItemLogged(String planItemId, List<FoodLogEntry> logs) =>
    logs.any((l) => l.planItemId == planItemId);
