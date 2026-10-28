import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../log/controller/log_food_flow.dart';
import '../../transparency/ui/transparency_screen.dart';
import '../ui/today_screen.dart';
import '../view_model/today_view_model.dart';
import 'today_controller.dart';

class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  bool _checkInShown = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(todayControllerProvider);
    final controller = ref.read(todayControllerProvider.notifier);

    ref.listen(todayControllerProvider, (_, next) {
      final s = next.valueOrNull;
      if (s != null && s.showCheckIn && !_checkInShown) {
        _checkInShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _showCheckIn());
      }
      if (s != null && s.needsOnboarding) context.go(AppRoutes.onboarding);
    });

    return async.when(
      loading: () => const TodayScreen(vm: TodayViewModel(dateDisplay: '', isLoading: true)),
      error: (e, _) => ErrorStateWidget(
        message: 'Today\'s plan could not be loaded. Your saved data is safe.',
        onRetry: controller.reload,
      ),
      data: (state) => TodayScreen(
        vm: state.vm,
        onInfoTap: () => context.push(AppRoutes.transparency),
        onMarkNextMealEaten: () {
          final id = state.vm.nextMeal?.id;
          if (id != null) _markEaten(id, state.vm);
        },
        onChangeNextMeal: () {
          final id = state.vm.nextMeal?.id;
          if (id != null) _openMeal(id);
        },
        onMealRowTap: (id) {
          if (!id.startsWith('log:')) _openMeal(id);
        },
        onMealLogTap: (id) {
          if (!id.startsWith('log:')) _markEaten(id, state.vm);
        },
        onRetry: controller.reload,
        onGeneratePlan: () async {
          final ok = await controller.regeneratePlan();
          if (!ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No safe plan could be made with your choices. You can still log food.')),
            );
          }
        },
        onPreviousDay: () => controller.goToDay(-1),
        onNextDay: () => controller.goToDay(1),
        onAddFood: () async {
          await LogFoodFlow.start(context, ref, date: state.day?.date);
          await controller.reload();
        },
      ),
    );
  }

  void _openMeal(String mealId) {
    final date = ref.read(todayControllerProvider).valueOrNull?.day?.date;
    context.push('${AppRoutes.mealDetailPath(mealId)}?date=${date?.toIso() ?? ''}');
  }

  Future<void> _markEaten(String mealId, TodayViewModel vm) async {
    final controller = ref.read(todayControllerProvider.notifier);
    final ids = await controller.markMealEaten(mealId);
    if (!mounted || ids.isEmpty) return;
    final slot = vm.meals.where((m) => m.id == mealId).firstOrNull?.slotTitle ?? 'Meal';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('$slot logged'),
        action: SnackBarAction(label: 'Undo', onPressed: () => controller.undo(ids)),
      ));
  }

  Future<void> _showCheckIn() async {
    if (!mounted) return;
    final controller = ref.read(todayControllerProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GentleCheckInSheet(
        onDismiss: () => Navigator.of(ctx).pop(),
        onAdjustGoals: () {
          Navigator.of(ctx).pop();
          context.push(AppRoutes.transparency);
        },
      ),
    );
    await controller.dismissCheckIn();
  }
}
