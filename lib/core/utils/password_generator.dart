import 'dart:math';

class PasswordGenerator {
  static String generate({
    int length = 12,
    bool useUppercase = true,
    bool useLowercase = true,
    bool useNumbers = true,
    bool useSpecial = true,
  }) {
    final random = Random.secure();
    final charCodes = <int>[];

    if (useUppercase) charCodes.addAll(List.generate(26, (i) => i + 65));
    if (useLowercase) charCodes.addAll(List.generate(26, (i) => i + 97));
    if (useNumbers) charCodes.addAll(List.generate(10, (i) => i + 48));
    if (useSpecial) {
      charCodes.addAll([
        33,
        35,
        36,
        37,
        38,
        40,
        41,
        42,
        43,
        45,
        46,
        47,
        63,
        64,
        94,
        95
      ]); // !#\$%&()*+-./?@^_
    }

    if (charCodes.isEmpty) {
      throw Exception('At least one character type must be selected');
    }

    return List.generate(
      length,
      (_) => String.fromCharCode(
        charCodes[random.nextInt(charCodes.length)],
      ),
    ).join();
  }

  static double checkStrength(String password) {
    if (password.isEmpty) return 0;

    double strength = 0;

    // Length contribution
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;

    // Character types contribution
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.1;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.1;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.1;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength += 0.2;

    return strength.clamp(0.0, 1.0);
  }
}
