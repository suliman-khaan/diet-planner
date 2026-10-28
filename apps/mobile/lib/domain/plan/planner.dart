import '../common/local_date.dart';
import '../common/meal_slot.dart';
import '../food/food.dart';
import '../profile/target_policy.dart';
import '../profile/user_profile.dart';
import 'daily_plan.dart';
import 'food_filter.dart';
import 'portion_math.dart';
import 'seeded_random.dart';

enum NoPlanReason {
  /// The meal schedule has no slots.
  noSlots,

  /// Restrictions exclude every food in the pack.
  noAllowedFoods,

  /// Restrictions leave no meal option for one of the slots.
  noOptionsForSlot,
}

enum PlanWarning {
  /// Total is more than [PlannerConfig.tolerance] away from target.
  outsideTolerance,

  /// The plan uses foods not yet reviewed (dev builds only).
  usesDraftData,
}

sealed class PlanResult {
  const PlanResult();
}

class PlanSuccess extends PlanResult {
  const PlanSuccess(this.plan, this.warnings);

  final DailyPlan plan;
  final Set<PlanWarning> warnings;
}

class PlanFailure extends PlanResult {
  const PlanFailure(this.reason, {this.slot});

  final NoPlanReason reason;
  final MealSlot? slot;
}

class PlannerConfig {
  const PlannerConfig({
    this.slotShares = const {
      MealSlot.sehri: 0.35,
      MealSlot.breakfast: 0.25,
      MealSlot.lunch: 0.30,
      MealSlot.chai: 0.10,
      MealSlot.snack: 0.08,
      MealSlot.iftar: 0.25,
      MealSlot.dinner: 0.35,
    },
    this.tolerance = 0.10,
    this.recentRepeatPenalty = 0.15,
    this.sameDayRepeatPenalty = 1.0,
    this.jitter = 0.04,
    this.maxAdjustSteps = 60,
  });

  final Map<MealSlot, double> slotShares;
  final double tolerance;
  final double recentRepeatPenalty;
  final double sameDayRepeatPenalty;
  final double jitter;
  final int maxAdjustSteps;
}

class PlanRequest {
  const PlanRequest({
    required this.date,
    required this.target,
    required this.pack,
    required this.slots,
    required this.filter,
    required this.oilLevel,
    required this.seed,
    required this.policyVersion,
    this.recentFoodIds = const {},
  });

  final LocalDate date;
  final NutritionTarget target;
  final FoodPack pack;
  final List<SlotTime> slots;
  final FoodFilter filter;
  final OilLevel oilLevel;
  final int seed;
  final String policyVersion;

  /// Main dishes from the last few days, to reduce repetition.
  final Set<String> recentFoodIds;
}

/// Builds a one-day meal plan. Pure: no I/O, no clock, no randomness except [PlanRequest.seed].
/// Same request (inputs + seed + pack version) always produces the same plan.
class Planner {
  const Planner([this.config = const PlannerConfig()]);

  final PlannerConfig config;

