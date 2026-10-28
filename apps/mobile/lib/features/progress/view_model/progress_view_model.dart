import 'package:flutter/foundation.dart';

enum EatingLogStatus { fullyLogged, partlyLogged, notLogged }

@immutable
class WeightPointViewModel {
  final DateTime? date;
  final String dateLabel; // e.g. "30 Sep", "7 Oct"
  final double weightKg;

  const WeightPointViewModel({
    this.date,
    required this.dateLabel,
    required this.weightKg,
  });
}

@immutable
class DayEatingBarViewModel {
  final String dayLabel; // e.g. "W", "T", "F", "S", "S", "M", "T"
  final double percentageOfTarget; // 0.0 to 1.0
  final num calories;
  final EatingLogStatus status;

  const DayEatingBarViewModel({
    required this.dayLabel,
    required this.percentageOfTarget,
    required this.calories,
    required this.status,
  });
}

@immutable
class ProgressViewModel {
  final double currentWeightKg;
  final String weightChangeSubtitle;
  final List<WeightPointViewModel> weightTrend;
  final List<DayEatingBarViewModel> weekEating;
  final int daysLoggedThisWeek;
  final int totalDaysInPeriod;
  final num averageProteinGrams;
  final bool isMonthView;
  final bool isLoading;
  final String? errorMessage;

  const ProgressViewModel({
    this.currentWeightKg = 78.4,
    this.weightChangeSubtitle = '1.6 kg down in 4 weeks',
    this.weightTrend = const [
      WeightPointViewModel(dateLabel: '30 Sep', weightKg: 80.0, date: null as dynamic),
      WeightPointViewModel(dateLabel: '7 Oct', weightKg: 79.5, date: null as dynamic),
      WeightPointViewModel(dateLabel: '14 Oct', weightKg: 79.2, date: null as dynamic),
      WeightPointViewModel(dateLabel: '21 Oct', weightKg: 78.8, date: null as dynamic),
      WeightPointViewModel(dateLabel: '28 Oct', weightKg: 78.4, date: null as dynamic),
    ],
    this.weekEating = const [
      DayEatingBarViewModel(dayLabel: 'W', percentageOfTarget: 0.85, calories: 1810, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'T', percentageOfTarget: 0.90, calories: 1850, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'F', percentageOfTarget: 0.20, calories: 420, status: EatingLogStatus.notLogged),
      DayEatingBarViewModel(dayLabel: 'S', percentageOfTarget: 0.78, calories: 1650, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'S', percentageOfTarget: 0.50, calories: 1100, status: EatingLogStatus.partlyLogged),
      DayEatingBarViewModel(dayLabel: 'M', percentageOfTarget: 0.95, calories: 1890, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'T', percentageOfTarget: 0.65, calories: 1350, status: EatingLogStatus.partlyLogged),
    ],
    this.daysLoggedThisWeek = 6,
    this.totalDaysInPeriod = 7,
    this.averageProteinGrams = 71,
    this.isMonthView = true,
    this.isLoading = false,
    this.errorMessage,
  });

  ProgressViewModel copyWith({
    double? currentWeightKg,
    String? weightChangeSubtitle,
    List<WeightPointViewModel>? weightTrend,
    List<DayEatingBarViewModel>? weekEating,
    int? daysLoggedThisWeek,
    int? totalDaysInPeriod,
    num? averageProteinGrams,
    bool? isMonthView,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProgressViewModel(
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      weightChangeSubtitle: weightChangeSubtitle ?? this.weightChangeSubtitle,
      weightTrend: weightTrend ?? this.weightTrend,
      weekEating: weekEating ?? this.weekEating,
      daysLoggedThisWeek: daysLoggedThisWeek ?? this.daysLoggedThisWeek,
      totalDaysInPeriod: totalDaysInPeriod ?? this.totalDaysInPeriod,
      averageProteinGrams: averageProteinGrams ?? this.averageProteinGrams,
      isMonthView: isMonthView ?? this.isMonthView,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
