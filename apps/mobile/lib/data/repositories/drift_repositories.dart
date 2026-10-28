import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/clock/clock.dart';
import '../../core/errors/app_failure.dart';
import '../../core/ids/ids.dart';
import '../../domain/common/local_date.dart';
import '../../domain/common/meal_slot.dart';
import '../../domain/common/nutrition.dart';
import '../../domain/log/food_log.dart';
import '../../domain/plan/daily_plan.dart';
import '../../domain/profile/target_policy.dart';
import '../../domain/profile/user_profile.dart';
import '../../domain/progress/progress.dart';
import '../../domain/reminders/reminder_schedule.dart';
import '../../domain/repositories.dart';
import '../db/app_database.dart';

Map<String, Object?> _decodeObject(String json, String what) {
  try {
    final Object? v = jsonDecode(json);
    if (v is Map<String, Object?>) return v;
  } on FormatException {
    // Fall through to the typed failure below.
  }
  throw StorageCorrupted('Unreadable $what record');
}

class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  @override
  Future<UserSetup?> load() async {
    final row = await (_db.select(_db.profiles)..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (row == null) return null;
    try {
      return UserSetup(
        profile:
            UserProfile.fromJson(_decodeObject(row.profileJson, 'profile')),
        preferences: DietaryPreferences.fromJson(
            _decodeObject(row.preferencesJson, 'preferences')),
        schedule:
            MealSchedule.fromJson(_decodeObject(row.scheduleJson, 'schedule')),
        target: row.targetJson == null
            ? null
            : NutritionTarget.fromJson(
                _decodeObject(row.targetJson!, 'target')),
        policyVersion: row.policyVersion,
      );
    } on StorageCorrupted {
      rethrow;
    } catch (e) {
      throw StorageCorrupted('Invalid profile record: ${e.runtimeType}');
    }
  }

  @override
  Future<void> save(UserSetup setup) async {
    final now = _clock.nowUtc();
    final existing = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    await _db
        .into(_db.profiles)
        .insertOnConflictUpdate(ProfilesCompanion.insert(
          id: const Value(1),
          profileJson: jsonEncode(setup.profile.toJson()),
          preferencesJson: jsonEncode(setup.preferences.toJson()),
          scheduleJson: jsonEncode(setup.schedule.toJson()),
          targetJson: Value(
              setup.target == null ? null : jsonEncode(setup.target!.toJson())),
          policyVersion: setup.policyVersion,
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
        ));
  }
}

class DriftPlanRepository implements PlanRepository {
  DriftPlanRepository(this._db, this._clock, this._ids, this._timezone);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;

  /// IANA timezone of the device when the plan was made, stored with the local date.
  final String Function() _timezone;

