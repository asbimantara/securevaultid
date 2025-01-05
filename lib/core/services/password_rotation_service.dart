import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/password_model.dart';
import '../../data/providers/password_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences.dart';

class PasswordRotationService {
  static const _lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const _uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _numberChars = '0123456789';
  static const _specialChars = '!@#\$%^&*(),.?":{}|<>';
  static const _rotationTaskName = 'password_rotation';

  static String generateStrongPassword({
    int length = 16,
    bool useLowercase = true,
    bool useUppercase = true,
    bool useNumbers = true,
    bool useSpecial = true,
  }) {
    final random = Random.secure();
    final charPool = StringBuffer();
    final password = StringBuffer();

    if (useLowercase) charPool.write(_lowercaseChars);
    if (useUppercase) charPool.write(_uppercaseChars);
    if (useNumbers) charPool.write(_numberChars);
    if (useSpecial) charPool.write(_specialChars);

    // Ensure at least one character from each selected type
    if (useLowercase) {
      password.write(_lowercaseChars[random.nextInt(_lowercaseChars.length)]);
    }
    if (useUppercase) {
      password.write(_uppercaseChars[random.nextInt(_uppercaseChars.length)]);
    }
    if (useNumbers) {
      password.write(_numberChars[random.nextInt(_numberChars.length)]);
    }
    if (useSpecial) {
      password.write(_specialChars[random.nextInt(_specialChars.length)]);
    }

    // Fill remaining length with random characters
    final remainingLength = length - password.length;
    final chars = charPool.toString();
    for (var i = 0; i < remainingLength; i++) {
      password.write(chars[random.nextInt(chars.length)]);
    }

    // Shuffle the password
    final passwordList = password.toString().split('');
    passwordList.shuffle(random);
    return passwordList.join();
  }

  static Future<void> rotatePassword(
    BuildContext context,
    Password password,
    PasswordProvider provider,
  ) async {
    try {
      final newPassword = generateStrongPassword();
      password.updatePassword(newPassword);
      await provider.updatePassword(password);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diperbarui'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> initializeRotationScheduler() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> scheduleRotation(Password password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '${_rotationTaskName}_${password.key}', password.key.toString());

    await Workmanager().registerPeriodicTask(
      '${_rotationTaskName}_${password.key}',
      _rotationTaskName,
      frequency: const Duration(days: 90), // Rotasi setiap 90 hari
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      inputData: {
        'password_key': password.key,
      },
    );
  }

  static Future<void> cancelRotation(Password password) async {
    await Workmanager()
        .cancelByUniqueName('${_rotationTaskName}_${password.key}');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_rotationTaskName}_${password.key}');
  }
}
