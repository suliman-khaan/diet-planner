import '../common/local_date.dart';
import '../common/meal_slot.dart';
import '../common/nutrition.dart';

/// One food in a planned meal. [id] is empty until the plan is stored.
class PlanItem {
  const PlanItem({
    this.id = '',
    required this.foodId,
    required this.foodRevision,
    required this.servingId,
    required this.servings,
    required this.grams,
    required this.oilLevel,
    required this.fromSharedDish,
    required this.nutrition,
  });

  final String id;
  final String foodId;
  final int foodRevision;
  final String servingId;
  final double servings;
  final double grams;

  /// Null for foods cooked without added oil.
  final OilLevel? oilLevel;

  /// The user's portion from a dish cooked for the whole family.
  final bool fromSharedDish;

  /// Includes added oil at [oilLevel].
  final Nutrition nutrition;

  PlanItem copyWith({String? id}) => PlanItem(
        id: id ?? this.id,
        foodId: foodId,
        foodRevision: foodRevision,
        servingId: servingId,
        servings: servings,
        grams: grams,
        oilLevel: oilLevel,
        fromSharedDish: fromSharedDish,
        nutrition: nutrition,
      );
}

class PlannedMeal {
  const PlannedMeal({
    this.id = '',
    required this.slot,
    required this.minutesOfDay,
    required this.comboId,
    required this.items,
  });

  final String id;
  final MealSlot slot;
  final int minutesOfDay;

  /// Null when the user assembled the meal by hand.
  final String? comboId;
  final List<PlanItem> items;

  Nutrition get nutrition => Nutrition.sum(items.map((i) => i.nutrition));

  PlannedMeal copyWith({String? id, List<PlanItem>? items, String? comboId}) =>
      PlannedMeal(
        id: id ?? this.id,
        slot: slot,
        minutesOfDay: minutesOfDay,
        comboId: comboId ?? this.comboId,
        items: items ?? this.items,
      );
}

class DailyPlan {
  const DailyPlan({
    this.id = '',
    required this.date,
    required this.meals,
    required this.targetKcal,
    required this.policyVersion,
    required this.packVersion,
    required this.seed,
    required this.usesDraftData,
  });

  final String id;
  final LocalDate date;
  final List<PlannedMeal> meals;
  final double targetKcal;
  final String policyVersion;
  final String packVersion;
  final int seed;

  /// True when any food in the plan is not yet reviewed (dev builds only).
  final bool usesDraftData;

  Nutrition get totals => Nutrition.sum(meals.map((m) => m.nutrition));

  /// Fractional deviation from target, e.g. 0.04 = 4 % over.
  double get deviation =>
      targetKcal == 0 ? 0 : (totals.kcal - targetKcal) / targetKcal;

  DailyPlan copyWith({String? id, List<PlannedMeal>? meals}) => DailyPlan(
        id: id ?? this.id,
        date: date,
        meals: meals ?? this.meals,
        targetKcal: targetKcal,
        policyVersion: policyVersion,
        packVersion: packVersion,
        seed: seed,
        usesDraftData: usesDraftData,
      );
}
