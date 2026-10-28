/// Meal slots. `snack` is a second light slot that uses the same foods as `chai`.
enum MealSlot {
  sehri,
  breakfast,
  lunch,
  chai,
  snack,
  iftar,
  dinner;

  /// The slot whose food list this slot draws from.
  MealSlot get foodSlot => this == MealSlot.snack ? MealSlot.chai : this;

  static MealSlot fromName(String name) =>
      MealSlot.values.firstWhere((s) => s.name == name,
          orElse: () => throw FormatException('Unknown meal slot: $name'));
}

/// Oil or ghee level used in cooking. Oil is the largest hidden calorie source in desi food.
enum OilLevel {
  light,
  normal,
  rich;

  static OilLevel fromName(String name) =>
      OilLevel.values.firstWhere((s) => s.name == name,
          orElse: () => throw FormatException('Unknown oil level: $name'));
}
