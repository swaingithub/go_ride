// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripStatusAdapter extends TypeAdapter<TripStatus> {
  @override
  final int typeId = 1;

  @override
  TripStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TripStatus.requested;
      case 1:
        return TripStatus.driverAssigned;
      case 2:
        return TripStatus.rideStarted;
      case 3:
        return TripStatus.completed;
      case 4:
        return TripStatus.cancelled;
      default:
        return TripStatus.requested;
    }
  }

  @override
  void write(BinaryWriter writer, TripStatus obj) {
    switch (obj) {
      case TripStatus.requested:
        writer.writeByte(0);
        break;
      case TripStatus.driverAssigned:
        writer.writeByte(1);
        break;
      case TripStatus.rideStarted:
        writer.writeByte(2);
        break;
      case TripStatus.completed:
        writer.writeByte(3);
        break;
      case TripStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
