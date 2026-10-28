import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/today/controller/today_controller.dart';
import 'app_config.dart';
import 'bootstrap.dart';
import 'providers/providers.dart';
import 'providers/reminder_coordinator.dart';

class DietPlannerApp extends ConsumerStatefulWidget {
  const DietPlannerApp({super.key, required this.router, required this.config});

  final GoRouter router;
  final AppConfig config;

  @override
  ConsumerState<DietPlannerApp> createState() => _DietPlannerAppState();
}

class _DietPlannerAppState extends ConsumerState<DietPlannerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onResume();
  }

  /// The date or timezone may have changed while the app was in the background.
  Future<void> _onResume() async {
    final tz = await currentTimezone();
    if (!mounted) return;
    if (tz != ref.read(timezoneNameProvider))
      ref.read(timezoneNameProvider.notifier).state = tz;
    ref
      ..invalidate(todayProvider)
      ..invalidate(todayControllerProvider);
    await ref.read(reminderCoordinatorProvider).reschedule();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: widget.config.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: widget.router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ur')],
        locale: const Locale('en'),
      );
}
