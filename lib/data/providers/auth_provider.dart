import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../../core/utils/encryption_util.dart';
import '../../features/auth/services/biometric_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hive/hive.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  DateTime? _lastActivity;
  DateTime? _lockUntil;
  int _failedAttempts = 0;
  static const int maxAttempts = 3;
  static const Duration setupLockDuration = Duration(seconds: 10);
  static const Duration loginLockDuration = Duration(minutes: 1);

  bool get isAuthenticated => _isAuthenticated;
  bool get hasUser => _user != null;
  User? get user => _user;
  bool get isLocked =>
      _lockUntil != null && DateTime.now().isBefore(_lockUntil!);
  Duration get remainingLockTime => _lockUntil != null
      ? _lockUntil!.difference(DateTime.now())
      : Duration.zero;
  int get remainingAttempts => maxAttempts - _failedAttempts;
  bool get shouldResetData => _failedAttempts >= maxAttempts * 2;

  Future<bool> setupPin(String pin) async {
    try {
      final salt = EncryptionUtil.generateSalt();
      final hashedPin = EncryptionUtil.hashWithSalt(pin, salt);

      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pin: hashedPin,
        salt: salt,
      );

      _failedAttempts = 0;
      _lockUntil = null;
      await _saveUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPin(String pin) async {
    if (isLocked) return false;
    if (_user == null) return false;

    final hashedInput = EncryptionUtil.hashWithSalt(pin, _user!.salt);
    if (hashedInput == _user!.pin) {
      _failedAttempts = 0;
      _lockUntil = null;
      _isAuthenticated = true;
      _lastActivity = DateTime.now();
      await _saveUser();
      notifyListeners();
      return true;
    } else {
      _failedAttempts++;
      if (_failedAttempts >= maxAttempts * 2) {
        await resetAllData();
      } else if (_failedAttempts >= maxAttempts) {
        _lockUntil = DateTime.now().add(loginLockDuration);
      }
      await _saveUser();
      notifyListeners();
      return false;
    }
  }

  Future<void> resetAllData() async {
    // Reset semua data
    await _user?.clearData(); // Implementasikan method ini di User model
    _user = null;
    _isAuthenticated = false;
    _lastActivity = null;
    _lockUntil = null;
    _failedAttempts = 0;
    await _saveUser();
    notifyListeners();
  }

  Future<bool> authenticateWithBiometrics() async {
    if (_user?.useBiometric != true) return false;

    final authenticated = await BiometricService.authenticate();
    if (authenticated) {
      await _login();
    }
    return authenticated;
  }

  Future<void> _login() async {
    _isAuthenticated = true;
    _lastActivity = DateTime.now();
    _user?.lastLogin = _lastActivity;
    await _saveUser();
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _lastActivity = null;
    notifyListeners();
  }

  void updateLastActivity() {
    _lastActivity = DateTime.now();
  }

  bool shouldLockApp(Duration timeout) {
    if (!_isAuthenticated || _lastActivity == null) return false;
    return DateTime.now().difference(_lastActivity!) > timeout;
  }

  Future<void> _saveUser() async {
    final box = await Hive.openBox('users');
    try {
      if (_user != null) {
        // Simpan data user ke Hive
        await box.put('current_user', _user!.toJson());
      }
    } finally {
      await box.close();
    }
  }

  Future<void> loadUser() async {
    final box = await Hive.openBox('users');
    try {
      final userData = box.get('current_user');
      if (userData != null) {
        _user = User.fromJson(Map<String, dynamic>.from(userData));
        notifyListeners();
      }
    } finally {
      await box.close();
    }
  }

  Future<bool> canUseBiometric() async {
    if (_user == null || !_user!.useBiometric) return false;
    final localAuth = LocalAuthentication();
    return await localAuth.canCheckBiometrics;
  }

  Future<void> changePin(String newPin) async {
    if (user == null) throw Exception('User tidak ditemukan');

    final salt = EncryptionUtil.generateSalt();
    final hashedPin = EncryptionUtil.hashWithSalt(newPin, salt);

    user!.pin = hashedPin;
    user!.salt = salt;

    await _saveUser();
    notifyListeners();
  }

  Future<bool> login(String pin) async {
    if (user == null) return false;

    final hashedInput = EncryptionUtil.hashWithSalt(pin, user!.salt);
    if (user!.pin != hashedInput) {
      return false;
    }

    _isAuthenticated = true;
    _lastActivity = DateTime.now();
    notifyListeners();
    return true;
  }
}
