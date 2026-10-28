import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/formatters.dart';
import '../../../app/routes.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../progress/controller/progress_controller.dart';
import '../../today/controller/today_controller.dart';
import '../ui/history_screen.dart';
import '../view_model/history_view_model.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(historyControllerProvider);
    return async.when(
      loading: () => const HistoryScreen(vm: HistoryViewModel(isLoading: true)),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: ErrorStateWidget(
          message: 'History could not be loaded. Your saved data is safe.',
          onRetry: () => ref.invalidate(historyControllerProvider),
        ),
      ),
      data: (days) {
        final byTitle = {for (final d in days) Fmt.date(d.date): d.date};
        return HistoryScreen(
          vm: HistoryViewModel(pastDays: [
            for (final d in days)
              PastDayLogSnapshotViewModel(
                dateTitle: Fmt.date(d.date),
                totalCalories: d.summary.eaten!.kcal.round(),
                targetCalories: d.targetKcal.round(),
                mealsLogged: d.summary.mealsLogged,
                totalMeals: d.summary.mealsPlanned,
                proteinGrams: d.summary.eaten!.protein.round(),
                carbsGrams: d.summary.eaten!.carbs.round(),
                fatGrams: d.summary.eaten!.fat.round(),
                topDishes: d.topDishes,
              ),
          ]),
          onDaySelected: (day) {
            final date = byTitle[day.dateTitle];
            if (date == null) return;
            ref.read(todayControllerProvider.notifier).goToDate(date);
            context.go(AppRoutes.today);
          },
        );
      },
    );
  }
}
