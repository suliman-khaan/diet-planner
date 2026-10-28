import 'package:intl/intl.dart';

import '../../core/widgets/segmented_controls.dart' as ui;
import '../../domain/common/local_date.dart';
import '../../domain/common/meal_slot.dart';
import '../../domain/food/food.dart';
import '../../domain/plan/daily_plan.dart';
import '../../domain/plan/planner.dart';
import '../../domain/profile/eligibility.dart';

/// Turns domain values into the text the screens show. Controllers only.
abstract final class Fmt {
  static final _dayFormat = DateFormat('EEEE, d MMMM');
  static final _shortDay = DateFormat('EEE, d MMM');
  static final _weekday = DateFormat('EEEE');
  static final _int = NumberFormat.decimalPattern('en');

  static String date(LocalDate d) => _dayFormat.format(d.atMinutes(0));
  static String shortDate(LocalDate d) => _shortDay.format(d.atMinutes(0));

  static String dayTitle(LocalDate d, LocalDate today) =>
      switch (d.daysSince(today)) {
        0 => 'Today',
        -1 => 'Yesterday',
        1 => 'Tomorrow',
        _ => _weekday.format(d.atMinutes(0)),
      };

  static String kcal(num v) => _int.format(v.round());

  static String time(int minutesOfDay) {
    final h = minutesOfDay ~/ 60;
    final m = minutesOfDay % 60;
    final suffix = h < 12 ? 'am' : 'pm';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:${m.toString().padLeft(2, '0')} $suffix';
  }

  static String slot(MealSlot s) => switch (s) {
        MealSlot.sehri => 'Sehri',
        MealSlot.breakfast => 'Breakfast',
        MealSlot.lunch => 'Lunch',
        MealSlot.chai => 'Chai',
        MealSlot.snack => 'Snack',
        MealSlot.iftar => 'Iftar',
        MealSlot.dinner => 'Dinner',
      };

  static String number(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  /// "1.5 katori", "2 medium roti", "1 × Half katori".
  static String portion(Food food, String servingId, double servings) {
    final label = food.servingById(servingId).label;
    if (label.startsWith('1 '))
      return '${number(servings)} ${label.substring(2)}';
    return servings == 1 ? label : '${number(servings)} × $label';
  }

  static String itemTitle(Food food, PlanItem item) =>
      '${food.nameEn} · ${portion(food, item.servingId, item.servings)}';

  static String oil(OilLevel? level) => switch (level) {
        OilLevel.light => 'light oil',
        OilLevel.normal => 'normal oil',
        OilLevel.rich => 'rich oil',
        null => 'no added oil',
      };

  static ui.OilLevel toUiOil(OilLevel level) =>
      ui.OilLevel.values.byName(level.name);
  static OilLevel fromUiOil(ui.OilLevel level) =>
      OilLevel.values.byName(level.name);

  static String noPlanReason(PlanFailure f) => switch (f.reason) {
        NoPlanReason.noSlots =>
          'Your meal schedule has no meals. Add meal times in More → Meal times.',
        NoPlanReason.noAllowedFoods =>
          'No foods in the catalogue fit your choices yet. Your diet type, allergies and exclusions are '
              'never relaxed, so there is no automatic plan. You can still log food yourself.',
        NoPlanReason.noOptionsForSlot =>
          'We could not find a safe ${f.slot == null ? 'meal' : slot(f.slot!).toLowerCase()} that fits your diet '
              'type, allergies and exclusions. We never relax them, so there is no automatic plan for today. '
              'You can still log food yourself.',
      };

  static String manualOnly(ManualOnly e) {
    final reasons = e.reasons;
    final why = reasons.contains(ManualOnlyReason.underAge)
        ? 'Automatic meal plans are for adults aged 18 and over.'
        : reasons.contains(ManualOnlyReason.pregnant) ||
                reasons.contains(ManualOnlyReason.breastfeeding)
            ? 'During pregnancy and breastfeeding, energy needs are personal.'
            : 'Medical diets need advice from your doctor or a dietitian.';
    return '$why You can log what you eat and see estimated totals. '
        'For a personal plan, please speak to a qualified professional.';
  }
}
