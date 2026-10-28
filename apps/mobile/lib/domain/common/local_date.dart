/// A calendar date with no time or timezone, e.g. 2026-10-20.
///
/// Plans and logs are keyed by the user's local date so an 11 pm dinner stays on the right day.
class LocalDate implements Comparable<LocalDate> {
  LocalDate(this.year, this.month, this.day) {
    final check = DateTime.utc(year, month, day);
    if (check.year != year || check.month != month || check.day != day) {
      throw ArgumentError('Invalid date $year-$month-$day');
    }
  }

  factory LocalDate.fromDateTime(DateTime dt) => LocalDate(dt.year, dt.month, dt.day);

  /// Parses `yyyy-mm-dd`.
  factory LocalDate.parse(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) throw FormatException('Invalid date: $iso');
    return LocalDate(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  final int year;
  final int month;
  final int day;

  DateTime get _utc => DateTime.utc(year, month, day);

  LocalDate addDays(int days) => LocalDate.fromDateTime(_utc.add(Duration(days: days)));

  int daysSince(LocalDate other) => _utc.difference(other._utc).inDays;

  /// 1 = Monday … 7 = Sunday.
  int get weekday => _utc.weekday;

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  /// Inclusive range check.
  bool isWithin(LocalDate start, LocalDate end) => !isBefore(start) && !isAfter(end);

  /// Local wall-clock time on this date.
  DateTime atMinutes(int minutesOfDay) =>
      DateTime(year, month, day, minutesOfDay ~/ 60, minutesOfDay % 60);

  int get yyyymmdd => year * 10000 + month * 100 + day;

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDate other) => yyyymmdd.compareTo(other.yyyymmdd);

  @override
  bool operator ==(Object other) => other is LocalDate && other.yyyymmdd == yyyymmdd;

  @override
  int get hashCode => yyyymmdd;

  @override
  String toString() => toIso();
}
