import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

/// Structured, levelled logging. Never pass personal or health data (weights, ages, foods,
/// allergies, free text): log ids, counts, enum names and error types only.
class AppLogger {
  const AppLogger(this.area);

  final String area;

  static LogLevel minimumLevel = LogLevel.info;

  void debug(String event, [Map<String, Object?> fields = const {}]) => _log(LogLevel.debug, event, fields);
  void info(String event, [Map<String, Object?> fields = const {}]) => _log(LogLevel.info, event, fields);
  void warning(String event, [Map<String, Object?> fields = const {}]) => _log(LogLevel.warning, event, fields);

  void error(String event, Object error, [StackTrace? stack, Map<String, Object?> fields = const {}]) =>
      _log(LogLevel.error, event, {...fields, 'errorType': error.runtimeType.toString()}, stack);

  void _log(LogLevel level, String event, Map<String, Object?> fields, [StackTrace? stack]) {
    if (level.index < minimumLevel.index) return;
    final details = fields.isEmpty ? '' : ' ${fields.entries.map((e) => '${e.key}=${e.value}').join(' ')}';
    developer.log(
      '[${level.name}] $event$details',
      name: area,
      level: switch (level) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warning => 900,
        LogLevel.error => 1000,
      },
      stackTrace: stack,
    );
  }
}
