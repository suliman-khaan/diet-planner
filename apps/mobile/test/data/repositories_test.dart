import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/clock/clock.dart';
import 'package:mobile/core/errors/app_failure.dart';
import 'package:mobile/core/ids/ids.dart';
import 'package:mobile/data/db/app_database.dart';
import 'package:mobile/data/db/open_database.dart';
import 'package:mobile/data/food/asset_food_repository.dart';
import 'package:mobile/data/repositories/drift_data_portability.dart';
import 'package:mobile/data/repositories/drift_repositories.dart';
import 'package:mobile/domain/common/local_date.dart';
import 'package:mobile/domain/common/meal_slot.dart';
import 'package:mobile/domain/common/nutrition.dart';
import 'package:mobile/domain/log/food_log.dart';
import 'package:mobile/domain/plan/daily_plan.dart';
import 'package:mobile/domain/plan/food_filter.dart';
import 'package:mobile/domain/plan/planner.dart';
import 'package:mobile/domain/profile/target_policy.dart';
import 'package:mobile/domain/profile/user_profile.dart';
import 'package:mobile/domain/progress/progress.dart';
import 'package:mobile/domain/reminders/reminder_schedule.dart';
import 'package:mobile/domain/repositories.dart';

import '../domain/helpers.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late SequentialIdGenerator ids;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime(2026, 10, 29, 12));
    ids = SequentialIdGenerator();
  });
  tearDown(() => db.close());

  DriftPlanRepository plansRepo() => DriftPlanRepository(db, clock, ids, () => 'Asia/Karachi');

  DailyPlan makePlan({int seed = 1, LocalDate? date}) {
    final pack = loadBundledPack();
    final r = const Planner().generate(PlanRequest(
      date: date ?? testToday,
      target: const NutritionTarget(kcal: 1800, proteinG: 90, carbsG: 225, fatG: 60, fibreG: 25),
      pack: pack,
      slots: MealSchedule.defaults.normalSlots,
      filter: const FoodFilter(preferences: DietaryPreferences(), allowDraftData: true),
      oilLevel: OilLevel.normal,
      seed: seed,
      policyVersion: 'test',
    ));
    return (r as PlanSuccess).plan;
  }

  UserSetup setup() => UserSetup(
        profile: profile(),
        preferences: const DietaryPreferences(dietType: DietType.vegetarian),
        schedule: MealSchedule.defaults,
        target: const NutritionTarget(kcal: 1800, proteinG: 90, carbsG: 225, fatG: 60, fibreG: 25),
        policyVersion: 'p1',
      );

  group('profile', () {
    test('saves and loads the whole setup', () async {
      final repo = DriftProfileRepository(db, clock);
      expect(await repo.load(), isNull);
      await repo.save(setup());
      final loaded = (await repo.load())!;
      expect(loaded.profile.toJson(), setup().profile.toJson());
      expect(loaded.preferences.dietType, DietType.vegetarian);
      expect(loaded.target!.kcal, 1800);
      await repo.save(setup().copyWith(clearTarget: true));
      expect((await repo.load())!.target, isNull);
    });

    test('a damaged record is reported, never silently reset', () async {
      await DriftProfileRepository(db, clock).save(setup());
      await db.customStatement("UPDATE profiles SET profile_json = '{not json'");
      await expectLater(DriftProfileRepository(db, clock).load(), throwsA(isA<StorageCorrupted>()));
      await db.customStatement("UPDATE profiles SET profile_json = '{\"goal\": \"nope\"}'");
      await expectLater(DriftProfileRepository(db, clock).load(), throwsA(isA<StorageCorrupted>()));
    });
  });

  group('plans', () {
    test('saving assigns ids and loads back identically', () async {
      final repo = plansRepo();
      final plan = makePlan();
      final saved = await repo.savePlan(plan);
      expect(saved.id, isNotEmpty);
      expect(saved.meals.every((m) => m.id.isNotEmpty && m.items.every((i) => i.id.isNotEmpty)), isTrue);
      final loaded = (await repo.planFor(testToday))!;
      expect(loaded.id, saved.id);
      expect(loaded.meals.map((m) => m.slot), plan.meals.map((m) => m.slot));
      expect(loaded.totals.kcal, closeTo(plan.totals.kcal, 1e-6));
      expect(loaded.meals.first.items.first.oilLevel, plan.meals.first.items.first.oilLevel);
      expect(await repo.planFor(testToday.addDays(1)), isNull);
    });

    test('a new plan for the same date replaces the old one (tombstoned)', () async {
      final repo = plansRepo();
      await repo.savePlan(makePlan(seed: 1));
      final second = await repo.savePlan(makePlan(seed: 2));
      expect((await repo.planFor(testToday))!.id, second.id);
      final allRows = await db.select(db.plans).get();
      expect(allRows.where((r) => r.deletedAt == null), hasLength(1));
      expect(allRows, hasLength(2));
    });

    test('re-saving one meal keeps item ids and leaves other meals alone', () async {
      final repo = plansRepo();
      final saved = await repo.savePlan(makePlan());
      final meal = saved.meals.first;
      final resized = meal.copyWith(items: [
        for (final i in meal.items) const Planner().resizeItem(loadBundledPack(), i, servings: i.servings),
      ]);
      final again = await repo.saveMeal(saved.id, resized);
      expect(again.items.map((i) => i.id), meal.items.map((i) => i.id));
      final loaded = (await repo.planFor(testToday))!;
      expect(loaded.meals, hasLength(saved.meals.length));
      expect(loaded.meals.last.id, saved.meals.last.id);
      final added = await repo.saveMeal(saved.id, PlannedMeal(
        slot: MealSlot.snack,
        minutesOfDay: 11 * 60,
        comboId: null,
        items: const [],
      ));
      expect(added.id, isNotEmpty);
      expect((await repo.planFor(testToday))!.meals, hasLength(saved.meals.length + 1));
    });

    test('plans between dates', () async {
      final repo = plansRepo();
      await repo.savePlan(makePlan(date: testToday));
      await repo.savePlan(makePlan(date: testToday.addDays(1)));
      await repo.savePlan(makePlan(date: testToday.addDays(5)));
      final range = await repo.plansBetween(testToday, testToday.addDays(2));
      expect(range.map((p) => p.date), [testToday, testToday.addDays(1)]);
    });

    test('a crash mid-transaction leaves the last valid state', () async {
      final repo = plansRepo();
      final first = await repo.savePlan(makePlan(seed: 1));
      await expectLater(
        db.transaction(() async {
          await (db.update(db.plans)..where((t) => t.id.equals(first.id)))
              .write(PlansCompanion(deletedAt: Value(clock.nowUtc())));
          throw StateError('simulated crash');
        }),
        throwsStateError,
      );
      expect((await repo.planFor(testToday))!.id, first.id);
    });
  });

  group('food logs', () {
    test('add, read by date range, and soft-delete for undo', () async {
      final repo = DriftFoodLogRepository(db, clock);
      final plan = await plansRepo().savePlan(makePlan());
      final entries = logEntriesForMeal(
        meal: plan.meals.first,
        date: testToday,
        pack: loadBundledPack(),
        nowUtc: clock.nowUtc(),
        newId: ids.newId,
      );
      await repo.add(entries);
      final read = await repo.entriesFor(testToday);
      expect(read, hasLength(entries.length));
      expect(read.first.planItemId, plan.meals.first.items.first.id);
      expect(read.first.nutrition.kcal, closeTo(entries.first.nutrition.kcal, 1e-9));
      expect(read.first.source, LogSource.planned);
      expect(await repo.entriesBetween(testToday.addDays(1), testToday.addDays(2)), isEmpty);
      await repo.remove([read.first.id]);
      expect(await repo.entriesFor(testToday), hasLength(entries.length - 1));
    });

    test('snapshots do not change when the plan is replaced', () async {
      final repo = DriftFoodLogRepository(db, clock);
      final plan = await plansRepo().savePlan(makePlan(seed: 1));
      await repo.add(logEntriesForMeal(
          meal: plan.meals.first, date: testToday, pack: loadBundledPack(), nowUtc: clock.nowUtc(), newId: ids.newId));
      final before = (await repo.entriesFor(testToday)).map((e) => e.nutrition.kcal).toList();
      await plansRepo().savePlan(makePlan(seed: 7));
      expect((await repo.entriesFor(testToday)).map((e) => e.nutrition.kcal), before);
    });

    test('quick-add entries need no plan item', () async {
      final repo = DriftFoodLogRepository(db, clock);
      await repo.add([
        FoodLogEntry(
          id: 'q1',
          date: testToday,
          slot: MealSlot.chai,
          source: LogSource.quickAdd,
          label: 'Biscuits',
          nutrition: const Nutrition(kcal: 150, protein: 0, carbs: 0, fat: 0, fibre: 0),
          loggedAtUtc: clock.nowUtc(),
        ),
      ]);
      final e = (await repo.entriesFor(testToday)).single;
      expect(e.planItemId, isNull);
      expect(e.oilLevel, isNull);
    });
  });

  group('weights, shopping and settings', () {
    test('weights can be added, edited and deleted', () async {
      final repo = DriftWeightRepository(db, clock, ids);
      final a = await repo.add(testToday, 78.4);
      await repo.add(testToday.addDays(-7), 79);
      await repo.update(WeightEntry(id: a.id, date: a.date, weightKg: 78.2));
      expect((await repo.all()).map((w) => w.weightKg), [79, 78.2]);
      await repo.remove(a.id);
      expect(await repo.all(), hasLength(1));
    });

    test('purchased ticks persist and manual items work', () async {
      final repo = DriftShoppingRepository(db, clock, ids);
      await repo.setPurchased(testToday, 'atta', true);
      await repo.setPurchased(testToday, 'oil', true);
      await repo.setPurchased(testToday, 'oil', false);
      expect(await repo.purchasedKeys(testToday), {'atta'});
      expect(await repo.purchasedKeys(testToday.addDays(1)), isEmpty);
      await repo.addManualItem(testToday, 'Soap');
      final items = await repo.manualItems(testToday);
      expect(items.single.name, 'Soap');
      await repo.setManualPurchased(items.single.id, true);
      expect((await repo.manualItems(testToday)).single.purchased, isTrue);
      await repo.removeManualItem(items.single.id);
      expect(await repo.manualItems(testToday), isEmpty);
    });

    test('settings round-trip', () async {
      final repo = DriftSettingsRepository(db);
      expect((await repo.load()).onboardingComplete, isFalse);
      await repo.save(const AppSettings().copyWith(
        onboardingComplete: true,
        analyticsConsent: true,
        consentAsked: true,
        reminders: const ReminderPreferences(enabled: true, enabledSlots: {MealSlot.dinner}),
        lastReminderTimezone: 'Asia/Karachi',
        lowIntakeCheckDismissedOn: testToday,
      ));
      final s = await repo.load();
      expect(s.onboardingComplete, isTrue);
      expect(s.analyticsConsent, isTrue);
      expect(s.crashReportingConsent, isFalse);
      expect(s.reminders.enabledSlots, {MealSlot.dinner});
      expect(s.lastReminderTimezone, 'Asia/Karachi');
      expect(s.lowIntakeCheckDismissedOn, testToday);
    });
  });

  group('export, import, delete-all', () {
    Future<void> seed() async {
      await DriftProfileRepository(db, clock).save(setup());
      final plan = await plansRepo().savePlan(makePlan());
      await DriftFoodLogRepository(db, clock).add(logEntriesForMeal(
          meal: plan.meals.first, date: testToday, pack: loadBundledPack(), nowUtc: clock.nowUtc(), newId: ids.newId));
      await DriftWeightRepository(db, clock, ids).add(testToday, 70.5);
      await DriftShoppingRepository(db, clock, ids).addManualItem(testToday, 'Milk');
      await DriftSettingsRepository(db).save(const AppSettings(onboardingComplete: true));
    }

    test('export → wipe → import restores everything', () async {
      await seed();
      final portability = DriftDataPortability(db, clock);
      final exported = await portability.exportAll();
      // Through real JSON text, as a file would be.
      final text = jsonEncode(exported);
      await portability.deleteAll();
      expect(await DriftProfileRepository(db, clock).load(), isNull);
      expect(await DriftWeightRepository(db, clock, ids).all(), isEmpty);
      await portability.importAll(jsonDecode(text) as Map<String, Object?>);
      final again = await portability.exportAll();
      expect(jsonEncode(again['tables']), jsonEncode(exported['tables']));
      expect((await DriftProfileRepository(db, clock).load())!.preferences.dietType, DietType.vegetarian);
      expect((await DriftSettingsRepository(db).load()).onboardingComplete, isTrue);
    });

    test('an invalid file changes nothing', () async {
      await seed();
      final portability = DriftDataPortability(db, clock);
      final before = jsonEncode((await portability.exportAll())['tables']);
      await expectLater(portability.importAll({'format': 'other'}), throwsA(isA<InvalidImportFile>()));
      await expectLater(
          portability.importAll({'format': DriftDataPortability.format, 'formatVersion': 99}),
          throwsA(isA<InvalidImportFile>()));
      await expectLater(
          portability.importAll({
            'format': DriftDataPortability.format,
            'formatVersion': 1,
            'schemaVersion': 1,
            'tables': {
              'weights': [
                {'id': 'w', 'date': '2026-10-29'},
              ],
            },
          }),
          throwsA(isA<InvalidImportFile>()));
      await expectLater(
          portability.importAll({
            'format': DriftDataPortability.format,
            'formatVersion': 1,
            'schemaVersion': 999,
            'tables': <String, Object?>{},
          }),
          throwsA(isA<InvalidImportFile>()));
      expect(jsonEncode((await portability.exportAll())['tables']), before);
    });
  });

  group('database file', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('diet_db_'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('data survives the process being killed (close and reopen the file)', () async {
      final file = File('${dir.path}/$databaseFileName');
      final first = await openCheckedDatabase(file);
      await DriftWeightRepository(first, clock, ids).add(testToday, 71);
      await first.close();
      final second = await openCheckedDatabase(file);
      expect((await DriftWeightRepository(second, clock, ids).all()).single.weightKg, 71);
      await second.close();
    });

    test('a damaged file is reported, not reset', () async {
      final file = File('${dir.path}/$databaseFileName')..writeAsBytesSync(List.filled(4096, 7));
      await expectLater(openCheckedDatabase(file), throwsA(isA<StorageCorrupted>()));
      expect(file.lengthSync(), 4096, reason: 'the damaged file is left untouched');
    });

    test('migrations: every shipped schema opens with the current code', () async {
      // Shipped schema versions. Add each released version here with a fixture file.
      const shipped = [1];
      expect(shipped.last, AppDatabase(NativeDatabase.memory()).schemaVersion);
      final file = File('${dir.path}/v1.sqlite');
      final v1 = await openCheckedDatabase(file);
      await DriftWeightRepository(v1, clock, ids).add(testToday, 70);
      await v1.close();
      final reopened = await openCheckedDatabase(file);
      expect(await DriftWeightRepository(reopened, clock, ids).all(), hasLength(1));
      expect(await reopened.passesIntegrityCheck(), isTrue);
      await reopened.close();
    });
  });

  group('food pack loading', () {
    test('loads the bundled pack and caches it', () async {
      var reads = 0;
      final repo = AssetFoodRepository(() async {
        reads++;
        return File('assets/packs/pk-core.json').readAsString();
      });
      final pack = await repo.loadPack();
      expect(pack.foods, isNotEmpty);
      await repo.loadPack();
      expect(reads, 1);
    });

    test('an invalid pack is a typed failure', () async {
      final repo = AssetFoodRepository(() async => '{"schemaVersion": 1}');
      await expectLater(repo.loadPack(), throwsA(isA<InvalidFoodPack>()));
    });
  });
}

