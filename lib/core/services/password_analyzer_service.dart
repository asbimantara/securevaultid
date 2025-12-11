import 'package:flutter/material.dart';

class PasswordAnalyzerService {
  static const int _minLength = 8;
  static const int _strongLength = 12;

  static PasswordStrength analyzePassword(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        score: 0,
        strength: 'Kosong',
        color: Colors.grey,
        suggestions: ['Masukkan password'],
      );
    }

    double score = 0;
    final suggestions = <String>[];

    // Length check (25%)
    if (password.length < _minLength) {
      suggestions.add('Gunakan minimal $_minLength karakter');
    } else {
      score += 0.125;
      if (password.length >= _strongLength) {
        score += 0.125;
      }
    }

    // Character variety (40%)
    if (!password.contains(RegExp(r'[A-Z]'))) {
      suggestions.add('Tambahkan huruf kapital');
    } else {
      score += 0.1;
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      suggestions.add('Tambahkan huruf kecil');
    } else {
      score += 0.1;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      suggestions.add('Tambahkan angka');
    } else {
      score += 0.1;
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      suggestions.add('Tambahkan karakter khusus');
    } else {
      score += 0.1;
    }

    // Pattern check (35%)
    if (_hasCommonPatterns(password)) {
      suggestions.add('Hindari pola umum (123, abc, dll)');
    } else {
      score += 0.175;
    }

    if (_hasRepeatingCharacters(password)) {
      suggestions.add('Hindari pengulangan karakter');
    } else {
      score += 0.175;
    }

    // Calculate final score and determine strength level
    score = score.clamp(0.0, 1.0);
    String strength;
    Color color;

    if (score < 0.3) {
      strength = 'Sangat Lemah';
      color = Colors.red[900]!;
    } else if (score < 0.5) {
      strength = 'Lemah';
      color = Colors.red;
    } else if (score < 0.7) {
      strength = 'Sedang';
      color = Colors.orange;
    } else if (score < 0.9) {
      strength = 'Kuat';
      color = Colors.lightGreen;
    } else {
      strength = 'Sangat Kuat';
      color = Colors.green;
    }

    return PasswordStrength(
      score: score,
      strength: strength,
      color: color,
      suggestions: suggestions,
    );
  }

  static bool _hasCommonPatterns(String password) {
    final commonPatterns = [
      RegExp(r'123'),
      RegExp(r'abc'),
      RegExp(r'qwerty'),
      RegExp(r'password'),
      RegExp(r'admin'),
      RegExp(r'letmein'),
      RegExp(r'welcome'),
    ];

    return commonPatterns
        .any((pattern) => password.toLowerCase().contains(pattern));
  }

  static bool _hasRepeatingCharacters(String password) {
    return RegExp(r'(.)\1{2,}').hasMatch(password);
  }

  static double calculateEntropy(String password) {
    final charsetSize = _getCharsetSize(password);
    return password.length * (log(charsetSize) / log(2));
  }

  static int _getCharsetSize(String password) {
    int size = 0;
    if (password.contains(RegExp(r'[a-z]'))) size += 26;
    if (password.contains(RegExp(r'[A-Z]'))) size += 26;
    if (password.contains(RegExp(r'[0-9]'))) size += 10;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) size += 32;
    return size > 0 ? size : 1;
  }
}

class PasswordStrength {
  final double score;
  final String strength;
  final Color color;
  final List<String> suggestions;

  const PasswordStrength({
    required this.score,
    required this.strength,
    required this.color,
    required this.suggestions,
  });
}
