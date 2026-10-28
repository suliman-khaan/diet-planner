import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/day_service.dart';
import '../../../app/providers/providers.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../domain/common/local_date.dart';
import '../../../domain/common/units.dart';
import '../../../domain/shopping/shopping.dart';
import '../ui/shopping_screen.dart';
import '../view_model/shopping_view_model.dart';

const _manualPrefix = 'manual:';

String _categoryLabel(String c) => switch (c) {
      'vegetable' || 'fruit' => 'Fruit & vegetables',
      'meat' || 'fish' || 'egg' => 'Meat, fish & eggs',
      'dairy' => 'Dairy',
      'bakery' => 'Bakery (ready-made)',
      'grain' || 'legume' => 'Flour, rice & daal',
      'fat' => 'Oil & ghee',
      _ => 'Other',
    };

/// Today's shopping list: raw ingredients for the user's planned portions. Purchased ticks
/// are stored per line and survive recalculation.
class ShoppingController extends AsyncNotifier<ShoppingViewModel> {
  late LocalDate _date;

  @override
  Future<ShoppingViewModel> build() async {
    _date = ref.watch(todayProvider);
    final day = await ref.watch(dayServiceProvider).load(_date);
    final repo = ref.read(shoppingRepositoryProvider);
    final purchased = await repo.purchasedKeys(_date);
    final lines = day?.plan == null
        ? const <ShoppingLine>[]
        : shoppingLinesFor(day!.pack, day.plan!.meals);
    final manual = await repo.manualItems(_date);
    return ShoppingViewModel(items: [
      for (final l in lines)
        ShoppingItemViewModel(
          id: l.ingredientId,
          name: l.name,
          amount: l.unit == ShoppingUnit.millilitres
              ? Units.formatMillilitres(l.amount)
              : Units.formatGrams(l.amount),
          category: _categoryLabel(l.category),
          isPurchased: purchased.contains(l.ingredientId),
        ),
      for (final m in manual)
        ShoppingItemViewModel(
          id: '$_manualPrefix${m.id}',
          name: m.name,
          amount: 'Added by you',
          category: 'Your items',
          isPurchased: m.purchased,
        ),
    ]);
  }

  Future<void> toggle(String id) async {
    final item = state.valueOrNull?.items.where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    final repo = ref.read(shoppingRepositoryProvider);
    if (id.startsWith(_manualPrefix)) {
      await repo.setManualPurchased(
          id.substring(_manualPrefix.length), !item.isPurchased);
    } else {
      await repo.setPurchased(_date, id, !item.isPurchased);
    }
    ref.invalidateSelf();
  }

  Future<void> addManual(String name) async {
    if (name.trim().isEmpty) return;
    await ref
        .read(shoppingRepositoryProvider)
        .addManualItem(_date, name.trim());
    ref.invalidateSelf();
  }

  /// Removes ticked items you added; ticked plan ingredients stay ticked.
  Future<void> clearChecked() async {
    final repo = ref.read(shoppingRepositoryProvider);
    for (final i
        in state.valueOrNull?.items ?? const <ShoppingItemViewModel>[]) {
      if (i.isPurchased && i.id.startsWith(_manualPrefix))
        await repo.removeManualItem(i.id.substring(_manualPrefix.length));
    }
    ref.invalidateSelf();
  }
}

final shoppingControllerProvider =
    AsyncNotifierProvider<ShoppingController, ShoppingViewModel>(
        ShoppingController.new);

class ShoppingPage extends ConsumerWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(shoppingControllerProvider);
    final controller = ref.read(shoppingControllerProvider.notifier);
    const note = 'Raw ingredients for your own portions in today\'s plan. '
        'For the family pot, buy for everyone who eats it.';
    return async.when(
      loading: () =>
          const ShoppingScreen(vm: ShoppingViewModel(isLoading: true)),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Shopping List')),
        body: ErrorStateWidget(
          message: 'The shopping list could not be made.',
          onRetry: () => ref.invalidate(shoppingControllerProvider),
        ),
      ),
      data: (vm) => ShoppingScreen(
        vm: vm,
        note: note,
        onItemToggled: controller.toggle,
        onClearCompleted: controller.clearChecked,
        onAddItem: () async {
          final name = await _askName(context);
          if (name != null) await controller.addManual(name);
        },
      ),
    );
  }

  Future<String?> _askName(BuildContext context) {
    final text = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add item'),
        content: TextField(
          controller: text,
          autofocus: true,
          maxLength: 60,
          decoration: const InputDecoration(labelText: 'Item name'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(text.text),
              child: const Text('Add')),
        ],
      ),
    );
  }
}
