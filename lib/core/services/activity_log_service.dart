import 'package:hive/hive.dart';
import '../../data/models/activity_log_model.dart';

class ActivityLogService {
  static const _boxName = 'activity_logs';
  static late Box<ActivityLog> _box;

  static Future<void> initialize() async {
    _box = await Hive.openBox<ActivityLog>(_boxName);
  }

  static Future<void> logActivity(
    ActivityType type,
    String description, {
    String? details,
  }) async {
    final log = ActivityLog(
      type: type,
      description: description,
      details: details,
      timestamp: DateTime.now(),
    );
    await _box.add(log);

    // Keep only last 100 logs
    if (_box.length > 100) {
      final keysToDelete = _box.keys.take(_box.length - 100);
      await _box.deleteAll(keysToDelete);
    }
  }

  static List<ActivityLog> getRecentLogs([int limit = 50]) {
    final logs = _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs.take(limit).toList();
  }

  static Future<void> clearLogs() async {
    await _box.clear();
  }
}
