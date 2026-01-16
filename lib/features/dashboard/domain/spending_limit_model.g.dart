// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_limit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpendingLimitModelAdapter extends TypeAdapter<SpendingLimitModel> {
  @override
  final int typeId = 3;

  @override
  SpendingLimitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpendingLimitModel(
      rideType: fields[0] as RideType,
      limitAmount: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SpendingLimitModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.rideType)
      ..writeByte(1)
      ..write(obj.limitAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpendingLimitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
