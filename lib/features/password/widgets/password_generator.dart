import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PasswordGenerator {
  static const String _boxName = 'password_generator_settings';
  static late Box<dynamic> _box;

  static Future<void> initialize() async {
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  static int getLength() => _box.get('length', defaultValue: 16);
  static bool useUppercase() => _box.get('uppercase', defaultValue: true);
  static bool useLowercase() => _box.get('lowercase', defaultValue: true);
  static bool useNumbers() => _box.get('numbers', defaultValue: true);
  static bool useSpecial() => _box.get('special', defaultValue: true);

  static Future<void> saveSettings({
    required int length,
    required bool uppercase,
    required bool lowercase,
    required bool numbers,
    required bool special,
  }) async {
    await _box.putAll({
      'length': length,
      'uppercase': uppercase,
      'lowercase': lowercase,
      'numbers': numbers,
      'special': special,
    });
  }

  static String generate() {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (useUppercase()) chars += uppercase;
    if (useLowercase()) chars += lowercase;
    if (useNumbers()) chars += numbers;
    if (useSpecial()) chars += special;

    if (chars.isEmpty) chars = lowercase + numbers;

    return List.generate(getLength(), (index) {
      final randomIndex = Random.secure().nextInt(chars.length);
      return chars[randomIndex];
    }).join();
  }
}
