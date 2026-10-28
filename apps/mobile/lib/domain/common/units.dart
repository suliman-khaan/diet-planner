/// Unit conversion for display only. Storage and logic always use kg, cm, g, ml and kcal.
abstract final class Units {
  static const double poundsPerKg = 2.2046226218;
  static const double cmPerInch = 2.54;
  static const double kjPerKcal = 4.184;

  static double kgToLb(double kg) => kg * poundsPerKg;
  static double lbToKg(double lb) => lb / poundsPerKg;

  /// Returns (feet, inches) rounded to the nearest inch.
  static (int, int) cmToFeetInches(double cm) {
    final totalInches = (cm / cmPerInch).round();
    return (totalInches ~/ 12, totalInches % 12);
  }

  static double feetInchesToCm(int feet, int inches) =>
      (feet * 12 + inches) * cmPerInch;

  static double kcalToKj(double kcal) => kcal * kjPerKcal;

  /// "250 g" below a kilogram, "1.2 kg" above.
  static String formatGrams(double grams) {
    if (grams >= 1000) {
      final kg = grams / 1000;
      return '${kg.toStringAsFixed(kg >= 10 ? 0 : 1)} kg';
    }
    return '${_roundTo(grams, grams >= 100 ? 10 : 5).toStringAsFixed(0)} g';
  }

  /// "250 ml" below a litre, "1.5 L" above.
  static String formatMillilitres(double ml) {
    if (ml >= 1000) return '${(ml / 1000).toStringAsFixed(1)} L';
    return '${_roundTo(ml, ml >= 100 ? 10 : 5).toStringAsFixed(0)} ml';
  }

  static double _roundTo(double v, int step) {
    final r = (v / step).round() * step;
    return r == 0 && v > 0 ? step.toDouble() : r.toDouble();
  }
}
