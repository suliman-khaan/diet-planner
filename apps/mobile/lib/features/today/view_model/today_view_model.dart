import 'package:flutter/foundation.dart';
import '../../../core/widgets/badges.dart';

@immutable
class TodayMealItemViewModel {
  final String id;
  final String slotTitle;
  final String time;
  final MealStatus status;
  final String summaryText;
  final num calories;

  const TodayMealItemViewModel({
    required this.id,
    required this.slotTitle,
    required this.time,
    required this.status,
    required this.summaryText,
    required this.calories,
  });
}

@immutable
class NextMealViewModel {
  final String id;
  final String slotLabel; // e.g. "Next · Dinner · 9:30 pm" or "Next · Iftar · 6:18 pm"
  final num estimatedCalories;
  final String mainDishTitle;
  final String familyPotDetail;
  final String sidesDetail;

  const NextMealViewModel({
    required this.id,
    required this.slotLabel,
    required this.estimatedCalories,
    required this.mainDishTitle,
    required this.familyPotDetail,
    required this.sidesDetail,
  });
}

@immutable
class TodayViewModel {
  final String dateDisplay;

  /// 'Today', 'Yesterday', 'Tomorrow' or a weekday.
  final String title;

  /// Dev builds only: the plan uses food data no one has reviewed yet.
  final bool usesDraftData;

  /// Why automated plans are off (manual-only mode). Shown instead of targets.
  final String? manualOnlyMessage;
  final bool isRamadanMode;
  final int? ramadanDay;
  final bool isManualOnly;

  // Calorie targets & progress
  final num eatenKcal;
  final num plannedKcal;
  final num targetKcal;

  // Macros (current / target in grams)
  final num proteinCurrent;
  final num proteinTarget;
  final num carbsCurrent;
  final num carbsTarget;
  final num fatCurrent;
  final num fatTarget;
  final num fibreCurrent;
  final num fibreTarget;

  // Hero next meal card
  final NextMealViewModel? nextMeal;

  // Daily timeline list
  final List<TodayMealItemViewModel> meals;

  // Screen states
  final bool isLoading;
  final bool isOffline;
  final bool hasNoPlan;
  final String? noPlanReason;
  final String? errorMessage;

  const TodayViewModel({
    required this.dateDisplay,
    this.title = 'Today',
    this.usesDraftData = false,
    this.manualOnlyMessage,
    this.isRamadanMode = false,
    this.ramadanDay,
    this.isManualOnly = false,
    this.eatenKcal = 0,
    this.plannedKcal = 0,
    this.targetKcal = 1850,
    this.proteinCurrent = 0,
    this.proteinTarget = 95,
    this.carbsCurrent = 0,
    this.carbsTarget = 230,
    this.fatCurrent = 0,
    this.fatTarget = 60,
    this.fibreCurrent = 0,
    this.fibreTarget = 28,
    this.nextMeal,
    this.meals = const [],
    this.isLoading = false,
    this.isOffline = false,
    this.hasNoPlan = false,
    this.noPlanReason,
    this.errorMessage,
  });

  TodayViewModel copyWith({
    String? dateDisplay,
    String? title,
    bool? usesDraftData,
    String? manualOnlyMessage,
    bool? isRamadanMode,
    int? ramadanDay,
    bool? isManualOnly,
    num? eatenKcal,
    num? plannedKcal,
    num? targetKcal,
    num? proteinCurrent,
    num? proteinTarget,
    num? carbsCurrent,
    num? carbsTarget,
    num? fatCurrent,
    num? fatTarget,
    num? fibreCurrent,
    num? fibreTarget,
    NextMealViewModel? nextMeal,
    List<TodayMealItemViewModel>? meals,
    bool? isLoading,
    bool? isOffline,
    bool? hasNoPlan,
    String? noPlanReason,
    String? errorMessage,
  }) {
    return TodayViewModel(
      dateDisplay: dateDisplay ?? this.dateDisplay,
      title: title ?? this.title,
      usesDraftData: usesDraftData ?? this.usesDraftData,
      manualOnlyMessage: manualOnlyMessage ?? this.manualOnlyMessage,
      isRamadanMode: isRamadanMode ?? this.isRamadanMode,
      ramadanDay: ramadanDay ?? this.ramadanDay,
      isManualOnly: isManualOnly ?? this.isManualOnly,
      eatenKcal: eatenKcal ?? this.eatenKcal,
      plannedKcal: plannedKcal ?? this.plannedKcal,
      targetKcal: targetKcal ?? this.targetKcal,
      proteinCurrent: proteinCurrent ?? this.proteinCurrent,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      carbsCurrent: carbsCurrent ?? this.carbsCurrent,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      fatCurrent: fatCurrent ?? this.fatCurrent,
      fatTarget: fatTarget ?? this.fatTarget,
      fibreCurrent: fibreCurrent ?? this.fibreCurrent,
      fibreTarget: fibreTarget ?? this.fibreTarget,
      nextMeal: nextMeal ?? this.nextMeal,
      meals: meals ?? this.meals,
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
      hasNoPlan: hasNoPlan ?? this.hasNoPlan,
      noPlanReason: noPlanReason ?? this.noPlanReason,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
