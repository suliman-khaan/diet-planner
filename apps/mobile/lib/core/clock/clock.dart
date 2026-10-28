/// Injectable time source. Domain code never reads the system clock directly.
abstract interface class Clock {
  DateTime nowUtc();
  DateTime nowLocal();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();

  @override
  DateTime nowLocal() => DateTime.now();
}

/// For tests: time only moves when told to.
class FixedClock implements Clock {
  FixedClock(this._local);

  DateTime _local;

  void advance(Duration d) => _local = _local.add(d);
  void set(DateTime local) => _local = local;

  @override
  DateTime nowUtc() => _local.toUtc();

  @override
  DateTime nowLocal() => _local;
}
