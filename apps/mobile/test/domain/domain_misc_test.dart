import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/common/local_date.dart';
import 'package:mobile/domain/common/meal_slot.dart';
import 'package:mobile/domain/common/nutrition.dart';
import 'package:mobile/domain/common/units.dart';
import 'package:mobile/domain/food/food.dart';
import 'package:mobile/domain/food/food_pack_parser.dart';
import 'package:mobile/domain/food/food_search.dart';
import 'package:mobile/domain/log/food_log.dart';
import 'package:mobile/domain/plan/daily_plan.dart';
import 'package:mobile/domain/plan/food_filter.dart';
import 'package:mobile/domain/plan/planner.dart';
import 'package:mobile/domain/profile/target_policy.dart';
import 'package:mobile/domain/profile/user_profile.dart';
import 'package:mobile/domain/progress/progress.dart';
import 'package:mobile/domain/reminders/reminder_schedule.dart';
import 'package:mobile/domain/repositories.dart';
import 'package:mobile/domain/shopping/shopping.dart';

import 'helpers.dart';

/// Fixed inputs for tests that need a plan but do not test the planner.
const _target = NutritionTarget(
    kcal: 1800, proteinG: 90, carbsG: 225, fatG: 60, fibreG: 25);
const _filter =
    FoodFilter(preferences: DietaryPreferences(), allowDraftData: true);

