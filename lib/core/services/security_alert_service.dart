import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/models/password_model.dart';
import 'activity_log_service.dart';

class SecurityAlertService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static const _channelId = 'security_alerts';
  static const _channelName = 'Security Alerts';

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

  static Future<void> checkPasswordSecurity(List<Password> passwords) async {
    for (final password in passwords) {
      // Check password age
      final age = DateTime.now().difference(
        password.lastModified ?? password.createdAt,
      );
      if (age > const Duration(days: 90)) {
        await _showAlert(
          'Password Perlu Diperbarui',
          'Password untuk ${password.title} sudah lebih dari 90 hari',
        );
        await ActivityLogService.logActivity(
          ActivityType.securityAlert,
          'Password terlalu lama',
          details: 'Password ${password.title} perlu diperbarui',
        );
      }

      // Check password strength
      if (password.password.length < 8) {
        await _showAlert(
          'Password Lemah Terdeteksi',
          'Password untuk ${password.title} terlalu pendek',
        );
        await ActivityLogService.logActivity(
          ActivityType.securityAlert,
          'Password lemah terdeteksi',
          details: 'Password ${password.title} terlalu pendek',
        );
      }
    }
  }

  static Future<void> _showAlert(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
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
    );
  }
}
