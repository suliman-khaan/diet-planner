/// Small deterministic PRNG (xorshift32). Same seed → same sequence on every platform,
/// which the planner's determinism guarantee depends on.
class SeededRandom {
  SeededRandom(int seed) : _state = _mix(seed);

  int _state;

  static int _mix(int seed) {
    var s = seed & 0xFFFFFFFF;
    s = ((s ^ 0x9E3779B9) * 0x85EBCA6B) & 0xFFFFFFFF;
    s ^= s >> 13;
    return s == 0 ? 0x6D2B79F5 : s;
  }

  int nextUint32() {
    var x = _state;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    _state = x & 0xFFFFFFFF;
    return _state;
  }

  /// Uniform in [0, 1).
  double nextDouble() => nextUint32() / 4294967296.0;

  /// Stable 32-bit hash of a string (FNV-1a), for deriving seeds from ids and dates.
  static int hashString(String s) {
    var h = 0x811C9DC5;
    for (final unit in s.codeUnits) {
      h ^= unit;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }
}
