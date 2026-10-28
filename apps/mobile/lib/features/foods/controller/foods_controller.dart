import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/providers.dart';
import '../../../domain/common/meal_slot.dart';
import '../../../domain/food/food.dart';
import '../../../domain/plan/portion_math.dart';
import '../../../services/analytics/analytics_service.dart';
import '../view_model/foods_view_model.dart';

/// Screen category label → pack categories.
const foodCategoryLabels = <String, Set<String>>{
  'All': {},
  'Breads': {'breads'},
  'Rice': {'rice'},
  'Daal & chana': {'daal'},
  'Meat & fish': {'meat'},
  'Vegetables': {'vegetables'},
  'Eggs & dairy': {'eggs', 'dairy'},
  'Snacks': {'snacks'},
  'Fruit': {'fruit'},
  'Beverages': {'beverages'},
  'Salads & sweets': {'salads', 'desserts'},
};

String _labelFor(String category) => foodCategoryLabels.entries
    .firstWhere((e) => e.value.contains(category),
        orElse: () => const MapEntry('All', {}))
    .key;

class FoodsController extends AsyncNotifier<FoodsViewModel> {
  String _query = '';
  String _category = 'All';

  @override
  Future<FoodsViewModel> build() async => _compute();

  Future<FoodsViewModel> _compute() async {
    final pack = await ref.watch(foodPackProvider.future);
    final search = await ref.watch(foodSearchProvider.future);
    final setup = await ref.watch(userSetupProvider.future);
    final oil = setup?.profile.cookingRichness ?? OilLevel.normal;
    final cats = foodCategoryLabels[_category] ?? const {};
    final results = search
        .search(_query)
        .where((f) => cats.isEmpty || cats.contains(f.category))
        .toList();
    if (_query.trim().isNotEmpty && results.isEmpty) {
      // Length bucket only, never the query text.
      ref.read(analyticsServiceProvider).log(
          AnalyticsEvent.searchNoResult, {'lengthBucket': _query.length ~/ 5});
    }
    return FoodsViewModel(
      searchQuery: _query,
      selectedCategory: _category,
      categories: foodCategoryLabels.keys.toList(),
      searchResults: [for (final f in results) foodItemViewModel(pack, f, oil)],
    );
  }

  Future<void> setQuery(String q) async {
    _query = q;
    state = AsyncData(await _compute());
  }

  Future<void> setCategory(String c) async {
    _category = c;
    state = AsyncData(await _compute());
  }
}

final foodsControllerProvider =
    AsyncNotifierProvider<FoodsController, FoodsViewModel>(FoodsController.new);

FoodItemViewModel foodItemViewModel(FoodPack pack, Food f, OilLevel oil) {
  final s = f.defaultServing;
  final n = portionNutrition(pack, f, s.grams, oilLevelFor(f, oil));
  return FoodItemViewModel(
    id: f.id,
    englishName: f.nameEn,
    urduName: f.nameUr ?? '',
    standardServing: '${s.label} · ${s.grams.round()} g',
    calories: n.kcal.round(),
    proteinGrams: n.protein.round(),
    carbsGrams: n.carbs.round(),
    fatGrams: n.fat.round(),
    fibreGrams: n.fibre.round(),
    isReviewed: f.status.isVerified,
    allergens: [
      for (final a in f.allergens) a.name[0].toUpperCase() + a.name.substring(1)
    ],
    category: _labelFor(f.category),
  );
}