  @override
  Future<DailyPlan?> planFor(LocalDate date) async {
    final row = await (_db.select(_db.plans)
          ..where((t) => t.date.equals(date.toIso()) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _assemble(row);
  }

  @override
  Future<List<DailyPlan>> plansBetween(LocalDate from, LocalDate to) async {
    final rows = await (_db.select(_db.plans)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(from.toIso()) &
              t.date.isSmallerOrEqualValue(to.toIso()) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
    return [for (final r in rows) await _assemble(r)];
  }

  @override
  Future<DailyPlan> savePlan(DailyPlan plan) => _db.transaction(() async {
        final now = _clock.nowUtc();
        // Tombstone the previous plan for this date; its meals and items go with it.
        final old = await (_db.select(_db.plans)
              ..where((t) =>
                  t.date.equals(plan.date.toIso()) & t.deletedAt.isNull()))
            .get();
        for (final o in old) {
          await _tombstonePlan(o.id, now);
        }
        final planId = _ids.newId();
        await _db.into(_db.plans).insert(PlansCompanion.insert(
              id: planId,
              date: plan.date.toIso(),
              timezone: _timezone(),
              targetKcal: plan.targetKcal,
              policyVersion: plan.policyVersion,
              packVersion: plan.packVersion,
              seed: plan.seed,
              usesDraftData: plan.usesDraftData,
              createdAt: now,
              updatedAt: now,
            ));
        final meals = <PlannedMeal>[];
        for (var i = 0; i < plan.meals.length; i++) {
          meals.add(await _insertMeal(planId, plan.meals[i], i, now));
        }
        return plan.copyWith(id: planId, meals: meals);
      });

  @override
  Future<PlannedMeal> saveMeal(String planId, PlannedMeal meal) =>
      _db.transaction(() async {
        final now = _clock.nowUtc();
        await (_db.update(_db.plans)..where((t) => t.id.equals(planId)))
            .write(PlansCompanion(updatedAt: Value(now)));
        final existing = meal.id.isEmpty
            ? null
            : await (_db.select(_db.planMeals)
                  ..where((t) => t.id.equals(meal.id)))
                .getSingleOrNull();
        if (existing == null) {
          final count = await (_db.select(_db.planMeals)
                ..where((t) => t.planId.equals(planId) & t.deletedAt.isNull()))
              .get();
          return _insertMeal(planId, meal.copyWith(id: ''), count.length, now);
        }
        // Same meal id: update the meal row and replace its items. Items that are kept keep
        // their ids; removed items are tombstoned.
        await (_db.update(_db.planMeals)..where((t) => t.id.equals(meal.id)))
            .write(PlanMealsCompanion(
          comboId: Value(meal.comboId),
          updatedAt: Value(now),
          deletedAt: const Value(null),
        ));
        await (_db.update(_db.planItems)
              ..where((t) => t.mealId.equals(meal.id) & t.deletedAt.isNull()))
            .write(PlanItemsCompanion(
                deletedAt: Value(now), updatedAt: Value(now)));
        return _writeItems(meal.id, meal, now);
      });

  @override
  Future<void> removePlansFrom(LocalDate from) => _db.transaction(() async {
        final now = _clock.nowUtc();
        final rows = await (_db.select(_db.plans)
              ..where((t) =>
                  t.date.isBiggerOrEqualValue(from.toIso()) &
                  t.deletedAt.isNull()))
            .get();
        for (final r in rows) {
          await _tombstonePlan(r.id, now);
        }
      });

  Future<PlannedMeal> _insertMeal(
      String planId, PlannedMeal meal, int position, DateTime now) async {
    final mealId = _ids.newId();
    await _db.into(_db.planMeals).insert(PlanMealsCompanion.insert(
          id: mealId,
          planId: planId,
          slot: meal.slot.name,
          minutesOfDay: meal.minutesOfDay,
          comboId: Value(meal.comboId),
          position: position,
          createdAt: now,
          updatedAt: now,
        ));
    return _writeItems(mealId, meal, now);
  }

  Future<PlannedMeal> _writeItems(
      String mealId, PlannedMeal meal, DateTime now) async {
    final items = <PlanItem>[];
    for (var i = 0; i < meal.items.length; i++) {
      final item = meal.items[i];
      // Items keep their id when a meal is re-saved, so logs that point at them stay valid.
      final itemId = item.id.isEmpty ? _ids.newId() : item.id;
      final reused = item.id.isNotEmpty &&
          await (_db.select(_db.planItems)..where((t) => t.id.equals(itemId)))
                  .getSingleOrNull() !=
              null;
      final companion = PlanItemsCompanion.insert(
        id: itemId,
        mealId: mealId,
        foodId: item.foodId,
        foodRevision: item.foodRevision,
        servingId: item.servingId,
        servings: item.servings,
        grams: item.grams,
        oilLevel: Value(item.oilLevel?.name),
        fromSharedDish: item.fromSharedDish,
        kcal: item.nutrition.kcal,
        protein: item.nutrition.protein,
        carbs: item.nutrition.carbs,
        fat: item.nutrition.fat,
        fibre: item.nutrition.fibre,
        position: i,
        createdAt: now,
        updatedAt: now,
      );
      if (reused) {
        await (_db.update(_db.planItems)..where((t) => t.id.equals(itemId)))
            .write(companion.copyWith(deletedAt: const Value(null)));
      } else {
        await _db.into(_db.planItems).insert(companion);
      }
      items.add(item.copyWith(id: itemId));
    }
    return meal.copyWith(id: mealId, items: items);
  }

  Future<void> _tombstonePlan(String planId, DateTime now) async {
    final meals = await (_db.select(_db.planMeals)
          ..where((t) => t.planId.equals(planId)))
        .get();
    for (final m in meals) {
      await _tombstoneMeal(m.id, now);
    }
    await (_db.update(_db.plans)..where((t) => t.id.equals(planId)))
        .write(PlansCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }

  Future<void> _tombstoneMeal(String mealId, DateTime now) async {
    await (_db.update(_db.planItems)
          ..where((t) => t.mealId.equals(mealId) & t.deletedAt.isNull()))
        .write(
            PlanItemsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await (_db.update(_db.planMeals)..where((t) => t.id.equals(mealId))).write(
        PlanMealsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }

  Future<DailyPlan> _assemble(PlanRow row) async {
    final mealRows = await (_db.select(_db.planMeals)
          ..where((t) => t.planId.equals(row.id) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.minutesOfDay),
            (t) => OrderingTerm.asc(t.position)
          ]))
        .get();
    final meals = <PlannedMeal>[];
    for (final m in mealRows) {
      final itemRows = await (_db.select(_db.planItems)
            ..where((t) => t.mealId.equals(m.id) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();
      meals.add(PlannedMeal(
        id: m.id,
        slot: MealSlot.fromName(m.slot),
        minutesOfDay: m.minutesOfDay,
        comboId: m.comboId,
        items: [
          for (final i in itemRows)
            PlanItem(
              id: i.id,
              foodId: i.foodId,
              foodRevision: i.foodRevision,
              servingId: i.servingId,
              servings: i.servings,
              grams: i.grams,
              oilLevel:
                  i.oilLevel == null ? null : OilLevel.fromName(i.oilLevel!),
              fromSharedDish: i.fromSharedDish,
              nutrition: Nutrition(
                  kcal: i.kcal,
                  protein: i.protein,
                  carbs: i.carbs,
                  fat: i.fat,
                  fibre: i.fibre),
            ),
        ],
      ));
    }
    return DailyPlan(
      id: row.id,
      date: LocalDate.parse(row.date),
      meals: meals,
      targetKcal: row.targetKcal,
      policyVersion: row.policyVersion,
      packVersion: row.packVersion,
      seed: row.seed,
      usesDraftData: row.usesDraftData,
    );
  }
}

class DriftFoodLogRepository implements FoodLogRepository {
  DriftFoodLogRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  @override
  Future<List<FoodLogEntry>> entriesFor(LocalDate date) =>
      entriesBetween(date, date);

  @override
  Future<List<FoodLogEntry>> entriesBetween(
      LocalDate from, LocalDate to) async {
    final rows = await (_db.select(_db.foodLogs)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(from.toIso()) &
              t.date.isSmallerOrEqualValue(to.toIso()) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.loggedAt)]))
        .get();
    return rows.map(_toEntry).toList();
  }

  @override
  Future<void> add(List<FoodLogEntry> entries) => _db.transaction(() async {
        final now = _clock.nowUtc();
        for (final e in entries) {
          await _db.into(_db.foodLogs).insert(FoodLogsCompanion.insert(
                id: e.id,
                date: e.date.toIso(),
                slot: e.slot.name,
                source: e.source.name,
                label: e.label,
                kcal: e.nutrition.kcal,
                protein: e.nutrition.protein,
                carbs: e.nutrition.carbs,
                fat: e.nutrition.fat,
                fibre: e.nutrition.fibre,
                loggedAt: e.loggedAtUtc,
                planItemId: Value(e.planItemId),
                foodId: Value(e.foodId),
                foodRevision: Value(e.foodRevision),
                packVersion: Value(e.packVersion),
                grams: Value(e.grams),
                oilLevel: Value(e.oilLevel?.name),
                createdAt: now,
                updatedAt: now,
              ));
        }
      });

  @override
  Future<void> remove(List<String> ids) async {
    final now = _clock.nowUtc();
    await (_db.update(_db.foodLogs)..where((t) => t.id.isIn(ids)))
        .write(FoodLogsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }

  static FoodLogEntry _toEntry(FoodLogRow r) => FoodLogEntry(
        id: r.id,
        date: LocalDate.parse(r.date),
        slot: MealSlot.fromName(r.slot),
        source: LogSource.values.byName(r.source),
        label: r.label,
        nutrition: Nutrition(
            kcal: r.kcal,
            protein: r.protein,
            carbs: r.carbs,
            fat: r.fat,
            fibre: r.fibre),
        loggedAtUtc: r.loggedAt.toUtc(),
        planItemId: r.planItemId,
        foodId: r.foodId,
        foodRevision: r.foodRevision,
        packVersion: r.packVersion,
        grams: r.grams,
        oilLevel: r.oilLevel == null ? null : OilLevel.fromName(r.oilLevel!),
      );
}

class DriftWeightRepository implements WeightRepository {
  DriftWeightRepository(this._db, this._clock, this._ids);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;

  @override
  Future<List<WeightEntry>> all() async {
    final rows = await (_db.select(_db.weights)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.date),
            (t) => OrderingTerm.asc(t.createdAt)
          ]))
        .get();
    return [
      for (final r in rows)
        WeightEntry(
            id: r.id, date: LocalDate.parse(r.date), weightKg: r.weightKg)
    ];
  }

  @override
  Future<WeightEntry> add(LocalDate date, double weightKg) async {
    final now = _clock.nowUtc();
    final id = _ids.newId();
    await _db.into(_db.weights).insert(WeightsCompanion.insert(
          id: id,
          date: date.toIso(),
          weightKg: weightKg,
          createdAt: now,
          updatedAt: now,
        ));
    return WeightEntry(id: id, date: date, weightKg: weightKg);
  }

  @override
  Future<void> update(WeightEntry entry) async {
    await (_db.update(_db.weights)..where((t) => t.id.equals(entry.id)))
        .write(WeightsCompanion(
      date: Value(entry.date.toIso()),
      weightKg: Value(entry.weightKg),
      updatedAt: Value(_clock.nowUtc()),
    ));
  }

  @override
  Future<void> remove(String id) async {
    final now = _clock.nowUtc();
    await (_db.update(_db.weights)..where((t) => t.id.equals(id)))
        .write(WeightsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }
}

class DriftShoppingRepository implements ShoppingRepository {
  DriftShoppingRepository(this._db, this._clock, this._ids);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;

  @override
  Future<Set<String>> purchasedKeys(LocalDate listDate) async {
    final rows = await (_db.select(_db.shoppingChecks)
          ..where((t) =>
              t.listDate.equals(listDate.toIso()) & t.purchased.equals(true)))
        .get();
    return {for (final r in rows) r.itemKey};
  }

  @override
  Future<void> setPurchased(
      LocalDate listDate, String key, bool purchased) async {
    await _db
        .into(_db.shoppingChecks)
        .insertOnConflictUpdate(ShoppingChecksCompanion.insert(
          listDate: listDate.toIso(),
          itemKey: key,
          purchased: purchased,
          updatedAt: _clock.nowUtc(),
        ));
  }

  @override
  Future<List<ManualShoppingItem>> manualItems(LocalDate listDate) async {
    final rows = await (_db.select(_db.shoppingManualItems)
          ..where(
              (t) => t.listDate.equals(listDate.toIso()) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return [
      for (final r in rows)
        ManualShoppingItem(id: r.id, name: r.name, purchased: r.purchased)
    ];
  }

  @override
  Future<void> addManualItem(LocalDate listDate, String name) async {
    final now = _clock.nowUtc();
    await _db
        .into(_db.shoppingManualItems)
        .insert(ShoppingManualItemsCompanion.insert(
          id: _ids.newId(),
          listDate: listDate.toIso(),
          name: name,
          purchased: false,
          createdAt: now,
          updatedAt: now,
        ));
  }

  @override
  Future<void> setManualPurchased(String id, bool purchased) async {
    await (_db.update(_db.shoppingManualItems)..where((t) => t.id.equals(id)))
        .write(ShoppingManualItemsCompanion(
            purchased: Value(purchased), updatedAt: Value(_clock.nowUtc())));
  }

  @override
  Future<void> removeManualItem(String id) async {
    final now = _clock.nowUtc();
    await (_db.update(_db.shoppingManualItems)..where((t) => t.id.equals(id)))
        .write(ShoppingManualItemsCompanion(
            deletedAt: Value(now), updatedAt: Value(now)));
  }
}

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;
  static const _key = 'app_settings';

  @override
  Future<AppSettings> load() async {
    final row = await (_db.select(_db.settings)
          ..where((t) => t.key.equals(_key)))
        .getSingleOrNull();
    if (row == null) return const AppSettings();
    final m = _decodeObject(row.value, 'settings');
    final dismissed = m['lowIntakeCheckDismissedOn'] as String?;
    return AppSettings(
      onboardingComplete: m['onboardingComplete'] == true,
      analyticsConsent: m['analyticsConsent'] == true,
      crashReportingConsent: m['crashReportingConsent'] == true,
      consentAsked: m['consentAsked'] == true,
      reminders: m['reminders'] is Map<String, Object?>
          ? ReminderPreferences.fromJson(
              m['reminders']! as Map<String, Object?>)
          : const ReminderPreferences(),
      lastReminderTimezone: m['lastReminderTimezone'] as String?,
      lowIntakeCheckDismissedOn:
          dismissed == null ? null : LocalDate.parse(dismissed),
    );
  }

  @override
  Future<void> save(AppSettings s) async {
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(SettingsCompanion.insert(
          key: _key,
          value: jsonEncode({
            'onboardingComplete': s.onboardingComplete,
            'analyticsConsent': s.analyticsConsent,
            'crashReportingConsent': s.crashReportingConsent,
            'consentAsked': s.consentAsked,
            'reminders': s.reminders.toJson(),
            'lastReminderTimezone': s.lastReminderTimezone,
            'lowIntakeCheckDismissedOn': s.lowIntakeCheckDismissedOn?.toIso(),
          }),
        ));
  }
}
