import '../../core/widgets/badges.dart';
import '../features/today/view_model/today_view_model.dart';

/// Previews and test fixtures for Today screen across all states.
abstract class TodayFixtures {
  static const standardSuccess = TodayViewModel(
    dateDisplay: 'Tuesday, 28 October',
    isRamadanMode: false,
    eatenKcal: 1120,
    plannedKcal: 800,
    targetKcal: 1850,
    proteinCurrent: 52,
    proteinTarget: 95,
    carbsCurrent: 140,
    carbsTarget: 230,
    fatCurrent: 38,
    fatTarget: 60,
    fibreCurrent: 14,
    fibreTarget: 28,
    nextMeal: NextMealViewModel(
      id: 'dinner-01',
      slotLabel: 'Next · Dinner · 9:30 pm',
      estimatedCalories: 620,
      mainDishTitle: 'Chicken karahi · 1 katori',
      familyPotDetail: 'From the family pot · normal oil',
      sidesDetail: '1 tandoori roti · kheera salad',
    ),
    meals: [
      TodayMealItemViewModel(
        id: 'breakfast-01',
        slotTitle: 'Breakfast',
        time: '8:00 am',
        status: MealStatus.eaten,
        summaryText: 'Anda paratha (light oil), doodh patti',
        calories: 420,
      ),
      TodayMealItemViewModel(
        id: 'lunch-01',
        slotTitle: 'Lunch',
        time: '2:00 pm',
        status: MealStatus.eaten,
        summaryText: 'Daal mash, 1 roti, raita',
        calories: 700,
      ),
      TodayMealItemViewModel(
        id: 'chai-01',
        slotTitle: 'Chai',
        time: '5:30 pm',
        status: MealStatus.planned,
        summaryText: 'Doodh patti, 2 rusk',
        calories: 180,
      ),
      TodayMealItemViewModel(
        id: 'dinner-01',
        slotTitle: 'Dinner',
        time: '9:30 pm',
        status: MealStatus.planned,
        summaryText: 'Chicken karahi, 1 roti, salad',
        calories: 620,
      ),
    ],
  );

  static const ramadanSuccess = TodayViewModel(
    dateDisplay: 'Thursday, 12 March',
    isRamadanMode: true,
    ramadanDay: 22,
    eatenKcal: 560,
    plannedKcal: 1020,
    targetKcal: 1850,
    proteinCurrent: 35,
    proteinTarget: 95,
    carbsCurrent: 80,
    carbsTarget: 230,
    fatCurrent: 20,
    fatTarget: 60,
    fibreCurrent: 8,
    fibreTarget: 28,
    nextMeal: NextMealViewModel(
      id: 'iftar-01',
      slotLabel: 'Next · Iftar · 6:18 pm',
      estimatedCalories: 430,
      mainDishTitle: '3 khajoor · 1 glass water',
      familyPotDetail: 'Fruit chaat · 2 pakoray (light oil)',
      sidesDetail: '~430 kcal · estimate',
    ),
    meals: [
      TodayMealItemViewModel(
        id: 'sehri-01',
        slotTitle: 'Sehri',
        time: '4:50 am',
        status: MealStatus.eaten,
        summaryText: '2 anday, 1 roti, dahi, chai',
        calories: 560,
      ),
      TodayMealItemViewModel(
        id: 'iftar-01',
        slotTitle: 'Iftar',
        time: '6:18 pm',
        status: MealStatus.planned,
        summaryText: 'Khajoor, fruit chaat, pakoray',
        calories: 430,
      ),
      TodayMealItemViewModel(
        id: 'dinner-01',
        slotTitle: 'Dinner',
        time: '9:45 pm',
        status: MealStatus.planned,
        summaryText: 'Aloo gosht · 1 katori, 1 roti',
        calories: 590,
      ),
    ],
  );

  static const emptyNoPlan = TodayViewModel(
    dateDisplay: 'Today',
    hasNoPlan: true,
  );

  static const loading = TodayViewModel(
    dateDisplay: 'Loading...',
    isLoading: true,
  );

  static const error = TodayViewModel(
    dateDisplay: 'Today',
    errorMessage: 'Could not load your plan for today. Please retry.',
  );
}
