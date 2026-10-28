import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app_config.dart';
import 'package:mobile/app/providers/providers.dart';
import 'package:mobile/core/clock/clock.dart';
import 'package:mobile/core/ids/ids.dart';
import 'package:mobile/core/widgets/badges.dart';
import 'package:mobile/core/widgets/segmented_controls.dart' as ui;
import 'package:mobile/data/db/app_database.dart';
import 'package:mobile/data/food/asset_food_repository.dart';
import 'package:mobile/domain/common/local_date.dart';
import 'package:mobile/domain/common/meal_slot.dart';
import 'package:mobile/domain/common/nutrition.dart';
import 'package:mobile/domain/log/food_log.dart';
import 'package:mobile/domain/profile/user_profile.dart';
import 'package:mobile/features/meal/controller/meal_controller.dart';
import 'package:mobile/features/onboarding/controller/onboarding_controller.dart';
import 'package:mobile/features/onboarding/view_model/onboarding_view_model.dart' as ovm;
import 'package:mobile/features/progress/controller/progress_controller.dart';
import 'package:mobile/features/reminders/controller/reminders_page.dart';
import 'package:mobile/features/settings/controller/settings_controller.dart';
import 'package:mobile/features/shopping/controller/shopping_page.dart';
import 'package:mobile/features/today/controller/today_controller.dart';
import 'package:mobile/services/notifications/reminder_service.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late NoopReminderService reminders;
  final today = LocalDate(2026, 10, 29);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    reminders = NoopReminderService();
  });
  tearDown(() => db.close());

  /// A fresh container on the same database, like restarting the app. No network anywhere.
  ProviderContainer app({int hour = 7}) => ProviderContainer(overrides: [
        appConfigProvider.overrideWithValue(const AppConfig(flavor: Flavor.dev)),
        databaseProvider.overrideWithValue(db),
        foodRepositoryProvider.overrideWithValue(
          AssetFoodRepository(() => File('assets/packs/pk-core.json').readAsString()),
        ),
        clockProvider.overrideWithValue(FixedClock(today.atMinutes(hour * 60))),
        idGeneratorProvider.overrideWithValue(SequentialIdGenerator('t${DateTime.now().microsecondsSinceEpoch}')),
        reminderServiceProvider.overrideWithValue(reminders),
      ]);

  Future<void> onboard(ProviderContainer c, {int birthYear = 1992, Set<String> conditions = const {}}) async {
    final p = onboardingControllerProvider(false);
    await c.read(p.future);
    final o = c.read(p.notifier);
    o.next(); // welcome → goal
    o.setGoal(ovm.WeightGoal.loseWeight);
    o.next();
    o.setSex(ovm.BiologicalSex.female);
    o.setHeight(162);
    o.setWeight(70);
    o.next();
    o.setActivity(ovm.ActivityLevel.lightlyActive);
    o.next();
    // Eligibility needs a birth year before continuing.
    o.next();
    expect(c.read(p).value!.errorMessage, isNotNull);
    o.setBirthYear(birthYear);
    for (final k in conditions) {
      o.toggleCondition(k);
    }
    o.next();
    o.next();
    o.setRichness(ui.OilLevel.normal);
    o.next();
    expect(c.read(p).value!.currentStep, ovm.OnboardingStep.targetSummary);
    await o.finish();
  }

  test('onboarding → plan → log → restart keeps everything, offline', () async {
    final c1 = app();
    await onboard(c1);
    final s1 = await c1.read(todayControllerProvider.future);
    expect(s1.needsOnboarding, isFalse);
    expect(s1.day!.plan, isNotNull);
    expect(s1.vm.meals, hasLength(4));
    expect(s1.vm.targetKcal, greaterThan(1000));
    expect(s1.vm.usesDraftData, isTrue, reason: 'dev builds label draft data');
    expect(s1.vm.nextMeal, isNotNull);
    expect((await c1.read(weightRepositoryProvider).all()).single.weightKg, 70);

    // Logging a planned meal is one action; doing it again never logs twice.
    final firstMeal = s1.vm.meals.first.id;
    final ids = await c1.read(todayControllerProvider.notifier).markMealEaten(firstMeal);
    expect(ids, isNotEmpty);
    expect(await c1.read(todayControllerProvider.notifier).markMealEaten(firstMeal), isEmpty);
    final afterLog = await c1.read(todayControllerProvider.future);
    expect(afterLog.vm.meals.first.status, MealStatus.eaten);
    expect(afterLog.vm.eatenKcal, greaterThan(0));
    c1.dispose();

    // Restart: same plan (same seed), same log.
    final c2 = app();
    final s2 = await c2.read(todayControllerProvider.future);
    expect(s2.day!.plan!.id, s1.day!.plan!.id);
    expect(s2.vm.meals.first.status, MealStatus.eaten);

    // Undo.
    await c2.read(todayControllerProvider.notifier).undo(ids);
    expect((await c2.read(todayControllerProvider.future)).vm.meals.first.status, MealStatus.planned);
    c2.dispose();
  });

  test('under-18 users get manual logging only, with an explanation and no target', () async {
    final c = app();
    await onboard(c, birthYear: today.year - 16);
    final setup = await c.read(userSetupProvider.future);
    expect(setup!.target, isNull);
    final s = await c.read(todayControllerProvider.future);
    expect(s.day!.plan, isNull);
    expect(s.vm.isManualOnly, isTrue);
    expect(s.vm.hasNoPlan, isFalse, reason: 'manual mode still shows the day so food can be logged');
    expect(s.vm.manualOnlyMessage, contains('18'));
    expect(s.vm.targetKcal, 0);
    c.dispose();
  });

  test('pregnancy routes to manual mode', () async {
    final c = app();
    await onboard(c, conditions: {'pregnant'});
    expect((await c.read(userSetupProvider.future))!.target, isNull);
    c.dispose();
  });

  test('turning vegetarian re-plans today at once; no meat remains', () async {
    final c = app();
    await onboard(c);
    await c.read(todayControllerProvider.future);
    await c.read(settingsControllerProvider.future);
    await c.read(settingsControllerProvider.notifier).setDietType(DietType.vegetarian);
    final s = await c.read(todayControllerProvider.future);
    final pack = s.day!.pack;
    for (final m in s.day!.plan!.meals) {
      for (final i in m.items) {
        final d = pack.food(i.foodId)!.dietary;
        expect(d.containsMeat || d.containsFish || d.containsEgg, isFalse, reason: i.foodId);
      }
    }
    expect((await c.read(settingsControllerProvider.future)).exclusionsSummary, contains('Vegetarian'));
    c.dispose();
  });

  test('meal edits: portion, oil, remove with undo, replace', () async {
    final c = app();
    await onboard(c);
    final s = await c.read(todayControllerProvider.future);
    final dinner = s.day!.plan!.meals.firstWhere((m) => m.slot == MealSlot.dinner);
    final key = MealKey(today, dinner.id);
    final p = mealControllerProvider(key);
    final before = (await c.read(p.future))!;
    final mc = c.read(p.notifier);

    await mc.setMainServings(before.vm.mainDishKatoriCount + 0.5);
    final bigger = (await c.read(p.future))!;
    expect(bigger.vm.totalCalories, greaterThan(before.vm.totalCalories));
    expect(bigger.meal.id, dinner.id, reason: 'editing keeps the meal');

    await mc.setOil(OilLevel.rich);
    final rich = (await c.read(p.future))!;
    expect(rich.vm.oilRichness, ui.OilLevel.rich);
    expect(rich.vm.totalCalories, greaterThanOrEqualTo(bigger.vm.totalCalories));

    final side = rich.vm.sideItems.first;
    final undo = await mc.removeItem(side.id);
    expect((await c.read(p.future))!.vm.sideItems.any((i) => i.id == side.id), isFalse);
    await mc.restore(undo!);
    expect((await c.read(p.future))!.vm.sideItems.any((i) => i.id == side.id), isTrue);

    expect(await mc.replace(), isTrue);
    expect((await c.read(p.future))!.meal.comboId, isNot(dinner.comboId));

    final logged = await mc.markEaten();
    expect(logged, isNotEmpty);
    expect((await c.read(p.future))!.vm.isEaten, isTrue);
    c.dispose();
  });

  test('shopping list comes from the plan and ticks survive recalculation', () async {
    final c = app();
    await onboard(c);
    final vm = await c.read(shoppingControllerProvider.future);
    expect(vm.items, isNotEmpty);
    expect(vm.items.any((i) => i.id == 'water'), isFalse);
    final first = vm.items.first;
    await c.read(shoppingControllerProvider.notifier).toggle(first.id);
    final again = await c.read(shoppingControllerProvider.future);
    expect(again.items.firstWhere((i) => i.id == first.id).isPurchased, isTrue);
    await c.read(shoppingControllerProvider.notifier).addManual('Soap');
    expect((await c.read(shoppingControllerProvider.future)).items.any((i) => i.name == 'Soap'), isTrue);
    c.dispose();
  });

  test('reminders: permission on enable, skip logged meals, denied keeps them off', () async {
    final c = app();
    await onboard(c);
    await c.read(remindersControllerProvider.future);
    await c.read(remindersControllerProvider.notifier).setEnabled(true);
    expect(reminders.scheduled, isNotEmpty);
    expect(reminders.scheduled.map((r) => r.id).toSet().length, reminders.scheduled.length, reason: 'no duplicates');
    final breakfastToday = reminders.scheduled.where((r) => r.date == today && r.slot == MealSlot.breakfast);
    expect(breakfastToday, isNotEmpty);

    final s = await c.read(todayControllerProvider.future);
    final breakfast = s.day!.plan!.meals.firstWhere((m) => m.slot == MealSlot.breakfast);
    await c.read(todayControllerProvider.notifier).markMealEaten(breakfast.id);
    await c.read(remindersControllerProvider.notifier).setSlot('dinner', true);
    expect(reminders.scheduled.where((r) => r.date == today && r.slot == MealSlot.breakfast), isEmpty);

    await c.read(remindersControllerProvider.notifier).setEnabled(false);
    expect(reminders.scheduled, isEmpty);

    reminders.permitted = false;
    await c.read(remindersControllerProvider.notifier).setEnabled(true);
    final vm = await c.read(remindersControllerProvider.future);
    expect(vm.enabled, isFalse);
    expect(vm.permissionDenied, isTrue);
    c.dispose();
  });

  test('three complete very-low days show the gentle check-in once', () async {
    final c = app();
    await onboard(c);
    final logs = c.read(foodLogRepositoryProvider);
    for (var d = 1; d <= 3; d++) {
      await logs.add([
        FoodLogEntry(
          id: 'low-$d',
          date: today.addDays(-d),
          slot: MealSlot.lunch,
          source: LogSource.quickAdd,
          label: 'Quick add',
          nutrition: const Nutrition(kcal: 500, protein: 0, carbs: 0, fat: 0, fibre: 0),
          loggedAtUtc: DateTime.utc(2026),
        ),
      ]);
    }
    expect((await c.read(todayControllerProvider.future)).showCheckIn, isTrue);
    await c.read(todayControllerProvider.notifier).dismissCheckIn();
    expect((await c.read(todayControllerProvider.future)).showCheckIn, isFalse);
    c.dispose();
  });

  test('progress shows missed days as not logged, never as 0 kcal', () async {
    final c = app();
    await onboard(c);
    final vm = await c.read(progressControllerProvider.future);
    expect(vm.weekEating, hasLength(7));
    expect(vm.weekEating.take(6).every((d) => d.status.name == 'notLogged'), isTrue);
    expect(vm.currentWeightKg, 70);
    await c.read(progressControllerProvider.notifier).addWeight(69.5);
    expect((await c.read(progressControllerProvider.future)).currentWeightKg, 69.5);
    c.dispose();
  });
}
