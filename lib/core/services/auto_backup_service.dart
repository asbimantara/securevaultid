import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences.dart';
import '../../data/models/password_model.dart';

class AutoBackupService {
  static const String _lastBackupKey = 'last_backup_time';
  static const int _backupIntervalDays = 7;

  static Future<bool> shouldBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackup = prefs.getInt(_lastBackupKey);

    if (lastBackup == null) return true;

    final lastBackupDate = DateTime.fromMillisecondsSinceEpoch(lastBackup);
    final daysSinceLastBackup =
        DateTime.now().difference(lastBackupDate).inDays;

    return daysSinceLastBackup >= _backupIntervalDays;
  }

  static Future<String?> createAutoBackup(List<Password> passwords) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Cleanup old backups (keep last 5)
      final backups = await backupDir
          .list()
          .where((entity) => entity.path.endsWith('.json'))
          .toList();
      backups.sort((a, b) => b.path.compareTo(a.path));

      if (backups.length > 5) {
        for (var i = 5; i < backups.length; i++) {
          await backups[i].delete();
        }
      }

      // Create new backup
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File('${backupDir.path}/backup_$timestamp.json');

      final List<Map<String, dynamic>> passwordsJson = passwords
          .map((p) => {
                'title': p.title,
                'username': p.username,
                'password': p.password,
                'website': p.website,
                'category': p.category,
                'createdAt': p.createdAt.toIso8601String(),
                'lastModified': p.lastModified?.toIso8601String(),
                'tags': p.tags,
                'isFavorite': p.isFavorite,
              })
          .toList();

      await backupFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(passwordsJson),
      );

      // Update last backup time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastBackupKey, timestamp);

      return backupFile.path;
    } catch (e) {
      debugPrint('Error creating auto-backup: $e');
      return null;
    }
  }

  static Future<List<FileSystemEntity>> getBackupFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');

    if (!await backupDir.exists()) {
      return [];
    }

    final backups = await backupDir
        .list()
        .where((entity) => entity.path.endsWith('.json'))
        .toList();
    backups.sort((a, b) => b.path.compareTo(a.path));

    return backups;
  }
}
