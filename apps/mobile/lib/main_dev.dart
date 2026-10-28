import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_radii.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/widgets/app_buttons.dart';
import 'core/widgets/app_card.dart';
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
  State<DietPlannerPrototypeApp> createState() =>
      _DietPlannerPrototypeAppState();
}

class _DietPlannerPrototypeAppState extends State<DietPlannerPrototypeApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      final isCurrentlyDark = _themeMode == ThemeMode.dark ||
          (_themeMode == ThemeMode.system &&
              WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark);
      _themeMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
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

  String _foodsSearchQuery = '';
  String _foodsSelectedCategory = 'All';
  OilLevel _defaultRichness = OilLevel.normal;

  void _filterFoods() {
    var results = FoodsFixtures.allCatalogueFoods;
    if (_foodsSelectedCategory != 'All') {
      results =
          results.where((f) => f.category == _foodsSelectedCategory).toList();
    }
    if (_foodsSearchQuery.trim().isNotEmpty) {
      final q = _foodsSearchQuery.trim().toLowerCase();
      results = results.where((f) {
        return f.englishName.toLowerCase().contains(q) ||
            f.urduName.contains(q) ||
            f.category.toLowerCase().contains(q);
      }).toList();
    }
    setState(() {
      _foodsVm = _foodsVm.copyWith(
        searchQuery: _foodsSearchQuery,
        selectedCategory: _foodsSelectedCategory,
        searchResults: results,
      );
    });
  }

  // --- Onboarding Flow Helpers ---
  void _recalculateTarget() {
    final isMale = _onboardingVm.sex == BiologicalSex.male;
    final age = 2026 - _onboardingVm.birthYear;
    final bmr = (10 * _onboardingVm.weightKg) +
        (6.25 * _onboardingVm.heightCm) -
        (5 * age) +
        (isMale ? 5 : -161);

    double activityMult;
    switch (_onboardingVm.activityLevel) {
      case ActivityLevel.sedentary:
        activityMult = 1.2;
      case ActivityLevel.lightlyActive:
        activityMult = 1.375;
      case ActivityLevel.moderatelyActive:
        activityMult = 1.55;
      case ActivityLevel.veryActive:
        activityMult = 1.725;
    }

    final tdee = bmr * activityMult;
    double targetKcal;
    switch (_onboardingVm.goal) {
      case WeightGoal.loseWeight:
        targetKcal = tdee - 450;
      case WeightGoal.maintain:
        targetKcal = tdee;
      case WeightGoal.gainWeight:
        targetKcal = tdee + 350;
    }

    final floor = isMale ? 1500.0 : 1200.0;
    if (targetKcal < floor) targetKcal = floor;

    final finalKcal = targetKcal.round();
    final proteinG = ((finalKcal * 0.20) / 4).round();
    final carbsG = ((finalKcal * 0.50) / 4).round();
    final fatG = ((finalKcal * 0.30) / 9).round();

    _onboardingVm = _onboardingVm.copyWith(
      recommendedCalories: finalKcal,
      recommendedProtein: proteinG,
      recommendedCarbs: carbsG,
      recommendedFat: fatG,
      recommendedFibre: 28,
    );
  }

  void _nextOnboardingStep() {
    setState(() {
      switch (_onboardingVm.currentStep) {
        case OnboardingStep.welcome:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.goal, currentStepIndex: 2);
        case OnboardingStep.goal:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.aboutYou, currentStepIndex: 3);
        case OnboardingStep.aboutYou:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.activity, currentStepIndex: 4);
        case OnboardingStep.activity:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.eligibility, currentStepIndex: 5);
        case OnboardingStep.eligibility:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.dietary, currentStepIndex: 6);
        case OnboardingStep.dietary:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.cookingRichness, currentStepIndex: 7);
        case OnboardingStep.cookingRichness:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.targetSummary, currentStepIndex: 8);
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
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.welcome, currentStepIndex: 1);
        case OnboardingStep.aboutYou:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.goal, currentStepIndex: 2);
        case OnboardingStep.activity:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.aboutYou, currentStepIndex: 3);
        case OnboardingStep.eligibility:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.activity, currentStepIndex: 4);
        case OnboardingStep.dietary:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.eligibility, currentStepIndex: 5);
        case OnboardingStep.cookingRichness:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.dietary, currentStepIndex: 6);
        case OnboardingStep.targetSummary:
          _onboardingVm = _onboardingVm.copyWith(
              currentStep: OnboardingStep.cookingRichness, currentStepIndex: 7);
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

      final newEatenKcal = _todayVm.eatenKcal + 460;
      _todayVm = _todayVm.copyWith(
        meals: updatedMeals,
        eatenKcal: newEatenKcal,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marked Dinner as eaten! Remaining calories updated.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openMealDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MealDetailScreen(
          vm: _dinnerVm,
          onKatoriCountChanged: (val) {
            setState(() {
              final newKcal = (180 * val).round();
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
                        SnackBar(
                            content:
                                Text('Added ${food.englishName} to dinner')),
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

  // --- Preference Modal Sheets ---
  void _showProfileTargetSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorderStrong
                        : AppColors.lightBorderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile & Health Target',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? AppColors.darkInk : AppColors.lightInk,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileRow(
                        'Sex & Age', 'Male · 28 years old', isDark),
                    const Divider(height: 16),
                    _buildProfileRow('Height & Weight',
                        '175 cm · 78.4 kg (BMI 25.6)', isDark),
                    const Divider(height: 16),
                    _buildProfileRow('Activity Level',
                        'Moderate (3–5 workouts/week)', isDark),
                    const Divider(height: 16),
                    _buildProfileRow('Daily Calorie Target',
                        '1,850 kcal/day (400 deficit)', isDark),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Re-run Onboarding Assessment',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() => _isOnboarding = true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.captionStrong.copyWith(
                color: isDark ? AppColors.darkInk : AppColors.lightInk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCookingRichnessSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.card)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorderStrong
                        : AppColors.lightBorderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Default Cooking Richness',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? AppColors.darkInk : AppColors.lightInk,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Sets how much oil or ghee is assumed in family pot dishes (salan, karahi, daal).',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
              const SizedBox(height: 18),
              OilLevelSelector(
                selected: _defaultRichness,
                onChanged: (level) {
                  setSheetState(() => _defaultRichness = level);
                  setState(() => _defaultRichness = level);
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save Richness Preference',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cooking richness updated.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllergiesSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.card)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorderStrong
                        : AppColors.lightBorderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Allergies & Exclusions',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? AppColors.darkInk : AppColors.lightInk,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Foods matching your excluded categories will never appear in your suggested plans.',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildSwitchItem('Vegetarian only',
                        'Excludes meat, chicken, fish', false, isDark),
                    const Divider(height: 1),
                    _buildSwitchItem('Nut allergy',
                        'Excludes peanuts, almonds, pistachios', true, isDark),
                    const Divider(height: 1),
                    _buildSwitchItem(
                        'Lactose intolerant',
                        'Excludes whole milk, doodh patti, lassi',
                        false,
                        isDark),
                    const Divider(height: 1),
                    _buildSwitchItem('Gluten sensitive',
                        'Excludes wheat roti, parathas, naan', false, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save Exclusions',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Allergies and exclusions saved.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
      String title, String subtitle, bool initial, bool isDark) {
    return StatefulBuilder(
      builder: (ctx, setItemState) {
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          title: Text(
            title,
            style: AppTypography.bodyStrong.copyWith(
              color: isDark ? AppColors.darkInk : AppColors.lightInk,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          value: initial,
          onChanged: (val) => setItemState(() => initial = val),
        );
      },
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBorderStrong
                      : AppColors.lightBorderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Language / زبان',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.darkInk : AppColors.lightInk,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:
                        const Icon(Icons.check, color: AppColors.lightPrimary),
                    title: const Text('English (Default)'),
                    subtitle: const Text(
                        'Full interface and food catalogue in English'),
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const SizedBox(width: 24),
                    title: const Text('اردو (Urdu)'),
                    subtitle: const Text(
                        'Coming in next update (Nastaliq translation in review)'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Urdu localization is in review and coming in v0.2.0')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
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
          title: Text(
            'Diet Planner · Onboarding',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? AppColors.darkInk : AppColors.lightInk,
            ),
          ),
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
          onGoalChanged: (g) {
            setState(() {
              _onboardingVm = _onboardingVm.copyWith(goal: g);
              _recalculateTarget();
            });
          },
          onRichnessChanged: (r) => setState(
              () => _onboardingVm = _onboardingVm.copyWith(cookingRichness: r)),
          onSexChanged: (s) {
            setState(() {
              _onboardingVm = _onboardingVm.copyWith(sex: s);
              _recalculateTarget();
            });
          },
          onActivityChanged: (a) {
            setState(() {
              _onboardingVm = _onboardingVm.copyWith(activityLevel: a);
              _recalculateTarget();
            });
          },
          onHeightChanged: (h) {
            setState(() {
              _onboardingVm = _onboardingVm.copyWith(heightCm: h);
              _recalculateTarget();
            });
          },
          onWeightChanged: (w) {
            setState(() {
              _onboardingVm = _onboardingVm.copyWith(weightKg: w);
              _recalculateTarget();
            });
          },
          onDietTypeChanged: (d) => setState(
              () => _onboardingVm = _onboardingVm.copyWith(dietType: d)),
          onAllergyToggled: (allergy) {
            setState(() {
              final list = List<String>.from(_onboardingVm.allergies);
              if (list.contains(allergy)) {
                list.remove(allergy);
              } else {
                list.add(allergy);
              }
              _onboardingVm = _onboardingVm.copyWith(allergies: list);
            });
          },
          onNext: _nextOnboardingStep,
          onBack: _prevOnboardingStep,
          onFinish: () {
            setState(() {
              _isOnboarding = false;
              if (_onboardingVm.recommendedCalories != null) {
                _todayVm = _todayVm.copyWith(
                  targetKcal: _onboardingVm.recommendedCalories!,
                  proteinTarget: _onboardingVm.recommendedProtein ??
                      _todayVm.proteinTarget,
                  carbsTarget:
                      _onboardingVm.recommendedCarbs ?? _todayVm.carbsTarget,
                  fatTarget: _onboardingVm.recommendedFat ?? _todayVm.fatTarget,
                );
              }
            });
          },
          onSkipToDashboard: () => setState(() => _isOnboarding = false),
        ),
      );
    }

    return AppScaffold(
      currentTab: _currentTab,
      onTabChanged: (tab) => setState(() => _currentTab = tab),
      body: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 2,
          title: Text(
            _getTabTitle(_currentTab),
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? AppColors.darkInk : AppColors.lightInk,
            ),
          ),
          actions: [
            if (_currentTab == AppTab.today)
              IconButton(
                icon: const Icon(Icons.mosque),
                tooltip: _todayVm.isRamadanMode
                    ? 'Switch to Normal Mode'
                    : 'Switch to Ramadan Mode',
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
                  MaterialPageRoute(
                      builder: (_) => const ScreenGalleryScreen()),
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
            _foodsSearchQuery = query;
            _filterFoods();
          },
          onSearchCleared: () {
            _foodsSearchQuery = '';
            _filterFoods();
          },
          onCategorySelected: (cat) {
            _foodsSelectedCategory = cat;
            _filterFoods();
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
                    SnackBar(
                        content: Text(
                            'Added $servings serving(s) of ${food.englishName}')),
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
            setState(() {
              _progressVm = isMonth
                  ? ProgressFixtures.standardMonth
                  : ProgressFixtures.standardWeek;
            });
          },
          onAddWeightTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddWeightSheet(
                onWeightSaved: (newWeight) {
                  setState(() {
                    final updatedTrend = [
                      ..._progressVm.weightTrend
                          .take(_progressVm.weightTrend.length - 1),
                      WeightPointViewModel(
                        dateLabel: 'Today',
                        weightKg: newWeight,
                      ),
                    ];
                    _progressVm = _progressVm.copyWith(
                      currentWeightKg: newWeight,
                      weightChangeSubtitle: 'Latest entry saved just now',
                      weightTrend: updatedTrend,
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
              MaterialPageRoute(
                  builder: (_) =>
                      const HistoryScreen(vm: HistoryFixtures.standard)),
            );
          },
          onOpenShopping: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) =>
                      const ShoppingScreen(vm: ShoppingFixtures.standard)),
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
          onOpenProfileTarget: () => _showProfileTargetSheet(context),
          onOpenCookingRichness: () => _showCookingRichnessSheet(context),
          onOpenAllergies: () => _showAllergiesSheet(context),
          onOpenLanguage: () => _showLanguageSheet(context),
        );
    }
  }
}
