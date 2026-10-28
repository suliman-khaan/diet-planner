import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/day_service.dart';
import '../../../app/providers/providers.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../domain/common/local_date.dart';
import '../../../domain/common/meal_slot.dart';
import '../../../domain/common/nutrition.dart';
import '../../../domain/food/food.dart';
import '../../../domain/log/food_log.dart';
import '../../../domain/plan/portion_math.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../foods/controller/foods_controller.dart';
import '../../foods/ui/food_detail_sheet.dart';
import '../../foods/ui/foods_screen.dart';
import '../../foods/view_model/foods_view_model.dart';
import '../ui/quick_add_sheet.dart';

/// Logging food that is not in the plan: pick from the catalogue or quick-add calories.
abstract final class LogFoodFlow {
  static Future<void> start(BuildContext context, WidgetRef ref,
      {LocalDate? date}) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search foods'),
              subtitle: const Text('Pick a food and portion'),
              onTap: () => Navigator.of(ctx).pop('search'),
            ),
            ListTile(
              leading: const Icon(Icons.bolt_outlined),
              title: const Text('Quick add calories'),
              subtitle: const Text('When you only know the calories'),
              onTap: () => Navigator.of(ctx).pop('quick'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || choice == null) return;
    final day = date ?? ref.read(dayServiceProvider).today;
    if (choice == 'search') {
      final picked = await pickFood(context);
      if (picked == null || !context.mounted) return;
      await showFoodDetail(context, ref, picked, date: day);
    } else {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => QuickAddSheet(
          onQuickAddSubmitted: (label, kcal, slot) => logQuickAdd(
              ref, day, label, kcal.toDouble(), _slotFromLabel(slot)),
        ),
      );
    }
  }

  /// Opens the catalogue and returns the chosen food id.
  static Future<String?> pickFood(BuildContext context) =>
      Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const _FoodPickerPage()),
      );

  /// Detail sheet for one food with "Add" logging it to [date] at the current meal slot.
  static Future<void> showFoodDetail(
      BuildContext context, WidgetRef ref, String foodId,
      {LocalDate? date}) async {
    final pack = await ref.read(foodPackProvider.future);
    final food = pack.food(foodId);
    if (food == null || !context.mounted) return;
    final setup = await ref.read(userSetupProvider.future);
    final oil = setup?.profile.cookingRichness ?? OilLevel.normal;
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodDetailSheet(
        food: foodItemViewModel(pack, food, oil),
        onAddToMeal: (servings) => logFood(
            ref,
            date ?? ref.read(dayServiceProvider).today,
            pack,
            food,
            servings.toDouble(),
            oil),
      ),
    );
  }

  static Future<void> logFood(WidgetRef ref, LocalDate date, FoodPack pack,
      Food food, double servings, OilLevel oil) async {
    final service = ref.read(dayServiceProvider);
    final grams = servings * food.defaultServing.grams;
    final level = oilLevelFor(food, oil);
    await ref.read(foodLogRepositoryProvider).add([
      FoodLogEntry(
        id: service.ids.newId(),
        date: date,
        slot: _currentSlot(ref),
        source: LogSource.manual,
        label: food.nameEn,
        nutrition: portionNutrition(pack, food, grams, level),
        loggedAtUtc: service.clock.nowUtc(),
        foodId: food.id,
        foodRevision: food.revision,
        packVersion: pack.packVersion,
        grams: grams,
        oilLevel: level,
      ),
    ]);
    ref
        .read(analyticsServiceProvider)
        .log(AnalyticsEvent.mealLogged, {'source': 'manual'});
  }

  static Future<void> logQuickAdd(WidgetRef ref, LocalDate date, String label,
      double kcal, MealSlot slot) async {
    final service = ref.read(dayServiceProvider);
    await ref.read(foodLogRepositoryProvider).add([
      FoodLogEntry(
        id: service.ids.newId(),
        date: date,
        slot: slot,
        source: LogSource.quickAdd,
        label: label.trim().isEmpty ? 'Quick add' : label.trim(),
        // Quick add records energy only; macros stay unknown rather than guessed.
        nutrition:
            Nutrition(kcal: kcal, protein: 0, carbs: 0, fat: 0, fibre: 0),
        loggedAtUtc: service.clock.nowUtc(),
      ),
    ]);
    ref
        .read(analyticsServiceProvider)
        .log(AnalyticsEvent.mealLogged, {'source': 'quickAdd', 'slot': slot});
  }

  static MealSlot _currentSlot(WidgetRef ref) {
    final h = ref.read(clockProvider).nowLocal().hour;
    if (h < 11) return MealSlot.breakfast;
    if (h < 16) return MealSlot.lunch;
    if (h < 19) return MealSlot.chai;
    return MealSlot.dinner;
  }

  static MealSlot _slotFromLabel(String label) => switch (label.toLowerCase()) {
        'breakfast' => MealSlot.breakfast,
        'lunch' => MealSlot.lunch,
        'chai' => MealSlot.chai,
        'dinner' => MealSlot.dinner,
        'sehri' => MealSlot.sehri,
        'iftar' => MealSlot.iftar,
        _ => MealSlot.snack,
      };
}

class _FoodPickerPage extends ConsumerWidget {
  const _FoodPickerPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(foodsControllerProvider);
    final controller = ref.read(foodsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a food')),
      body: async.when(
        loading: () => const FoodsScreen(vm: FoodsViewModel(isLoading: true)),
        error: (_, __) => ErrorStateWidget(
          message: 'The food list could not be loaded.',
          onRetry: () => ref.invalidate(foodsControllerProvider),
        ),
        data: (vm) => FoodsScreen(
          vm: vm,
          onSearchChanged: controller.setQuery,
          onSearchCleared: () => controller.setQuery(''),
          onCategorySelected: controller.setCategory,
          onFoodSelected: (FoodItemViewModel f) =>
              Navigator.of(context).pop(f.id),
        ),
      ),
    );
  }
}
