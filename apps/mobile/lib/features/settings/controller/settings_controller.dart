import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/day_service.dart';
import '../../../app/providers/formatters.dart';
import '../../../app/providers/providers.dart';
import '../../../app/providers/reminder_coordinator.dart';
import '../../../domain/common/meal_slot.dart';
import '../../../domain/food/food.dart';
import '../../../domain/log/food_log.dart';
import '../../../domain/plan/food_filter.dart';
import '../../../domain/profile/user_profile.dart';
import '../../../domain/repositories.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../today/controller/today_controller.dart';
import '../ui/settings_screen.dart';

class SettingsController extends AsyncNotifier<SettingsViewModel> {
  @override
  Future<SettingsViewModel> build() async {
    final setup = await ref.watch(userSetupProvider.future);
    final pack = await ref.watch(foodPackProvider.future);
    if (setup == null) return const SettingsViewModel();
    final prefs = setup.preferences;
    final exclusions = [
      if (prefs.dietType != DietType.everything) _dietLabel(prefs.dietType),
      for (final a in prefs.allergies) '${a.name[0].toUpperCase()}${a.name.substring(1)} allergy',
      if (prefs.excludedIngredientIds.isNotEmpty) '${prefs.excludedIngredientIds.length} excluded ingredients',
    ];
    final slots = setup.schedule.normalSlots;
    return SettingsViewModel(
      targetSummary: setup.target == null
          ? 'Manual logging only · no automatic target'
          : '~${Fmt.kcal(setup.target!.kcal)} kcal/day · estimate',
      richnessSummary: switch (setup.profile.cookingRichness) {
        OilLevel.light => 'Light (about 1 tsp oil per katori)',
        OilLevel.normal => 'Normal (about 2 tsp oil per katori)',
        OilLevel.rich => 'Rich (about 4 tsp oil per katori)',
      },
      exclusionsSummary: exclusions.isEmpty ? 'None set' : exclusions.join(', '),
      scheduleSummary: '${slots.length} meals${setup.schedule.ramadanStart != null ? ' · Ramadan dates set' : ''}',
      versionLabel: 'Diet Planner 0.1.0 · food pack ${pack.packVersion}${pack.isDraft ? ' (draft)' : ''}',
    );
  }

  static String _dietLabel(DietType d) => switch (d) {
        DietType.everything => 'Everything',
        DietType.vegetarian => 'Vegetarian',
        DietType.vegan => 'Vegan',
        DietType.pescatarian => 'Pescatarian',
      };

  Future<UserSetup?> _setup() => ref.read(profileRepositoryProvider).load();

  Future<void> _saveAndRefresh(UserSetup setup) async {
    await ref.read(profileRepositoryProvider).save(setup);
    ref
      ..invalidate(userSetupProvider)
      ..invalidate(todayControllerProvider)
      ..invalidateSelf();
    await ref.read(reminderCoordinatorProvider).reschedule();
  }

  /// Restrictions apply at once: today's plan is remade if any not-yet-eaten item no longer
  /// fits, and later plans are made again. Exclusions are never silently ignored.
  Future<void> updatePreferences(DietaryPreferences prefs) async {
    final setup = await _setup();
    if (setup == null) return;
    final updated = setup.copyWith(preferences: prefs);
    await ref.read(profileRepositoryProvider).save(updated);
    final service = ref.read(dayServiceProvider);
    final today = service.today;
    await ref.read(planRepositoryProvider).removePlansFrom(today.addDays(1));
    final day = await service.load(today, generateIfMissing: false);
    final plan = day?.plan;
    if (day != null && plan != null) {
      final filter = FoodFilter(preferences: prefs, allowDraftData: ref.read(appConfigProvider).allowDraftData);
      final violates = plan.meals.any((m) => m.items.any((i) {
            final food = day.pack.food(i.foodId);
            return !isPlanItemLogged(i.id, day.logs) && (food == null || !filter.allows(food));
          }));
      if (violates) await service.regenerateDay(day);
    }
    await _saveAndRefresh(updated);
  }

  /// Affects plans made from now on; today's plan keeps its oil levels unless the user edits it.
  Future<void> updateRichness(OilLevel level) async {
    final setup = await _setup();
    if (setup == null) return;
    await ref.read(planRepositoryProvider).removePlansFrom(ref.read(dayServiceProvider).today.addDays(1));
    await _saveAndRefresh(setup.copyWith(profile: setup.profile.copyWith(cookingRichness: level)));
  }

  Future<void> updateSchedule(MealSchedule schedule) async {
    final setup = await _setup();
    if (setup == null) return;
    final service = ref.read(dayServiceProvider);
    final today = service.today;
    final todayLogs = await ref.read(foodLogRepositoryProvider).entriesFor(today);
    // Today's plan is remade only if nothing has been logged yet.
    await ref.read(planRepositoryProvider).removePlansFrom(todayLogs.isEmpty ? today : today.addDays(1));
    if (schedule.ramadanStart != null && setup.schedule.ramadanStart == null) {
      ref.read(analyticsServiceProvider).log(AnalyticsEvent.ramadanModeEnabled);
    }
    await _saveAndRefresh(setup.copyWith(schedule: schedule));
  }

  Future<void> setAllergy(Allergen allergen, bool on) async {
    final setup = await _setup();
    if (setup == null) return;
    final allergies = {...setup.preferences.allergies};
    on ? allergies.add(allergen) : allergies.remove(allergen);
    await updatePreferences(setup.preferences.copyWith(allergies: allergies));
  }

  Future<void> setDietType(DietType type) async {
    final setup = await _setup();
    if (setup == null) return;
    await updatePreferences(setup.preferences.copyWith(dietType: type));
  }

  /// Slots offered in the meal-times sheet besides the default four.
  static const optionalSlots = [MealSlot.snack];
}

final settingsControllerProvider = AsyncNotifierProvider<SettingsController, SettingsViewModel>(SettingsController.new);
