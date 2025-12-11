// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityLogAdapter extends TypeAdapter<ActivityLog> {
  @override
  final int typeId = 3;

  @override
  ActivityLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityLog(
      type: fields[0] as ActivityType,
      description: fields[1] as String,
      details: fields[2] as String?,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.details)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityTypeAdapter extends TypeAdapter<ActivityType> {
  @override
  final int typeId = 4;

  @override
  ActivityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityType.passwordCreated;
      case 1:
        return ActivityType.passwordModified;
      case 2:
        return ActivityType.passwordDeleted;
      case 3:
        return ActivityType.passwordShared;
      case 4:
        return ActivityType.categoryModified;
      case 5:
        return ActivityType.securityAlert;
      case 6:
        return ActivityType.settingsChanged;
      case 7:
        return ActivityType.backup;
      case 8:
        return ActivityType.restore;
      default:
        return ActivityType.passwordCreated;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityType obj) {
    switch (obj) {
      case ActivityType.passwordCreated:
        writer.writeByte(0);
        break;
      case ActivityType.passwordModified:
        writer.writeByte(1);
        break;
      case ActivityType.passwordDeleted:
        writer.writeByte(2);
        break;
      case ActivityType.passwordShared:
        writer.writeByte(3);
        break;
      case ActivityType.categoryModified:
        writer.writeByte(4);
        break;
      case ActivityType.securityAlert:
        writer.writeByte(5);
        break;
      case ActivityType.settingsChanged:
        writer.writeByte(6);
        break;
      case ActivityType.backup:
        writer.writeByte(7);
        break;
      case ActivityType.restore:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
