import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock/clock.dart';
import '../../core/ids/ids.dart';
import '../../domain/common/local_date.dart';
import '../../domain/food/food.dart';
import '../../domain/log/food_log.dart';
import '../../domain/plan/daily_plan.dart';
import '../../domain/plan/food_filter.dart';
import '../../domain/plan/planner.dart';
import '../../domain/plan/seeded_random.dart';
import '../../domain/profile/eligibility.dart';
import '../../domain/profile/user_profile.dart';
import '../../domain/repositories.dart';
import '../../services/analytics/analytics_service.dart';
import '../app_config.dart';
import 'providers.dart';

/// Everything a screen needs about one day.
class DayData {
  const DayData({
    required this.date,
    required this.today,
    required this.setup,
    required this.pack,
    required this.eligibility,
    required this.plan,
    required this.failure,
    required this.logs,
  });

  final LocalDate date;
  final LocalDate today;
  final UserSetup setup;
  final FoodPack pack;
  final Eligibility eligibility;
  final DailyPlan? plan;
  final PlanFailure? failure;
  final List<FoodLogEntry> logs;

  bool get isManualOnly => eligibility is ManualOnly;

  bool isMealLogged(PlannedMeal meal) =>
      meal.items.isNotEmpty && meal.items.every((i) => isPlanItemLogged(i.id, logs));
}

/// Plan lifecycle for a day: load, generate when missing, log, regenerate, edit.
/// Shared by the Today, Meal and Shopping controllers.
class DayService {
  DayService({
    required this.config,
    required this.clock,
    required this.ids,
    required this.planner,
    required this.eligibility,
    required this.profiles,
    required this.plans,
    required this.logs,
    required this.foods,
    required this.analytics,
  });

  final AppConfig config;
  final Clock clock;
  final IdGenerator ids;
  final Planner planner;
  final EligibilityChecker eligibility;
  final ProfileRepository profiles;
  final PlanRepository plans;
  final FoodLogRepository logs;
  final FoodRepository foods;
  final AnalyticsService analytics;

  LocalDate get today => LocalDate.fromDateTime(clock.nowLocal());

  /// Null when onboarding has not been completed.
  Future<DayData?> load(LocalDate date, {bool generateIfMissing = true}) async {
    final setup = await profiles.load();
    if (setup == null) return null;
    final pack = await foods.loadPack();
    final e = eligibility.check(setup.profile, today);
    var plan = await plans.planFor(date);
    PlanFailure? failure;
    // Plans are made for today and future days only; past days show what was logged.
    if (plan == null && generateIfMissing && setup.target != null && e is! ManualOnly && !date.isBefore(today)) {
      final result = planner.generate(await _request(date, setup, pack));
      switch (result) {
        case PlanSuccess(plan: final generated):
          final saved = await plans.savePlan(generated);
          analytics.log(AnalyticsEvent.planGenerated, {'source': 'auto', 'success': true});
          return _data(date, setup, pack, e, saved, null);
        case final PlanFailure f:
          failure = f;
          analytics.log(AnalyticsEvent.planGenerated, {'source': 'auto', 'success': false, 'reason': f.reason});
      }
    }
    return _data(date, setup, pack, e, plan, failure);
  }

  Future<DayData> _data(
    LocalDate date,
    UserSetup setup,
    FoodPack pack,
    Eligibility e,
    DailyPlan? plan,
    PlanFailure? failure,
  ) async =>
      DayData(
        date: date,
        today: today,
        setup: setup,
        pack: pack,
        eligibility: e,
        plan: plan,
        failure: failure,
        logs: await logs.entriesFor(date),
      );

  /// A new whole-day plan. Meals already eaten keep their log entries (snapshots).
  Future<PlanResult> regenerateDay(DayData day) async {
    final seed = ((day.plan?.seed ?? _baseSeed(day.date)) + 1) & 0x7FFFFFFF;
    final result = planner.generate(await _request(day.date, day.setup, day.pack, seed: seed));
    if (result is PlanSuccess) {
      await plans.savePlan(result.plan);
      analytics.log(AnalyticsEvent.planGenerated, {'source': 'regenerate', 'success': true});
    }
    return result;
  }

