import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/formatters.dart';
import '../../../app/providers/providers.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/segmented_controls.dart' as ui;
import '../../../core/widgets/state_widgets.dart';
import '../../../domain/food/food.dart';
import '../../../domain/profile/user_profile.dart';
import '../ui/settings_screen.dart';
import 'meal_schedule_sheet.dart';
import 'settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(settingsControllerProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => ErrorStateWidget(
        message: 'Settings could not be loaded. Your saved data is safe.',
        onRetry: () => ref.invalidate(settingsControllerProvider),
      ),
      data: (vm) => SettingsScreen(
        vm: vm,
        onOpenHistory: () => context.push(AppRoutes.history),
        onOpenShopping: () => context.push(AppRoutes.shopping),
        onOpenReminders: () => context.push(AppRoutes.reminders),
        onOpenPrivacy: () => context.push(AppRoutes.privacy),
        onOpenTransparency: () => context.push(AppRoutes.transparency),
        onOpenProfileTarget: () => _profileSheet(context, ref),
        onOpenCookingRichness: () => _richnessSheet(context, ref),
        onOpenAllergies: () => _restrictionsSheet(context, ref),
        onOpenLanguage: () => _languageSheet(context),
        onOpenMealSchedule: () => MealScheduleSheet.show(context),
        onSendFeedback: () async {
          final config = ref.read(appConfigProvider);
          final ok = await ref.read(linkServiceProvider).composeEmail(
              to: config.supportEmail, subject: 'Diet Planner feedback');
          if (!ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No email app found on this phone.')),
            );
          }
        },
        onOpenAbout: () => _aboutSheet(context, ref),
      ),
    );
  }

  Future<void> _profileSheet(BuildContext context, WidgetRef ref) async {
    final setup = await ref.read(profileRepositoryProvider).load();
    if (setup == null || !context.mounted) return;
    final p = setup.profile;
    final today = ref.read(todayProvider);
    final rows = <(String, String)>[
      (
        'Sex & age',
        '${p.sex == Sex.male ? 'Male' : 'Female'} · born ${p.birthYear} (about ${p.ageIn(today)})'
      ),
      (
        'Height & weight',
        '${p.heightCm.round()} cm · ${p.weightKg.toStringAsFixed(1)} kg (BMI ${p.bmi.toStringAsFixed(1)})'
      ),
      (
        'Activity',
        switch (p.activity) {
          ActivityLevel.sedentary => 'Mostly sitting',
          ActivityLevel.light => 'Lightly active',
          ActivityLevel.moderate => 'Moderately active',
          ActivityLevel.veryActive => 'Very active',
        }
      ),
      (
        'Daily target',
        setup.target == null
            ? 'Manual logging only'
            : '~${Fmt.kcal(setup.target!.kcal)} kcal · estimate'
      ),
    ];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Profile & calorie target',
                  style: AppTypography.titleMedium),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final r in rows)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 2,
                                child:
                                    Text(r.$1, style: AppTypography.caption)),
                            const SizedBox(width: 12),
                            Expanded(
                                flex: 3,
                                child: Text(r.$2,
                                    textAlign: TextAlign.end,
                                    style: AppTypography.captionStrong)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                  'Changes apply to plans made from now on. Today\'s plan stays unless you make a new one.',
                  style: AppTypography.caption),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Update my details',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push('${AppRoutes.onboarding}?edit=1');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _richnessSheet(BuildContext context, WidgetRef ref) async {
    final setup = await ref.read(profileRepositoryProvider).load();
    if (setup == null || !context.mounted) return;
    var selected = Fmt.toUiOil(setup.profile.cookingRichness);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Default cooking richness',
                    style: AppTypography.titleMedium),
                const SizedBox(height: 6),
                Text(
                    'How much oil or ghee is assumed in salan, karahi and daal. Used for plans made from now on; '
                    'you can still change oil for any single meal.',
                    style: AppTypography.caption),
                const SizedBox(height: 16),
                ui.OilLevelSelector(
                    selected: selected,
                    onChanged: (l) => setSheet(() => selected = l)),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Save',
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await ref
                        .read(settingsControllerProvider.notifier)
                        .updateRichness(Fmt.fromUiOil(selected));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _restrictionsSheet(BuildContext context, WidgetRef ref) async {
    final setup = await ref.read(profileRepositoryProvider).load();
    if (setup == null || !context.mounted) return;
    var prefs = setup.preferences;
    const allergyLabels = {
      Allergen.gluten: (
        'Gluten',
        'Wheat roti, paratha, naan, bread, rusk, suji'
      ),
      Allergen.dairy: ('Dairy', 'Milk, chai, dahi, raita, lassi, ghee'),
      Allergen.nuts: ('Nuts', 'Almonds and other nuts'),
      Allergen.egg: ('Egg', 'Eggs and omelettes'),
      Allergen.fish: ('Fish', 'Fish curry'),
    };
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Diet & allergies', style: AppTypography.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                      'Foods with these are never planned. Changes apply to today\'s plan right away.',
                      style: AppTypography.caption),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final d in DietType.values)
                        ChoiceChip(
                          label: Text(switch (d) {
                            DietType.everything => 'Everything',
                            DietType.vegetarian => 'Vegetarian',
                            DietType.vegan => 'Vegan',
                            DietType.pescatarian => 'Pescatarian',
                          }),
                          selected: prefs.dietType == d,
                          onSelected: (_) => setSheet(
                              () => prefs = prefs.copyWith(dietType: d)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final e in allergyLabels.entries)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${e.value.$1} allergy'),
                      subtitle: Text(e.value.$2),
                      value: prefs.allergies.contains(e.key),
                      onChanged: (on) => setSheet(() {
                        final a = {...prefs.allergies};
                        on ? a.add(e.key) : a.remove(e.key);
                        prefs = prefs.copyWith(allergies: a);
                      }),
                    ),
                  const SizedBox(height: 4),
                  Text(
                      'Ingredient lists cannot rule out cross-contact in kitchens, spice mixes or restaurants.',
                      style: AppTypography.caption),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Save',
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await ref
                          .read(settingsControllerProvider.notifier)
                          .updatePreferences(prefs);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _languageSheet(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Language / زبان', style: AppTypography.titleMedium),
                const SizedBox(height: 12),
                const ListTile(
                  leading: Icon(Icons.check),
                  title: Text('English'),
                  subtitle: Text(
                      'Food names also show in Urdu, and search understands Roman Urdu'),
                ),
                const ListTile(
                  leading: SizedBox(width: 24),
                  title: Text('اردو (Urdu)'),
                  subtitle: Text('Planned for version 1.1'),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _aboutSheet(BuildContext context, WidgetRef ref) async {
    final pack = await ref.read(foodPackProvider.future);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('About & disclaimer', style: AppTypography.titleMedium),
              const SizedBox(height: 12),
              Text(
                'Calories and nutrients in this app are estimates. They help you plan everyday meals; '
                'they are not medical advice and do not treat any condition. If you are pregnant, '
                'breastfeeding, under 18 or follow a medical diet, please speak to a doctor or dietitian.',
                style: AppTypography.body,
              ),
              const SizedBox(height: 12),
              Text(
                'Nutrition data: USDA FoodData Central (public domain). Recipes, portions and Urdu names: '
                'project content. Food pack ${pack.packVersion}: ${pack.reviewedFoodCount} of ${pack.foods.length} '
                'foods reviewed by a nutrition professional so far.',
                style: AppTypography.caption,
              ),
              if (pack.isDraft) ...[
                const SizedBox(height: 8),
                Text(pack.notice, style: AppTypography.captionStrong),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
