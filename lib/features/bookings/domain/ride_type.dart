import 'package:hive/hive.dart';

part 'ride_type.g.dart';

@HiveType(typeId: 0)
enum RideType {
  @HiveField(0)
  mini,
  @HiveField(1)
  sedan,
  @HiveField(2)
  auto,
  @HiveField(3)
  bike;

  String get displayName {
    switch (this) {
      case RideType.mini:
        return 'Mini';
      case RideType.sedan:
        return 'Sedan';
      case RideType.auto:
        return 'Auto';
      case RideType.bike:
        return 'Bike';
    }
  }
}
