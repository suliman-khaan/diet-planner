import 'common/local_date.dart';
import 'food/food.dart';
import 'log/food_log.dart';
import 'plan/daily_plan.dart';
import 'profile/target_policy.dart';
import 'profile/user_profile.dart';
import 'progress/progress.dart';
import 'reminders/reminder_schedule.dart';

/// Repository contracts. The data lane implements them; controllers depend only on these.
/// Changing a signature is a contract change (see .agent/rules/collaboration.md §4).

abstract interface class FoodRepository {
  /// The active food pack. Bundled with the app; never needs network.
  Future<FoodPack> loadPack();
}

/// Everything onboarding produces. Saved together so it is never half-written.
class UserSetup {
  const UserSetup({
    required this.profile,
    required this.preferences,
    required this.schedule,
    required this.target,
    required this.policyVersion,
  });

  final UserProfile profile;
  final DietaryPreferences preferences;
  final MealSchedule schedule;

  /// Null when the user is in manual-only mode.
  final NutritionTarget? target;
  final String policyVersion;

  UserSetup copyWith({
    UserProfile? profile,
    DietaryPreferences? preferences,
    MealSchedule? schedule,
    NutritionTarget? target,
    String? policyVersion,
    bool clearTarget = false,
  }) =>
      UserSetup(
        profile: profile ?? this.profile,
        preferences: preferences ?? this.preferences,
        schedule: schedule ?? this.schedule,
        target: clearTarget ? null : (target ?? this.target),
        policyVersion: policyVersion ?? this.policyVersion,
      );
}

abstract interface class ProfileRepository {
  Future<UserSetup?> load();
  Future<void> save(UserSetup setup);
}

abstract interface class PlanRepository {
  Future<DailyPlan?> planFor(LocalDate date);
  Future<List<DailyPlan>> plansBetween(LocalDate from, LocalDate to);

  /// Stores [plan] for its date, replacing any previous plan for that date. Assigns ids.
  Future<DailyPlan> savePlan(DailyPlan plan);

  /// Replaces one meal's items (regenerate, add, remove, resize). Assigns ids to new items.
  Future<PlannedMeal> saveMeal(String planId, PlannedMeal meal);
}

abstract interface class FoodLogRepository {
  Future<List<FoodLogEntry>> entriesFor(LocalDate date);
  Future<List<FoodLogEntry>> entriesBetween(LocalDate from, LocalDate to);
  Future<void> add(List<FoodLogEntry> entries);

  /// Soft delete (tombstone), used for undo.
  Future<void> remove(List<String> ids);
}

abstract interface class WeightRepository {
  Future<List<WeightEntry>> all();
  Future<WeightEntry> add(LocalDate date, double weightKg);
  Future<void> update(WeightEntry entry);
  Future<void> remove(String id);
}

class ManualShoppingItem {
  const ManualShoppingItem({required this.id, required this.name, required this.purchased});

  final String id;
  final String name;
  final bool purchased;
}

abstract interface class ShoppingRepository {
  /// Keys of computed lines marked purchased for the list starting on [listDate].
  /// Kept when the list is recalculated.
  Future<Set<String>> purchasedKeys(LocalDate listDate);
  Future<void> setPurchased(LocalDate listDate, String key, bool purchased);
  Future<List<ManualShoppingItem>> manualItems(LocalDate listDate);
  Future<void> addManualItem(LocalDate listDate, String name);
  Future<void> setManualPurchased(String id, bool purchased);
  Future<void> removeManualItem(String id);
}

class AppSettings {
  const AppSettings({
    this.onboardingComplete = false,
    this.analyticsConsent = false,
    this.crashReportingConsent = false,
    this.consentAsked = false,
    this.reminders = const ReminderPreferences(),
    this.lastReminderTimezone,
    this.lowIntakeCheckDismissedOn,
  });

  final bool onboardingComplete;
  final bool analyticsConsent;
  final bool crashReportingConsent;
  final bool consentAsked;
  final ReminderPreferences reminders;
  final String? lastReminderTimezone;
  final LocalDate? lowIntakeCheckDismissedOn;

  AppSettings copyWith({
    bool? onboardingComplete,
    bool? analyticsConsent,
    bool? crashReportingConsent,
    bool? consentAsked,
    ReminderPreferences? reminders,
    String? lastReminderTimezone,
    LocalDate? lowIntakeCheckDismissedOn,
  }) =>
      AppSettings(
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        analyticsConsent: analyticsConsent ?? this.analyticsConsent,
        crashReportingConsent: crashReportingConsent ?? this.crashReportingConsent,
        consentAsked: consentAsked ?? this.consentAsked,
        reminders: reminders ?? this.reminders,
        lastReminderTimezone: lastReminderTimezone ?? this.lastReminderTimezone,
        lowIntakeCheckDismissedOn: lowIntakeCheckDismissedOn ?? this.lowIntakeCheckDismissedOn,
      );
}

abstract interface class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

/// Export → wipe → import must restore everything (blueprint Phase 2).
abstract interface class DataPortability {
  /// All user data as a JSON-encodable map.
  Future<Map<String, Object?>> exportAll();

  /// Replaces all user data with [data]. Validates first; on any error nothing changes.
  Future<void> importAll(Map<String, Object?> data);

  Future<void> deleteAll();
}
