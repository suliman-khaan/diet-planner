import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../fixtures/foods_fixtures.dart';
import '../../../fixtures/meal_fixtures.dart';
import '../../../fixtures/onboarding_fixtures.dart';
import '../../../fixtures/today_fixtures.dart';
import '../../foods/ui/food_detail_sheet.dart';
import '../../foods/ui/foods_screen.dart';
import '../../log/ui/quick_add_sheet.dart';
import '../../meal/ui/meal_detail_screen.dart';
import '../../meal/ui/portion_picker_sheet.dart';
import '../../onboarding/ui/onboarding_screen.dart';
import '../../today/ui/today_screen.dart';

/// Developer Screen Gallery Matrix for inspecting every screen × state.
class ScreenGalleryScreen extends StatefulWidget {
  const ScreenGalleryScreen({super.key});

  @override
  State<ScreenGalleryScreen> createState() => _ScreenGalleryScreenState();
}

class _ScreenGalleryScreenState extends State<ScreenGalleryScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Dev Screen Gallery'),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          _buildSectionHeader('ONBOARDING FLOW (U-06)'),
          _buildGalleryTile(
            title: 'Welcome Screen',
            subtitle: 'Local privacy pledge, start action',
            onTap: () => _openScreen(context, const OnboardingScreen(vm: OnboardingFixtures.welcome)),
          ),
          _buildGalleryTile(
            title: 'Goal Selection',
            subtitle: 'Healthy deficit/maintenance options',
            onTap: () => _openScreen(context, const OnboardingScreen(vm: OnboardingFixtures.goal)),
          ),
          _buildGalleryTile(
            title: 'Cooking Richness Step',
            subtitle: 'Light, Normal, Rich oil radio cards',
            onTap: () => _openScreen(context, const OnboardingScreen(vm: OnboardingFixtures.cookingRichness)),
          ),
          _buildGalleryTile(
            title: 'Target Summary Result',
            subtitle: 'Mifflin-St Jeor daily calories & macros',
            onTap: () => _openScreen(context, const OnboardingScreen(vm: OnboardingFixtures.targetSummary)),
          ),
          _buildGalleryTile(
            title: 'Onboarding · Loading State',
            subtitle: 'Generating plan spinner',
            onTap: () => _openScreen(context, const OnboardingScreen(vm: OnboardingFixtures.loading)),
          ),
          _buildGalleryTile(
            title: 'Onboarding · Error State',
            subtitle: 'Inline error notification',
            onTap: () => _openScreen(context, const OnboardingScreen(vm: OnboardingFixtures.error)),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('TODAY SCREEN (U-07)'),
          _buildGalleryTile(
            title: 'Today · Standard Success Mode',
            subtitle: 'Calorie split, next meal hero, daily timeline',
            onTap: () => _openScreen(
              context,
              AppScaffold(
                currentTab: AppTab.today,
                onTabChanged: (_) {},
                body: const TodayScreen(vm: TodayFixtures.standardSuccess),
              ),
            ),
          ),
          _buildGalleryTile(
            title: 'Today · Ramadan Mode',
            subtitle: 'Deep blue night theme, Sehri/Iftar schedule',
            onTap: () => _openScreen(
              context,
              AppScaffold(
                currentTab: AppTab.today,
                onTabChanged: (_) {},
                body: const TodayScreen(vm: TodayFixtures.ramadanSuccess),
              ),
            ),
          ),
          _buildGalleryTile(
            title: 'Today · Empty State (No Plan Yet)',
            subtitle: 'Clear explanation with 1-click generator',
            onTap: () => _openScreen(
              context,
              AppScaffold(
                currentTab: AppTab.today,
                onTabChanged: (_) {},
                body: const TodayScreen(vm: TodayFixtures.emptyNoPlan),
              ),
            ),
          ),
          _buildGalleryTile(
            title: 'Today · Loading Skeleton State',
            subtitle: 'Shimmer cards & list rows',
            onTap: () => _openScreen(
              context,
              AppScaffold(
                currentTab: AppTab.today,
                onTabChanged: (_) {},
                body: const TodayScreen(vm: TodayFixtures.loading),
              ),
            ),
          ),
          _buildGalleryTile(
            title: 'Today · Error State',
            subtitle: 'Supportive error with retry action',
            onTap: () => _openScreen(
              context,
              AppScaffold(
                currentTab: AppTab.today,
                onTabChanged: (_) {},
                body: TodayScreen(
                  vm: TodayFixtures.error,
                  onRetry: () {},
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('MEAL DETAIL SCREEN (U-08)'),
          _buildGalleryTile(
            title: 'Meal Detail · Planned',
            subtitle: 'Family pot portion, oil selector, sides',
            onTap: () => _openScreen(context, const MealDetailScreen(vm: MealFixtures.dinnerSuccess)),
          ),
          _buildGalleryTile(
            title: 'Meal Detail · Eaten',
            subtitle: 'Checked eaten state with undo option',
            onTap: () => _openScreen(context, const MealDetailScreen(vm: MealFixtures.dinnerEaten)),
          ),
          _buildGalleryTile(
            title: 'Portion Size Guide Sheet (U-09)',
            subtitle: 'Katori, Pyala, Chamach, Roti guide & calibration',
            onTap: () => _showModal(context, const PortionPickerSheet()),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('FOODS & SEARCH (U-10 & U-11)'),
          _buildGalleryTile(
            title: 'Foods Search · Results View',
            subtitle: 'Roman Urdu & English search with categories',
            onTap: () => _openScreen(
              context,
              AppScaffold(
                currentTab: AppTab.foods,
                onTabChanged: (_) {},
                body: const FoodsScreen(vm: FoodsFixtures.standardSearch),
              ),
            ),
          ),
          _buildGalleryTile(
            title: 'Foods Search · Empty State',
            subtitle: 'No results + tell us what is missing',
            onTap: () => _openScreen(
              context,
              AppScaffold(
                currentTab: AppTab.foods,
                onTabChanged: (_) {},
                body: const FoodsScreen(vm: FoodsFixtures.emptySearch),
              ),
            ),
          ),
          _buildGalleryTile(
            title: 'Food Detail Sheet (U-10)',
            subtitle: 'Nutritional breakdown, allergens & portion stepper',
            onTap: () => _showModal(
              context,
              FoodDetailSheet(food: FoodsFixtures.standardSearch.searchResults.first),
            ),
          ),
          _buildGalleryTile(
            title: 'Quick Add Sheet (U-11)',
            subtitle: 'Manual calorie entry with meal slot selection',
            onTap: () => _showModal(context, const QuickAddSheet()),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, start: 4),
      child: Text(
        title,
        style: AppTypography.micro.copyWith(
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
        ),
      ),
    );
  }

  Widget _buildGalleryTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.row),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ListTile(
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showModal(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }
}
