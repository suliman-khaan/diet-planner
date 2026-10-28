import 'dart:convert';

import '../common/meal_slot.dart';
import '../common/nutrition.dart';
import 'food.dart';

/// Parses a built food pack (see tools/food-pack). Food packs are external input:
/// everything is type-checked and an invalid pack throws [FormatException] instead of
/// loading partially.
abstract final class FoodPackParser {
  static const int supportedSchemaVersion = 1;

  static FoodPack parse(String source) {
    final Object? decoded = jsonDecode(source);
    final root = _map(decoded, 'pack');
    if (root['schemaVersion'] != supportedSchemaVersion) {
      throw const FormatException('Unsupported food pack schema version');
    }
    final ingredients = _list(root['ingredients'], 'ingredients').map(_ingredient).toList();
    final ingredientIds = {for (final i in ingredients) i.id};
    final foods = _list(root['foods'], 'foods').map(_food).toList();
    final foodIds = <String>{};
    for (final f in foods) {
      if (!foodIds.add(f.id)) throw FormatException('Duplicate food id ${f.id}');
      for (final part in f.ingredients) {
        if (!ingredientIds.contains(part.ingredientId)) {
          throw FormatException('Food ${f.id} references unknown ingredient ${part.ingredientId}');
        }
      }
      if (f.oilIngredientId != null && !ingredientIds.contains(f.oilIngredientId)) {
        throw FormatException('Food ${f.id} references unknown oil ${f.oilIngredientId}');
      }
    }
    final combos = _list(root['combos'], 'combos').map(_combo).toList();
    for (final c in combos) {
      for (final item in c.items) {
        if (!foodIds.contains(item.foodId)) {
          throw FormatException('Combo ${c.id} references unknown food ${item.foodId}');
        }
      }
    }
    final measures = root['measures'] == null
        ? <HouseholdMeasure>[]
        : _list(root['measures'], 'measures').map(_measure).toList();

    return FoodPack(
      packId: _string(root['packId'], 'packId'),
      packVersion: _string(root['packVersion'], 'packVersion'),
      isDraft: root['status'] == 'draft',
      notice: root['notice'] is String ? root['notice']! as String : '',
      ingredients: ingredients,
      foods: foods,
      combos: combos,
      measures: measures,
    );
  }

  static Ingredient _ingredient(Object? raw) {
    final m = _map(raw, 'ingredient');
    return Ingredient(
      id: _string(m['id'], 'ingredient.id'),
      name: _string(m['name'], 'ingredient.name'),
      category: _string(m['category'], 'ingredient.category'),
      per100g: Nutrition.fromJson(_map(m['per100g'], 'ingredient.per100g')),
      allergens: _allergens(m['allergens']),
    );
  }

