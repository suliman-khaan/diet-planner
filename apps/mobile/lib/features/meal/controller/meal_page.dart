import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/formatters.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../domain/common/local_date.dart';
import '../../log/controller/log_food_flow.dart';
import '../../today/controller/today_controller.dart';
import '../ui/meal_detail_screen.dart';
import 'meal_controller.dart';

class MealPage extends ConsumerWidget {
  const MealPage({super.key, required this.date, required this.mealId});

  final LocalDate date;
  final String mealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = MealKey(date, mealId);
    final async = ref.watch(mealControllerProvider(key));
    final controller = ref.read(mealControllerProvider(key).notifier);

    void refreshToday() => ref.invalidate(todayControllerProvider);
    void snack(String text, {SnackBarAction? action}) =>
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(text), action: action));

    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: ErrorStateWidget(
          message: 'This meal could not be loaded.',
          onRetry: () => ref.invalidate(mealControllerProvider(key)),
        ),
      ),
      data: (state) {
        if (state == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyStateWidget(
              icon: Icons.restaurant_outlined,
              title: 'Meal not found',
              message:
                  'This meal is no longer in the plan. It may have been replaced.',
            ),
          );
        }
        return MealDetailScreen(
          vm: state.vm,
          onBack: () => Navigator.of(context).maybePop(),
          onKatoriCountChanged: (v) async {
            await controller.setMainServings(v);
            refreshToday();
          },
          onOilLevelChanged: (level) async {
            await controller.setOil(Fmt.fromUiOil(level));
            refreshToday();
          },
          onSideCountChanged: (id, v) async {
            await controller.setItemServings(id, v);
            refreshToday();
          },
          onRemoveSideItem: (id) async {
            final before = await controller.removeItem(id);
            refreshToday();
            if (before != null && context.mounted) {
              snack('Removed from ${state.vm.slotTitle.toLowerCase()}',
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () async {
                      await controller.restore(before);
                      refreshToday();
                    },
                  ));
            }
          },
          onAddFood: () async {
            final foodId = await LogFoodFlow.pickFood(context);
            if (foodId == null) return;
            await controller.addFood(foodId);
            refreshToday();
          },
          onReplaceDish: () async {
            final ok = await controller.replace();
            refreshToday();
            if (context.mounted) {
              snack(ok
                  ? 'Here is another option'
                  : 'No other option fits your choices for this meal');
            }
          },
          onToggleEaten: () async {
            final ids = await controller.markEaten();
            refreshToday();
            if (ids.isNotEmpty && context.mounted) {
              snack('${state.vm.slotTitle} logged',
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () async {
                      await controller.undoEaten(ids);
                      refreshToday();
                    },
                  ));
            }
          },
        );
      },
    );
  }
}
