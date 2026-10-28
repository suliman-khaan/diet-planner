import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/errors/app_failure.dart';
import 'app_database.dart';

const databaseFileName = 'diet_planner.sqlite';

/// Opens the on-device database and checks its integrity.
///
/// A damaged file throws [StorageCorrupted]; the app then shows a recovery screen.
/// The file is never deleted or reset without the user choosing to.
Future<AppDatabase> openAppDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return openCheckedDatabase(File(p.join(dir.path, databaseFileName)), background: true);
}

/// Opens [file] and runs SQLite's integrity check before anything else reads it.
Future<AppDatabase> openCheckedDatabase(File file, {bool background = false}) async {
  final db = AppDatabase(background ? NativeDatabase.createInBackground(file) : NativeDatabase(file));
  try {
    if (!await db.passesIntegrityCheck()) {
      await db.close();
      throw const StorageCorrupted('Database integrity check failed');
    }
  } on StorageCorrupted {
    rethrow;
  } on Object catch (e) {
    try {
      await db.close();
    } on Object {
      // The file could not be opened at all; nothing to close.
    }
    throw StorageCorrupted('Database could not be opened: ${e.runtimeType}');
  }
  return db;
}

/// Moves a damaged database aside (kept for support, never deleted) so a fresh one can be
/// created. Called only after the user confirms on the recovery screen.
Future<void> setAsideDamagedDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, databaseFileName));
  if (await file.exists()) {
    final stamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    await file.rename(p.join(dir.path, 'damaged_$stamp.sqlite'));
  }
}
