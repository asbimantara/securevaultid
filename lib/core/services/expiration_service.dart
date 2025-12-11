import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/models/password_model.dart';

class ExpirationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
  }

  static Future<void> scheduleExpirationReminder(Password password) async {
    if (password.expirationDate == null) return;

    final daysUntilExpiration =
        password.expirationDate!.difference(DateTime.now()).inDays;

    if (daysUntilExpiration <= 0) return;

    // Schedule notification 7 days before expiration
    if (daysUntilExpiration > 7) {
      await _scheduleNotification(
        id: password.key,
        title: 'Password akan Kedaluwarsa',
        body: 'Password untuk ${password.title} akan kedaluwarsa dalam 7 hari',
        scheduledDate:
            password.expirationDate!.subtract(const Duration(days: 7)),
      );
    }

    // Schedule notification on expiration day
    await _scheduleNotification(
      id: password.key + 1000, // Avoid ID conflict
      title: 'Password Kedaluwarsa',
      body: 'Password untuk ${password.title} telah kedaluwarsa',
      scheduledDate: password.expirationDate!,
    );
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'password_expiration',
          'Password Expiration',
          channelDescription: 'Notifikasi kedaluwarsa password',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  static Future<void> cancelReminder(Password password) async {
    await _notifications.cancel(password.key);
    await _notifications.cancel(password.key + 1000);
  }
}
