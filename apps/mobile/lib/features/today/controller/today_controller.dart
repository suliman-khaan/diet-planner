import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/day_service.dart';
import '../../../app/providers/formatters.dart';
import '../../../app/providers/providers.dart';
import '../../../core/widgets/badges.dart';
import '../../../domain/common/local_date.dart';
import '../../../domain/common/nutrition.dart';
import '../../../domain/log/food_log.dart';
import '../../../domain/plan/daily_plan.dart';
import '../../../domain/plan/planner.dart';
import '../../../domain/profile/eligibility.dart';
import '../view_model/today_view_model.dart';

/// The day shown on Today. Null means "today".
final selectedDateProvider = StateProvider<LocalDate?>((ref) => null);

class TodayState {
  const TodayState({required this.vm, this.day, this.needsOnboarding = false, this.showCheckIn = false});

  final TodayViewModel vm;
  final DayData? day;
  final bool needsOnboarding;

  /// Very low logged intake for several complete days: show the gentle check-in once a day.
  final bool showCheckIn;
}

class TodayController extends AsyncNotifier<TodayState> {
  @override
  Future<TodayState> build() async {
    final service = ref.watch(dayServiceProvider);
    final date = ref.watch(selectedDateProvider) ?? service.today;
    final day = await service.load(date);
    if (day == null) {
      return TodayState(vm: TodayViewModel(dateDisplay: Fmt.date(date)), needsOnboarding: true);
    }
    return TodayState(vm: mapToday(day), day: day, showCheckIn: await _shouldCheckIn(day));
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  void goToDay(int delta) {
    final current = state.valueOrNull?.day?.date ?? ref.read(dayServiceProvider).today;
    ref.read(selectedDateProvider.notifier).state = current.addDays(delta);
  }

  void goToDate(LocalDate date) => ref.read(selectedDateProvider.notifier).state = date;

  /// Logs a planned meal. Returns entry ids for undo; empty if it was already logged.
  Future<List<String>> markMealEaten(String mealId) async {
    final day = state.valueOrNull?.day;
    final meal = day?.plan?.meals.where((m) => m.id == mealId).firstOrNull;
    if (day == null || meal == null) return const [];
    final ids = await ref.read(dayServiceProvider).markEaten(day, meal);
    await reload();
    return ids;
  }

  Future<void> undo(List<String> entryIds) async {
    await ref.read(dayServiceProvider).undoLog(entryIds);
    await reload();
  }

  Future<bool> regeneratePlan() async {
    final day = state.valueOrNull?.day;
    if (day == null) return false;
    final service = ref.read(dayServiceProvider);
    final bool ok;
    if (day.plan == null) {
      ok = (await service.load(day.date))?.plan != null;
    } else {
      ok = await service.regenerateDay(day) is PlanSuccess;
    }
    await reload();
    return ok;
  }

  Future<void> dismissCheckIn() async {
    final repo = ref.read(settingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(lowIntakeCheckDismissedOn: ref.read(dayServiceProvider).today));
    ref.invalidate(appSettingsProvider);
    await reload();
  }

  Future<bool> _shouldCheckIn(DayData day) async {
    if (day.date != day.today) return false;
    final settings = await ref.read(settingsRepositoryProvider).load();
    if (settings.lowIntakeCheckDismissedOn == day.today) return false;
    final from = day.today.addDays(-7);
    final to = day.today.addDays(-1);
    final logs = await ref.read(foodLogRepositoryProvider).entriesBetween(from, to);
    final plans = {for (final p in await ref.read(planRepositoryProvider).plansBetween(from, to)) p.date: p};
    final summaries = [
      for (var d = from; !d.isAfter(to); d = d.addDays(1)) summarizeDay(d, plans[d], logs),
    ];
    return ref.read(lowIntakeCheckProvider).shouldCheckIn(summaries);
  }
}

final todayControllerProvider = AsyncNotifierProvider<TodayController, TodayState>(TodayController.new);

/// Maps a day to what the Today screen shows.
TodayViewModel mapToday(DayData day) {
  final plan = day.plan;
  final pack = day.pack;
  final target = day.setup.target;
  final manual = day.eligibility is ManualOnly;
  final eaten = Nutrition.sum(day.logs.map((l) => l.nutrition));
  final isPast = day.date.isBefore(day.today);

  final meals = <TodayMealItemViewModel>[];
  PlannedMeal? next;
  var stillPlanned = 0.0;
  for (final m in plan?.meals ?? const <PlannedMeal>[]) {
    final logged = day.isMealLogged(m);
    if (!logged) {
      stillPlanned += m.nutrition.kcal;
      if (!isPast && day.date == day.today) next ??= m;
    }
    meals.add(TodayMealItemViewModel(
      id: m.id,
      slotTitle: Fmt.slot(m.slot),
      time: Fmt.time(m.minutesOfDay),
      status: logged ? MealStatus.eaten : (isPast ? MealStatus.notLogged : MealStatus.planned),
      summaryText: m.items.map((i) => pack.food(i.foodId)?.nameEn ?? i.foodId).join(', '),
      calories: m.nutrition.kcal.round(),
    ));
  }
  // Food logged outside the plan (manual or quick-add).
  for (final l in day.logs.where((l) => l.planItemId == null)) {
    meals.add(TodayMealItemViewModel(
      id: 'log:${l.id}',
      slotTitle: Fmt.slot(l.slot),
      time: 'Logged',
      status: MealStatus.eaten,
      summaryText: l.label,
      calories: l.nutrition.kcal.round(),
    ));
  }

  NextMealViewModel? nextVm;
  if (next != null) {
    final items = next.items;
    final mainItem = items.where((i) => pack.food(i.foodId)?.role == 'main').firstOrNull ?? items.firstOrNull;
    if (mainItem != null) {
      final mainFood = pack.food(mainItem.foodId)!;
      nextVm = NextMealViewModel(
        id: next.id,
        slotLabel: 'Next · ${Fmt.slot(next.slot)} · ${Fmt.time(next.minutesOfDay)}',
        estimatedCalories: next.nutrition.kcal.round(),
        mainDishTitle: Fmt.itemTitle(mainFood, mainItem),
        familyPotDetail: mainItem.fromSharedDish
            ? 'From the family pot · ${Fmt.oil(mainItem.oilLevel)}'
            : (mainItem.oilLevel == null ? 'Estimate' : 'Cooked with ${Fmt.oil(mainItem.oilLevel)}'),
        sidesDetail: [
          for (final i in items)
            if (!identical(i, mainItem)) Fmt.itemTitle(pack.food(i.foodId)!, i),
        ].join(' · '),
      );
    }
  }

  final schedule = day.setup.schedule;
  return TodayViewModel(
    dateDisplay: Fmt.date(day.date),
    title: Fmt.dayTitle(day.date, day.today),
    usesDraftData: plan?.usesDraftData ?? false,
    manualOnlyMessage: day.eligibility is ManualOnly ? Fmt.manualOnly(day.eligibility as ManualOnly) : null,
    isRamadanMode: schedule.isRamadan(day.date),
    ramadanDay: schedule.ramadanDay(day.date),
    isManualOnly: manual,
    eatenKcal: eaten.kcal.round(),
    plannedKcal: stillPlanned.round(),
    targetKcal: manual ? 0 : (plan?.targetKcal ?? target?.kcal ?? 0).round(),
    proteinCurrent: eaten.protein.round(),
    proteinTarget: manual ? 0 : (target?.proteinG ?? 0).round(),
    carbsCurrent: eaten.carbs.round(),
    carbsTarget: manual ? 0 : (target?.carbsG ?? 0).round(),
    fatCurrent: eaten.fat.round(),
    fatTarget: manual ? 0 : (target?.fatG ?? 0).round(),
    fibreCurrent: eaten.fibre.round(),
    fibreTarget: manual ? 0 : (target?.fibreG ?? 0).round(),
    nextMeal: nextVm,
    meals: meals,
    hasNoPlan: plan == null && !manual && !isPast,
    noPlanReason: day.failure == null ? null : Fmt.noPlanReason(day.failure!),
  );
}
