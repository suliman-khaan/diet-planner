import 'package:flutter/foundation.dart';

@immutable
class PastDayLogSnapshotViewModel {
  final String dateTitle; // e.g. "Monday, 27 October"
  final num totalCalories;
  final num targetCalories;
  final int mealsLogged;
  final int totalMeals;
  final num proteinGrams;
  final num carbsGrams;
  final num fatGrams;
  final List<String> topDishes;

  const PastDayLogSnapshotViewModel({
    required this.dateTitle,
    required this.totalCalories,
    required this.targetCalories,
    required this.mealsLogged,
    required this.totalMeals,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.topDishes = const [],
  });
}

@immutable
class HistoryViewModel {
  final List<PastDayLogSnapshotViewModel> pastDays;
  final bool isLoading;
  final String? errorMessage;

  const HistoryViewModel({
    this.pastDays = const [],
    this.isLoading = false,
    this.errorMessage,
  });
}
