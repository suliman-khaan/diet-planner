import 'package:flutter/foundation.dart';
import '../../../core/widgets/segmented_controls.dart';

@immutable
class MealSideItemViewModel {
  final String id;
  final String name;
  final String portionDescription;
  final num calories;
  final num count;
  final bool hasStepper;

  const MealSideItemViewModel({
    required this.id,
    required this.name,
    required this.portionDescription,
    required this.calories,
    this.count = 1,
    this.hasStepper = true,
  });

  MealSideItemViewModel copyWith({
    String? id,
    String? name,
    String? portionDescription,
    num? calories,
    num? count,
    bool? hasStepper,
  }) {
    return MealSideItemViewModel(
      id: id ?? this.id,
      name: name ?? this.name,
      portionDescription: portionDescription ?? this.portionDescription,
      calories: calories ?? this.calories,
      count: count ?? this.count,
      hasStepper: hasStepper ?? this.hasStepper,
    );
  }
}

@immutable
class MealViewModel {
  final String mealId;
  final String slotTitle; // e.g. "Dinner"
  final String timeLabel; // e.g. "Today · 9:30 pm"
  final num totalCalories;

  // Primary Family Pot item
  final String mainDishId;
  final String mainDishName;
  final String mainDishDescription;
  final num mainDishCalories;
  final num mainDishKatoriCount;
  final OilLevel oilRichness;

  // Accompaniments & Side items
  final List<MealSideItemViewModel> sideItems;

  final bool isEaten;
  final bool isLoading;
  final String? errorMessage;

  const MealViewModel({
    required this.mealId,
    required this.slotTitle,
    required this.timeLabel,
    required this.totalCalories,
    required this.mainDishId,
    required this.mainDishName,
    required this.mainDishDescription,
    required this.mainDishCalories,
    this.mainDishKatoriCount = 1,
    this.oilRichness = OilLevel.normal,
    this.sideItems = const [],
    this.isEaten = false,
    this.isLoading = false,
    this.errorMessage,
  });

  MealViewModel copyWith({
    String? mealId,
    String? slotTitle,
    String? timeLabel,
    num? totalCalories,
    String? mainDishId,
    String? mainDishName,
    String? mainDishDescription,
    num? mainDishCalories,
    num? mainDishKatoriCount,
    OilLevel? oilRichness,
    List<MealSideItemViewModel>? sideItems,
    bool? isEaten,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MealViewModel(
      mealId: mealId ?? this.mealId,
      slotTitle: slotTitle ?? this.slotTitle,
      timeLabel: timeLabel ?? this.timeLabel,
      totalCalories: totalCalories ?? this.totalCalories,
      mainDishId: mainDishId ?? this.mainDishId,
      mainDishName: mainDishName ?? this.mainDishName,
      mainDishDescription: mainDishDescription ?? this.mainDishDescription,
      mainDishCalories: mainDishCalories ?? this.mainDishCalories,
      mainDishKatoriCount: mainDishKatoriCount ?? this.mainDishKatoriCount,
      oilRichness: oilRichness ?? this.oilRichness,
      sideItems: sideItems ?? this.sideItems,
      isEaten: isEaten ?? this.isEaten,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
