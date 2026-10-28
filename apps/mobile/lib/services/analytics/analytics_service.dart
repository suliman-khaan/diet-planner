/// Core analytics events (blueprint §11). Properties never carry health values, foods,
/// free text or query text.
enum AnalyticsEvent {
  onboardingCompleted,
  planGenerated,
  mealLogged,
  itemReplaced,
  familyPotUsed,
  ramadanModeEnabled,
  reminderEnabled,
  searchNoResult,
}

/// Where events go once the owner sets up a provider (Phase 8). Until then: nowhere.
abstract interface class AnalyticsSink {
  void send(String name, Map<String, Object> properties);
}

class NoopAnalyticsSink implements AnalyticsSink {
  const NoopAnalyticsSink();

  @override
  void send(String name, Map<String, Object> properties) {}
}

abstract interface class AnalyticsService {
  void setConsent(bool granted);
  void log(AnalyticsEvent event, [Map<String, Object> properties = const {}]);
}

/// Drops every event unless the user has consented. Only enum names, small integers and
/// booleans are allowed as properties, so personal data cannot slip through.
class ConsentGatedAnalytics implements AnalyticsService {
  ConsentGatedAnalytics(this._sink);

  final AnalyticsSink _sink;
  bool _consent = false;

  bool get hasConsent => _consent;

  @override
  void setConsent(bool granted) => _consent = granted;

  @override
  void log(AnalyticsEvent event, [Map<String, Object> properties = const {}]) {
    if (!_consent) return;
    final safe = <String, Object>{
      for (final e in properties.entries)
        if (e.value is bool ||
            (e.value is int && (e.value as int).abs() < 1000) ||
            e.value is Enum)
          e.key: e.value is Enum ? (e.value as Enum).name : e.value,
    };
    _sink.send(_snake(event.name), safe);
  }

  static String _snake(String camel) =>
      camel.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');
}
