import '../features/foods/view_model/foods_view_model.dart';

/// Previews and test fixtures for Foods catalogue.
abstract class FoodsFixtures {
  static const standardSearch = FoodsViewModel(
    searchQuery: 'chana',
    selectedCategory: 'All',
    searchResults: [
      FoodItemViewModel(
        id: 'food-01',
        englishName: 'Chana chaat',
        urduName: 'چنا چاٹ',
        standardServing: '1 plate · 180 g',
        calories: 230,
        proteinGrams: 9,
        carbsGrams: 36,
        fatGrams: 4,
        fibreGrams: 7,
        isReviewed: true,
        category: 'Snacks',
      ),
      FoodItemViewModel(
        id: 'food-02',
        englishName: 'Chana daal',
        urduName: 'چنے کی دال',
        standardServing: '1 katori · 180 g',
        calories: 260,
        proteinGrams: 14,
        carbsGrams: 38,
        fatGrams: 6,
        fibreGrams: 8,
        isReviewed: true,
        category: 'Daal & chana',
      ),
      FoodItemViewModel(
        id: 'food-03',
        englishName: 'Cholay (chana masala)',
        urduName: 'چھولے',
        standardServing: '1 katori · 180 g',
        calories: 290,
        proteinGrams: 12,
        carbsGrams: 40,
        fatGrams: 9,
        fibreGrams: 9,
        isReviewed: true,
        category: 'Daal & chana',
      ),
      FoodItemViewModel(
        id: 'food-04',
        englishName: 'Bhuna chana',
        urduName: 'بھنے چنے',
        standardServing: '1 handful · 30 g',
        calories: 110,
        proteinGrams: 6,
        carbsGrams: 16,
        fatGrams: 2,
        fibreGrams: 4,
        isReviewed: false,
        category: 'Snacks',
      ),
    ],
  );

  static const emptySearch = FoodsViewModel(
    searchQuery: 'pizza burger unknown',
    searchResults: [],
  );

  static const loadingSearch = FoodsViewModel(
    isLoading: true,
  );
}
