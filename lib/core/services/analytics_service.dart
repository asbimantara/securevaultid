import 'package:flutter/material.dart';
import '../../data/models/password_model.dart';
import '../../data/models/category_model.dart';

class AnalyticsService {
  static PasswordAnalytics analyzePasswords(List<Password> passwords) {
    final totalPasswords = passwords.length;
    final weakPasswords = _countWeakPasswords(passwords);
    final expiredPasswords = _countExpiredPasswords(passwords);
    final duplicatePasswords = _findDuplicatePasswords(passwords);
    final categoryDistribution = _analyzeCategoryDistribution(passwords);
    final strengthDistribution = _analyzeStrengthDistribution(passwords);

    return PasswordAnalytics(
      totalPasswords: totalPasswords,
      weakPasswords: weakPasswords,
      expiredPasswords: expiredPasswords,
      duplicatePasswords: duplicatePasswords,
      categoryDistribution: categoryDistribution,
      strengthDistribution: strengthDistribution,
    );
  }

  static int _countWeakPasswords(List<Password> passwords) {
    return passwords.where((p) => p.password.length < 8).length;
  }

  static int _countExpiredPasswords(List<Password> passwords) {
    final now = DateTime.now();
    return passwords.where((p) {
      final lastModified = p.lastModified ?? p.createdAt;
      return now.difference(lastModified) > const Duration(days: 90);
    }).length;
  }

  static List<String> _findDuplicatePasswords(List<Password> passwords) {
    final duplicates = <String>[];
    final seen = <String, String>{};

    for (final password in passwords) {
      if (seen.containsKey(password.password)) {
        duplicates.add('${seen[password.password]} dan ${password.title}');
      } else {
        seen[password.password] = password.title;
      }
    }

    return duplicates;
  }

  static Map<String, int> _analyzeCategoryDistribution(
      List<Password> passwords) {
    final distribution = <String, int>{};
    for (final password in passwords) {
      distribution.update(
        password.category ?? 'Uncategorized',
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return distribution;
  }

  static Map<String, int> _analyzeStrengthDistribution(
      List<Password> passwords) {
    final distribution = {
      'Sangat Kuat': 0,
      'Kuat': 0,
      'Sedang': 0,
      'Lemah': 0,
    };

    for (final password in passwords) {
      final strength = _calculatePasswordStrength(password.password);
      if (strength >= 90) {
        distribution['Sangat Kuat'] = distribution['Sangat Kuat']! + 1;
      } else if (strength >= 70) {
        distribution['Kuat'] = distribution['Kuat']! + 1;
      } else if (strength >= 50) {
        distribution['Sedang'] = distribution['Sedang']! + 1;
      } else {
        distribution['Lemah'] = distribution['Lemah']! + 1;
      }
    }

    return distribution;
  }

  static double _calculatePasswordStrength(String password) {
    double score = 0;

    if (password.length >= 8) score += 25;
    if (password.contains(RegExp(r'[A-Z]'))) score += 25;
    if (password.contains(RegExp(r'[0-9]'))) score += 25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 25;

    return score;
  }
}

class PasswordAnalytics {
  final int totalPasswords;
  final int weakPasswords;
  final int expiredPasswords;
  final List<String> duplicatePasswords;
  final Map<String, int> categoryDistribution;
  final Map<String, int> strengthDistribution;

  const PasswordAnalytics({
    required this.totalPasswords,
    required this.weakPasswords,
    required this.expiredPasswords,
    required this.duplicatePasswords,
    required this.categoryDistribution,
    required this.strengthDistribution,
  });
}
