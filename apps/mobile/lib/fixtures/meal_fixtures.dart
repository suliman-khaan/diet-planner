import '../../core/widgets/segmented_controls.dart';
import '../features/meal/view_model/meal_view_model.dart';

/// Previews and test fixtures for Meal Detail screen.
abstract class MealFixtures {
  static const dinnerSuccess = MealViewModel(
    mealId: 'dinner-01',
    slotTitle: 'Dinner',
    timeLabel: 'Today · 9:30 pm',
    totalCalories: 620,
    mainDishId: 'karahi-01',
    mainDishName: 'Chicken karahi',
    mainDishDescription: 'Your portion from the dish cooked for everyone · about 180 g',
    mainDishCalories: 340,
    mainDishKatoriCount: 1,
    oilRichness: OilLevel.normal,
    sideItems: [
      MealSideItemViewModel(
        id: 'roti-01',
        name: 'Tandoori roti',
        portionDescription: 'Medium size',
        calories: 250,
        count: 1,
        hasStepper: true,
      ),
      MealSideItemViewModel(
        id: 'salad-01',
        name: 'Kheera salad',
        portionDescription: '1 plate',
        calories: 30,
        count: 1,
        hasStepper: false,
      ),
    ],
  );

  static const dinnerEaten = MealViewModel(
    mealId: 'dinner-01',
    slotTitle: 'Dinner',
    timeLabel: 'Today · 9:30 pm',
    totalCalories: 620,
    mainDishId: 'karahi-01',
    mainDishName: 'Chicken karahi',
    mainDishDescription: 'Your portion from the dish cooked for everyone · about 180 g',
    mainDishCalories: 340,
    mainDishKatoriCount: 1,
    oilRichness: OilLevel.normal,
    isEaten: true,
    sideItems: [
      MealSideItemViewModel(
        id: 'roti-01',
        name: 'Tandoori roti',
        portionDescription: 'Medium size',
        calories: 250,
        count: 1,
        hasStepper: true,
      ),
    ],
  );
}
