import '../features/history/view_model/history_view_model.dart';

/// Previews and test fixtures for History screen.
abstract class HistoryFixtures {
  static const standard = HistoryViewModel(
    pastDays: [
      PastDayLogSnapshotViewModel(
        dateTitle: 'Monday, 27 October',
        totalCalories: 1810,
        targetCalories: 1850,
        mealsLogged: 4,
        totalMeals: 4,
        proteinGrams: 92,
        carbsGrams: 220,
        fatGrams: 58,
        topDishes: [
          'Daal chana',
          '2 tandoori roti',
          'Chicken boti',
          'Doodh patti'
        ],
      ),
      PastDayLogSnapshotViewModel(
        dateTitle: 'Sunday, 26 October',
        totalCalories: 1720,
        targetCalories: 1850,
        mealsLogged: 3,
        totalMeals: 4,
        proteinGrams: 80,
        carbsGrams: 210,
        fatGrams: 55,
        topDishes: ['Aloo gosht', 'Boiled rice', 'Kachumber salad'],
      ),
      PastDayLogSnapshotViewModel(
        dateTitle: 'Saturday, 25 October',
        totalCalories: 1910,
        targetCalories: 1850,
        mealsLogged: 4,
        totalMeals: 4,
        proteinGrams: 98,
        carbsGrams: 240,
        fatGrams: 64,
        topDishes: ['Chicken biryani', 'Mint raita', 'Chai', '2 rusks'],
      ),
    ],
  );

  static const empty = HistoryViewModel(pastDays: []);
}
