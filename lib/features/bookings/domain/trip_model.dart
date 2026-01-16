import 'package:hive/hive.dart';
import 'package:go_ride/features/bookings/domain/ride_type.dart';
import 'package:go_ride/features/bookings/domain/trip_status.dart';

part 'trip_model.g.dart';

@HiveType(typeId: 2)
class TripModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String pickupLocation;

  @HiveField(2)
  final String dropLocation;

  @HiveField(3)
  final RideType rideType;

  @HiveField(4)
  double fareAmount;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  TripStatus status;
  
  // For simulation
  @HiveField(7)
  int? estimatedDurationMinutes;

  TripModel({
    required this.id,
    required this.pickupLocation,
    required this.dropLocation,
    required this.rideType,
    required this.fareAmount,
    required this.date,
    this.status = TripStatus.requested,
    this.estimatedDurationMinutes,
  });

  TripModel copyWith({
    String? id,
    String? pickupLocation,
    String? dropLocation,
    RideType? rideType,
    double? fareAmount,
    DateTime? date,
    TripStatus? status,
    int? estimatedDurationMinutes,
  }) {
    return TripModel(
      id: id ?? this.id,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropLocation: dropLocation ?? this.dropLocation,
      rideType: rideType ?? this.rideType,
      fareAmount: fareAmount ?? this.fareAmount,
      date: date ?? this.date,
      status: status ?? this.status,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    );
  }
}
