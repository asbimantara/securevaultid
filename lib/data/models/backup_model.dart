import 'dart:convert';
import 'package:hive/hive.dart';
import 'password_model.dart';
import 'category_model.dart';

class BackupData {
  final List<Password> passwords;
  final List<Category> categories;
  final DateTime createdAt;
  final String version;
  final Map<String, dynamic> settings;

  BackupData({
    required this.passwords,
    required this.categories,
    required this.createdAt,
    required this.version,
    required this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'passwords': passwords.map((p) => p.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'version': version,
      'settings': settings,
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      passwords:
          (json['passwords'] as List).map((p) => Password.fromJson(p)).toList(),
      categories: (json['categories'] as List)
          .map((c) => Category.fromJson(c))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      version: json['version'],
      settings: json['settings'],
    );
  }

  String toEncryptedJson(String encryptionKey) {
    final jsonString = jsonEncode(toJson());
    // TODO: Implement encryption
    return jsonString;
  }

  factory BackupData.fromEncryptedJson(String encrypted, String encryptionKey) {
    // TODO: Implement decryption
    final jsonString = encrypted;
    final json = jsonDecode(jsonString);
    return BackupData.fromJson(json);
  }
}
