import '../common/meal_slot.dart';
import '../common/nutrition.dart';

enum ContentStatus {
  draft,
  reviewed,
  published;

  /// Only reviewed or published content may be used for public automated planning.
  bool get isVerified => this != ContentStatus.draft;
}

/// How a food's allergen list was established. Unknown is never treated as safe.
enum AllergenReview {
  /// Derived from the ingredient list by tooling; not yet checked by a person.
  derived,

  /// Checked by a named reviewer.
  reviewed,
}

enum Allergen { gluten, dairy, nuts, egg, fish }

class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.per100g,
    required this.allergens,
  });

  final String id;
  final String name;
  final String category;
  final Nutrition per100g;
  final Set<Allergen> allergens;

  /// Ingredients that are bought ready to eat rather than cooked from raw.
  bool get isReadyMade => category == 'bakery';
}

class Serving {
  const Serving({required this.id, required this.label, required this.grams});

  final String id;
  final String label;
  final double grams;
}

/// How far the planner (and the user's steppers) may move a portion, in servings.
class PortionRule {
  const PortionRule({required this.min, required this.max, required this.step});

  final double min;
  final double max;
  final double step;

  double clampAndSnap(double servings) {
    final snapped = (servings / step).round() * step;
    return snapped.clamp(min, max).toDouble();
  }
}

/// Grams of cooking oil per 100 g of cooked dish at each level.
class OilProfile {
  const OilProfile(
      {required this.light, required this.normal, required this.rich});

  final double light;
  final double normal;
  final double rich;

  double gramsPer100g(OilLevel level) => switch (level) {
        OilLevel.light => light,
        OilLevel.normal => normal,
        OilLevel.rich => rich,
      };
}

class DietaryFlags {
  const DietaryFlags({
    required this.containsMeat,
    required this.containsFish,
    required this.containsEgg,
    required this.containsDairy,
  });

  final bool containsMeat;
  final bool containsFish;
  final bool containsEgg;
  final bool containsDairy;
}

class IngredientShare {
  const IngredientShare(
      {required this.ingredientId, required this.gramsPer100g});

  final String ingredientId;

  /// Raw ingredient grams in 100 g of the cooked food.
  final double gramsPer100g;
}

class Food {
  const Food({
    required this.id,
    required this.revision,
    required this.nameEn,
    required this.nameUr,
    required this.romanUrduAliases,
    required this.category,
    required this.role,
    required this.nutritionPer100g,
    required this.ingredients,
    required this.servings,
    required this.defaultServingId,
    required this.portion,
    required this.oilProfile,
    required this.oilIngredientId,
    required this.isSharedDish,
    required this.mealSlotFit,
    required this.dietary,
    required this.allergens,
    required this.allergenReview,
    required this.status,
    required this.source,
  });

  final String id;
  final int revision;
  final String nameEn;
  final String? nameUr;
  final List<String> romanUrduAliases;
  final String category;
  final String role;

  /// Without added cooking oil; oil is added from [oilProfile] at the chosen level.
  final Nutrition nutritionPer100g;
  final List<IngredientShare> ingredients;
  final List<Serving> servings;
  final String defaultServingId;
  final PortionRule portion;
  final OilProfile? oilProfile;
  final String? oilIngredientId;
  final bool isSharedDish;
  final Set<MealSlot> mealSlotFit;
  final DietaryFlags dietary;
  final Set<Allergen> allergens;
  final AllergenReview allergenReview;
  final ContentStatus status;
  final String source;

  Serving get defaultServing =>
      servings.firstWhere((s) => s.id == defaultServingId);

  Serving servingById(String servingId) => servings
      .firstWhere((s) => s.id == servingId, orElse: () => defaultServing);

  bool get hasOil => oilProfile != null && oilIngredientId != null;
}

class ComboItem {
  const ComboItem({required this.foodId, required this.servings});

  final String foodId;
  final double servings;
}

/// A curated meal combination, e.g. salan + roti + salad.
class Combo {
  const Combo({required this.id, required this.slots, required this.items});

  final String id;
  final Set<MealSlot> slots;
  final List<ComboItem> items;
}

class HouseholdMeasure {
  const HouseholdMeasure({
    required this.id,
    required this.label,
    required this.labelUr,
    required this.description,
    this.grams,
    this.ml,
  });

  final String id;
  final String label;
  final String labelUr;
  final String description;
  final double? grams;
  final double? ml;
}

class FoodPack {
  FoodPack({
    required this.packId,
    required this.packVersion,
    required this.isDraft,
    required this.notice,
    required this.ingredients,
    required this.foods,
    required this.combos,
    required this.measures,
  })  : _ingredientsById = {for (final i in ingredients) i.id: i},
        _foodsById = {for (final f in foods) f.id: f};

  final String packId;
  final String packVersion;
  final bool isDraft;
  final String notice;
  final List<Ingredient> ingredients;
  final List<Food> foods;
  final List<Combo> combos;
  final List<HouseholdMeasure> measures;

  final Map<String, Ingredient> _ingredientsById;
  final Map<String, Food> _foodsById;

  Food? food(String id) => _foodsById[id];
  Ingredient? ingredient(String id) => _ingredientsById[id];

  int get reviewedFoodCount => foods.where((f) => f.status.isVerified).length;
}
