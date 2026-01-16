import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_ride/core/constants/hive_constants.dart';
import 'package:go_ride/features/bookings/domain/ride_type.dart';
import 'package:go_ride/features/bookings/domain/trip_model.dart';
import 'package:go_ride/features/bookings/domain/trip_status.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(Hive.box<TripModel>(HiveConstants.tripBox));
});

class TripRepository {
  final Box<TripModel> _box;

  TripRepository(this._box);

  List<TripModel> getTrips() {
    return _box.values.toList();
  }

  Future<void> addTrip(TripModel trip) async {
    // Check if key exists (UUID) just in case, but put will overwrite if so.
    // Ensure we use the same key strategy.
    await _box.put(trip.id, trip);
  }

  Future<void> updateTrip(TripModel trip) async {
    await _box.put(trip.id, trip);
  }

  Future<void> deleteTrip(String id) async {
    await _box.delete(id);
  }
  
  Stream<List<TripModel>> watchTrips() {
    return _box.watch().map((event) {
      return _box.values.toList();
    });
  }

  Future<void> checkAndSeed() async {
    if (_box.isEmpty) {
      final now = DateTime.now();
      final random = Random();
      
      final locations = [
        ('Central Mall', 'Airport'),
        ('Tech Park', 'Home'),
        ('City Center', 'Gym'),
        ('Station', 'Office'),
        ('Market', 'Cinema'),
      ];

      final trips = List.generate(10, (index) {
        final loc = locations[random.nextInt(locations.length)];
        final type = RideType.values[random.nextInt(RideType.values.length)];
        // Random date within last 30 days
        final date = now.subtract(Duration(days: random.nextInt(30), hours: random.nextInt(24)));
        final status = index < 2 ? TripStatus.requested : TripStatus.completed; // 2 active, rest completed
        
        return TripModel(
          id: const Uuid().v4(),
          pickupLocation: loc.$1,
          dropLocation: loc.$2,
          rideType: type,
          fareAmount: 50.0 + random.nextInt(150), // 50 - 200
          date: date,
          status: status,
        );
      });

      for (var trip in trips) {
        await addTrip(trip);
      }
    }
  }
}
