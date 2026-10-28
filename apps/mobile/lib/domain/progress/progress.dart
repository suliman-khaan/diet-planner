import '../common/local_date.dart';
import '../log/food_log.dart';

class WeightEntry {
  const WeightEntry(
      {required this.id, required this.date, required this.weightKg});

  final String id;
  final LocalDate date;
  final double weightKg;
}

class WeightTrend {
  const WeightTrend(
      {required this.points,
      required this.latest,
      required this.changeKg,
      required this.spanDays});

  /// Oldest first, one point per day (the last entry of that day).
  final List<WeightEntry> points;
  final WeightEntry? latest;

  /// Latest minus first in the range; null with fewer than two entries.
  final double? changeKg;
  final int spanDays;
}

WeightTrend weightTrend(
    List<WeightEntry> entries, LocalDate from, LocalDate to) {
  final inRange = entries.where((e) => e.date.isWithin(from, to)).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  final byDay = <LocalDate, WeightEntry>{for (final e in inRange) e.date: e};
  final points = byDay.values.toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  final latest = points.isEmpty ? null : points.last;
  return WeightTrend(
    points: points,
    latest: latest,
    changeKg:
        points.length < 2 ? null : points.last.weightKg - points.first.weightKg,
    spanDays:
        points.length < 2 ? 0 : points.last.date.daysSince(points.first.date),
  );
}

/// Very low logged intake on consecutive fully-logged days → gentle check-in with a help link
/// (blueprint §3 rule 6). Partly logged days are ignored because they undercount.
class LowIntakeCheck {
  const LowIntakeCheck({this.thresholdKcal = 800, this.consecutiveDays = 3});

  /// Placeholder pending nutritionist review, like the other safety values.
  final double thresholdKcal;
  final int consecutiveDays;

  /// [summaries] for past days only (today is still in progress).
  bool shouldCheckIn(List<DaySummary> summaries) {
    final sorted = [...summaries]..sort((a, b) => b.date.compareTo(a.date));
    var run = 0;
    for (final s in sorted) {
      if (s.status == DayLogStatus.complete &&
          s.eaten != null &&
          s.eaten!.kcal < thresholdKcal) {
        run++;
        if (run >= consecutiveDays) return true;
      } else {
        return false;
      }
    }
    return false;
  }
}
