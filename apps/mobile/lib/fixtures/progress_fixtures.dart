import '../features/progress/view_model/progress_view_model.dart';

/// Previews and test fixtures for Progress screen.
abstract class ProgressFixtures {
  static final standardMonth = ProgressViewModel(
    currentWeightKg: 78.4,
    weightChangeSubtitle: '1.6 kg down in 4 weeks',
    isMonthView: true,
    daysLoggedThisWeek: 6,
    totalDaysInPeriod: 7,
    averageProteinGrams: 71,
    weightTrend: [
      WeightPointViewModel(date: DateTime.now().subtract(const Duration(days: 28)), weightKg: 80.0),
      WeightPointViewModel(date: DateTime.now().subtract(const Duration(days: 21)), weightKg: 79.5),
      WeightPointViewModel(date: DateTime.now().subtract(const Duration(days: 14)), weightKg: 79.1),
      WeightPointViewModel(date: DateTime.now().subtract(const Duration(days: 7)), weightKg: 78.7),
      WeightPointViewModel(date: DateTime.now(), weightKg: 78.4),
    ],
    weekEating: const [
      DayEatingBarViewModel(dayLabel: 'W', percentageOfTarget: 0.82, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'T', percentageOfTarget: 0.90, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'F', percentageOfTarget: 0.10, status: EatingLogStatus.notLogged),
      DayEatingBarViewModel(dayLabel: 'S', percentageOfTarget: 0.76, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'S', percentageOfTarget: 0.48, status: EatingLogStatus.partlyLogged),
      DayEatingBarViewModel(dayLabel: 'M', percentageOfTarget: 0.95, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'T', percentageOfTarget: 0.60, status: EatingLogStatus.partlyLogged),
    ],
  );

  static const loading = ProgressViewModel(
    isLoading: true,
  );
}
