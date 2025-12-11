class PasswordStrengthService {
  static const int _minLength = 8;
  static const int _strongLength = 12;

  static double checkStrength(String password) {
    if (password.isEmpty) return 0;

    double score = 0;

    // Length check (30%)
    if (password.length >= _minLength) {
      score += 0.15;
      if (password.length >= _strongLength) {
        score += 0.15;
      }
    }

    // Character variety (40%)
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.1;
    if (password.contains(RegExp(r'[a-z]'))) score += 0.1;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.1;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score += 0.1;

    // Pattern check (30%)
    if (!_hasCommonPatterns(password)) score += 0.15;
    if (!_hasRepeatingCharacters(password)) score += 0.15;

    return score.clamp(0.0, 1.0);
  }

  static String getStrengthText(double strength) {
    if (strength < 0.3) return 'Sangat Lemah';
    if (strength < 0.5) return 'Lemah';
    if (strength < 0.7) return 'Sedang';
    if (strength < 0.9) return 'Kuat';
    return 'Sangat Kuat';
  }

  static Color getStrengthColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.5) return Colors.orange;
    if (strength < 0.7) return Colors.yellow;
    if (strength < 0.9) return Colors.lightGreen;
    return Colors.green;
  }

  static List<String> getStrengthSuggestions(String password) {
    final suggestions = <String>[];

    if (password.length < _minLength) {
      suggestions.add('Gunakan minimal $_minLength karakter');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      suggestions.add('Tambahkan huruf kapital');
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      suggestions.add('Tambahkan huruf kecil');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      suggestions.add('Tambahkan angka');
    }
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      suggestions.add('Tambahkan karakter khusus');
    }
    if (_hasCommonPatterns(password)) {
      suggestions.add('Hindari pola umum (123, abc, dll)');
    }
    if (_hasRepeatingCharacters(password)) {
      suggestions.add('Hindari pengulangan karakter');
    }

    return suggestions;
  }

  static bool _hasCommonPatterns(String password) {
    final commonPatterns = [
      RegExp(r'123'),
      RegExp(r'abc'),
      RegExp(r'qwerty'),
      RegExp(r'password'),
      RegExp(r'admin'),
    ];

    return commonPatterns
        .any((pattern) => password.toLowerCase().contains(pattern));
  }

  static bool _hasRepeatingCharacters(String password) {
    return RegExp(r'(.)\1{2,}').hasMatch(password);
  }
}
