import '../food/food.dart';
import '../plan/daily_plan.dart';
import '../plan/portion_math.dart';

enum ShoppingUnit { grams, millilitres }

class ShoppingLine {
  const ShoppingLine({
    required this.ingredientId,
    required this.name,
    required this.category,
    required this.amount,
    required this.unit,
    required this.isReadyMade,
  });

  final String ingredientId;
  final String name;
  final String category;
  final double amount;
  final ShoppingUnit unit;

  /// Bought ready to eat (bread, rusk) rather than cooked from raw.
  final bool isReadyMade;
}

/// Raw ingredients needed for the user's planned portions, aggregated by ingredient.
///
/// Quantities come from each food's recipe (raw grams per 100 g cooked) scaled by the
/// planned grams, plus cooking oil at the chosen level. Water and brewed tea are skipped.
/// All amounts are grams or millilitres of the same ingredient, so they always add up;
/// different units are kept as separate lines.
List<ShoppingLine> shoppingLinesFor(
    FoodPack pack, Iterable<PlannedMeal> meals) {
  final totals = <(String, ShoppingUnit), double>{};
  void add(String ingredientId, double grams) {
    if (_skipped.contains(ingredientId) || grams <= 0) return;
    final key = (ingredientId, _unitFor(ingredientId));
    totals[key] = (totals[key] ?? 0) + grams;
  }

  for (final meal in meals) {
    for (final item in meal.items) {
      final food = pack.food(item.foodId);
      if (food == null) continue;
      for (final part in food.ingredients) {
        add(part.ingredientId, part.gramsPer100g * item.grams / 100);
      }
      final oil = oilGramsFor(food, item.grams, item.oilLevel);
      if (oil > 0) add(food.oilIngredientId!, oil);
    }
  }

  final lines = [
    for (final entry in totals.entries)
      if (pack.ingredient(entry.key.$1) case final ing?)
        ShoppingLine(
          ingredientId: ing.id,
          name: ing.name,
          category: ing.category,
          amount: entry.value,
          unit: entry.key.$2,
          isReadyMade: ing.isReadyMade,
        ),
  ];
  lines.sort((a, b) {
    final c = a.category.compareTo(b.category);
    return c != 0 ? c : a.name.compareTo(b.name);
  });
  return lines;
}

const _skipped = {'water', 'tea-brewed'};
const _liquids = {'milk', 'lemon-juice'};

ShoppingUnit _unitFor(String ingredientId) => _liquids.contains(ingredientId)
    ? ShoppingUnit.millilitres
    : ShoppingUnit.grams;
