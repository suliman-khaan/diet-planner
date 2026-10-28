import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/common/meal_slot.dart';
import 'package:mobile/domain/common/nutrition.dart';
import 'package:mobile/domain/food/food.dart';
import 'package:mobile/domain/plan/daily_plan.dart';
import 'package:mobile/domain/plan/food_filter.dart';
import 'package:mobile/domain/plan/planner.dart';
import 'package:mobile/domain/plan/portion_math.dart';
import 'package:mobile/domain/plan/seeded_random.dart';
import 'package:mobile/domain/profile/eligibility.dart';
import 'package:mobile/domain/profile/target_policy.dart';
import 'package:mobile/domain/profile/user_profile.dart';

import 'helpers.dart';

void main() {
  const planner = Planner();
  const policy = TargetPolicy();
  const checker = EligibilityChecker();
  final pack = loadBundledPack();

  PlanRequest requestFor(
    UserProfile p, {
    DietaryPreferences prefs = const DietaryPreferences(),
    int seed = 1,
    bool allowDraft = true,
    List<SlotTime>? slots,
  }) {
    final e = checker.check(p, testToday);
    final target = policy.compute(p.copyWith(goal: checker.effectiveGoal(p, e)), testToday).target;
    return PlanRequest(
      date: testToday,
      target: target,
      pack: pack,
      slots: slots ?? MealSchedule.defaults.normalSlots,
      filter: FoodFilter(preferences: prefs, allowDraftData: allowDraft),
      oilLevel: p.cookingRichness,
      seed: seed,
      policyVersion: policy.config.version,
    );
  }

  DailyPlan planOf(PlanResult r) {
    expect(r, isA<PlanSuccess>(), reason: r is PlanFailure ? '${r.reason} ${r.slot}' : null);
    return (r as PlanSuccess).plan;
  }

  group('determinism', () {
    test('same inputs + seed + pack version = same plan', () {
      final a = planOf(planner.generate(requestFor(profile(), seed: 99)));
      final b = planOf(planner.generate(requestFor(profile(), seed: 99)));
      expect(_fingerprint(a), _fingerprint(b));
      expect(a.packVersion, pack.packVersion);
      expect(a.seed, 99);
    });

    test('different seeds vary the meals', () {
      final plans = {
        for (var s = 0; s < 10; s++) _fingerprint(planOf(planner.generate(requestFor(profile(), seed: s)))),
      };
      expect(plans.length, greaterThan(1));
    });

    test('seeded random is stable', () {
      final r = SeededRandom(123);
      final first = [r.nextUint32(), r.nextUint32(), r.nextUint32()];
      final again = SeededRandom(123);
      expect([again.nextUint32(), again.nextUint32(), again.nextUint32()], first);
      expect(SeededRandom(0).nextDouble(), inInclusiveRange(0, 1));
      expect(SeededRandom.hashString('abc'), SeededRandom.hashString('abc'));
      expect(SeededRandom.hashString('abc'), isNot(SeededRandom.hashString('abd')));
    });
  });

  group('accuracy', () {
    test('≥ 95% of 1,000 generated profiles are within ±10% of target', () {
      final profiles = generatedProfiles(1000, seed: 2026);
      var within = 0;
      var failures = 0;
      final sw = Stopwatch()..start();
      for (var i = 0; i < profiles.length; i++) {
        final r = planner.generate(requestFor(profiles[i], seed: i));
        if (r is PlanSuccess) {
          if (r.plan.deviation.abs() <= 0.10) within++;
          expect(r.warnings.contains(PlanWarning.outsideTolerance), r.plan.deviation.abs() > 0.10);
        } else {
          failures++;
        }
      }
      sw.stop();
      expect(failures, 0);
      expect(within / profiles.length, greaterThanOrEqualTo(0.95), reason: 'within: $within / ${profiles.length}');
      // Performance budget: one-day plan ≤ 500 ms (blueprint §9). Average on CI is far below.
      expect(sw.elapsedMilliseconds / profiles.length, lessThan(500));
    });

    test('Ramadan schedule plans sehri, iftar and dinner', () {
      final plan = planOf(planner.generate(requestFor(profile(), slots: MealSchedule.defaults.ramadanSlots)));
      expect(plan.meals.map((m) => m.slot), [MealSlot.sehri, MealSlot.iftar, MealSlot.dinner]);
      expect(plan.deviation.abs(), lessThanOrEqualTo(0.10));
    });

    test('a snack slot draws from chai foods', () {
      final slots = [...MealSchedule.defaults.normalSlots, const SlotTime(MealSlot.snack, 11 * 60)];
      final plan = planOf(planner.generate(requestFor(profile(), slots: slots)));
      final snack = plan.meals.firstWhere((m) => m.slot == MealSlot.snack);
      for (final item in snack.items) {
        expect(pack.food(item.foodId)!.mealSlotFit, contains(MealSlot.chai));
      }
    });
  });

  group('restrictions', () {
    test('property: random restrictions never produce an excluded food', () {
      final rng = SeededRandom(5);
      final ingredientIds = pack.ingredients.map((i) => i.id).toList();
      var plansChecked = 0;
      for (var i = 0; i < 300; i++) {
        final prefs = DietaryPreferences(
          dietType: DietType.values[(rng.nextDouble() * DietType.values.length).floor()],
          allergies: {
            for (final a in Allergen.values)
              if (rng.nextDouble() < 0.25) a,
          },
          excludedIngredientIds: {
            for (var k = 0; k < 3; k++) ingredientIds[(rng.nextDouble() * ingredientIds.length).floor()],
          },
        );
        final filter = FoodFilter(preferences: prefs, allowDraftData: true);
        final r = planner.generate(requestFor(profile(), prefs: prefs, seed: i));
        if (r is PlanSuccess) {
          plansChecked++;
          for (final m in r.plan.meals) {
            for (final item in m.items) {
              final food = pack.food(item.foodId)!;
              expect(filter.exclusionReason(food), isNull, reason: '${food.id} with ${prefs.toJson()}');
              expect(food.allergens.intersection(prefs.allergies), isEmpty);
            }
          }
        } else {
          expect(r, isA<PlanFailure>());
        }
      }
      expect(plansChecked, greaterThan(30));
    });

    test('vegetarian plans contain no meat, fish or egg', () {
      const prefs = DietaryPreferences(dietType: DietType.vegetarian);
      final plan = planOf(planner.generate(requestFor(profile(), prefs: prefs)));
      for (final m in plan.meals) {
        for (final i in m.items) {
          final d = pack.food(i.foodId)!.dietary;
          expect(d.containsMeat || d.containsFish || d.containsEgg, isFalse, reason: i.foodId);
        }
      }
    });

    test('release builds never auto-plan draft foods', () {
      final r = planner.generate(requestFor(profile(), allowDraft: false));
      expect(r, isA<PlanFailure>());
      expect((r as PlanFailure).reason, NoPlanReason.noAllowedFoods);
    });

    test('a slot with no safe option explains why instead of forcing portions', () {
      // Excluding wheat and rice leaves no lunch or dinner combo.
      const prefs = DietaryPreferences(excludedIngredientIds: {'atta', 'maida', 'rice', 'corn-flour'});
      final r = planner.generate(requestFor(profile(), prefs: prefs));
      expect(r, isA<PlanFailure>());
      expect((r as PlanFailure).reason, NoPlanReason.noOptionsForSlot);
      expect(r.slot, isNotNull);
    });

    test('no slots gives a clear reason', () {
      final r = planner.generate(requestFor(profile(), slots: const []));
      expect((r as PlanFailure).reason, NoPlanReason.noSlots);
    });

    test('unknown allergen status is never treated as safe', () {
      final food = pack.food('roti')!;
      const withAllergy = DietaryPreferences(allergies: {Allergen.nuts});
      expect(food.allergenReview, AllergenReview.derived);
      expect(const FoodFilter(preferences: withAllergy, allowDraftData: false).exclusionReason(food),
          anyOf(ExclusionReason.notReviewed, ExclusionReason.allergenStatusUnknown));
      expect(const FoodFilter(preferences: withAllergy, allowDraftData: true).allows(food), isTrue);
      expect(const FoodFilter(preferences: DietaryPreferences(allergies: {Allergen.gluten}), allowDraftData: true)
          .exclusionReason(food), ExclusionReason.allergen);
    });

    test('excluded foods and oil ingredients are filtered', () {
      const byFood = FoodFilter(preferences: DietaryPreferences(excludedFoodIds: {'roti'}), allowDraftData: true);
      expect(byFood.exclusionReason(pack.food('roti')!), ExclusionReason.excludedFood);
      const byOil = FoodFilter(preferences: DietaryPreferences(excludedIngredientIds: {'ghee'}), allowDraftData: true);
      expect(byOil.exclusionReason(pack.food('sarson-saag')!), ExclusionReason.excludedIngredient);
      const vegan = FoodFilter(preferences: DietaryPreferences(dietType: DietType.vegan), allowDraftData: true);
      expect(vegan.exclusionReason(pack.food('dahi')!), ExclusionReason.dietType);
      const pesc = FoodFilter(preferences: DietaryPreferences(dietType: DietType.pescatarian), allowDraftData: true);
      expect(pesc.allows(pack.food('fish-curry')!), isTrue);
      expect(pesc.allows(pack.food('chicken-karahi')!), isFalse);
    });
  });

  group('nutrition maths', () {
    test('no double-counting: item = cooked food + oil at its level, nothing else', () {
      final plan = planOf(planner.generate(requestFor(profile())));
      for (final m in plan.meals) {
        for (final item in m.items) {
          final food = pack.food(item.foodId)!;
          final base = food.nutritionPer100g.forGrams(item.grams);
          final oilGrams = oilGramsFor(food, item.grams, item.oilLevel);
          final expected = oilGrams == 0 ? base : base + pack.ingredient(food.oilIngredientId!)!.per100g.forGrams(oilGrams);
          expect(item.nutrition.kcal, closeTo(expected.kcal, 1e-9));
          expect(item.oilLevel == null, !food.hasOil);
        }
      }
      expect(plan.totals.kcal, closeTo(Nutrition.sum(plan.meals.map((m) => m.nutrition)).kcal, 1e-9));
    });

    test('richer oil means more calories for the same portion', () {
      final karahi = pack.food('chicken-karahi')!;
      final light = portionNutrition(pack, karahi, 180, OilLevel.light).kcal;
      final normal = portionNutrition(pack, karahi, 180, OilLevel.normal).kcal;
      final rich = portionNutrition(pack, karahi, 180, OilLevel.rich).kcal;
      expect(light, lessThan(normal));
      expect(normal, lessThan(rich));
      expect(portionNutrition(pack, pack.food('roti')!, 55, OilLevel.rich).kcal,
          closeTo(pack.food('roti')!.nutritionPer100g.kcal * 0.55, 1e-9));
    });

    test('family pot dishes are marked as shared portions', () {
      final item = planner.itemFor(pack, pack.food('chicken-karahi')!, 1, OilLevel.normal);
      expect(item.fromSharedDish, isTrue);
      expect(item.grams, 180);
      expect(planner.itemFor(pack, pack.food('roti')!, 2, OilLevel.normal).fromSharedDish, isFalse);
    });

    test('resizing an item recomputes nutrition and keeps its id', () {
      final item = planner.itemFor(pack, pack.food('daal-masoor')!, 1, OilLevel.normal).copyWith(id: 'x');
      final bigger = planner.resizeItem(pack, item, servings: 2);
      expect(bigger.id, 'x');
      expect(bigger.grams, 360);
      expect(bigger.nutrition.kcal, closeTo(item.nutrition.kcal * 2, 1e-6));
      final lighter = planner.resizeItem(pack, item, oilLevel: OilLevel.light);
      expect(lighter.nutrition.kcal, lessThan(item.nutrition.kcal));
      expect(lighter.oilLevel, OilLevel.light);
    });
  });

  group('regenerate one meal', () {
    test('returns a different combo for the slot and leaves the rest alone', () {
      final req = requestFor(profile());
      final plan = planOf(planner.generate(req));
      final dinner = plan.meals.last;
      final slot = MealSchedule.defaults.normalSlots.last;
      final replacement = planner.regenerateMeal(req, slot, dinner.nutrition.kcal,
          attempt: 1, avoidComboIds: {dinner.comboId!})!;
      expect(replacement.comboId, isNot(dinner.comboId));
      expect(replacement.slot, dinner.slot);
      expect(replacement.nutrition.kcal, closeTo(dinner.nutrition.kcal, dinner.nutrition.kcal * 0.15));
      final again = planner.regenerateMeal(req, slot, dinner.nutrition.kcal, attempt: 1, avoidComboIds: {dinner.comboId!});
      expect(again!.comboId, replacement.comboId, reason: 'deterministic per attempt');
      final updated = plan.copyWith(meals: [...plan.meals.take(plan.meals.length - 1), replacement]);
      expect(updated.meals.first.comboId, plan.meals.first.comboId);
      expect(Planner.mainDishesIn(pack, [updated]), isNotEmpty);
    });
  });

  group('golden data: 20 reference profiles', () {
    // Plans for reference profiles must not change unless the policy or pack version changes.
    // If they change deliberately, delete the file, run the tests, and commit the new file.
    test('plans match the recorded snapshot', () {
      final file = File('test/golden_data/reference_plans.json');
      final profiles = generatedProfiles(20, seed: 314);
      final snapshot = {
        'policyVersion': policy.config.version,
        'packVersion': pack.packVersion,
        'plans': [
          for (var i = 0; i < profiles.length; i++) _fingerprint(planOf(planner.generate(requestFor(profiles[i], seed: i)))),
        ],
      };
      final encoded = const JsonEncoder.withIndent(' ').convert(snapshot);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
        file.writeAsStringSync('$encoded\n');
        fail('Recorded new golden data at ${file.path}; commit it.');
      }
      final recorded = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      if (recorded['policyVersion'] == snapshot['policyVersion'] && recorded['packVersion'] == snapshot['packVersion']) {
        expect(jsonDecode(encoded), recorded);
      }
    });
  });
}

/// Stable, readable summary of a plan for comparisons and golden files.
List<String> _fingerprint(DailyPlan p) => [
      for (final m in p.meals)
        '${m.slot.name}:${m.comboId}:${m.items.map((i) => '${i.foodId}x${i.servings}').join('+')}:${m.nutrition.kcal.round()}',
    ];
