import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_scaffold.dart';
import 'core/widgets/badges.dart';
import 'core/widgets/segmented_controls.dart';
import 'features/foods/ui/food_detail_sheet.dart';
import 'features/foods/ui/foods_screen.dart';
import 'features/foods/view_model/foods_view_model.dart';
import 'features/gallery/ui/screen_gallery_screen.dart';
import 'features/history/ui/history_screen.dart';
import 'features/log/ui/quick_add_sheet.dart';
import 'features/meal/ui/meal_detail_screen.dart';
import 'features/meal/ui/portion_picker_sheet.dart';
import 'features/meal/view_model/meal_view_model.dart';
import 'features/onboarding/ui/onboarding_screen.dart';
import 'features/onboarding/view_model/onboarding_view_model.dart';
import 'features/privacy/ui/privacy_screen.dart';
import 'features/progress/ui/add_weight_sheet.dart';
import 'features/progress/ui/progress_screen.dart';
import 'features/progress/view_model/progress_view_model.dart';
import 'features/reminders/ui/reminders_screen.dart';
import 'features/settings/ui/settings_screen.dart';
import 'features/shopping/ui/shopping_screen.dart';
import 'features/today/ui/today_screen.dart';
import 'features/today/view_model/today_view_model.dart';
import 'features/transparency/ui/transparency_screen.dart';
import 'fixtures/foods_fixtures.dart';
import 'fixtures/history_fixtures.dart';
import 'fixtures/meal_fixtures.dart';
import 'fixtures/onboarding_fixtures.dart';
import 'fixtures/progress_fixtures.dart';
import 'fixtures/shopping_fixtures.dart';
import 'fixtures/today_fixtures.dart';

void main() {
  runApp(const DietPlannerPrototypeApp());
}

/// Connected interactive prototype for testing all user flows.
class DietPlannerPrototypeApp extends StatefulWidget {
  const DietPlannerPrototypeApp({super.key});

  @override
  State<DietPlannerPrototypeApp> createState() => _DietPlannerPrototypeAppState();
}

