import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  bool _isDarkMode = false;
  bool _useSystemTheme = true;
  String _accentColor = 'deepPurple';
  bool _useBiometric = false;
  int _autoLockDuration = 5;
  bool _hidePasswords = true;
  bool _autoBackup = true;
  int _backupInterval = 7;
  bool _encryptBackup = true;
  bool _autoLock = true;

  bool get autoLock => _autoLock;

  SettingsProvider(this._repository);

  // Theme Settings
  bool get isDarkMode => _isDarkMode;
  bool get useSystemTheme => _useSystemTheme;
  String get accentColor => _accentColor;

  // Security Settings
  bool get useBiometric => _useBiometric;
  int get autoLockDuration => _autoLockDuration;
  bool get hidePasswords => _hidePasswords;

  // Backup Settings
  bool get autoBackup => _autoBackup;
  int get backupInterval => _backupInterval;
  bool get encryptBackup => _encryptBackup;

  Future<void> initialize() async {
    _isDarkMode = await _repository.getDarkMode();
    _useSystemTheme = await _repository.getUseSystemTheme();
    _accentColor = _repository.getAccentColor();
    _useBiometric = _repository.getUseBiometric();
    _autoLockDuration = _repository.getAutoLockDuration();
    _hidePasswords = _repository.getHidePasswords();
    _autoBackup = _repository.getAutoBackup();
    _backupInterval = _repository.getBackupInterval();
    _encryptBackup = _repository.getEncryptBackup();
    _autoLock = await _repository.getAutoLock();
    notifyListeners();
  }

  // Theme Settings Methods
  Future<void> setDarkMode(bool value) async {
    await _repository.setDarkMode(value);
    _isDarkMode = value;
    notifyListeners();
  }

  Future<void> setUseSystemTheme(bool value) async {
    await _repository.setUseSystemTheme(value);
    _useSystemTheme = value;
    notifyListeners();
  }

  Future<void> setAccentColor(String value) async {
    await _repository.setAccentColor(value);
    _accentColor = value;
    notifyListeners();
  }

  // Security Settings Methods
  Future<void> setUseBiometric(bool value) async {
    await _repository.setUseBiometric(value);
    _useBiometric = value;
    notifyListeners();
  }

  Future<void> setAutoLockDuration(int minutes) async {
    await _repository.setAutoLockDuration(minutes);
    _autoLockDuration = minutes;
    notifyListeners();
  }

  Future<void> setHidePasswords(bool value) async {
    await _repository.setHidePasswords(value);
    _hidePasswords = value;
    notifyListeners();
  }

  // Backup Settings Methods
  Future<void> setAutoBackup(bool value) async {
    await _repository.setAutoBackup(value);
    _autoBackup = value;
    notifyListeners();
  }

  Future<void> setBackupInterval(int days) async {
    await _repository.setBackupInterval(days);
    _backupInterval = days;
    notifyListeners();
  }

  Future<void> setEncryptBackup(bool value) async {
    await _repository.setEncryptBackup(value);
    _encryptBackup = value;
    notifyListeners();
  }

  Future<void> setAutoLock(bool value) async {
    _autoLock = value;
    await _repository.setAutoLock(value);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    await _repository.clearAll();
    await initialize();
  }
}
