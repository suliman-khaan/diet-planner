enum Flavor { dev, prod }

class AppConfig {
  const AppConfig({required this.flavor});

  final Flavor flavor;

  bool get isDev => flavor == Flavor.dev;

  /// Dev builds may auto-plan with draft (unreviewed) food data, clearly labelled.
  /// Release builds never do (blueprint §3 and Phase 1 exit criteria).
  bool get allowDraftData => isDev;

  bool get showScreenGallery => isDev;

  String get appName => isDev ? 'Diet Planner Dev' : 'Diet Planner';

  /// Placeholder until the owner sets a support address (Phase 8 decision).
  String get supportEmail => 'support@example.invalid';

  /// Help link for the gentle check-in. Placeholder until the owner chooses a local
  /// resource (Phase 8 decision); points to general WHO guidance meanwhile.
  String get wellbeingHelpUrl =>
      'https://www.who.int/news-room/fact-sheets/detail/healthy-diet';
}
