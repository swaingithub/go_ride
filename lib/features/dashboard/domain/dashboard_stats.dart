import 'package:go_ride/features/bookings/domain/ride_type.dart';
import 'package:go_ride/features/bookings/domain/trip_model.dart';
import 'package:go_ride/features/bookings/domain/trip_status.dart';

class DashboardStats {
  final int totalTripsCompleted;
  final double totalAmountSpent;
  final List<TripModel> recentTrips;
  final Map<RideType, int> tripsByType;
  final Map<RideType, double> spendingByType;

  DashboardStats({
    required this.totalTripsCompleted,
    required this.totalAmountSpent,
    required this.recentTrips,
    required this.tripsByType,
    required this.spendingByType,
  });

  factory DashboardStats.fromTrips(List<TripModel> trips) {
    var completedTrips = trips.where((t) => t.status == TripStatus.completed).toList();
    var totalSpent = completedTrips.fold(0.0, (sum, t) => sum + t.fareAmount);
    
    // Recent trips: showing all active and recently completed
    // Requirements say "Recent trips (last 5-10)"
    // Sort by date descending
    trips.sort((a, b) => b.date.compareTo(a.date));
    var recent = trips.take(10).toList();

    var byType = <RideType, int>{};
    for (var type in RideType.values) {
      byType[type] = trips.where((t) => t.rideType == type).length;
    }
    
    var spendingByType = <RideType, double>{};
     for (var type in RideType.values) {
      // Assuming limits check against ALL spending or just this month?
      // "Monthly spending limit"
      // Let's filter by current month for spending calculations relevant to limits
      // But for total dashboard stats, maybe total? 
      // "Total amount spent" usually implies total.
      // "Highlight over-limit ride categories" -> implies we need monthly spending per category.
      // I'll calculate monthly spending per category here too.
      
      var monthlyTrips = completedTrips.where((t) => 
        t.rideType == type && 
        t.date.month == DateTime.now().month && 
        t.date.year == DateTime.now().year
      );
      
      spendingByType[type] = monthlyTrips.fold(0.0, (sum, t) => sum + t.fareAmount);
    }


    return DashboardStats(
      totalTripsCompleted: completedTrips.length,
      totalAmountSpent: totalSpent,
      recentTrips: recent,
      tripsByType: byType,
      spendingByType: spendingByType,
    );
  }
}
