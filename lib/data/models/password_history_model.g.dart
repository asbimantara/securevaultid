// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PasswordHistoryAdapter extends TypeAdapter<PasswordHistory> {
  @override
  final int typeId = 2;

  @override
  PasswordHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PasswordHistory(
      password: fields[0] as String,
      changedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PasswordHistory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.password)
      ..writeByte(1)
      ..write(obj.changedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
