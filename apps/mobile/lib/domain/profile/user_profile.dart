import '../common/local_date.dart';
import '../common/meal_slot.dart';
import '../food/food.dart';

enum Goal { lose, maintain, gain }

enum Sex { female, male }

enum ActivityLevel { sedentary, light, moderate, veryActive }

enum DietType { everything, vegetarian, vegan, pescatarian }

/// Conditions that route a user to manual logging only (blueprint §3, safety rule 1).
enum HealthCondition { pregnant, breastfeeding, diabetes, kidneyDisease, otherMedicalDiet }

class UserProfile {
  const UserProfile({
    required this.goal,
    required this.birthYear,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
    required this.conditions,
    required this.cookingRichness,
  });

  final Goal goal;
  final int birthYear;
  final Sex sex;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activity;
  final Set<HealthCondition> conditions;
  final OilLevel cookingRichness;

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  /// Age this calendar year. With only a birth year the true age may be one less.
  int ageIn(LocalDate date) => date.year - birthYear;

  UserProfile copyWith({
    Goal? goal,
    int? birthYear,
    Sex? sex,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activity,
    Set<HealthCondition>? conditions,
    OilLevel? cookingRichness,
  }) =>
      UserProfile(
        goal: goal ?? this.goal,
        birthYear: birthYear ?? this.birthYear,
        sex: sex ?? this.sex,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        activity: activity ?? this.activity,
        conditions: conditions ?? this.conditions,
        cookingRichness: cookingRichness ?? this.cookingRichness,
      );

  Map<String, Object?> toJson() => {
        'goal': goal.name,
        'birthYear': birthYear,
        'sex': sex.name,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'activity': activity.name,
        'conditions': conditions.map((c) => c.name).toList()..sort(),
        'cookingRichness': cookingRichness.name,
      };

  factory UserProfile.fromJson(Map<String, Object?> json) => UserProfile(
        goal: Goal.values.byName(json['goal']! as String),
        birthYear: json['birthYear']! as int,
        sex: Sex.values.byName(json['sex']! as String),
        heightCm: (json['heightCm']! as num).toDouble(),
        weightKg: (json['weightKg']! as num).toDouble(),
        activity: ActivityLevel.values.byName(json['activity']! as String),
        conditions: ((json['conditions'] as List<Object?>?) ?? const [])
            .map((c) => HealthCondition.values.byName(c! as String))
            .toSet(),
        cookingRichness: OilLevel.values.byName(json['cookingRichness']! as String),
      );
}

/// Valid input ranges for onboarding fields. Values outside are input errors, not safety rules.
abstract final class ProfileLimits {
  static const double minHeightCm = 120;
  static const double maxHeightCm = 230;
  static const double minWeightKg = 30;
  static const double maxWeightKg = 250;
  static const int oldestBirthYearOffset = 100;
}

enum ProfileFieldError { heightOutOfRange, weightOutOfRange, birthYearOutOfRange }

Set<ProfileFieldError> validateProfile(UserProfile p, LocalDate today) {
  final errors = <ProfileFieldError>{};
  if (!p.heightCm.isFinite || p.heightCm < ProfileLimits.minHeightCm || p.heightCm > ProfileLimits.maxHeightCm) {
    errors.add(ProfileFieldError.heightOutOfRange);
  }
  if (!p.weightKg.isFinite || p.weightKg < ProfileLimits.minWeightKg || p.weightKg > ProfileLimits.maxWeightKg) {
    errors.add(ProfileFieldError.weightOutOfRange);
  }
  if (p.birthYear > today.year || p.birthYear < today.year - ProfileLimits.oldestBirthYearOffset) {
    errors.add(ProfileFieldError.birthYearOutOfRange);
  }
  return errors;
}

/// Vegetarian flag, allergies and excluded ingredients. Never silently ignored.
class DietaryPreferences {
  const DietaryPreferences({
    this.dietType = DietType.everything,
    this.allergies = const {},
    this.excludedIngredientIds = const {},
    this.excludedFoodIds = const {},
  });

  final DietType dietType;
  final Set<Allergen> allergies;
  final Set<String> excludedIngredientIds;
  final Set<String> excludedFoodIds;

  DietaryPreferences copyWith({
    DietType? dietType,
    Set<Allergen>? allergies,
    Set<String>? excludedIngredientIds,
    Set<String>? excludedFoodIds,
  }) =>
      DietaryPreferences(
        dietType: dietType ?? this.dietType,
        allergies: allergies ?? this.allergies,
        excludedIngredientIds: excludedIngredientIds ?? this.excludedIngredientIds,
        excludedFoodIds: excludedFoodIds ?? this.excludedFoodIds,
      );

