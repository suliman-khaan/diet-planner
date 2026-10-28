import 'package:flutter/foundation.dart';

enum EatingLogStatus { fullyLogged, partlyLogged, notLogged }

@immutable
class WeightPointViewModel {
  final DateTime date;
  final double weightKg;

  const WeightPointViewModel({
    required this.date,
    required this.weightKg,
  });
}

@immutable
class DayEatingBarViewModel {
  final String dayLabel; // e.g. "M", "T", "W"
  final double percentageOfTarget;
  final EatingLogStatus status;

  const DayEatingBarViewModel({
    required this.dayLabel,
    required this.percentageOfTarget,
    required this.status,
  });
}

@immutable
class ProgressViewModel {
  final double currentWeightKg;
  final String weightChangeSubtitle; // e.g. "1.6 kg down in 4 weeks"
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
    this.weightTrend = const [],
    this.weekEating = const [],
    this.daysLoggedThisWeek = 6,
    this.totalDaysInPeriod = 7,
    this.averageProteinGrams = 71,
    this.isMonthView = true,
    this.isLoading = false,
    this.errorMessage,
  });
}
