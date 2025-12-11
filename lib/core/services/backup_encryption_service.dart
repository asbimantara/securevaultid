import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/password_model.dart';
import '../../data/models/category_model.dart';

class BackupEncryptionService {
  static const _version = 'v1';
  static const _separator = '::';

  static Future<String?> createEncryptedBackup({
    required List<Password> passwords,
    required List<Category> categories,
    required String backupKey,
  }) async {
    try {
      final data = {
        'passwords': passwords
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
                  if (p.expirationDate != null)
                    'expirationDate': p.expirationDate!.toIso8601String(),
                })
            .toList(),
        'categories': categories
            .map((c) => {
                  'name': c.name,
                  'icon': c.icon,
                  'color': c.color.value,
                })
            .toList(),
      };

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/encrypted_backups');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Cleanup old backups (keep last 5)
      final backups = await backupDir
          .list()
          .where((entity) => entity.path.endsWith('.enc'))
          .toList();
      backups.sort((a, b) => b.path.compareTo(a.path));

      if (backups.length > 5) {
        for (var i = 5; i < backups.length; i++) {
          await backups[i].delete();
        }
      }

      final backupFile = File('${backupDir.path}/backup_$timestamp.enc');

      // Encrypt data
      final encrypted = _encryptData(jsonEncode(data), backupKey);
      final backupContent = '$_version$_separator$encrypted';

      await backupFile.writeAsString(backupContent);
      return backupFile.path;
    } catch (e) {
      debugPrint('Error creating encrypted backup: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> restoreFromEncryptedBackup(
    String filePath,
    String backupKey,
  ) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();

      final parts = content.split(_separator);
      if (parts.length != 2 || parts[0] != _version) {
        throw Exception('Invalid backup format');
      }

      final decrypted = _decryptData(parts[1], backupKey);
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error restoring from encrypted backup: $e');
      return null;
    }
  }

  static String _encryptData(String data, String key) {
    final keyBytes = Key.fromUtf8(key.padRight(32, '0'));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(keyBytes));

    final encrypted = encrypter.encrypt(data, iv: iv);
    return '${encrypted.base64}$_separator${iv.base64}';
  }

  static String _decryptData(String encryptedData, String key) {
    final parts = encryptedData.split(_separator);
    if (parts.length != 2) throw Exception('Invalid encrypted data format');

    final keyBytes = Key.fromUtf8(key.padRight(32, '0'));
    final encrypter = Encrypter(AES(keyBytes));

    final encrypted = Encrypted.fromBase64(parts[0]);
    final iv = IV.fromBase64(parts[1]);

    return encrypter.decrypt(encrypted, iv: iv);
  }
}
