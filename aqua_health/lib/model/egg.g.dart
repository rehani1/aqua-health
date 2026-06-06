// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'egg.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EggAdapter extends TypeAdapter<Egg> {
  @override
  final int typeId = 1;

  @override
  Egg read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Egg(
      fields[0] as int,
      fields[1] as int,
    )..totalSteps = fields[2] as int;
  }

  @override
  void write(BinaryWriter writer, Egg obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.rarity)
      ..writeByte(1)
      ..write(obj.stepsNeeded)
      ..writeByte(2)
      ..write(obj.totalSteps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EggAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
