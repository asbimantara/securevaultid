import 'package:flutter/material.dart';
import '../../data/models/password_model.dart';

class PasswordHealthService {
  static const _minLength = 8;
  static const _maxAge = Duration(days: 90);

  static PasswordHealth checkPasswordHealth(Password password) {
    final score = _calculateScore(password);
    final issues = _findIssues(password);
    final recommendations = _getRecommendations(issues);

    return PasswordHealth(
      score: score,
      issues: issues,
      recommendations: recommendations,
      lastChanged: password.lastModified ?? password.createdAt,
    );
  }

  static double _calculateScore(Password password) {
    double score = 100;

    // Check length
    if (password.password.length < _minLength) {
      score -= 20;
    }

    // Check complexity
    if (!password.password.contains(RegExp(r'[A-Z]'))) score -= 10;
    if (!password.password.contains(RegExp(r'[a-z]'))) score -= 10;
    if (!password.password.contains(RegExp(r'[0-9]'))) score -= 10;
    if (!password.password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score -= 10;
    }

    // Check age
    final age = DateTime.now().difference(
      password.lastModified ?? password.createdAt,
    );
    if (age > _maxAge) score -= 15;

    return score.clamp(0, 100);
  }

  static List<PasswordIssue> _findIssues(Password password) {
    final issues = <PasswordIssue>[];

    // Check basic requirements
    if (password.password.length < _minLength) {
      issues.add(PasswordIssue.tooShort);
    }
    if (!password.password.contains(RegExp(r'[A-Z]'))) {
      issues.add(PasswordIssue.noUppercase);
    }
    if (!password.password.contains(RegExp(r'[a-z]'))) {
      issues.add(PasswordIssue.noLowercase);
    }
    if (!password.password.contains(RegExp(r'[0-9]'))) {
      issues.add(PasswordIssue.noNumbers);
    }
    if (!password.password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      issues.add(PasswordIssue.noSpecialChars);
    }

    // Check age
    final age = DateTime.now().difference(
      password.lastModified ?? password.createdAt,
    );
    if (age > _maxAge) {
      issues.add(PasswordIssue.tooOld);
    }

    return issues;
  }

  static List<String> _getRecommendations(List<PasswordIssue> issues) {
    return issues.map((issue) {
      switch (issue) {
        case PasswordIssue.tooShort:
          return 'Gunakan minimal 8 karakter';
        case PasswordIssue.noUppercase:
          return 'Tambahkan huruf kapital';
        case PasswordIssue.noLowercase:
          return 'Tambahkan huruf kecil';
        case PasswordIssue.noNumbers:
          return 'Tambahkan angka';
        case PasswordIssue.noSpecialChars:
          return 'Tambahkan karakter khusus';
        case PasswordIssue.tooOld:
          return 'Password sudah terlalu lama, sebaiknya diganti';
      }
    }).toList();
  }
}

enum PasswordIssue {
  tooShort,
  noUppercase,
  noLowercase,
  noNumbers,
  noSpecialChars,
  tooOld,
}

class PasswordHealth {
  final double score;
  final List<PasswordIssue> issues;
  final List<String> recommendations;
  final DateTime lastChanged;

  const PasswordHealth({
    required this.score,
    required this.issues,
    required this.recommendations,
    required this.lastChanged,
  });

  String get status {
    if (score >= 90) return 'Sangat Kuat';
    if (score >= 70) return 'Kuat';
    if (score >= 50) return 'Sedang';
    return 'Lemah';
  }

  Color get statusColor {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