  /// Replaces one meal with a different option of similar size. Eaten meals are never touched.
  Future<PlannedMeal?> regenerateMeal(DayData day, PlannedMeal meal, {required int attempt}) async {
    final plan = day.plan;
    if (plan == null || day.isMealLogged(meal)) return null;
    final request = await _request(day.date, day.setup, day.pack, seed: plan.seed);
    final slot = SlotTime(meal.slot, meal.minutesOfDay);
    final others = Planner.mainDishesIn(day.pack, [plan.copyWith(meals: plan.meals.where((m) => m.id != meal.id).toList())]);
    final replacement = planner.regenerateMeal(
      request,
      slot,
      meal.nutrition.kcal,
      attempt: attempt,
      avoidComboIds: {if (meal.comboId != null) meal.comboId!},
      otherMainFoodIds: others,
    );
    if (replacement == null) return null;
    analytics.log(AnalyticsEvent.itemReplaced, {'slot': meal.slot});
    return plans.saveMeal(plan.id, replacement.copyWith(id: meal.id));
  }

  Future<PlannedMeal> saveMeal(DailyPlan plan, PlannedMeal meal) => plans.saveMeal(plan.id, meal);

  /// Logs every not-yet-logged item of [meal]. Returns the new entry ids (for undo).
  /// Tapping twice never logs twice.
  Future<List<String>> markEaten(DayData day, PlannedMeal meal) async {
    final pending = meal.items.where((i) => !isPlanItemLogged(i.id, day.logs)).toList();
    if (pending.isEmpty) return const [];
    final entries = logEntriesForMeal(
      meal: meal.copyWith(items: pending),
      date: day.date,
      pack: day.pack,
      nowUtc: clock.nowUtc(),
      newId: ids.newId,
    );
    await logs.add(entries);
    analytics.log(AnalyticsEvent.mealLogged, {'source': 'planned', 'slot': meal.slot});
    if (meal.items.any((i) => i.fromSharedDish)) analytics.log(AnalyticsEvent.familyPotUsed);
    return [for (final e in entries) e.id];
  }

  Future<void> undoLog(List<String> entryIds) => logs.remove(entryIds);

  /// Stable per date, so reopening the app shows the same plan.
  static int _baseSeed(LocalDate date) => SeededRandom.hashString(date.toIso()) & 0x7FFFFFFF;

  Future<PlanRequest> _request(LocalDate date, UserSetup setup, FoodPack pack, {int? seed}) async {
    final recentPlans = await plans.plansBetween(date.addDays(-3), date.addDays(-1));
    return PlanRequest(
      date: date,
      target: setup.target!,
      pack: pack,
      slots: setup.schedule.slotsFor(date),
      filter: FoodFilter(preferences: setup.preferences, allowDraftData: config.allowDraftData),
      oilLevel: setup.profile.cookingRichness,
      seed: seed ?? _baseSeed(date),
      policyVersion: setup.policyVersion,
      recentFoodIds: Planner.mainDishesIn(pack, recentPlans),
    );
  }
}

final dayServiceProvider = Provider<DayService>((ref) => DayService(
      config: ref.watch(appConfigProvider),
      clock: ref.watch(clockProvider),
      ids: ref.watch(idGeneratorProvider),
      planner: ref.watch(plannerProvider),
      eligibility: ref.watch(eligibilityCheckerProvider),
      profiles: ref.watch(profileRepositoryProvider),
      plans: ref.watch(planRepositoryProvider),
      logs: ref.watch(foodLogRepositoryProvider),
      foods: ref.watch(foodRepositoryProvider),
      analytics: ref.watch(analyticsServiceProvider),
    ));
