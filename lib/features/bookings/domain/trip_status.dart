import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'trip_status.g.dart';

@HiveType(typeId: 1)
enum TripStatus {
  @HiveField(0)
  requested,
  @HiveField(1)
  driverAssigned,
  @HiveField(2)
  rideStarted,
  @HiveField(3)
  completed,
  @HiveField(4)
  cancelled;

  String get displayName {
    switch (this) {
      case TripStatus.requested:
        return 'Requested';
      case TripStatus.driverAssigned:
        return 'Driver Assigned';
      case TripStatus.rideStarted:
        return 'Ride Started';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case TripStatus.requested:
        return Colors.orange;
      case TripStatus.driverAssigned:
        return Colors.blue;
      case TripStatus.rideStarted:
        return Colors.purple;
      case TripStatus.completed:
        return Colors.green;
      case TripStatus.cancelled:
        return Colors.red;
    }
  }
}
