import 'package:drift/drift.dart';

part 'app_database.g.dart';

// Every user record carries createdAt/updatedAt (UTC), deletedAt (tombstone) and revision
// (server-assigned from v1.5). Dates for plans and logs are local calendar dates (yyyy-mm-dd).

/// Singleton row (id = 1) with the onboarding result. Small aggregates are stored as JSON;
/// they are always read and written whole.
@DataClassName('ProfileRow')
class Profiles extends Table {
  IntColumn get id => integer()();
  TextColumn get profileJson => text()();
  TextColumn get preferencesJson => text()();
  TextColumn get scheduleJson => text()();
  TextColumn get targetJson => text().nullable()();
  TextColumn get policyVersion => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PlanRow')
@TableIndex(name: 'plans_by_date', columns: {#date})
class Plans extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()();
  TextColumn get timezone => text()();
  RealColumn get targetKcal => real()();
  TextColumn get policyVersion => text()();
  TextColumn get packVersion => text()();
  IntColumn get seed => integer()();
  BoolColumn get usesDraftData => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get revision => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PlanMealRow')
@TableIndex(name: 'plan_meals_by_plan', columns: {#planId})
class PlanMeals extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text().references(Plans, #id)();
  TextColumn get slot => text()();
  IntColumn get minutesOfDay => integer()();
  TextColumn get comboId => text().nullable()();
  IntColumn get position => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PlanItemRow')
@TableIndex(name: 'plan_items_by_meal', columns: {#mealId})
class PlanItems extends Table {
  TextColumn get id => text()();
  TextColumn get mealId => text().references(PlanMeals, #id)();
  TextColumn get foodId => text()();
  IntColumn get foodRevision => integer()();
  TextColumn get servingId => text()();
  RealColumn get servings => real()();
  RealColumn get grams => real()();
  TextColumn get oilLevel => text().nullable()();
  BoolColumn get fromSharedDish => boolean()();
  RealColumn get kcal => real()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fat => real()();
  RealColumn get fibre => real()();
  IntColumn get position => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Consumed food with a nutrition snapshot. Not linked by foreign key to plan items:
/// replacing a planned meal must never change what was already logged.
@DataClassName('FoodLogRow')
@TableIndex(name: 'food_logs_by_date', columns: {#date})
class FoodLogs extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()();
  TextColumn get slot => text()();
  TextColumn get source => text()();
  TextColumn get label => text()();
  RealColumn get kcal => real()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fat => real()();
  RealColumn get fibre => real()();
  DateTimeColumn get loggedAt => dateTime()();
  TextColumn get planItemId => text().nullable()();
  TextColumn get foodId => text().nullable()();
  IntColumn get foodRevision => integer().nullable()();
  TextColumn get packVersion => text().nullable()();
  RealColumn get grams => real().nullable()();
  TextColumn get oilLevel => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get revision => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('WeightRow')
class Weights extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()();
  RealColumn get weightKg => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get revision => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Purchased ticks for computed shopping lines, kept across recalculation.
@DataClassName('ShoppingCheckRow')
class ShoppingChecks extends Table {
  TextColumn get listDate => text()();
  TextColumn get itemKey => text()();
  BoolColumn get purchased => boolean()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {listDate, itemKey};
}

@DataClassName('ShoppingManualRow')
class ShoppingManualItems extends Table {
  TextColumn get id => text()();
  TextColumn get listDate => text()();
  TextColumn get name => text()();
  BoolColumn get purchased => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Reserved for sync (v1.5). Created now so no migration is needed later.
@DataClassName('OutboxRow')
class OutboxOperations extends Table {
  TextColumn get id => text()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Profiles,
  Plans,
  PlanMeals,
  PlanItems,
  FoodLogs,
  Weights,
  ShoppingChecks,
  ShoppingManualItems,
  Settings,
  OutboxOperations,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bump with a migration step and a migration test for every shipped version.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // No shipped schema older than 1 yet. Add `if (from < 2) { ... }` steps here.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// SQLite's own integrity check. Anything other than "ok" means the file is damaged.
  Future<bool> passesIntegrityCheck() async {
    final rows = await customSelect('PRAGMA quick_check').get();
    return rows.length == 1 && rows.first.data.values.first == 'ok';
  }

  /// All user tables, children before parents, for delete-all and import.
  List<TableInfo<Table, Object?>> get userTables => [
        planItems,
        planMeals,
        plans,
        foodLogs,
        weights,
        shoppingChecks,
        shoppingManualItems,
        profiles,
        settings,
        outboxOperations,
      ];
}
