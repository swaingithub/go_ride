import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_ride/features/bookings/data/trip_repository.dart';
import 'package:go_ride/features/bookings/domain/trip_model.dart';
import 'package:go_ride/features/bookings/domain/trip_status.dart';

final rideSimulationServiceProvider = Provider<RideSimulationService>((ref) {
  final service = RideSimulationService(ref.read(tripRepositoryProvider));
  ref.onDispose(() => service.dispose());
  return service;
});

class RideSimulationService {
  final TripRepository _repository;
  Timer? _timer;
  final Random _random = Random();

  final _eventController = StreamController<TripEvent>.broadcast();
  Stream<TripEvent> get events => _eventController.stream;

  RideSimulationService(this._repository) {
    _startSimulation();
  }

  void _startSimulation() {
    // Run every 3 seconds to simulate updates
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _processTrips();
    });
  }

  void dispose() {
    _timer?.cancel();
    _eventController.close();
  }


  Future<void> _processTrips() async {
    final trips = _repository.getTrips();
    final activeTrips = trips.where((t) => 
      t.status != TripStatus.completed && t.status != TripStatus.cancelled).toList();

    for (final trip in activeTrips) {
      TripStatus? newStatus;
      double? newFare;
      
      // Simulate real-time transitions
      switch (trip.status) {
        case TripStatus.requested:
          if (_random.nextDouble() > 0.5) {
             newStatus = TripStatus.driverAssigned;
          }
          break;
        case TripStatus.driverAssigned:
           if (_random.nextDouble() > 0.5) {
             newStatus = TripStatus.rideStarted;
           }
           break;
        case TripStatus.rideStarted:
           newFare = trip.fareAmount + (_random.nextDouble() * 2);
           if (_random.nextDouble() > 0.7) {
             newStatus = TripStatus.completed;
           }
           break;
        default:
          break;
      }

      if (newStatus != null || newFare != null) {
        final updatedTrip = trip.copyWith(
          status: newStatus,
          fareAmount: newFare,
        );
        await _repository.updateTrip(updatedTrip);
        
        if (newStatus != null) {
          _eventController.add(TripStatusChangedEvent(trip, newStatus));
        }
      }
    }
  }
}

class TripEvent {}
class TripStatusChangedEvent extends TripEvent {
  final TripModel trip;
  final TripStatus newStatus;
  TripStatusChangedEvent(this.trip, this.newStatus);
}

