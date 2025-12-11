import 'package:hive/hive.dart';

class SettingsRepository {
  static const String _boxName = 'settings';
  late Box<dynamic> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  // Theme Settings
  Future<bool> getDarkMode() async {
    return _box.get('dark_mode', defaultValue: false);
  }

  Future<void> setDarkMode(bool value) async {
    await _box.put('dark_mode', value);
  }

  Future<bool> getUseSystemTheme() async {
    return _box.get('use_system_theme', defaultValue: true);
  }

  Future<void> setUseSystemTheme(bool value) async {
    await _box.put('use_system_theme', value);
  }

  String getAccentColor() =>
      _box.get('accentColor', defaultValue: 'deepPurple');
  Future<void> setAccentColor(String value) => _box.put('accentColor', value);

  // Security Settings
  bool getUseBiometric() => _box.get('useBiometric', defaultValue: false);
  Future<void> setUseBiometric(bool value) => _box.put('useBiometric', value);

  int getAutoLockDuration() => _box.get('autoLockDuration', defaultValue: 5);
  Future<void> setAutoLockDuration(int minutes) =>
      _box.put('autoLockDuration', minutes);

  bool getHidePasswords() => _box.get('hidePasswords', defaultValue: true);
  Future<void> setHidePasswords(bool value) => _box.put('hidePasswords', value);

  // Backup Settings
  bool getAutoBackup() => _box.get('autoBackup', defaultValue: true);
  Future<void> setAutoBackup(bool value) => _box.put('autoBackup', value);

  int getBackupInterval() => _box.get('backupInterval', defaultValue: 7);
  Future<void> setBackupInterval(int days) => _box.put('backupInterval', days);

  bool getEncryptBackup() => _box.get('encryptBackup', defaultValue: true);
  Future<void> setEncryptBackup(bool value) => _box.put('encryptBackup', value);

  Future<bool> getAutoLock() async {
    return _box.get('auto_lock', defaultValue: true);
  }

  Future<void> setAutoLock(bool value) async {
    await _box.put('auto_lock', value);
  }

  Future<void> clearAll() => _box.clear();
}