class _DietPlannerPrototypeAppState extends State<DietPlannerPrototypeApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diet Planner (Prototype)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: PrototypeHomeFlow(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class PrototypeHomeFlow extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const PrototypeHomeFlow({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<PrototypeHomeFlow> createState() => _PrototypeHomeFlowState();
}

class _PrototypeHomeFlowState extends State<PrototypeHomeFlow> {
  bool _isOnboarding = true;
  OnboardingViewModel _onboardingVm = OnboardingFixtures.welcome;

  AppTab _currentTab = AppTab.today;
  TodayViewModel _todayVm = TodayFixtures.standardSuccess;
  MealViewModel _dinnerVm = MealFixtures.dinnerSuccess;
  FoodsViewModel _foodsVm = FoodsFixtures.standardSearch;
  ProgressViewModel _progressVm = ProgressFixtures.standardMonth;

  // --- Onboarding Flow Helpers ---
  void _nextOnboardingStep() {
    setState(() {
      switch (_onboardingVm.currentStep) {
        case OnboardingStep.welcome:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.goal, currentStepIndex: 2);
        case OnboardingStep.goal:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.aboutYou, currentStepIndex: 3);
        case OnboardingStep.aboutYou:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.activity, currentStepIndex: 4);
        case OnboardingStep.activity:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.eligibility, currentStepIndex: 5);
        case OnboardingStep.eligibility:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.dietary, currentStepIndex: 6);
        case OnboardingStep.dietary:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.cookingRichness, currentStepIndex: 7);
        case OnboardingStep.cookingRichness:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.targetSummary, currentStepIndex: 8);
        case OnboardingStep.targetSummary:
          _isOnboarding = false;
        default:
          _isOnboarding = false;
      }
    });
  }

  void _prevOnboardingStep() {
    setState(() {
      switch (_onboardingVm.currentStep) {
        case OnboardingStep.goal:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.welcome, currentStepIndex: 1);
        case OnboardingStep.aboutYou:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.goal, currentStepIndex: 2);
        case OnboardingStep.activity:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.aboutYou, currentStepIndex: 3);
        case OnboardingStep.eligibility:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.activity, currentStepIndex: 4);
        case OnboardingStep.dietary:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.eligibility, currentStepIndex: 5);
        case OnboardingStep.cookingRichness:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.dietary, currentStepIndex: 6);
        case OnboardingStep.targetSummary:
          _onboardingVm = _onboardingVm.copyWith(currentStep: OnboardingStep.cookingRichness, currentStepIndex: 7);
        default:
          break;
      }
    });
  }

  // --- Meal & Logging Actions ---
  void _markNextMealEaten() {
    setState(() {
      _dinnerVm = _dinnerVm.copyWith(isEaten: true);
      final updatedMeals = _todayVm.meals.map((m) {
        if (m.slotTitle == 'Dinner') {
          return TodayMealItemViewModel(
            id: m.id,
            slotTitle: m.slotTitle,
            time: m.time,
            status: MealStatus.eaten,
            summaryText: m.summaryText,
            calories: m.calories,
          );
        }
        return m;
      }).toList();

      _todayVm = _todayVm.copyWith(
        meals: updatedMeals,
        eatenKcal: _todayVm.eatenKcal + 620,
        plannedKcal: (_todayVm.plannedKcal - 620).clamp(0, 3000),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dinner marked as eaten!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _dinnerVm = _dinnerVm.copyWith(isEaten: false);
              _todayVm = _todayVm.copyWith(
                eatenKcal: _todayVm.eatenKcal - 620,
                plannedKcal: _todayVm.plannedKcal + 620,
              );
            });
          },
        ),
      ),
    );
  }

  void _openMealDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MealDetailScreen(
          vm: _dinnerVm,
          onBack: () => Navigator.of(context).pop(),
          onKatoriCountChanged: (val) {
            setState(() {
              final newKcal = 340 * val;
              _dinnerVm = _dinnerVm.copyWith(
                mainDishKatoriCount: val,
                mainDishCalories: newKcal,
                totalCalories: newKcal + 280,
              );
            });
          },
          onOilLevelChanged: (level) {
            setState(() => _dinnerVm = _dinnerVm.copyWith(oilRichness: level));
          },
          onToggleEaten: () {
            _markNextMealEaten();
            Navigator.of(context).pop();
          },
          onAddFood: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Add Food to Dinner')),
                  body: FoodsScreen(
                    vm: _foodsVm,
                    onFoodSelected: (food) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added ${food.englishName} to dinner')),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isOnboarding) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Diet Planner · Onboarding'),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              tooltip: 'Toggle Theme',
              onPressed: widget.onToggleTheme,
            ),
          ],
        ),
        body: OnboardingScreen(
          vm: _onboardingVm,
          onGoalChanged: (g) => setState(() => _onboardingVm = _onboardingVm.copyWith(goal: g)),
          onRichnessChanged: (r) => setState(() => _onboardingVm = _onboardingVm.copyWith(cookingRichness: r)),
          onSexChanged: (s) => setState(() => _onboardingVm = _onboardingVm.copyWith(sex: s)),
          onActivityChanged: (a) => setState(() => _onboardingVm = _onboardingVm.copyWith(activityLevel: a)),
          onNext: _nextOnboardingStep,
          onBack: _prevOnboardingStep,
          onFinish: () => setState(() => _isOnboarding = false),
          onSkipToDashboard: () => setState(() => _isOnboarding = false),
        ),
      );
    }

    return AppScaffold(
      currentTab: _currentTab,
      onTabChanged: (tab) => setState(() => _currentTab = tab),
      body: Scaffold(
        appBar: AppBar(
          title: Text(_getTabTitle(_currentTab)),
          actions: [
            if (_currentTab == AppTab.today)
              IconButton(
                icon: Icon(_todayVm.isRamadanMode ? Icons.sunny : Icons.nightlight_round),
                tooltip: _todayVm.isRamadanMode ? 'Switch to Normal Mode' : 'Switch to Ramadan Mode',
                onPressed: () {
                  setState(() {
                    _todayVm = _todayVm.isRamadanMode
                        ? TodayFixtures.standardSuccess
                        : TodayFixtures.ramadanSuccess;
                  });
                },
              ),
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              tooltip: 'Toggle Theme',
              onPressed: widget.onToggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              tooltip: 'Dev Screen Gallery',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScreenGalleryScreen()),
                );
              },
            ),
          ],
        ),
        body: _buildCurrentTabBody(context),
      ),
    );
  }

  String _getTabTitle(AppTab tab) {
    switch (tab) {
      case AppTab.today:
        return 'Diet Planner';
      case AppTab.foods:
        return 'Foods Catalogue';
      case AppTab.progress:
        return 'Weight & Consistency';
      case AppTab.more:
        return 'More Tools & Settings';
    }
  }

  Widget _buildCurrentTabBody(BuildContext context) {
    switch (_currentTab) {
      case AppTab.today:
        return TodayScreen(
          vm: _todayVm,
          onInfoTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TransparencyScreen()),
            );
          },
          onMarkNextMealEaten: _markNextMealEaten,
          onChangeNextMeal: _openMealDetail,
          onMealRowTap: (_) => _openMealDetail(),
          onMealLogTap: (_) => _markNextMealEaten(),
          onGeneratePlan: () {
            setState(() => _todayVm = TodayFixtures.standardSuccess);
          },
        );

      case AppTab.foods:
        return FoodsScreen(
          vm: _foodsVm,
          onSearchChanged: (query) {
            setState(() {
              if (query.trim().isEmpty) {
                _foodsVm = FoodsFixtures.standardSearch;
              } else {
                final filtered = FoodsFixtures.standardSearch.searchResults.where((f) {
                  return f.englishName.toLowerCase().contains(query.toLowerCase()) ||
                      f.urduName.contains(query);
                }).toList();
                _foodsVm = _foodsVm.copyWith(searchQuery: query, searchResults: filtered);
              }
            });
          },
          onSearchCleared: () {
            setState(() => _foodsVm = FoodsFixtures.standardSearch);
          },
          onCategorySelected: (cat) {
            setState(() {
              if (cat == 'All') {
                _foodsVm = _foodsVm.copyWith(
                  selectedCategory: cat,
                  searchResults: FoodsFixtures.standardSearch.searchResults,
                );
              } else {
                final filtered = FoodsFixtures.standardSearch.searchResults
                    .where((f) => f.category == cat)
                    .toList();
                _foodsVm = _foodsVm.copyWith(selectedCategory: cat, searchResults: filtered);
              }
            });
          },
          onFoodSelected: (food) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => FoodDetailSheet(
                food: food,
                onAddToMeal: (servings) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added $servings serving(s) of ${food.englishName}')),
                  );
                },
              ),
            );
          },
          onRequestMissingFood: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const QuickAddSheet(),
            );
          },
        );

      case AppTab.progress:
        return ProgressScreen(
          vm: _progressVm,
          onRangeToggled: (isMonth) {
            setState(() => _progressVm = ProgressViewModel(isMonthView: isMonth));
          },
          onAddWeightTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddWeightSheet(
                onWeightSaved: (newWeight) {
                  setState(() {
                    _progressVm = ProgressViewModel(
                      currentWeightKg: newWeight,
                      weightChangeSubtitle: 'Latest entry saved just now',
                      isMonthView: _progressVm.isMonthView,
                      weekEating: _progressVm.weekEating,
                    );
                  });
                },
              ),
            );
          },
        );

      case AppTab.more:
        return SettingsScreen(
          onOpenHistory: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen(vm: HistoryFixtures.standard)),
            );
          },
          onOpenShopping: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ShoppingScreen(vm: ShoppingFixtures.standard)),
            );
          },
          onOpenReminders: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RemindersScreen()),
            );
          },
          onOpenPrivacy: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyScreen()),
            );
          },
          onOpenTransparency: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TransparencyScreen()),
            );
          },
        );
    }
  }
}
