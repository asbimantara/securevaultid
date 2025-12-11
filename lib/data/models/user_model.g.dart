// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 2;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      pin: fields[1] as String,
      salt: fields[2] as String,
      useBiometric: fields[3] as bool,
      lastLogin: fields[4] as DateTime?,
      failedAttempts: fields[5] as int,
      lockedUntil: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pin)
      ..writeByte(2)
      ..write(obj.salt)
      ..writeByte(3)
      ..write(obj.useBiometric)
      ..writeByte(4)
      ..write(obj.lastLogin)
      ..writeByte(5)
      ..write(obj.failedAttempts)
      ..writeByte(6)
      ..write(obj.lockedUntil);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
