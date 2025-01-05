import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import '../../data/models/password_model.dart';

class ShareService {
  static Future<void> sharePassword(
    BuildContext context,
    Password password, {
    bool includePassword = false,
  }) async {
    try {
      final Map<String, dynamic> shareData = {
        'title': password.title,
        'username': password.username,
        if (includePassword) 'password': password.password,
        if (password.website != null) 'website': password.website,
        'category': password.category,
      };

      final String text = const JsonEncoder.withIndent('  ')
          .convert(shareData)
          .replaceAll('"', '')
          .replaceAll('{', '')
          .replaceAll('}', '')
          .trim();

      await Share.share(
        text,
        subject: 'Detail Login ${password.title}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membagikan password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
