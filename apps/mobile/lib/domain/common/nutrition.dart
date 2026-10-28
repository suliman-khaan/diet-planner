/// Energy and macronutrients. Canonical units: kcal and grams.
class Nutrition {
  const Nutrition({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fibre,
  });

  static const Nutrition zero =
      Nutrition(kcal: 0, protein: 0, carbs: 0, fat: 0, fibre: 0);

  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final double fibre;

  Nutrition operator +(Nutrition other) => Nutrition(
        kcal: kcal + other.kcal,
        protein: protein + other.protein,
        carbs: carbs + other.carbs,
        fat: fat + other.fat,
        fibre: fibre + other.fibre,
      );

  Nutrition scale(double factor) => Nutrition(
        kcal: kcal * factor,
        protein: protein * factor,
        carbs: carbs * factor,
        fat: fat * factor,
        fibre: fibre * factor,
      );

  /// Nutrition of [grams] of something whose values are given per 100 g.
  Nutrition forGrams(double grams) => scale(grams / 100);

  static Nutrition sum(Iterable<Nutrition> values) =>
      values.fold(Nutrition.zero, (a, b) => a + b);

  Map<String, double> toJson() => {
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fibre': fibre,
      };

  factory Nutrition.fromJson(Map<String, Object?> json) => Nutrition(
        kcal: _num(json['kcal']),
        protein: _num(json['protein']),
        carbs: _num(json['carbs']),
        fat: _num(json['fat']),
        fibre: _num(json['fibre']),
      );

  static double _num(Object? v) {
    if (v is num && v.isFinite && v >= 0) return v.toDouble();
    throw FormatException('Invalid nutrient value: $v');
  }

  @override
  bool operator ==(Object other) =>
      other is Nutrition &&
      other.kcal == kcal &&
      other.protein == protein &&
      other.carbs == carbs &&
      other.fat == fat &&
      other.fibre == fibre;

  @override
  int get hashCode => Object.hash(kcal, protein, carbs, fat, fibre);

  @override
  String toString() =>
      'Nutrition(${kcal.toStringAsFixed(1)} kcal, P${protein.toStringAsFixed(1)} '
      'C${carbs.toStringAsFixed(1)} F${fat.toStringAsFixed(1)} Fb${fibre.toStringAsFixed(1)})';
}
