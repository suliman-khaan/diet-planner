import 'package:flutter/foundation.dart';

@immutable
class ShoppingItemViewModel {
  final String id;
  final String name;
  final String amount; // e.g. "500 g", "1 dozen", "1 bottle"
  final String category; // e.g. "Produce", "Meat", "Pantry", "Dairy"
  final bool isPurchased;

  const ShoppingItemViewModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    this.isPurchased = false,
  });

  ShoppingItemViewModel copyWith({
    String? id,
    String? name,
    String? amount,
    String? category,
    bool? isPurchased,
  }) {
    return ShoppingItemViewModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}

@immutable
class ShoppingViewModel {
  final List<ShoppingItemViewModel> items;
  final bool isLoading;

  const ShoppingViewModel({
    this.items = const [],
    this.isLoading = false,
  });
}
