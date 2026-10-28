import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/errors/app_failure.dart';

/// Saving and opening backup files. Exports go to a folder excluded from Android backup
/// and leave the device only when the user shares them.
abstract interface class BackupFileService {
  Future<void> shareExport(String json, String fileName);

  /// The chosen file's text, or null if the user cancelled.
  Future<String?> pickImportFile();
}

class NoopBackupFileService implements BackupFileService {
  const NoopBackupFileService();

  @override
  Future<void> shareExport(String json, String fileName) async {}

  @override
  Future<String?> pickImportFile() async => null;
}

class PlatformBackupFileService implements BackupFileService {
  const PlatformBackupFileService();

  static const maxImportBytes = 20 * 1024 * 1024;

  @override
  Future<void> shareExport(String json, String fileName) async {
    final dir = Directory(
        p.join((await getApplicationDocumentsDirectory()).path, 'exports'));
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(json, flush: true);
    await Share.shareXFiles([XFile(file.path, mimeType: 'application/json')],
        subject: 'Diet Planner backup');
  }

  @override
  Future<String?> pickImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (result == null) return null;
    if (bytes == null) throw const InvalidImportFile('File could not be read');
    if (bytes.length > maxImportBytes)
      throw const InvalidImportFile('File is too large');
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw const InvalidImportFile('File is not text');
    }
  }
}