void main() {
  final pack = loadBundledPack();
  const planner = Planner();

  group('LocalDate', () {
    test('parses, formats, compares and does day maths', () {
      final d = LocalDate.parse('2026-02-28');
      expect(d.addDays(1), LocalDate(2026, 3, 1));
      expect(d.addDays(1).daysSince(d), 1);
      expect(d.toIso(), '2026-02-28');
      expect(d.toString(), '2026-02-28');
      expect(d.yyyymmdd, 20260228);
      expect(d.isBefore(d.addDays(1)), isTrue);
      expect(d.isAfter(d.addDays(-1)), isTrue);
      expect(d.isWithin(d.addDays(-1), d.addDays(1)), isTrue);
      expect(d.weekday, DateTime.saturday);
      expect(d.atMinutes(21 * 60 + 30), DateTime(2026, 2, 28, 21, 30));
      expect(LocalDate.fromDateTime(DateTime(2026, 1, 2, 23, 59)),
          LocalDate(2026, 1, 2));
      expect({d, LocalDate(2026, 2, 28)}.length, 1);
      expect(() => LocalDate(2026, 2, 30), throwsArgumentError);
      expect(() => LocalDate.parse('2026/02/28'), throwsFormatException);
    });
  });

  group('Nutrition and units', () {
    test('adds, scales and round-trips', () {
      const a = Nutrition(kcal: 100, protein: 5, carbs: 10, fat: 2, fibre: 1);
      expect(a + a, a.scale(2));
      expect(a.forGrams(50).kcal, 50);
      expect(Nutrition.sum([a, a, a]).fibre, 3);
      expect(Nutrition.fromJson(a.toJson()), a);
      expect(a.hashCode, Nutrition.fromJson(a.toJson()).hashCode);
      expect(a.toString(), contains('100.0 kcal'));
      expect(
          () => Nutrition.fromJson(const {
                'kcal': -1,
                'protein': 0,
                'carbs': 0,
                'fat': 0,
                'fibre': 0
              }),
          throwsFormatException);
    });

    test('display conversions never change canonical values', () {
      expect(Units.lbToKg(Units.kgToLb(70)), closeTo(70, 1e-9));
      expect(Units.cmToFeetInches(170), (5, 7));
      expect(Units.feetInchesToCm(5, 7), closeTo(170.18, 0.01));
      expect(Units.kcalToKj(100), closeTo(418.4, 0.01));
      expect(Units.formatGrams(243), '240 g');
      expect(Units.formatGrams(12), '10 g');
      expect(Units.formatGrams(2), '5 g');
      expect(Units.formatGrams(1240), '1.2 kg');
      expect(Units.formatGrams(12400), '12 kg');
      expect(Units.formatMillilitres(180), '180 ml');
      expect(Units.formatMillilitres(1500), '1.5 L');
    });

    test('slot and oil names parse', () {
      expect(MealSlot.fromName('iftar'), MealSlot.iftar);
      expect(MealSlot.snack.foodSlot, MealSlot.chai);
      expect(MealSlot.lunch.foodSlot, MealSlot.lunch);
      expect(OilLevel.fromName('rich'), OilLevel.rich);
      expect(() => MealSlot.fromName('brunch'), throwsFormatException);
      expect(() => OilLevel.fromName('extra'), throwsFormatException);
    });
  });

  group('Food pack parser', () {
    test('loads the bundled pack offline with every food and combo', () {
      expect(pack.packId, 'pk-core');
      expect(pack.isDraft, isTrue);
      expect(pack.notice, isNotEmpty);
      expect(pack.foods.length, greaterThanOrEqualTo(50));
      expect(pack.combos, isNotEmpty);
      expect(pack.measures.map((m) => m.id), contains('katori'));
      expect(pack.reviewedFoodCount, 0,
          reason: 'nothing is reviewed until the nutritionist signs off');
      final karahi = pack.food('chicken-karahi')!;
      expect(karahi.nameUr, isNotEmpty);
      expect(karahi.defaultServing.grams, 180);
      expect(karahi.servingById('missing').id, karahi.defaultServingId);
      expect(karahi.oilProfile!.gramsPer100g(OilLevel.rich),
          greaterThan(karahi.oilProfile!.light));
      expect(karahi.portion.clampAndSnap(10), karahi.portion.max);
      expect(karahi.portion.clampAndSnap(1.2), 1.0);
      expect(pack.ingredient('bread-white')!.isReadyMade, isTrue);
      expect(pack.ingredient('atta')!.isReadyMade, isFalse);
      expect(ContentStatus.reviewed.isVerified, isTrue);
      expect(ContentStatus.draft.isVerified, isFalse);
    });

    test('rejects malformed or inconsistent packs', () {
      expect(() => FoodPackParser.parse('not json'), throwsFormatException);
      expect(() => FoodPackParser.parse('{"schemaVersion": 2}'),
          throwsFormatException);
      expect(() => FoodPackParser.parse('[]'), throwsFormatException);
      const ingredient =
          '{"id":"a","name":"A","category":"grain","per100g":{"kcal":1,"protein":0,"carbs":0,"fat":0,"fibre":0},"allergens":[]}';
      String food(String extra) =>
          '{"id":"f","revision":1,"names":{"en":"F","romanUrdu":["f"]},"category":"c","role":"main",'
          '"nutritionPer100g":{"kcal":1,"protein":0,"carbs":0,"fat":0,"fibre":0},'
          '"servings":[{"id":"s","label":"S","grams":10}],"defaultServing":"s",'
          '"portion":{"min":1,"max":2,"step":1},"mealSlotFit":["lunch"],'
          '"dietary":{},"allergens":[],"allergenReview":"derived","status":"draft","source":"x"$extra}';
      String packWith(String f, {String combos = '[]'}) =>
          '{"schemaVersion":1,"packId":"p","packVersion":"1","status":"draft","ingredients":[$ingredient],"foods":[$f],"combos":$combos}';
      expect(
          FoodPackParser.parse(packWith(
                  food(',"ingredientsPer100g":[{"id":"a","grams":50}]')))
              .foods,
          hasLength(1));
      expect(
          () => FoodPackParser.parse(packWith(
              food(',"ingredientsPer100g":[{"id":"zzz","grams":50}]'))),
          throwsFormatException);
      expect(
          () => FoodPackParser.parse(
              packWith(food(',"ingredientsPer100g":[{"id":"a","grams":-1}]'))),
          throwsFormatException);
      expect(
          () => FoodPackParser.parse(packWith(
              food(',"ingredientsPer100g":[{"id":"a","grams":5}]'),
              combos:
                  '[{"id":"c","slots":["lunch"],"items":[{"foodId":"ghost","servings":1}]}]')),
          throwsFormatException);
      expect(
          () => FoodPackParser.parse(packWith(food(
              ',"ingredientsPer100g":[{"id":"a","grams":5}],"oilPer100g":{"light":1,"normal":2,"rich":3},"oilIngredient":"nope"'))),
          throwsFormatException);
    });
  });

  group('Food search', () {
    final search = FoodSearch(pack.foods);

    test('Roman Urdu spellings find the right food in the top 3', () {
      const cases = {
        'chana chat': 'chana-chaat',
        'chanay ki chaat': 'chana-chaat',
        'aloo ki bhujia': 'aloo-bhujia',
        'dal masoor': 'daal-masoor',
        'masur dal': 'daal-masoor',
        'karhai': 'chicken-karahi',
        'chapati': 'roti',
        'khichri': 'khichdi',
        'bhindi': 'bhindi',
        'doodh pati': 'doodh-patti',
        'kheer': 'kheer',
        'chawal': 'chawal',
      };
      cases.forEach((query, id) {
        final top = search.search(query).take(3).map((f) => f.id);
        expect(top, contains(id), reason: '"$query" → $top');
      });
    });

    test('Urdu script and categories work; empty query lists the category', () {
      expect(search.search('روٹی').first.id, 'roti');
      final breads = search.search('', category: 'breads');
      expect(breads, isNotEmpty);
      expect(breads.every((f) => f.category == 'breads'), isTrue);
      expect(search.search('xyzxyz'), isEmpty);
    });
  });

  group('Logging and day status', () {
    final plan = (planner.generate(PlanRequest(
      date: testToday,
      target: _target,
      pack: pack,
      slots: MealSchedule.defaults.normalSlots,
      filter: _filter,
      oilLevel: OilLevel.normal,
      seed: 3,
      policyVersion: 'test',
    )) as PlanSuccess)
        .plan;
    var n = 0;
    String newId() => 'id-${n++}';

    test('marking a meal eaten snapshots each item', () {
      final meal = plan.meals.first.copyWith(
        items: [
          for (final i in plan.meals.first.items)
            i.copyWith(id: 'item-${i.foodId}')
        ],
      );
      final entries = logEntriesForMeal(
          meal: meal,
          date: testToday,
          pack: pack,
          nowUtc: DateTime.utc(2026),
          newId: newId);
      expect(entries, hasLength(meal.items.length));
      expect(entries.first.source, LogSource.planned);
      expect(entries.first.packVersion, pack.packVersion);
      expect(Nutrition.sum(entries.map((e) => e.nutrition)).kcal,
          closeTo(meal.nutrition.kcal, 1e-9));
      expect(isPlanItemLogged(meal.items.first.id, entries), isTrue);
      expect(isPlanItemLogged('other', entries), isFalse);
    });

    test('missed days are "not logged", never 0 kcal', () {
      final s = summarizeDay(testToday, plan, const []);
      expect(s.status, DayLogStatus.notLogged);
      expect(s.eaten, isNull);
      expect(s.mealsPlanned, plan.meals.length);
    });

    test(
        'some meals logged = partial; all = complete; planned meals never assumed eaten',
        () {
      final first = logEntriesForMeal(
          meal: plan.meals.first,
          date: testToday,
          pack: pack,
          nowUtc: DateTime.utc(2026),
          newId: newId);
      final partial = summarizeDay(testToday, plan, first);
      expect(partial.status, DayLogStatus.partial);
      expect(partial.mealsLogged, 1);
      expect(partial.eaten!.kcal, lessThan(plan.totals.kcal));
      final all = [
        for (final m in plan.meals)
          ...logEntriesForMeal(
              meal: m,
              date: testToday,
              pack: pack,
              nowUtc: DateTime.utc(2026),
              newId: newId),
      ];
      expect(summarizeDay(testToday, plan, all).status, DayLogStatus.complete);
      final noPlan = summarizeDay(testToday, null, first);
      expect(noPlan.status, DayLogStatus.complete);
      expect(noPlan.mealsPlanned, 1);
    });
  });

  group('Progress and check-in', () {
    test('weight trend uses the last entry per day and reports change', () {
      final entries = [
        WeightEntry(id: 'a', date: LocalDate(2026, 10, 1), weightKg: 80),
        WeightEntry(id: 'b', date: LocalDate(2026, 10, 8), weightKg: 79.5),
        WeightEntry(id: 'c', date: LocalDate(2026, 10, 29), weightKg: 78.4),
        WeightEntry(id: 'd', date: LocalDate(2026, 9, 1), weightKg: 82),
      ];
      final t = weightTrend(entries, LocalDate(2026, 10, 1), testToday);
      expect(t.points.map((p) => p.id), ['a', 'b', 'c']);
      expect(t.latest!.weightKg, 78.4);
      expect(t.changeKg, closeTo(-1.6, 1e-9));
      expect(t.spanDays, 28);
      final empty = weightTrend(const [], LocalDate(2026, 10, 1), testToday);
      expect(empty.latest, isNull);
      expect(empty.changeKg, isNull);
    });

    DaySummary day(int offset, double? kcal, DayLogStatus status) => DaySummary(
          date: testToday.addDays(-offset),
          status: status,
          eaten: kcal == null
              ? null
              : Nutrition(kcal: kcal, protein: 0, carbs: 0, fat: 0, fibre: 0),
          mealsLogged: 3,
          mealsPlanned: 3,
        );

    test('three complete very-low days trigger a gentle check-in', () {
      const check = LowIntakeCheck();
      expect(
          check.shouldCheckIn([
            day(1, 600, DayLogStatus.complete),
            day(2, 700, DayLogStatus.complete),
            day(3, 500, DayLogStatus.complete),
          ]),
          isTrue);
      expect(
          check.shouldCheckIn([
            day(1, 600, DayLogStatus.complete),
            day(2, 1500, DayLogStatus.complete),
            day(3, 500, DayLogStatus.complete),
          ]),
          isFalse);
      // Partly logged or missed days do not count as low intake.
      expect(
          check.shouldCheckIn([
            day(1, 600, DayLogStatus.partial),
            day(2, 700, DayLogStatus.complete),
            day(3, 500, DayLogStatus.complete),
          ]),
          isFalse);
      expect(
          check.shouldCheckIn([day(1, null, DayLogStatus.notLogged)]), isFalse);
      expect(check.shouldCheckIn(const []), isFalse);
    });
  });

  group('Shopping list', () {
    test('aggregates matching ingredients from recipes and oil, skips water',
        () {
      final roti =
          planner.itemFor(pack, pack.food('roti')!, 2, OilLevel.normal);
      final paratha =
          planner.itemFor(pack, pack.food('paratha')!, 1, OilLevel.normal);
      final meal = PlannedMeal(
          slot: MealSlot.breakfast,
          minutesOfDay: 480,
          comboId: null,
          items: [roti, paratha]);
      final lines = shoppingLinesFor(pack, [meal]);
      final atta = lines.firstWhere((l) => l.ingredientId == 'atta');
      // 2 rotis × 40 g atta + 1 paratha × 50 g atta.
      expect(atta.amount, closeTo(130, 0.5));
      expect(atta.unit, ShoppingUnit.grams);
      expect(lines.any((l) => l.ingredientId == 'water'), isFalse);
      final oil = lines.firstWhere((l) => l.ingredientId == 'oil');
      expect(oil.amount, closeTo(70 * 11 / 100, 0.01));
    });

    test(
        'scales with portions, keeps units separate and marks ready-made items',
        () {
      final chai =
          planner.itemFor(pack, pack.food('doodh-patti')!, 2, OilLevel.normal);
      final bread =
          planner.itemFor(pack, pack.food('bread-slice')!, 2, OilLevel.normal);
      final lines = shoppingLinesFor(pack, [
        PlannedMeal(
            slot: MealSlot.breakfast,
            minutesOfDay: 480,
            comboId: null,
            items: [chai, bread]),
      ]);
      final milk = lines.firstWhere((l) => l.ingredientId == 'milk');
      expect(milk.unit, ShoppingUnit.millilitres);
      expect(milk.amount, closeTo(240, 0.5));
      expect(
          lines.firstWhere((l) => l.ingredientId == 'bread-white').isReadyMade,
          isTrue);
      expect(lines.any((l) => l.ingredientId == 'tea-brewed'), isFalse);
    });
  });

  group('Reminders', () {
    final schedule = MealSchedule.defaults.copyWith(
        ramadanStart: LocalDate(2026, 11, 2),
        ramadanEnd: LocalDate(2026, 11, 3));
    const prefs = ReminderPreferences(
      enabled: true,
      enabledSlots: {
        MealSlot.breakfast,
        MealSlot.lunch,
        MealSlot.dinner,
        MealSlot.sehri,
        MealSlot.iftar
      },
    );

    test('ids are stable per date and slot', () {
      expect(reminderIdFor(testToday, MealSlot.dinner),
          20261029 * 10 + MealSlot.dinner.index);
      expect(reminderIdFor(testToday, MealSlot.dinner), lessThan(2147483647));
    });

    test('switches to sehri and iftar on Ramadan dates and back afterwards',
        () {
      final r = upcomingReminders(
          schedule: schedule,
          prefs: prefs,
          from: testToday,
          nowMinutes: 0,
          days: 7);
      final nov2 = r
          .where((o) => o.date == LocalDate(2026, 11, 2))
          .map((o) => o.slot)
          .toSet();
      expect(nov2, {MealSlot.sehri, MealSlot.iftar, MealSlot.dinner});
      final nov4 = r
          .where((o) => o.date == LocalDate(2026, 11, 4))
          .map((o) => o.slot)
          .toSet();
      expect(nov4, {MealSlot.breakfast, MealSlot.lunch, MealSlot.dinner});
      expect(r.map((o) => o.id).toSet().length, r.length,
          reason: 'no duplicates');
      expect(schedule.ramadanDay(LocalDate(2026, 11, 3)), 2);
      expect(schedule.ramadanDay(testToday), isNull);
    });

    test(
        'skips logged meals, past times today, quiet hours (except sehri) and disabled reminders',
        () {
      final r = upcomingReminders(
        schedule: schedule,
        prefs:
            prefs.copyWith(quietStartMinutes: 21 * 60, quietEndMinutes: 6 * 60),
        from: testToday,
        nowMinutes: 9 * 60,
        days: 5,
        loggedSlots: {
          testToday: {MealSlot.lunch}
        },
      );
      final today = r.where((o) => o.date == testToday).map((o) => o.slot);
      expect(today, isEmpty,
          reason: 'breakfast past, lunch logged, dinner in quiet hours');
      final ramadan = r
          .where((o) => o.date == LocalDate(2026, 11, 2))
          .map((o) => o.slot)
          .toSet();
      expect(ramadan, contains(MealSlot.sehri));
      expect(ramadan, isNot(contains(MealSlot.dinner)));
      expect(
          upcomingReminders(
              schedule: schedule,
              prefs: const ReminderPreferences(),
              from: testToday,
              nowMinutes: 0),
          isEmpty);
    });

    test('quiet hours work across midnight and can be off', () {
      const p = ReminderPreferences(
          quietStartMinutes: 23 * 60, quietEndMinutes: 7 * 60);
      expect(p.isQuiet(23 * 60 + 30), isTrue);
      expect(p.isQuiet(6 * 60), isTrue);
      expect(p.isQuiet(12 * 60), isFalse);
      expect(
          const ReminderPreferences(
                  quietStartMinutes: 600, quietEndMinutes: 600)
              .isQuiet(600),
          isFalse);
      expect(
          const ReminderPreferences(quietStartMinutes: 60, quietEndMinutes: 120)
              .isQuiet(90),
          isTrue);
      final back = ReminderPreferences.fromJson(prefs.toJson());
      expect(back.enabledSlots, prefs.enabledSlots);
      expect(back.enabled, isTrue);
    });
  });

  group('Schedules, preferences and settings', () {
    test('schedule slots are time-ordered and survive JSON', () {
      final s = MealSchedule.defaults
          .copyWith(ramadanStart: testToday, ramadanEnd: testToday.addDays(29));
      expect(s.slotsFor(testToday).first.slot, MealSlot.sehri);
      expect(s.slotsFor(testToday.addDays(40)).first.slot, MealSlot.breakfast);
      final back = MealSchedule.fromJson(s.toJson());
      expect(back.toJson(), s.toJson());
      expect(back.copyWith(clearRamadan: true).ramadanStart, isNull);
      expect(MealSchedule.minSlots, 3);
      expect(MealSchedule.maxSlots, 6);
    });

    test('dietary preferences round-trip', () {
      const p = DietaryPreferences(
        dietType: DietType.vegetarian,
        allergies: {Allergen.nuts},
        excludedIngredientIds: {'egg'},
        excludedFoodIds: {'roti'},
      );
      final back = DietaryPreferences.fromJson(p.toJson());
      expect(back.toJson(), p.toJson());
      expect(back.copyWith(dietType: DietType.vegan).dietType, DietType.vegan);
    });

    test('setup and settings copy', () {
      final setup = UserSetup(
        profile: profile(),
        preferences: const DietaryPreferences(),
        schedule: MealSchedule.defaults,
        target: _target,
        policyVersion: 'v',
      );
      expect(setup.copyWith(clearTarget: true).target, isNull);
      expect(setup.copyWith(policyVersion: 'w').policyVersion, 'w');
      const s = AppSettings();
      final changed = s.copyWith(
        onboardingComplete: true,
        analyticsConsent: true,
        crashReportingConsent: true,
        consentAsked: true,
        reminders: const ReminderPreferences(enabled: true),
        lastReminderTimezone: 'Asia/Karachi',
        lowIntakeCheckDismissedOn: testToday,
      );
      expect(changed.onboardingComplete, isTrue);
      expect(changed.reminders.enabled, isTrue);
      expect(changed.lastReminderTimezone, 'Asia/Karachi');
      expect(changed.lowIntakeCheckDismissedOn, testToday);
    });
  });
}
