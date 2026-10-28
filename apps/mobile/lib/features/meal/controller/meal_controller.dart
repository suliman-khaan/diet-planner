import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/day_service.dart';
import '../../../app/providers/formatters.dart';
import '../../../app/providers/providers.dart';
import '../../../domain/common/local_date.dart';
import '../../../domain/common/meal_slot.dart';
import '../../../domain/plan/daily_plan.dart';
import '../view_model/meal_view_model.dart';

class MealKey {
  const MealKey(this.date, this.mealId);

  final LocalDate date;
  final String mealId;

  @override
  bool operator ==(Object other) => other is MealKey && other.date == date && other.mealId == mealId;

  @override
  int get hashCode => Object.hash(date, mealId);
}

class MealState {
  const MealState({required this.vm, required this.day, required this.meal});

  final MealViewModel vm;
  final DayData day;
  final PlannedMeal meal;
}

class MealController extends FamilyAsyncNotifier<MealState?, MealKey> {
  int _regenerateAttempts = 0;

  @override
  Future<MealState?> build(MealKey key) async {
    final day = await ref.watch(dayServiceProvider).load(key.date, generateIfMissing: false);
    final meal = day?.plan?.meals.where((m) => m.id == key.mealId).firstOrNull;
    if (day == null || meal == null) return null;
    return MealState(vm: mapMeal(day, meal), day: day, meal: meal);
  }

  MealState? get _s => state.valueOrNull;

  Future<void> _save(PlannedMeal updated) async {
    final s = _s;
    if (s == null || s.day.plan == null) return;
    await ref.read(dayServiceProvider).saveMeal(s.day.plan!, updated);
    ref.invalidateSelf();
    await future;
  }

  PlanItem? get _mainItem {
    final s = _s;
    if (s == null) return null;
    return s.meal.items.where((i) => i.id == s.vm.mainDishId).firstOrNull;
  }

  Future<void> setMainServings(num servings) async {
    final main = _mainItem;
    if (main == null) return;
    await _resize(main.id, servings.toDouble());
  }

  Future<void> setItemServings(String itemId, num servings) => _resize(itemId, servings.toDouble());

  Future<void> _resize(String itemId, double servings) async {
    final s = _s;
    if (s == null || s.vm.isEaten) return;
    final planner = ref.read(plannerProvider);
    final items = [
      for (final i in s.meal.items)
        if (i.id == itemId)
          planner.resizeItem(s.day.pack, i, servings: s.day.pack.food(i.foodId)!.portion.clampAndSnap(servings))
        else
          i,
    ];
    await _save(s.meal.copyWith(items: items));
  }

  /// Meal-level oil override: applies to every item cooked with oil.
  Future<void> setOil(OilLevel level) async {
    final s = _s;
    if (s == null || s.vm.isEaten) return;
    final planner = ref.read(plannerProvider);
    await _save(s.meal.copyWith(items: [
      for (final i in s.meal.items) i.oilLevel == null ? i : planner.resizeItem(s.day.pack, i, oilLevel: level),
    ]));
  }

  /// Removes an item. Returns the meal as it was, for undo.
  Future<PlannedMeal?> removeItem(String itemId) async {
    final s = _s;
    if (s == null || s.vm.isEaten) return null;
    final before = s.meal;
    await _save(before.copyWith(items: before.items.where((i) => i.id != itemId).toList()));
    return before;
  }

  Future<void> restore(PlannedMeal meal) => _save(meal);

  Future<void> addFood(String foodId) async {
    final s = _s;
    if (s == null || s.vm.isEaten) return;
    final food = s.day.pack.food(foodId);
    if (food == null) return;
    final item = ref.read(plannerProvider).itemFor(s.day.pack, food, food.portion.clampAndSnap(1), s.day.setup.profile.cookingRichness);
    await _save(s.meal.copyWith(items: [...s.meal.items, item]));
  }

  /// A different option for this meal. False when none is available.
  Future<bool> replace() async {
    final s = _s;
    if (s == null || s.vm.isEaten) return false;
    final replacement = await ref.read(dayServiceProvider).regenerateMeal(s.day, s.meal, attempt: ++_regenerateAttempts);
    ref.invalidateSelf();
    await future;
    return replacement != null;
  }

  Future<List<String>> markEaten() async {
    final s = _s;
    if (s == null) return const [];
    final ids = await ref.read(dayServiceProvider).markEaten(s.day, s.meal);
    ref.invalidateSelf();
    await future;
    return ids;
  }

  Future<void> undoEaten(List<String> ids) async {
    await ref.read(dayServiceProvider).undoLog(ids);
    ref.invalidateSelf();
    await future;
  }
}

final mealControllerProvider =
    AsyncNotifierProvider.family<MealController, MealState?, MealKey>(MealController.new);

MealViewModel mapMeal(DayData day, PlannedMeal meal) {
  final pack = day.pack;
  final main = meal.items.where((i) => pack.food(i.foodId)?.role == 'main').firstOrNull ?? meal.items.firstOrNull;
  final mainFood = main == null ? null : pack.food(main.foodId);
  final oil = main?.oilLevel ??
      meal.items.map((i) => i.oilLevel).whereType<OilLevel>().firstOrNull ??
      day.setup.profile.cookingRichness;
  return MealViewModel(
    mealId: meal.id,
    slotTitle: Fmt.slot(meal.slot),
    timeLabel: '${Fmt.dayTitle(day.date, day.today)} · ${Fmt.time(meal.minutesOfDay)}',
    totalCalories: meal.nutrition.kcal.round(),
    mainDishId: main?.id ?? '',
    mainDishName: mainFood?.nameEn ?? 'No main dish',
    mainDishDescription: main == null
        ? 'Add a food to this meal.'
        : main.fromSharedDish
            ? 'Your portion from the dish cooked for everyone · about ${main.grams.round()} g'
            : '${Fmt.portion(mainFood!, main.servingId, main.servings)} · about ${main.grams.round()} g',
    mainDishCalories: main?.nutrition.kcal.round() ?? 0,
    mainDishKatoriCount: main?.servings ?? 1,
    oilRichness: Fmt.toUiOil(oil),
    sideItems: [
      for (final i in meal.items)
        if (!identical(i, main))
          MealSideItemViewModel(
            id: i.id,
            name: pack.food(i.foodId)?.nameEn ?? i.foodId,
            portionDescription: '${Fmt.portion(pack.food(i.foodId)!, i.servingId, i.servings)} · ${i.nutrition.kcal.round()} kcal',
            calories: i.nutrition.kcal.round(),
            count: i.servings,
          ),
    ],
    isEaten: day.isMealLogged(meal),
  );
}
