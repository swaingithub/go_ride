import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_ride/features/bookings/application/ride_simulation_service.dart';
import 'package:go_ride/features/bookings/data/trip_repository.dart';
import 'package:go_ride/features/bookings/domain/ride_type.dart';
import 'package:go_ride/features/dashboard/data/spending_limit_repository.dart';
import 'package:go_ride/features/dashboard/domain/dashboard_stats.dart';


final tripEventsProvider = StreamProvider<TripEvent>((ref) {
  final service = ref.watch(rideSimulationServiceProvider);
  return service.events;
});


final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) async* {
  // Activate simulation
  ref.watch(rideSimulationServiceProvider);
  
  final repo = ref.watch(tripRepositoryProvider);
  
  // Initial stats
  yield DashboardStats.fromTrips(repo.getTrips());
  
  // Updates
  await for (final trips in repo.watchTrips()) {
    yield DashboardStats.fromTrips(trips);
  }
});

final spendingLimitsProvider = StreamProvider<Map<RideType, double>>((ref) async* {
  final repo = ref.watch(spendingLimitRepositoryProvider);
  yield repo.getAllLimits();
  yield* repo.watchLimits();
});
