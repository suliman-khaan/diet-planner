import 'package:drift/drift.dart';

import '../../core/clock/clock.dart';
import '../../core/errors/app_failure.dart';
import '../../domain/repositories.dart';
import '../db/app_database.dart';

/// JSON export/import of every user table, and delete-all.
///
/// Import parses the whole file before touching the database and then replaces everything in
/// one transaction, so a bad file changes nothing.
class DriftDataPortability implements DataPortability {
  DriftDataPortability(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  static const format = 'diet-planner-export';
  static const formatVersion = 1;

  @override
  Future<Map<String, Object?>> exportAll() async {
    final tables = <String, Object?>{};
    for (final t in _db.userTables) {
      final rows = await _db.select(t).get();
      tables[t.actualTableName] = [
        for (final r in rows) (r as DataClass).toJson()
      ];
    }
    return {
      'format': format,
      'formatVersion': formatVersion,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': _clock.nowUtc().toIso8601String(),
      'tables': tables,
    };
  }

  @override
  Future<void> importAll(Map<String, Object?> data) async {
    if (data['format'] != format)
      throw const InvalidImportFile('Not a Diet Planner export');
    if (data['formatVersion'] != formatVersion)
      throw const InvalidImportFile('Unsupported export version');
    final schema = data['schemaVersion'];
    if (schema is! int || schema > _db.schemaVersion) {
      throw const InvalidImportFile('Export is from a newer app version');
    }
    final tables = data['tables'];
    if (tables is! Map<String, Object?>)
      throw const InvalidImportFile('Missing tables');

    // Parse everything first.
    final parsed = <TableInfo<Table, Object?>, List<Insertable<Object?>>>{};
    for (final t in _db.userTables) {
      final raw = tables[t.actualTableName] ?? const <Object?>[];
      if (raw is! List<Object?>)
        throw InvalidImportFile('Table ${t.actualTableName} is not a list');
      try {
        parsed[t] = [
          for (final row in raw)
            _fromJson(
                t, (row! as Map<Object?, Object?>).cast<String, Object?>()),
        ];
      } catch (e) {
        throw InvalidImportFile(
            'Invalid row in ${t.actualTableName}: ${e.runtimeType}');
      }
    }

    await _db.transaction(() async {
      for (final t in _db.userTables) {
        await _db.delete(t).go();
      }
      // Parents before children.
      for (final t in _db.userTables.reversed) {
        for (final row in parsed[t]!) {
          await _db.into(t).insert(row);
        }
      }
    });
  }

  @override
  Future<void> deleteAll() => _db.transaction(() async {
        for (final t in _db.userTables) {
          await _db.delete(t).go();
        }
      });

  Insertable<Object?> _fromJson(
      TableInfo<Table, Object?> t, Map<String, Object?> json) {
    final db = _db;
    if (identical(t, db.profiles)) return ProfileRow.fromJson(json);
    if (identical(t, db.plans)) return PlanRow.fromJson(json);
    if (identical(t, db.planMeals)) return PlanMealRow.fromJson(json);
    if (identical(t, db.planItems)) return PlanItemRow.fromJson(json);
    if (identical(t, db.foodLogs)) return FoodLogRow.fromJson(json);
    if (identical(t, db.weights)) return WeightRow.fromJson(json);
    if (identical(t, db.shoppingChecks)) return ShoppingCheckRow.fromJson(json);
    if (identical(t, db.shoppingManualItems))
      return ShoppingManualRow.fromJson(json);
    if (identical(t, db.settings)) return SettingRow.fromJson(json);
    if (identical(t, db.outboxOperations)) return OutboxRow.fromJson(json);
    throw StateError('Unknown table ${t.actualTableName}');
  }
}
