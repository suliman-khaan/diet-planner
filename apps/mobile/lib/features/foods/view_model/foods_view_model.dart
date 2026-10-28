import 'package:flutter/foundation.dart';

@immutable
class FoodItemViewModel {
  final String id;
  final String englishName;
  final String urduName;
  final String standardServing; // e.g. "1 katori · 180 g"
  final num calories;
  final num proteinGrams;
  final num carbsGrams;
  final num fatGrams;
  final num fibreGrams;
  final bool isReviewed;
  final List<String> allergens;
  final String category;

  const FoodItemViewModel({
    required this.id,
    required this.englishName,
    required this.urduName,
    required this.standardServing,
    required this.calories,
    this.proteinGrams = 0,
    this.carbsGrams = 0,
    this.fatGrams = 0,
    this.fibreGrams = 0,
    this.isReviewed = true,
    this.allergens = const [],
    this.category = 'All',
  });
}

@immutable
class FoodsViewModel {
  final String searchQuery;
  final String selectedCategory;
  final List<String> categories;
  final List<FoodItemViewModel> searchResults;
  final bool isLoading;
  final String? errorMessage;

  const FoodsViewModel({
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.categories = const [
      'All',
      'Snacks',
      'Daal & chana',
      'Breads',
      'Rice',
      'Meat & chicken',
      'Vegetables',
      'Beverages',
    ],
    this.searchResults = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FoodsViewModel copyWith({
    String? searchQuery,
    String? selectedCategory,
    List<String>? categories,
    List<FoodItemViewModel>? searchResults,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FoodsViewModel(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
