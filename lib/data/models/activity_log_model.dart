import 'package:hive/hive.dart';

part 'activity_log_model.g.dart';

@HiveType(typeId: 3)
class ActivityLog extends HiveObject {
  @HiveField(0)
  final ActivityType type;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String? details;

  @HiveField(3)
  final DateTime timestamp;

  ActivityLog({
    required this.type,
    required this.description,
    this.details,
    required this.timestamp,
  });
}

@HiveType(typeId: 4)
enum ActivityType {
  @HiveField(0)
  passwordCreated,

  @HiveField(1)
  passwordModified,

  @HiveField(2)
  passwordDeleted,

  @HiveField(3)
  passwordShared,

  @HiveField(4)
  categoryModified,

  @HiveField(5)
  securityAlert,

  @HiveField(6)
  settingsChanged,

  @HiveField(7)
  backup,

  @HiveField(8)
  restore,
}
