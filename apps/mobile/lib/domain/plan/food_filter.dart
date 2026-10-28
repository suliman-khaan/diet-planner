import '../food/food.dart';
import '../profile/user_profile.dart';

enum ExclusionReason {
  notReviewed,
  dietType,
  allergen,
  allergenStatusUnknown,
  excludedIngredient,
  excludedFood,
}

/// Decides whether a food may appear in an automated plan. Restrictions are applied before
/// anything else and are never relaxed to make a plan fit.
class FoodFilter {
  const FoodFilter({required this.preferences, required this.allowDraftData});

  final DietaryPreferences preferences;

  /// Dev builds only: allows foods and allergen lists that no person has reviewed yet.
  /// Release builds must pass false (blueprint §3: unverified data never auto-planned).
  final bool allowDraftData;

  ExclusionReason? exclusionReason(Food food) {
    if (!food.status.isVerified && !allowDraftData)
      return ExclusionReason.notReviewed;
    if (preferences.excludedFoodIds.contains(food.id))
      return ExclusionReason.excludedFood;
    if (!_fitsDiet(food)) return ExclusionReason.dietType;
    if (preferences.allergies.isNotEmpty) {
      // Unknown allergen status is never treated as safe. Derived (unreviewed) lists are
      // accepted only when draft data is explicitly allowed.
      final statusTrusted =
          food.allergenReview == AllergenReview.reviewed || allowDraftData;
      if (!statusTrusted) return ExclusionReason.allergenStatusUnknown;
      if (food.allergens.any(preferences.allergies.contains))
        return ExclusionReason.allergen;
    }
    final excluded = preferences.excludedIngredientIds;
    if (excluded.isNotEmpty) {
      if (food.ingredients.any((i) => excluded.contains(i.ingredientId))) {
        return ExclusionReason.excludedIngredient;
      }
      if (food.oilIngredientId != null &&
          excluded.contains(food.oilIngredientId)) {
        return ExclusionReason.excludedIngredient;
      }
    }
    return null;
  }

  bool allows(Food food) => exclusionReason(food) == null;

  bool _fitsDiet(Food food) {
    final d = food.dietary;
    return switch (preferences.dietType) {
      DietType.everything => true,
      DietType.pescatarian => !d.containsMeat,
      DietType.vegetarian =>
        !d.containsMeat && !d.containsFish && !d.containsEgg,
      DietType.vegan => !d.containsMeat &&
          !d.containsFish &&
          !d.containsEgg &&
          !d.containsDairy,
    };
  }
}