  Map<String, Object?> toJson() => {
        'dietType': dietType.name,
        'allergies': allergies.map((a) => a.name).toList()..sort(),
        'excludedIngredientIds': excludedIngredientIds.toList()..sort(),
        'excludedFoodIds': excludedFoodIds.toList()..sort(),
      };

  factory DietaryPreferences.fromJson(Map<String, Object?> json) => DietaryPreferences(
        dietType: DietType.values.byName(json['dietType']! as String),
        allergies: _strings(json['allergies']).map(Allergen.values.byName).toSet(),
        excludedIngredientIds: _strings(json['excludedIngredientIds']).toSet(),
        excludedFoodIds: _strings(json['excludedFoodIds']).toSet(),
      );
}

List<String> _strings(Object? v) => ((v as List<Object?>?) ?? const []).map((e) => e! as String).toList();

class SlotTime {
  const SlotTime(this.slot, this.minutesOfDay);

  final MealSlot slot;

  /// Minutes after local midnight, e.g. 21:30 → 1290.
  final int minutesOfDay;

  Map<String, Object?> toJson() => {'slot': slot.name, 'minutes': minutesOfDay};

  factory SlotTime.fromJson(Map<String, Object?> json) =>
      SlotTime(MealSlot.fromName(json['slot']! as String), json['minutes']! as int);
}

/// Meal times. Ramadan mode replaces breakfast and lunch with sehri and iftar on the chosen dates.
class MealSchedule {
  const MealSchedule({
    required this.normalSlots,
    required this.ramadanSlots,
    this.ramadanStart,
    this.ramadanEnd,
  });

  static const MealSchedule defaults = MealSchedule(
    normalSlots: [
      SlotTime(MealSlot.breakfast, 8 * 60),
      SlotTime(MealSlot.lunch, 14 * 60),
      SlotTime(MealSlot.chai, 17 * 60 + 30),
      SlotTime(MealSlot.dinner, 21 * 60 + 30),
    ],
    ramadanSlots: [
      SlotTime(MealSlot.sehri, 4 * 60 + 30),
      SlotTime(MealSlot.iftar, 18 * 60 + 15),
      SlotTime(MealSlot.dinner, 21 * 60 + 45),
    ],
  );

  static const int minSlots = 3;
  static const int maxSlots = 6;

  final List<SlotTime> normalSlots;
  final List<SlotTime> ramadanSlots;
  final LocalDate? ramadanStart;
  final LocalDate? ramadanEnd;

  bool isRamadan(LocalDate date) =>
      ramadanStart != null && ramadanEnd != null && date.isWithin(ramadanStart!, ramadanEnd!);

  /// Slots for [date], ordered by time.
  List<SlotTime> slotsFor(LocalDate date) {
    final slots = [...(isRamadan(date) ? ramadanSlots : normalSlots)];
    slots.sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));
    return slots;
  }

  /// Day number within Ramadan (1-based), or null outside Ramadan.
  int? ramadanDay(LocalDate date) => isRamadan(date) ? date.daysSince(ramadanStart!) + 1 : null;

  MealSchedule copyWith({
    List<SlotTime>? normalSlots,
    List<SlotTime>? ramadanSlots,
    LocalDate? ramadanStart,
    LocalDate? ramadanEnd,
    bool clearRamadan = false,
  }) =>
      MealSchedule(
        normalSlots: normalSlots ?? this.normalSlots,
        ramadanSlots: ramadanSlots ?? this.ramadanSlots,
        ramadanStart: clearRamadan ? null : (ramadanStart ?? this.ramadanStart),
        ramadanEnd: clearRamadan ? null : (ramadanEnd ?? this.ramadanEnd),
      );

  Map<String, Object?> toJson() => {
        'normal': normalSlots.map((s) => s.toJson()).toList(),
        'ramadan': ramadanSlots.map((s) => s.toJson()).toList(),
        'ramadanStart': ramadanStart?.toIso(),
        'ramadanEnd': ramadanEnd?.toIso(),
      };

  factory MealSchedule.fromJson(Map<String, Object?> json) {
    List<SlotTime> slots(Object? v) => ((v as List<Object?>?) ?? const [])
        .map((e) => SlotTime.fromJson((e! as Map<Object?, Object?>).cast<String, Object?>()))
        .toList();
    final start = json['ramadanStart'] as String?;
    final end = json['ramadanEnd'] as String?;
    return MealSchedule(
      normalSlots: slots(json['normal']),
      ramadanSlots: slots(json['ramadan']),
      ramadanStart: start == null ? null : LocalDate.parse(start),
      ramadanEnd: end == null ? null : LocalDate.parse(end),
    );
  }
}
