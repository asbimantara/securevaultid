import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/password_model.dart';

class SecureSharingService {
  static const _separator = '::';
  static const _version = 'v1';

  static Future<void> shareSecurely(
    BuildContext context,
    Password password,
    String shareKey,
  ) async {
    try {
      // Prepare data
      final data = {
        'title': password.title,
        'username': password.username,
        'password': password.password,
        if (password.website != null) 'website': password.website,
        'category': password.category,
      };

      // Encrypt
      final encrypted = _encryptData(jsonEncode(data), shareKey);
      final shareText = '$_version$_separator$encrypted';

      // Share
      await Share.share(
        shareText,
        subject: 'Secure Password Share: ${password.title}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Password? decryptSharedPassword(
      String encryptedText, String shareKey) {
    try {
      final parts = encryptedText.split(_separator);
      if (parts.length != 2 || parts[0] != _version) {
        throw Exception('Invalid format');
      }

      final decrypted = _decryptData(parts[1], shareKey);
      final data = jsonDecode(decrypted) as Map<String, dynamic>;

      return Password(
        title: data['title'],
        username: data['username'],
        password: data['password'],
        website: data['website'],
        category: data['category'],
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error decrypting shared password: $e');
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
