import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:encrypt/encrypt.dart';
import '../../data/models/password_model.dart';

class EmergencyAccessService {
  static const _key = 'emergency_access_code';
  static const _attemptsKey = 'emergency_attempts';
  static const _maxAttempts = 3;
  static const _lockoutDuration = Duration(minutes: 30);

  static Future<void> setupEmergencyAccess(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypter = _getEncrypter();
    final encrypted = encrypter.encrypt(code).base64;
    await prefs.setString(_key, encrypted);
    await prefs.setInt(_attemptsKey, _maxAttempts);
  }

  static Future<bool> verifyEmergencyAccess(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_attemptsKey) ?? _maxAttempts;

    if (attempts <= 0) {
      final lastAttempt = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt('last_attempt') ?? 0,
      );
      if (DateTime.now().difference(lastAttempt) < _lockoutDuration) {
        throw Exception('Akses dikunci. Coba lagi nanti.');
      }
      await prefs.setInt(_attemptsKey, _maxAttempts);
    }

    final encrypted = prefs.getString(_key);
    if (encrypted == null) return false;

    final encrypter = _getEncrypter();
    try {
      final decrypted = encrypter.decrypt64(encrypted);
      if (decrypted == code) {
        await prefs.setInt(_attemptsKey, _maxAttempts);
        return true;
      }
      await _decrementAttempts();
      return false;
    } catch (e) {
      await _decrementAttempts();
      return false;
    }
  }

  static Future<void> _decrementAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_attemptsKey) ?? _maxAttempts;
    await prefs.setInt(_attemptsKey, attempts - 1);
    if (attempts <= 1) {
      await prefs.setInt(
        'last_attempt',
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Encrypter _getEncrypter() {
    final key = Key.fromLength(32);
    final iv = IV.fromLength(16);
    return Encrypter(AES(key));
  }
}
