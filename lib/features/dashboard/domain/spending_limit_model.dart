import 'package:hive/hive.dart';
import 'package:go_ride/features/bookings/domain/ride_type.dart';

part 'spending_limit_model.g.dart';

@HiveType(typeId: 3)
class SpendingLimitModel extends HiveObject {
  @HiveField(0)
  final RideType rideType;

  @HiveField(1)
  double limitAmount;

  SpendingLimitModel({
    required this.rideType,
    required this.limitAmount,
  });
}
