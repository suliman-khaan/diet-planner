import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';

import '../core/errors/app_failure.dart';
import '../core/logging/app_logger.dart';
import '../data/db/app_database.dart';
import '../data/db/open_database.dart';
import '../data/food/asset_food_repository.dart';
import '../data/repositories/drift_repositories.dart';
import '../services/analytics/analytics_service.dart';
import '../services/files/backup_file_service.dart';
import '../services/links/link_service.dart';
import '../services/notifications/flutter_reminder_service.dart';
import 'app.dart';
import 'app_config.dart';
import 'providers/providers.dart';
import 'providers/reminder_coordinator.dart';
import 'recovery_screen.dart';
import 'router.dart';

const _log = AppLogger('bootstrap');

/// Starts the app for [config]. Never resets user data on its own: a damaged database
/// shows the recovery screen instead.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    _log.error('flutter_error', details.exception, details.stack);
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    _log.error('uncaught_error', error, stack);
    return true;
  };
  if (!config.isDev) {
    // Never show raw exception text to users.
    ErrorWidget.builder = (_) => const Material(
          child: Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Something went wrong on this screen. Your data is safe. Please go back and try again.'),
          )),
        );
  }

  final AppDatabase db;
  try {
    db = await openAppDatabase();
  } on StorageCorrupted catch (e) {
    _log.error('database_corrupted', e);
    runApp(RecoveryApp(onStartFresh: () async {
      await setAsideDamagedDatabase();
      await bootstrap(config);
    }, onRetry: () => bootstrap(config)));
    return;
  }

  final timezone = await _timezone();
  final settings = await DriftSettingsRepository(db).load();
  final analytics = ConsentGatedAnalytics(const NoopAnalyticsSink())..setConsent(settings.analyticsConsent);
  final reminders = FlutterReminderService();
  late final GoRouter router;

  final container = ProviderContainer(overrides: [
    appConfigProvider.overrideWithValue(config),
    databaseProvider.overrideWithValue(db),
    foodRepositoryProvider.overrideWithValue(
      AssetFoodRepository(() => rootBundle.loadString(AssetFoodRepository.bundledPackAsset)),
    ),
    timezoneNameProvider.overrideWith((ref) => timezone),
    reminderServiceProvider.overrideWithValue(reminders),
    analyticsServiceProvider.overrideWithValue(analytics),
    backupFileServiceProvider.overrideWithValue(const PlatformBackupFileService()),
    linkServiceProvider.overrideWithValue(const PlatformLinkService()),
  ]);

  router = buildRouter(config: config, onboardingComplete: settings.onboardingComplete);
  try {
    await reminders.initialize(timezoneName: timezone, onTap: (route) => router.go(route));
  } on Object catch (e, st) {
    // Reminders failing must not stop the app.
    _log.error('reminders_init_failed', e, st);
  }

  runApp(UncontrolledProviderScope(container: container, child: DietPlannerApp(router: router, config: config)));

  final launchRoute = await reminders.launchRoute().catchError((Object _) => null);
  if (launchRoute != null && settings.onboardingComplete) router.go(launchRoute);
  unawaited(container.read(reminderCoordinatorProvider).reschedule());
}

Future<String> _timezone() async {
  try {
    return await FlutterTimezone.getLocalTimezone();
  } on Object {
    return 'UTC';
  }
}

/// Re-reads the timezone when the app resumes, e.g. after travelling.
Future<String> currentTimezone() => _timezone();