  PlanResult generate(PlanRequest r) {
    if (r.slots.isEmpty) return const PlanFailure(NoPlanReason.noSlots);
    if (!r.pack.foods.any(r.filter.allows)) return const PlanFailure(NoPlanReason.noAllowedFoods);

    final rng = SeededRandom(r.seed ^ r.date.yyyymmdd);
    final slots = [...r.slots]..sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));
    final shares = [for (final s in slots) config.slotShares[s.slot] ?? 0.1];

    final meals = <PlannedMeal>[];
    final usedToday = <String>{};
    var plannedKcal = 0.0;
    for (var i = 0; i < slots.length; i++) {
      // Spread whatever is left of the target over the remaining slots, so rounding in
      // earlier meals is corrected by later ones.
      final remainingShare = shares.sublist(i).fold<double>(0, (a, b) => a + b);
      final slotKcal = (r.target.kcal - plannedKcal) * shares[i] / remainingShare;
      final meal = _bestMeal(r, slots[i], slotKcal, rng, usedToday, const {});
      if (meal == null) return PlanFailure(NoPlanReason.noOptionsForSlot, slot: slots[i].slot);
      meals.add(meal);
      plannedKcal += meal.nutrition.kcal;
      usedToday.addAll(_mainFoodIds(r.pack, meal));
    }

    final plan = DailyPlan(
      date: r.date,
      meals: meals,
      targetKcal: r.target.kcal,
      policyVersion: r.policyVersion,
      packVersion: r.pack.packVersion,
      seed: r.seed,
      usesDraftData: meals.any((m) => m.items.any((i) => !r.pack.food(i.foodId)!.status.isVerified)),
    );
    return PlanSuccess(plan, _warnings(plan));
  }

  /// A new option for one meal. Other meals are untouched; the caller must not regenerate
  /// meals that are already eaten. Avoids [avoidComboIds] when any alternative exists.
  PlannedMeal? regenerateMeal(
    PlanRequest r,
    SlotTime slot,
    double slotKcal, {
    required int attempt,
    Set<String> avoidComboIds = const {},
    Set<String> otherMainFoodIds = const {},
  }) {
    final rng = SeededRandom(r.seed ^ r.date.yyyymmdd ^ SeededRandom.hashString('${slot.slot.name}#$attempt'));
    return _bestMeal(r, slot, slotKcal, rng, otherMainFoodIds, avoidComboIds);
  }

  /// Recomputes a plan item's nutrition after the user changes servings or oil level.
  PlanItem resizeItem(FoodPack pack, PlanItem item, {double? servings, OilLevel? oilLevel}) {
    final food = pack.food(item.foodId)!;
    final s = servings ?? item.servings;
    final grams = s * food.servingById(item.servingId).grams;
    final oil = food.hasOil ? (oilLevel ?? item.oilLevel ?? OilLevel.normal) : null;
    return PlanItem(
      id: item.id,
      foodId: item.foodId,
      foodRevision: food.revision,
      servingId: item.servingId,
      servings: s,
      grams: grams,
      oilLevel: oil,
      fromSharedDish: item.fromSharedDish,
      nutrition: portionNutrition(pack, food, grams, oil),
    );
  }

  /// A plan item for [food] at [servings] of its default serving.
  PlanItem itemFor(FoodPack pack, Food food, double servings, OilLevel oilLevel) {
    final serving = food.defaultServing;
    final grams = servings * serving.grams;
    final oil = oilLevelFor(food, oilLevel);
    return PlanItem(
      foodId: food.id,
      foodRevision: food.revision,
      servingId: serving.id,
      servings: servings,
      grams: grams,
      oilLevel: oil,
      fromSharedDish: food.isSharedDish,
      nutrition: portionNutrition(pack, food, grams, oil),
    );
  }

  Set<PlanWarning> _warnings(DailyPlan plan) => {
        if (plan.deviation.abs() > config.tolerance) PlanWarning.outsideTolerance,
        if (plan.usesDraftData) PlanWarning.usesDraftData,
      };

  PlannedMeal? _bestMeal(
    PlanRequest r,
    SlotTime slot,
    double slotKcal,
    SeededRandom rng,
    Set<String> usedToday,
    Set<String> avoidComboIds,
  ) {
    var candidates = r.pack.combos
        .where((c) => c.slots.contains(slot.slot.foodSlot))
        .where((c) => c.items.every((i) {
              final food = r.pack.food(i.foodId);
              return food != null && r.filter.allows(food);
            }))
        .toList();
    if (candidates.isEmpty) return null;
    final withoutAvoided = candidates.where((c) => !avoidComboIds.contains(c.id)).toList();
    if (withoutAvoided.isNotEmpty) candidates = withoutAvoided;

    PlannedMeal? best;
    var bestScore = double.infinity;
    for (final combo in candidates) {
      final items = _fit(r, combo, slotKcal);
      final meal = PlannedMeal(slot: slot.slot, minutesOfDay: slot.minutesOfDay, comboId: combo.id, items: items);
      final mains = _mainFoodIds(r.pack, meal);
      var score = slotKcal <= 0 ? 0.0 : (meal.nutrition.kcal - slotKcal).abs() / slotKcal;
      if (mains.any(usedToday.contains)) score += config.sameDayRepeatPenalty;
      if (mains.any(r.recentFoodIds.contains)) score += config.recentRepeatPenalty;
      // Jitter is drawn for every candidate in a fixed order, so results stay deterministic.
      score += rng.nextDouble() * config.jitter;
      if (score < bestScore) {
        bestScore = score;
        best = meal;
      }
    }
    return best;
  }

  /// Adjusts servings within each food's portion rule, one step at a time, choosing the
  /// step that brings the meal closest to [targetKcal]. Stops when no step helps.
  List<PlanItem> _fit(PlanRequest r, Combo combo, double targetKcal) {
    final foods = [for (final i in combo.items) r.pack.food(i.foodId)!];
    final servings = [for (var i = 0; i < foods.length; i++) foods[i].portion.clampAndSnap(combo.items[i].servings)];
    double kcalOf(int i, double s) =>
        portionNutrition(r.pack, foods[i], s * foods[i].defaultServing.grams, oilLevelFor(foods[i], r.oilLevel)).kcal;

    var total = 0.0;
    for (var i = 0; i < foods.length; i++) {
      total += kcalOf(i, servings[i]);
    }
    for (var step = 0; step < config.maxAdjustSteps; step++) {
      var bestGap = (total - targetKcal).abs();
      int? bestIndex;
      var bestServings = 0.0;
      var bestTotal = total;
      for (var i = 0; i < foods.length; i++) {
        final rule = foods[i].portion;
        for (final delta in [rule.step, -rule.step]) {
          final next = servings[i] + delta;
          if (next < rule.min - 1e-9 || next > rule.max + 1e-9) continue;
          final newTotal = total - kcalOf(i, servings[i]) + kcalOf(i, next);
          final gap = (newTotal - targetKcal).abs();
          if (gap < bestGap - 1e-9) {
            bestGap = gap;
            bestIndex = i;
            bestServings = next;
            bestTotal = newTotal;
          }
        }
      }
      if (bestIndex == null) break;
      servings[bestIndex] = bestServings;
      total = bestTotal;
    }
    return [for (var i = 0; i < foods.length; i++) itemFor(r.pack, foods[i], servings[i], r.oilLevel)];
  }

  static Set<String> _mainFoodIds(FoodPack pack, PlannedMeal meal) => {
        for (final i in meal.items)
          if (pack.food(i.foodId)?.role == 'main') i.foodId,
      };

  /// Main dishes in [plans], for [PlanRequest.recentFoodIds].
  static Set<String> mainDishesIn(FoodPack pack, Iterable<DailyPlan> plans) => {
        for (final p in plans)
          for (final m in p.meals) ..._mainFoodIds(pack, m),
      };
}
