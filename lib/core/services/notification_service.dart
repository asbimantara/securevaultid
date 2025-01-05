import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_constants.dart';
import '../../data/models/password_model.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static const _channelId = 'secure_vault';
  static const _channelName = 'SecureVault Notifications';
  static const _channelDescription = 'Notifikasi keamanan dan backup';

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  static Future<void> checkPasswordExpiry(List<Password> passwords) async {
    for (final password in passwords) {
      final age = DateTime.now().difference(
        password.lastModified ?? password.createdAt,
      );
      if (age > AppConstants.passwordMaxAge) {
        await showNotification(
          'Password Perlu Diperbarui',
          'Password untuk ${password.title} sudah lebih dari 90 hari',
          NotificationType.security,
        );
      }
    }
  }

  static Future<void> scheduleBackupReminder() async {
    await showNotification(
      'Backup Data',
      'Sudah waktunya untuk backup data Anda',
      NotificationType.backup,
    );
  }

  static Future<void> showNotification(
    String title,
    String body,
    NotificationType type,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: type.toString(),
    );
  }
}

enum NotificationType {
  security,
  backup,
  system,
}