  static Food _food(Object? raw) {
    final m = _map(raw, 'food');
    final id = _string(m['id'], 'food.id');
    final names = _map(m['names'], 'food.names');
    final servings = _list(m['servings'], 'food.servings').map((s) {
      final sm = _map(s, 'serving');
      final grams = _positive(sm['grams'], 'serving.grams');
      return Serving(id: _string(sm['id'], 'serving.id'), label: _string(sm['label'], 'serving.label'), grams: grams);
    }).toList();
    final defaultServing = _string(m['defaultServing'], 'food.defaultServing');
    if (!servings.any((s) => s.id == defaultServing)) {
      throw FormatException('Food $id: default serving $defaultServing missing');
    }
    final portion = _map(m['portion'], 'food.portion');
    final rule = PortionRule(
      min: _positive(portion['min'], 'portion.min'),
      max: _positive(portion['max'], 'portion.max'),
      step: _positive(portion['step'], 'portion.step'),
    );
    if (rule.max < rule.min) throw FormatException('Food $id: invalid portion rule');

    OilProfile? oil;
    if (m['oilPer100g'] != null) {
      final o = _map(m['oilPer100g'], 'food.oilPer100g');
      oil = OilProfile(
        light: _nonNegative(o['light'], 'oil.light'),
        normal: _nonNegative(o['normal'], 'oil.normal'),
        rich: _nonNegative(o['rich'], 'oil.rich'),
      );
    }
    final dietary = _map(m['dietary'], 'food.dietary');
    final review = _string(m['allergenReview'], 'food.allergenReview');

    return Food(
      id: id,
      revision: _int(m['revision'], 'food.revision'),
      nameEn: _string(names['en'], 'names.en'),
      nameUr: names['ur'] is String ? names['ur']! as String : null,
      romanUrduAliases: _list(names['romanUrdu'], 'names.romanUrdu').map((a) => _string(a, 'alias')).toList(),
      category: _string(m['category'], 'food.category'),
      role: _string(m['role'], 'food.role'),
      nutritionPer100g: Nutrition.fromJson(_map(m['nutritionPer100g'], 'food.nutritionPer100g')),
      ingredients: _list(m['ingredientsPer100g'], 'food.ingredientsPer100g').map((p) {
        final pm = _map(p, 'ingredientShare');
        return IngredientShare(
          ingredientId: _string(pm['id'], 'ingredientShare.id'),
          gramsPer100g: _positive(pm['grams'], 'ingredientShare.grams'),
        );
      }).toList(),
      servings: servings,
      defaultServingId: defaultServing,
      portion: rule,
      oilProfile: oil,
      oilIngredientId: m['oilIngredient'] is String ? m['oilIngredient']! as String : null,
      isSharedDish: m['isSharedDish'] == true,
      mealSlotFit: _list(m['mealSlotFit'], 'food.mealSlotFit').map((s) => MealSlot.fromName(_string(s, 'slot'))).toSet(),
      dietary: DietaryFlags(
        containsMeat: dietary['containsMeat'] == true,
        containsFish: dietary['containsFish'] == true,
        containsEgg: dietary['containsEgg'] == true,
        containsDairy: dietary['containsDairy'] == true,
      ),
      allergens: _allergens(m['allergens']),
      allergenReview: switch (review) {
        'reviewed' => AllergenReview.reviewed,
        'derived' => AllergenReview.derived,
        _ => throw FormatException('Food $id: unknown allergen review status $review'),
      },
      status: switch (_string(m['status'], 'food.status')) {
        'draft' => ContentStatus.draft,
        'reviewed' => ContentStatus.reviewed,
        'published' => ContentStatus.published,
        final s => throw FormatException('Food $id: unknown status $s'),
      },
      source: _string(m['source'], 'food.source'),
    );
  }

  static Combo _combo(Object? raw) {
    final m = _map(raw, 'combo');
    return Combo(
      id: _string(m['id'], 'combo.id'),
      slots: _list(m['slots'], 'combo.slots').map((s) => MealSlot.fromName(_string(s, 'slot'))).toSet(),
      items: _list(m['items'], 'combo.items').map((i) {
        final im = _map(i, 'comboItem');
        return ComboItem(
          foodId: _string(im['foodId'], 'comboItem.foodId'),
          servings: _positive(im['servings'], 'comboItem.servings'),
        );
      }).toList(),
    );
  }

  static HouseholdMeasure _measure(Object? raw) {
    final m = _map(raw, 'measure');
    return HouseholdMeasure(
      id: _string(m['id'], 'measure.id'),
      label: _string(m['label'], 'measure.label'),
      labelUr: m['ur'] is String ? m['ur']! as String : '',
      description: m['description'] is String ? m['description']! as String : '',
      grams: m['grams'] is num ? (m['grams']! as num).toDouble() : null,
      ml: m['ml'] is num ? (m['ml']! as num).toDouble() : null,
    );
  }

  static Set<Allergen> _allergens(Object? raw) => _list(raw, 'allergens').map((a) {
        final name = _string(a, 'allergen');
        return Allergen.values.firstWhere((x) => x.name == name,
            orElse: () => throw FormatException('Unknown allergen $name'));
      }).toSet();

  static Map<String, Object?> _map(Object? v, String what) {
    if (v is Map<String, Object?>) return v;
    if (v is Map<Object?, Object?>) return v.map((k, val) => MapEntry(k.toString(), val));
    throw FormatException('Expected object for $what');
  }

  static List<Object?> _list(Object? v, String what) {
    if (v is List<Object?>) return v;
    throw FormatException('Expected list for $what');
  }

  static String _string(Object? v, String what) {
    if (v is String && v.isNotEmpty) return v;
    throw FormatException('Expected text for $what');
  }

  static int _int(Object? v, String what) {
    if (v is int && v > 0) return v;
    throw FormatException('Expected positive integer for $what');
  }

  static double _positive(Object? v, String what) {
    if (v is num && v.isFinite && v > 0) return v.toDouble();
    throw FormatException('Expected positive number for $what');
  }

  static double _nonNegative(Object? v, String what) {
    if (v is num && v.isFinite && v >= 0) return v.toDouble();
    throw FormatException('Expected non-negative number for $what');
  }
}
