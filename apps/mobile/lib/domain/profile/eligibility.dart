import '../common/local_date.dart';
import 'target_policy.dart';
import 'user_profile.dart';

enum ManualOnlyReason { underAge, pregnant, breastfeeding, medicalCondition }

sealed class Eligibility {
  const Eligibility();
}

/// Automated plans allowed with the user's chosen goal.
class EligibleForPlans extends Eligibility {
  const EligibleForPlans();
}

/// Automated plans allowed only for maintenance (blueprint §3 rule 5: goal "lose" with
/// BMI below the guardrail gets no loss plan).
class MaintenanceOnly extends Eligibility {
  const MaintenanceOnly({required this.bmi});

  final double bmi;
}

/// No automated plans; the user can still log food manually and sees why.
class ManualOnly extends Eligibility {
  const ManualOnly(this.reasons);

  final Set<ManualOnlyReason> reasons;
}

class EligibilityChecker {
  const EligibilityChecker([this.config = TargetPolicyConfig.v1Provisional]);

  final TargetPolicyConfig config;

  Eligibility check(UserProfile p, LocalDate today) {
    final reasons = <ManualOnlyReason>{};
    // With only a birth year, the user may not have had their birthday yet this year.
    // Treat the lower possible age as the real one so a 17-year-old is never let through.
    final minimumPossibleAge = p.ageIn(today) - 1;
    if (minimumPossibleAge < config.minAgeForAutoPlans) reasons.add(ManualOnlyReason.underAge);
    if (p.conditions.contains(HealthCondition.pregnant)) reasons.add(ManualOnlyReason.pregnant);
    if (p.conditions.contains(HealthCondition.breastfeeding)) reasons.add(ManualOnlyReason.breastfeeding);
    if (p.conditions.any((c) =>
        c == HealthCondition.diabetes || c == HealthCondition.kidneyDisease || c == HealthCondition.otherMedicalDiet)) {
      reasons.add(ManualOnlyReason.medicalCondition);
    }
    if (reasons.isNotEmpty) return ManualOnly(reasons);
    if (p.goal == Goal.lose && p.bmi < config.minBmiForLoss) return MaintenanceOnly(bmi: p.bmi);
    return const EligibleForPlans();
  }

  /// The goal actually used for targets after the eligibility downgrade.
  Goal effectiveGoal(UserProfile p, Eligibility e) => e is MaintenanceOnly ? Goal.maintain : p.goal;
}
