// - Route names
// - Color constants
// - String constants

class AppConstants {
  // Route Names
  static const String routeHome = '/home';
  static const String routeAuth = '/auth';
  static const String routeSettings = '/settings';
  static const String routePasswordList = '/passwords';
  static const String routePasswordForm = '/password/form';
  static const String routeCategories = '/categories';
  static const String routeBackup = '/backup';

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyAutoBackup = 'auto_backup';
  static const String keyLastBackup = 'last_backup';
  static const String keyPinAttempts = 'pin_attempts';
  static const String keyLastAttempt = 'last_attempt';

  // Timeouts & Durations
  static const Duration sessionTimeout = Duration(minutes: 5);
  static const Duration backupInterval = Duration(days: 7);
  static const Duration passwordMaxAge = Duration(days: 90);
  static const Duration lockoutDuration = Duration(minutes: 30);

  // Limits & Thresholds
  static const int maxPinAttempts = 3;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int maxCategories = 20;
  static const int maxBackupFiles = 5;

  // Messages
  static const String msgPasswordCopied = 'Password disalin ke clipboard';
  static const String msgBackupSuccess = 'Backup berhasil dibuat';
  static const String msgRestoreSuccess = 'Data berhasil dipulihkan';
  static const String msgPinIncorrect = 'PIN tidak sesuai';
  static const String msgAccountLocked = 'Akun terkunci, coba lagi nanti';
}
