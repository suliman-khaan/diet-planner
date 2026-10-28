import '../features/progress/view_model/progress_view_model.dart';

/// Previews and test fixtures for Progress screen.
abstract class ProgressFixtures {
  static const standardMonth = ProgressViewModel(
    currentWeightKg: 78.4,
    weightChangeSubtitle: '1.6 kg down in 4 weeks',
    isMonthView: true,
    daysLoggedThisWeek: 6,
    totalDaysInPeriod: 7,
    averageProteinGrams: 71,
    weightTrend: [
      WeightPointViewModel(dateLabel: '30 Sep', weightKg: 80.0),
      WeightPointViewModel(dateLabel: '7 Oct', weightKg: 79.5),
      WeightPointViewModel(dateLabel: '14 Oct', weightKg: 79.1),
      WeightPointViewModel(dateLabel: '21 Oct', weightKg: 78.7),
      WeightPointViewModel(dateLabel: '28 Oct', weightKg: 78.4),
    ],
    weekEating: [
      DayEatingBarViewModel(dayLabel: 'W', percentageOfTarget: 0.82, calories: 1810, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'T', percentageOfTarget: 0.90, calories: 1850, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'F', percentageOfTarget: 0.15, calories: 420, status: EatingLogStatus.notLogged),
      DayEatingBarViewModel(dayLabel: 'S', percentageOfTarget: 0.76, calories: 1650, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'S', percentageOfTarget: 0.48, calories: 1100, status: EatingLogStatus.partlyLogged),
      DayEatingBarViewModel(dayLabel: 'M', percentageOfTarget: 0.95, calories: 1890, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'T', percentageOfTarget: 0.60, calories: 1350, status: EatingLogStatus.partlyLogged),
    ],
  );

  static const standardWeek = ProgressViewModel(
    currentWeightKg: 78.4,
    weightChangeSubtitle: '0.4 kg down this week',
    isMonthView: false,
    daysLoggedThisWeek: 6,
    totalDaysInPeriod: 7,
    averageProteinGrams: 74,
    weightTrend: [
      WeightPointViewModel(dateLabel: 'Mon', weightKg: 78.8),
      WeightPointViewModel(dateLabel: 'Tue', weightKg: 78.7),
      WeightPointViewModel(dateLabel: 'Wed', weightKg: 78.6),
      WeightPointViewModel(dateLabel: 'Thu', weightKg: 78.5),
      WeightPointViewModel(dateLabel: 'Today', weightKg: 78.4),
    ],
    weekEating: [
      DayEatingBarViewModel(dayLabel: 'M', percentageOfTarget: 0.95, calories: 1890, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'T', percentageOfTarget: 0.90, calories: 1850, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'W', percentageOfTarget: 0.82, calories: 1810, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'T', percentageOfTarget: 0.76, calories: 1650, status: EatingLogStatus.fullyLogged),
      DayEatingBarViewModel(dayLabel: 'F', percentageOfTarget: 0.15, calories: 420, status: EatingLogStatus.notLogged),
      DayEatingBarViewModel(dayLabel: 'S', percentageOfTarget: 0.60, calories: 1350, status: EatingLogStatus.partlyLogged),
      DayEatingBarViewModel(dayLabel: 'S', percentageOfTarget: 0.88, calories: 1780, status: EatingLogStatus.fullyLogged),
    ],
  );

  static const loading = ProgressViewModel(
    isLoading: true,
  );
}
