import 'package:go_ride/core/constants/hive_constants.dart';
import 'package:go_ride/features/bookings/domain/trip_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    await _box.add(trip); // Or _box.put(trip.id, trip) if I want string keys
    // Using default Hive add with auto-increment key or just put if ID is key.
    // Since I have a UUID in the model, let's use that as the key.
    await _box.put(trip.id, trip);
  }

  Future<void> updateTrip(TripModel trip) async {
    await _box.put(trip.id, trip);
  }


  Future<void> deleteTrip(String id) async {
    await _box.delete(id);
  }

  // Stream of trips for real-time updates
  Stream<List<TripModel>> watchTrips() {
    return _box.watch().map((event) {
      return _box.values.toList();
    }); // This might be slightly inefficient for large lists but fine for assignment
  }
}
