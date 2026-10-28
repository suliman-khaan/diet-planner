import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock/clock.dart';
import '../../core/ids/ids.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/drift_data_portability.dart';
import '../../data/repositories/drift_repositories.dart';
import '../../domain/common/local_date.dart';
import '../../domain/food/food.dart';
import '../../domain/food/food_search.dart';
import '../../domain/plan/planner.dart';
import '../../domain/profile/eligibility.dart';
import '../../domain/profile/target_policy.dart';
import '../../domain/progress/progress.dart';
import '../../domain/repositories.dart';
import '../../services/analytics/analytics_service.dart';
import '../../services/files/backup_file_service.dart';
import '../../services/links/link_service.dart';
import '../../services/notifications/reminder_service.dart';
import '../app_config.dart';

// Overridden in bootstrap (and in tests).
final appConfigProvider = Provider<AppConfig>((ref) => throw UnimplementedError('appConfigProvider'));
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('databaseProvider'));
final foodRepositoryProvider = Provider<FoodRepository>((ref) => throw UnimplementedError('foodRepositoryProvider'));
final timezoneNameProvider = Provider<String>((ref) => 'UTC');

final clockProvider = Provider<Clock>((ref) => const SystemClock());
final idGeneratorProvider = Provider<IdGenerator>((ref) => Uuid7IdGenerator());

final targetPolicyProvider = Provider<TargetPolicy>((ref) => const TargetPolicy());
final eligibilityCheckerProvider = Provider<EligibilityChecker>(
  (ref) => EligibilityChecker(ref.watch(targetPolicyProvider).config),
);
final plannerProvider = Provider<Planner>((ref) => const Planner());
final lowIntakeCheckProvider = Provider<LowIntakeCheck>((ref) => const LowIntakeCheck());

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => DriftProfileRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);
final planRepositoryProvider = Provider<PlanRepository>(
  (ref) => DriftPlanRepository(
    ref.watch(databaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
    () => ref.read(timezoneNameProvider),
  ),
);
final foodLogRepositoryProvider = Provider<FoodLogRepository>(
  (ref) => DriftFoodLogRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);
final weightRepositoryProvider = Provider<WeightRepository>(
  (ref) => DriftWeightRepository(ref.watch(databaseProvider), ref.watch(clockProvider), ref.watch(idGeneratorProvider)),
);
final shoppingRepositoryProvider = Provider<ShoppingRepository>(
  (ref) => DriftShoppingRepository(ref.watch(databaseProvider), ref.watch(clockProvider), ref.watch(idGeneratorProvider)),
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(databaseProvider)),
);
final dataPortabilityProvider = Provider<DataPortability>(
  (ref) => DriftDataPortability(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final reminderServiceProvider = Provider<ReminderService>((ref) => NoopReminderService());
final analyticsServiceProvider = Provider<AnalyticsService>((ref) => ConsentGatedAnalytics(const NoopAnalyticsSink()));
final backupFileServiceProvider = Provider<BackupFileService>((ref) => const NoopBackupFileService());
final linkServiceProvider = Provider<LinkService>((ref) => const NoopLinkService());

final foodPackProvider = FutureProvider<FoodPack>((ref) => ref.watch(foodRepositoryProvider).loadPack());
final foodSearchProvider = FutureProvider<FoodSearch>((ref) async => FoodSearch((await ref.watch(foodPackProvider.future)).foods));

/// The saved onboarding result. Invalidate after saving.
final userSetupProvider = FutureProvider<UserSetup?>((ref) => ref.watch(profileRepositoryProvider).load());

final appSettingsProvider = FutureProvider<AppSettings>((ref) => ref.watch(settingsRepositoryProvider).load());

/// Today's local date. Re-read when the app resumes.
final todayProvider = Provider<LocalDate>((ref) => LocalDate.fromDateTime(ref.watch(clockProvider).nowLocal()));
