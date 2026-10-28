import '../common/meal_slot.dart';
import '../common/nutrition.dart';
import '../food/food.dart';

/// Nutrition of a portion of [food], including cooking oil at [oilLevel].
///
/// Food nutrition excludes added oil; oil is added once here from the food's oil profile.
/// Recipe ingredients are never added on top of the cooked food (no double-counting).
Nutrition portionNutrition(FoodPack pack, Food food, double grams, OilLevel? oilLevel) {
  final base = food.nutritionPer100g.forGrams(grams);
  final oilGrams = oilGramsFor(food, grams, oilLevel);
  if (oilGrams == 0) return base;
  final oil = pack.ingredient(food.oilIngredientId!)!;
  return base + oil.per100g.forGrams(oilGrams);
}

/// Grams of added cooking oil in [grams] of cooked [food].
double oilGramsFor(Food food, double grams, OilLevel? oilLevel) {
  final profile = food.oilProfile;
  if (profile == null || oilLevel == null || food.oilIngredientId == null) return 0;
  return profile.gramsPer100g(oilLevel) * grams / 100;
}

/// The oil level to store on a plan item: null for foods with no added oil.
OilLevel? oilLevelFor(Food food, OilLevel preferred) => food.hasOil ? preferred : null;
