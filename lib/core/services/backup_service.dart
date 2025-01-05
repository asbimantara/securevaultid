import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../../data/models/password_model.dart';
import '../../data/models/category_model.dart';

class BackupService {
  static Future<String> createBackup(
    List<Password> passwords,
    List<Category> categories,
  ) async {
    try {
      final backupData = {
        'passwords': passwords
            .map((p) => {
                  'title': p.title,
                  'username': p.username,
                  'password': p.password,
                  'website': p.website,
                  'category': p.category,
                  'createdAt': p.createdAt.toIso8601String(),
                  'lastModified': p.lastModified?.toIso8601String(),
                })
            .toList(),
        'categories': categories
            .map((c) => {
                  'name': c.name,
                  'icon': c.icon,
                  'color': c.color,
                })
            .toList(),
      };

      final backupJson = jsonEncode(backupData);
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/securevault_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(backupJson);
      return file.path;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> restoreFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      final passwords = (backupData['passwords'] as List).map((p) => Password(
            title: p['title'],
            username: p['username'],
            password: p['password'],
            website: p['website'],
            category: p['category'],
            createdAt: DateTime.parse(p['createdAt']),
            lastModified: p['lastModified'] != null
                ? DateTime.parse(p['lastModified'])
                : null,
          ));

      final categories = (backupData['categories'] as List).map((c) => Category(
            name: c['name'],
            icon: c['icon'],
            color: c['color'],
          ));

      return {
        'passwords': passwords.toList(),
        'categories': categories.toList(),
      };
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      rethrow;
    }
  }
}
