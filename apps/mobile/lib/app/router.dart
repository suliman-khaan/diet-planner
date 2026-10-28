import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_typography.dart';
import '../core/widgets/app_scaffold.dart';
import '../core/widgets/state_widgets.dart';
import '../domain/common/local_date.dart';
import '../features/foods/controller/foods_controller.dart';
import '../features/foods/ui/foods_screen.dart';
import '../features/foods/view_model/foods_view_model.dart';
import '../features/gallery/ui/screen_gallery_screen.dart';
import '../features/history/controller/history_page.dart';
import '../features/log/controller/log_food_flow.dart';
import '../features/meal/controller/meal_page.dart';
import '../features/onboarding/controller/onboarding_page.dart';
import '../features/privacy/controller/privacy_page.dart';
import '../features/progress/controller/progress_controller.dart';
import '../features/reminders/controller/reminders_page.dart';
import '../features/settings/controller/settings_page.dart';
import '../features/shopping/controller/shopping_page.dart';
import '../features/today/controller/today_controller.dart';
import '../features/today/controller/today_page.dart';
import '../features/transparency/controller/transparency_page.dart';
import 'app_config.dart';
import 'providers/providers.dart';
import 'routes.dart';

/// Routes. Deep links (e.g. from a reminder) use the same paths:
/// `/today?date=2026-10-29`, `/meal/<id>?date=2026-10-29`.
GoRouter buildRouter({required AppConfig config, required bool onboardingComplete}) => GoRouter(
      initialLocation: onboardingComplete ? AppRoutes.today : AppRoutes.onboarding,
      routes: [
        GoRoute(
          path: AppRoutes.initial,
          redirect: (_, __) => onboardingComplete ? AppRoutes.today : AppRoutes.onboarding,
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, state) => OnboardingPage(editing: state.uri.queryParameters['edit'] == '1'),
        ),
        ShellRoute(
          builder: (context, state, child) => _TabShell(location: state.uri.path, config: config, child: child),
          routes: [
            GoRoute(
              path: AppRoutes.today,
              builder: (_, state) => _TodayRoute(date: _date(state.uri.queryParameters['date'])),
            ),
            GoRoute(path: AppRoutes.foods, builder: (_, __) => const _FoodsTab()),
            GoRoute(path: AppRoutes.progress, builder: (_, __) => const ProgressPage()),
            GoRoute(path: AppRoutes.more, builder: (_, __) => const SettingsPage()),
          ],
        ),
        GoRoute(
          path: AppRoutes.mealDetail,
          builder: (_, state) => MealPage(
            mealId: state.pathParameters['mealId']!,
            date: _date(state.uri.queryParameters['date']) ?? LocalDate.fromDateTime(DateTime.now()),
          ),
        ),
        GoRoute(path: AppRoutes.history, builder: (_, __) => const HistoryPage()),
        GoRoute(path: AppRoutes.shopping, builder: (_, __) => const ShoppingPage()),
        GoRoute(path: AppRoutes.reminders, builder: (_, __) => const RemindersPage()),
        GoRoute(path: AppRoutes.privacy, builder: (_, __) => const PrivacyPage()),
        GoRoute(path: AppRoutes.transparency, builder: (_, __) => const TransparencyPage()),
        if (config.showScreenGallery)
          GoRoute(path: AppRoutes.gallery, builder: (_, __) => const ScreenGalleryScreen()),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(),
        body: EmptyStateWidget(
          icon: Icons.explore_off_outlined,
          title: 'Page not found',
          message: 'This link does not open anything in the app.',
          actionLabel: 'Go to Today',
          onAction: () => context.go(AppRoutes.today),
        ),
      ),
    );

/// Dates in links are external input: anything that does not parse is ignored.
LocalDate? _date(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  try {
    return LocalDate.parse(iso);
  } on Object {
    return null;
  }
}

class _TabShell extends StatelessWidget {
  const _TabShell({required this.location, required this.config, required this.child});

  final String location;
  final AppConfig config;
  final Widget child;

  static const _paths = {
    AppTab.today: AppRoutes.today,
    AppTab.foods: AppRoutes.foods,
    AppTab.progress: AppRoutes.progress,
    AppTab.more: AppRoutes.more,
  };

  static const _titles = {
    AppTab.today: 'Diet Planner',
    AppTab.foods: 'Foods',
    AppTab.progress: 'Progress',
    AppTab.more: 'More',
  };

  @override
  Widget build(BuildContext context) {
    final tab = _paths.entries.firstWhere((e) => location.startsWith(e.value), orElse: () => _paths.entries.first).key;
    return AppScaffold(
      currentTab: tab,
      onTabChanged: (t) => context.go(_paths[t]!),
      body: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 2,
          title: Text(_titles[tab]!, style: AppTypography.titleMedium),
          actions: [
            if (config.showScreenGallery)
              IconButton(
                icon: const Icon(Icons.grid_view_rounded),
                tooltip: 'Dev screen gallery',
                onPressed: () => context.push(AppRoutes.gallery),
              ),
          ],
        ),
        body: child,
      ),
    );
  }
}

/// Applies a date from a link (e.g. a reminder) before showing Today.
class _TodayRoute extends ConsumerStatefulWidget {
  const _TodayRoute({this.date});

  final LocalDate? date;

  @override
  ConsumerState<_TodayRoute> createState() => _TodayRouteState();
}

class _TodayRouteState extends ConsumerState<_TodayRoute> {
  @override
  void initState() {
    super.initState();
    final date = widget.date;
    if (date != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(selectedDateProvider.notifier).state = date);
    }
  }

  @override
  Widget build(BuildContext context) => const TodayPage();
}

class _FoodsTab extends ConsumerWidget {
  const _FoodsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(foodsControllerProvider);
    final c = ref.read(foodsControllerProvider.notifier);
    return async.when(
      loading: () => const FoodsScreen(vm: FoodsViewModel(isLoading: true)),
      error: (_, __) => ErrorStateWidget(
        message: 'The food list could not be loaded.',
        onRetry: () => ref.invalidate(foodsControllerProvider),
      ),
      data: (vm) => FoodsScreen(
        vm: vm,
        onSearchChanged: c.setQuery,
        onSearchCleared: () => c.setQuery(''),
        onCategorySelected: c.setCategory,
        onFoodSelected: (f) async {
          await LogFoodFlow.showFoodDetail(context, ref, f.id);
          ref.invalidate(todayControllerProvider);
        },
        // "Food missing" requests go through the user's own email app (blueprint §11).
        onRequestMissingFood: () async {
          final ok = await ref.read(linkServiceProvider).composeEmail(
                to: ref.read(appConfigProvider).supportEmail,
                subject: 'Missing food request',
              );
          if (!ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No email app found on this phone.')),
            );
          }
        },
      ),
    );
  }
}
