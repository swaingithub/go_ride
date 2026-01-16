import 'package:go_ride/core/constants/hive_constants.dart';
import 'package:go_ride/features/bookings/domain/ride_type.dart';
import 'package:go_ride/features/dashboard/domain/spending_limit_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final spendingLimitRepositoryProvider = Provider<SpendingLimitRepository>((ref) {
  return SpendingLimitRepository(Hive.box<SpendingLimitModel>(HiveConstants.settingsBox));
});

class SpendingLimitRepository {
  final Box<SpendingLimitModel> _box;

  SpendingLimitRepository(this._box);

  Future<void> setLimit(RideType type, double amount) async {
    // Check if exists
    final existingKey = _box.values.firstWhere(
      (limit) => limit.rideType == type,
      orElse: () => SpendingLimitModel(rideType: type, limitAmount: 0),
    ).key;

    if (existingKey != null) {
      final limit = _box.get(existingKey);
      limit?.limitAmount = amount;
      await limit?.save();
    } else {
      await _box.add(SpendingLimitModel(rideType: type, limitAmount: amount));
    }
  }

  double getLimit(RideType type) {
    try {
      final limit = _box.values.firstWhere((l) => l.rideType == type);
      return limit.limitAmount;
    } catch (_) {
      return 0.0; // Default limit 0 (or infinite? Usually 0 means no budget set or strict 0, let's assume 0 means unset/unlimited or handle in UI. Requirement says "Allow user to set", so default might be 0/null)
    }
  }
  
  // Watch limits
  Stream<Map<RideType, double>> watchLimits() {
    return _box.watch().map((event) {
      return getAllLimits();
    }); // This will emit on every change
  }

  Map<RideType, double> getAllLimits() {
    final map = <RideType, double>{};
    for (var type in RideType.values) {
      map[type] = getLimit(type);
    }
    return map;
  }
}
