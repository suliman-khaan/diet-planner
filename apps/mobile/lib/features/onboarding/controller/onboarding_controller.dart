import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/formatters.dart';
import '../../../app/providers/providers.dart';
import '../../../app/providers/reminder_coordinator.dart';
import '../../../domain/common/meal_slot.dart';
import '../../../domain/food/food.dart';
import '../../../domain/profile/eligibility.dart';
import '../../../domain/profile/user_profile.dart';
import '../../../domain/repositories.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../today/controller/today_controller.dart';
import '../../../core/widgets/segmented_controls.dart' as ui;
import '../view_model/onboarding_view_model.dart' as ovm;

const _steps = [
  ovm.OnboardingStep.welcome,
  ovm.OnboardingStep.goal,
  ovm.OnboardingStep.aboutYou,
  ovm.OnboardingStep.activity,
  ovm.OnboardingStep.eligibility,
  ovm.OnboardingStep.dietary,
  ovm.OnboardingStep.cookingRichness,
  ovm.OnboardingStep.targetSummary,
];

/// Onboarding form. The argument is true when editing an existing profile.
class OnboardingController
    extends FamilyAsyncNotifier<ovm.OnboardingViewModel, bool> {
  late ovm.OnboardingStep _step;
  bool _editing = false;
  UserSetup? _existing;

  // Form values, in domain terms. Birth year starts unset: it must be chosen.
  Goal _goal = Goal.lose;
  int? _birthYear;
  Sex _sex = Sex.female;
  double _heightCm = 160;
  double _weightKg = 65;
  ActivityLevel _activity = ActivityLevel.light;
  final Set<HealthCondition> _conditions = {};
  DietType _diet = DietType.everything;
  final Set<Allergen> _allergies = {};
  OilLevel _richness = OilLevel.normal;
  String? _error;

  @override
  Future<ovm.OnboardingViewModel> build(bool editing) async {
    _editing = editing;
    _step = editing ? ovm.OnboardingStep.goal : ovm.OnboardingStep.welcome;
    if (editing) {
      _existing = await ref.read(profileRepositoryProvider).load();
      final s = _existing;
      if (s != null) {
        final p = s.profile;
        _goal = p.goal;
        _birthYear = p.birthYear;
        _sex = p.sex;
        _heightCm = p.heightCm;
        _weightKg = p.weightKg;
        _activity = p.activity;
        _conditions.addAll(p.conditions);
        _diet = s.preferences.dietType;
        _allergies.addAll(s.preferences.allergies);
        _richness = p.cookingRichness;
      }
    }
    return _vm();
  }

  UserProfile get _profile => UserProfile(
        goal: _goal,
        birthYear: _birthYear ?? ref.read(todayProvider).year,
        sex: _sex,
        heightCm: _heightCm,
        weightKg: _weightKg,
        activity: _activity,
        conditions: {..._conditions},
        cookingRichness: _richness,
      );

  ovm.OnboardingViewModel _vm() {
    final today = ref.read(todayProvider);
    final policy = ref.read(targetPolicyProvider);
    final checker = ref.read(eligibilityCheckerProvider);
    final profile = _profile;
    final eligibility =
        _birthYear == null ? null : checker.check(profile, today);
    final eligible = eligibility != null && eligibility is! ManualOnly;
    final result = eligible
        ? policy.compute(
            profile.copyWith(goal: checker.effectiveGoal(profile, eligibility)),
            today)
        : null;
    final target = result?.target;
    final notes = [
      if (result?.explanation.floorApplied ?? false)
        'Your target was raised to our safety minimum.',
      if (policy.config.isProvisional)
        'Safety limits are being confirmed by a nutrition professional.',
      'All values are estimates.',
    ];
    final index = _steps.indexOf(_step);
    return ovm.OnboardingViewModel(
      currentStep: _step,
      totalSteps: _steps.length - 1,
      currentStepIndex: index < 1 ? 1 : index,
      goal: switch (_goal) {
        Goal.lose => ovm.WeightGoal.loseWeight,
        Goal.maintain => ovm.WeightGoal.maintain,
        Goal.gain => ovm.WeightGoal.gainWeight,
      },
      birthYear: _birthYear ?? 0,
      birthYearOptions: [
        for (var y = today.year - 10; y >= today.year - 100; y--) y
      ],
      sex: _sex == Sex.male ? ovm.BiologicalSex.male : ovm.BiologicalSex.female,
      heightCm: _heightCm,
      weightKg: _weightKg,
      activityLevel: switch (_activity) {
        ActivityLevel.sedentary => ovm.ActivityLevel.sedentary,
        ActivityLevel.light => ovm.ActivityLevel.lightlyActive,
        ActivityLevel.moderate => ovm.ActivityLevel.moderatelyActive,
        ActivityLevel.veryActive => ovm.ActivityLevel.veryActive,
      },
      healthConditions: [for (final c in _conditions) c.name],
      isEligibleForAutoPlan: eligibility == null || eligible,
      eligibilityNotice: switch (eligibility) {
        null => 'Choose your birth year to continue.',
        final ManualOnly m => Fmt.manualOnly(m),
        MaintenanceOnly() =>
          'At your weight and height, we plan for keeping your weight steady rather than losing more. '
              'If you are worried about your weight, please speak to a doctor.',
        EligibleForPlans() => null,
      },
      dietType: ovm.DietType.values.byName(_diet.name),
      allergies: [for (final a in _allergies) a.name],
      cookingRichness: Fmt.toUiOil(_richness),
      recommendedCalories: target?.kcal.round(),
      recommendedProtein: target?.proteinG.round(),
      recommendedCarbs: target?.carbsG.round(),
      recommendedFat: target?.fatG.round(),
      recommendedFibre: target?.fibreG.round(),
      targetNotice: target == null ? null : notes.join(' '),
      errorMessage: _error,
    );
  }

  void _update(void Function() change) {
    change();
    _error = null;
    state = AsyncData(_vm());
  }

  void setGoal(ovm.WeightGoal g) => _update(() => _goal = switch (g) {
        ovm.WeightGoal.loseWeight => Goal.lose,
        ovm.WeightGoal.maintain => Goal.maintain,
        ovm.WeightGoal.gainWeight => Goal.gain,
      });
  void setSex(ovm.BiologicalSex s) =>
      _update(() => _sex = s == ovm.BiologicalSex.male ? Sex.male : Sex.female);
  void setHeight(double cm) => _update(() => _heightCm = cm);
  void setWeight(double kg) => _update(() => _weightKg = kg);
  void setBirthYear(int y) => _update(() => _birthYear = y);
  void setActivity(ovm.ActivityLevel a) =>
      _update(() => _activity = switch (a) {
            ovm.ActivityLevel.sedentary => ActivityLevel.sedentary,
            ovm.ActivityLevel.lightlyActive => ActivityLevel.light,
            ovm.ActivityLevel.moderatelyActive => ActivityLevel.moderate,
            ovm.ActivityLevel.veryActive => ActivityLevel.veryActive,
          });
  void toggleCondition(String key) => _update(() {
        final c = HealthCondition.values.byName(key);
        _conditions.contains(c) ? _conditions.remove(c) : _conditions.add(c);
      });
  void setDiet(ovm.DietType d) =>
      _update(() => _diet = DietType.values.byName(d.name));
  void toggleAllergy(String key) => _update(() {
        final a = Allergen.values.byName(key);
        _allergies.contains(a) ? _allergies.remove(a) : _allergies.add(a);
      });
  void setRichness(ui.OilLevel level) =>
      _update(() => _richness = Fmt.fromUiOil(level));

  /// Moves on, or shows why not.
  void next() {
    final today = ref.read(todayProvider);
    String? error;
    if (_step == ovm.OnboardingStep.aboutYou) {
      final errors = validateProfile(_profile, today);
      if (errors.contains(ProfileFieldError.heightOutOfRange)) {
        error =
            'Please enter a height between ${ProfileLimits.minHeightCm.round()} and ${ProfileLimits.maxHeightCm.round()} cm.';
      } else if (errors.contains(ProfileFieldError.weightOutOfRange)) {
        error =
            'Please enter a weight between ${ProfileLimits.minWeightKg.round()} and ${ProfileLimits.maxWeightKg.round()} kg.';
      }
    } else if (_step == ovm.OnboardingStep.eligibility && _birthYear == null) {
      error = 'Please choose the year you were born.';
    }
    if (error != null) {
      _error = error;
      state = AsyncData(_vm());
      return;
    }
    final i = _steps.indexOf(_step);
    if (i < _steps.length - 1) _update(() => _step = _steps[i + 1]);
  }

  /// Returns false when there is no earlier step (leave onboarding in edit mode).
  bool back() {
    final i = _steps.indexOf(_step);
    final first = _editing ? 1 : 0;
    if (i <= first) return false;
    _update(() => _step = _steps[i - 1]);
    return true;
  }

  /// Saves everything in one go. Profile changes apply to plans made from now on.
  Future<void> finish() async {
    final today = ref.read(todayProvider);
    final profile = _profile;
    final checker = ref.read(eligibilityCheckerProvider);
    final policy = ref.read(targetPolicyProvider);
    final e = checker.check(profile, today);
    final target = e is ManualOnly
        ? null
        : policy
            .compute(profile.copyWith(goal: checker.effectiveGoal(profile, e)),
                today)
            .target;
    final setup = UserSetup(
      profile: profile,
      preferences: (_existing?.preferences ?? const DietaryPreferences())
          .copyWith(dietType: _diet, allergies: {..._allergies}),
      schedule: _existing?.schedule ?? MealSchedule.defaults,
      target: target,
      policyVersion: policy.config.version,
    );
    await ref.read(profileRepositoryProvider).save(setup);

    final weights = ref.read(weightRepositoryProvider);
    final previous = await weights.all();
    if (previous.isEmpty ||
        (previous.last.weightKg - profile.weightKg).abs() >= 0.05) {
      await weights.add(today, profile.weightKg);
    }
    // Plans already made for later days are made again with the new details.
    await ref
        .read(planRepositoryProvider)
        .removePlansFrom(_editing ? today.addDays(1) : today);

    final settingsRepo = ref.read(settingsRepositoryProvider);
    final settings = await settingsRepo.load();
    await settingsRepo.save(settings.copyWith(onboardingComplete: true));
    ref.read(analyticsServiceProvider).log(AnalyticsEvent.onboardingCompleted, {
      'goal': profile.goal,
      'eligible': e is! ManualOnly,
      'slotCount': setup.schedule.normalSlots.length,
    });
    ref
      ..invalidate(userSetupProvider)
      ..invalidate(appSettingsProvider)
      ..invalidate(todayControllerProvider);
    await ref.read(reminderCoordinatorProvider).reschedule();
  }
}

final onboardingControllerProvider = AsyncNotifierProvider.family<
    OnboardingController,
    ovm.OnboardingViewModel,
    bool>(OnboardingController.new);
