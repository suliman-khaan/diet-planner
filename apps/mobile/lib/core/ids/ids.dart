import 'package:uuid/uuid.dart';

/// Record ids are UUIDv7 generated on device, so they stay stable through offline use and sync.
abstract interface class IdGenerator {
  String newId();
}

class Uuid7IdGenerator implements IdGenerator {
  Uuid7IdGenerator();

  final Uuid _uuid = const Uuid();

  @override
  String newId() => _uuid.v7();
}

/// For tests: predictable ids.
class SequentialIdGenerator implements IdGenerator {
  SequentialIdGenerator([this.prefix = 'id']);

  final String prefix;
  int _next = 1;

  @override
  String newId() => '$prefix-${_next++}';
}
