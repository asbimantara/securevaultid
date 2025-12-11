import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/password_model.dart';
import '../repositories/password_repository.dart';

class PasswordProvider extends ChangeNotifier {
  final PasswordRepository _repository;
  List<Password> _passwords = [];
  bool _isLoading = false;

  PasswordProvider(this._repository);

  List<Password> get passwords => _passwords;
  bool get isLoading => _isLoading;

  Future<void> loadPasswords() async {
    _isLoading = true;
    notifyListeners();

    try {
      _passwords = await _repository.getAllPasswords();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPassword(Password password) async {
    await _repository.savePassword(password);
    await loadPasswords();
  }

  Future<void> updatePassword(Password password) async {
    final index = _passwords.indexWhere((p) => p.id == password.id);
    if (index != -1) {
      _passwords[index] = password;
      await _repository.updatePassword(password);
      notifyListeners();
    }
  }

  Future<void> deletePassword(String id) async {
    await _repository.deletePassword(id);
    await loadPasswords();
  }

  Future<List<Password>> searchPasswords(String query) async {
    query = query.toLowerCase();
    return _passwords
        .where((p) =>
            p.title.toLowerCase().contains(query) ||
            p.username.toLowerCase().contains(query) ||
            (p.notes?.toLowerCase() ?? '').contains(query))
        .toList();
  }

  Future<List<Password>> getPasswordsByCategory(String categoryId) async {
    return _passwords.where((p) => p.categoryId == categoryId).toList();
  }

  List<Password> getRecentPasswords(int limit) {
    final sortedPasswords = List<Password>.from(_passwords);
    sortedPasswords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedPasswords.take(limit).toList();
  }

  Future<void> exportPasswords() async {
    try {
      final List<Map<String, dynamic>> passwordsJson =
          _passwords.map((password) {
        return {
          'id': password.id,
          'title': password.title,
          'username': password.username,
          'password': password.password,
          'categoryId': password.categoryId,
          'url': password.url,
          'notes': password.notes,
          'createdAt': password.createdAt.toIso8601String(),
          'lastModified': password.lastModified?.toIso8601String(),
        };
      }).toList();

      final String jsonString = jsonEncode(passwordsJson);

      await Share.share(
        jsonString,
        subject: 'SecureVault Backup ${DateTime.now().toString()}',
      );
    } catch (e) {
      throw Exception('Gagal mengekspor data: ${e.toString()}');
    }
  }

  Future<void> importPasswords(List<dynamic> jsonData) async {
    try {
      // Konversi JSON ke objek Password
      final List<Password> importedPasswords = jsonData.map((json) {
        return Password(
          id: json['id'],
          title: json['title'],
          username: json['username'],
          password: json['password'],
          categoryId: json['categoryId'],
          url: json['url'],
          notes: json['notes'],
          createdAt: DateTime.parse(json['createdAt']),
          lastModified: json['lastModified'] != null
              ? DateTime.parse(json['lastModified'])
              : null,
        );
      }).toList();

      // Simpan password yang diimpor
      for (var password in importedPasswords) {
        await _repository.savePassword(password);
      }

      // Refresh daftar password
      await loadPasswords();
    } catch (e) {
      throw Exception('Format data tidak valid: ${e.toString()}');
    }
  }
}
