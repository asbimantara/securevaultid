// - Auto backup
// - Data sync
// - Recovery options

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../data/models/password_model.dart';
import '../../data/models/category_model.dart';
import 'package:encrypt/encrypt.dart';

class SyncService {
  static const _backupFolder = 'backups';
  static final _encrypter = Encrypter(AES(Key.fromLength(32)));

  static Future<void> scheduleAutoBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackup = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt(AppConstants.keyLastBackup) ?? 0,
    );

    if (DateTime.now().difference(lastBackup) > AppConstants.backupInterval) {
      await createBackup();
    }
  }

  static Future<String> createBackup() async {
    final dir = await _getBackupDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/backup_$timestamp.enc');

    // Implementasi backup data
    final data = await _prepareBackupData();
    final encrypted = _encrypter.encrypt(data).base64;
    await file.writeAsString(encrypted);

    await _cleanOldBackups();
    await _updateLastBackupTime();

    return file.path;
  }

  static Future<void> restoreFromBackup(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('File backup tidak ditemukan');
    }

    final encrypted = await file.readAsString();
    final decrypted = _encrypter.decrypt64(encrypted);

    // Implementasi restore data
    await _restoreFromData(decrypted);
  }

  static Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/$_backupFolder');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  static Future<void> _cleanOldBackups() async {
    final dir = await _getBackupDirectory();
    final files = await dir.list().toList();
    if (files.length > AppConstants.maxBackupFiles) {
      files.sort(
          (a, b) => a.statSync().modified.compareTo(b.statSync().modified));
      for (var i = 0; i < files.length - AppConstants.maxBackupFiles; i++) {
        await files[i].delete();
      }
    }
  }

  static Future<void> _updateLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      AppConstants.keyLastBackup,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<String> _prepareBackupData() async {
    // Implementasi persiapan data untuk backup
    return '';
  }

  static Future<void> _restoreFromData(String data) async {
    // Implementasi pemulihan data dari backup
  }
}
