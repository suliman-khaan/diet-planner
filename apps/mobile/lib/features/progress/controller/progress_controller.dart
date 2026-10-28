import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers/providers.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../domain/common/local_date.dart';
import '../../../domain/log/food_log.dart';
import '../../../domain/progress/progress.dart';
import '../ui/add_weight_sheet.dart';
import '../ui/progress_screen.dart';
import '../view_model/progress_view_model.dart';

final progressMonthViewProvider = StateProvider<bool>((ref) => true);

class ProgressController extends AsyncNotifier<ProgressViewModel> {
  @override
  Future<ProgressViewModel> build() async {
    final isMonth = ref.watch(progressMonthViewProvider);
    final today = ref.watch(todayProvider);
    final setup = await ref.watch(userSetupProvider.future);
    final weights = await ref.read(weightRepositoryProvider).all();
    final from = today.addDays(isMonth ? -28 : -6);
    final trend = weightTrend(weights, from, today);
    final latest = weights.isEmpty ? null : weights.last;

    // Eating: the last 7 days including today.
    final weekFrom = today.addDays(-6);
    final logs = await ref.read(foodLogRepositoryProvider).entriesBetween(weekFrom, today);
    final plans = {for (final p in await ref.read(planRepositoryProvider).plansBetween(weekFrom, today)) p.date: p};
    final target = setup?.target?.kcal ?? 0;
    final dayLetter = DateFormat('E');
    final bars = <DayEatingBarViewModel>[];
    var logged = 0;
    var proteinSum = 0.0;
    for (var d = weekFrom; !d.isAfter(today); d = d.addDays(1)) {
      final s = summarizeDay(d, plans[d], logs);
      if (s.status != DayLogStatus.notLogged) {
        logged++;
        proteinSum += s.eaten!.protein;
      }
      final kcal = s.eaten?.kcal ?? 0;
      bars.add(DayEatingBarViewModel(
        dayLabel: dayLetter.format(d.atMinutes(0)).substring(0, 1),
        // A missed day is drawn as an empty outline, never as 0 kcal.
        percentageOfTarget: s.status == DayLogStatus.notLogged ? 1.0 : (target > 0 ? (kcal / target).clamp(0.05, 1.2) : 0.5),
        calories: kcal.round(),
        status: switch (s.status) {
          DayLogStatus.complete => EatingLogStatus.fullyLogged,
          DayLogStatus.partial => EatingLogStatus.partlyLogged,
          DayLogStatus.notLogged => EatingLogStatus.notLogged,
        },
      ));
    }

    final change = trend.changeKg;
    final label = DateFormat('d MMM');
    return ProgressViewModel(
      currentWeightKg: latest?.weightKg ?? setup?.profile.weightKg ?? 0,
      weightChangeSubtitle: change == null
          ? 'Add your weight regularly to see a trend'
          : change.abs() < 0.05
              ? 'Steady over ${trend.spanDays} days'
              : '${change.abs().toStringAsFixed(1)} kg ${change < 0 ? 'down' : 'up'} in ${trend.spanDays} days',
      weightTrend: [
        for (final p in trend.points)
          WeightPointViewModel(date: p.date.atMinutes(0), dateLabel: label.format(p.date.atMinutes(0)), weightKg: p.weightKg),
      ],
      weekEating: bars,
      daysLoggedThisWeek: logged,
      totalDaysInPeriod: 7,
      averageProteinGrams: logged == 0 ? 0 : (proteinSum / logged).round(),
      isMonthView: isMonth,
    );
  }

  Future<void> addWeight(double kg) async {
    await ref.read(weightRepositoryProvider).add(ref.read(todayProvider), kg);
    ref.invalidateSelf();
    await future;
  }
}

final progressControllerProvider = AsyncNotifierProvider<ProgressController, ProgressViewModel>(ProgressController.new);

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(progressControllerProvider);
    return async.when(
      loading: () => const ProgressScreen(vm: ProgressViewModel(isLoading: true)),
      error: (_, __) => ErrorStateWidget(
        message: 'Progress could not be loaded. Your saved data is safe.',
        onRetry: () => ref.invalidate(progressControllerProvider),
      ),
      data: (vm) => ProgressScreen(
        vm: vm,
        onRangeToggled: (isMonth) => ref.read(progressMonthViewProvider.notifier).state = isMonth,
        onAddWeightTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddWeightSheet(
            onWeightSaved: (kg) {
              if (kg >= 30 && kg <= 250) ref.read(progressControllerProvider.notifier).addWeight(kg);
            },
          ),
        ),
      ),
    );
  }
}

/// History: past days with what was logged (snapshots), newest first.
class HistoryController extends AsyncNotifier<List<HistoryDay>> {
  @override
  Future<List<HistoryDay>> build() async {
    final today = ref.watch(todayProvider);
    final from = today.addDays(-30);
    final to = today.addDays(-1);
    final logs = await ref.read(foodLogRepositoryProvider).entriesBetween(from, to);
    final plans = {for (final p in await ref.read(planRepositoryProvider).plansBetween(from, to)) p.date: p};
    final setup = await ref.watch(userSetupProvider.future);
    final days = <HistoryDay>[];
    for (var d = to; !d.isBefore(from); d = d.addDays(-1)) {
      final s = summarizeDay(d, plans[d], logs);
      if (s.status == DayLogStatus.notLogged) continue;
      final dayLogs = logs.where((l) => l.date == d).toList()
        ..sort((a, b) => b.nutrition.kcal.compareTo(a.nutrition.kcal));
      days.add(HistoryDay(
        date: d,
        summary: s,
        targetKcal: plans[d]?.targetKcal ?? setup?.target?.kcal ?? 0,
        topDishes: dayLogs.map((l) => l.label).toSet().take(3).toList(),
      ));
    }
    return days;
  }
}

class HistoryDay {
  const HistoryDay({required this.date, required this.summary, required this.targetKcal, required this.topDishes});

  final LocalDate date;
  final DaySummary summary;
  final double targetKcal;
  final List<String> topDishes;
}

final historyControllerProvider = AsyncNotifierProvider<HistoryController, List<HistoryDay>>(HistoryController.new);
