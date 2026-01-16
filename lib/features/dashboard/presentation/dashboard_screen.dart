import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_ride/features/bookings/application/ride_simulation_service.dart';

import 'package:go_ride/core/theme/app_theme.dart';
import 'package:go_ride/features/dashboard/application/dashboard_providers.dart';
import 'package:go_ride/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:go_ride/features/dashboard/presentation/widgets/trip_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:go_ride/features/bookings/domain/ride_type.dart';

import 'package:go_ride/features/dashboard/presentation/widgets/active_ride_card.dart';
import 'package:go_ride/features/bookings/domain/trip_status.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final limitsAsync = ref.watch(spendingLimitsProvider);
    
    ref.listen(tripEventsProvider, (previous, next) {
      next.whenData((event) {
        if (event is TripStatusChangedEvent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update: Ride to ${event.trip.dropLocation} is ${event.newStatus.displayName}'),
              backgroundColor: event.newStatus.color,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    });

    return Scaffold(
      body: statsAsync.when(
        data: (stats) {
          // Find if there is any active trip
          final activeTrips = stats.recentTrips.where((t) => 
            t.status == TripStatus.requested || 
            t.status == TripStatus.driverAssigned || 
            t.status == TripStatus.rideStarted
          ).toList();
          
          final activeTrip = activeTrips.isNotEmpty ? activeTrips.first : null;

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text('GoRide'),
                centerTitle: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activeTrip != null) ...[
                        Text('Live Trip', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ActiveRideCard(trip: activeTrip),
                        const SizedBox(height: 24),
                      ],
                    
                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 140,
                              child: StatCard(
                                title: 'Total Trips',
                                value: stats.totalTripsCompleted.toString(),
                                icon: Icons.playlist_add_check,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 140,
                              child: StatCard(
                                title: 'Total Spent',
                                value: NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(stats.totalAmountSpent),
                                icon: Icons.attach_money,

                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Chart Section
                      Text('Ride Analytics', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TripChart(tripsByType: stats.tripsByType),
                       const SizedBox(height: 24),
                      
                      // Limits Section (Bonus)
                      Text('Spending Limits', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      limitsAsync.when(
                        data: (limits) {
                           return Column(
                             children: RideType.values.map((type) {
                               final limit = limits[type] ?? 0;
                               final spent = stats.spendingByType[type] ?? 0;
                               final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                               final isOverLimit = limit > 0 && spent > limit;
                               final color = isOverLimit ? Colors.red : (progress > 0.8 ? Colors.orange : AppTheme.primaryColor);
                               
                               return Card(
                                 margin: const EdgeInsets.only(bottom: 12),
                                 elevation: 0,
                                 color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                 child: Padding(
                                   padding: const EdgeInsets.all(12.0),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           Row(children: [
                                              Icon(_getIconForType(type), size: 16, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Text(type.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                           ]),
                                           Text(
                                             '${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(spent)} / ${limit > 0 ? NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(limit) : "No Limit"}',
                                              style: TextStyle(

                                                color: isOverLimit ? Colors.red : Theme.of(context).colorScheme.onSurface,
                                                fontWeight: FontWeight.bold
                                              ),
                                           ),
                                         ],
                                       ),
                                       const SizedBox(height: 8),
                                       if (limit > 0)
                                         LinearProgressIndicator(
                                           value: progress,
                                           color: color,
                                           backgroundColor: color.withOpacity(0.1),
                                           borderRadius: BorderRadius.circular(4),
                                         ),
                                     ],
                                   ),
                                 ),
                               );
                             }).toList(),
                           );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (_,__) => const SizedBox(),
                      ),
                      const SizedBox(height: 24),

                      // Recent Trips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Trips', style: Theme.of(context).textTheme.titleLarge),
                          TextButton(onPressed: () => context.push('/trips'), child: const Text('View All')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // List of recent trips
                      if (stats.recentTrips.isEmpty) 
                        const Center(child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text("No trips yet. Book your first ride!"),
                        ))
                      else
                        ...stats.recentTrips.take(5).map((trip) => Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surface,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: trip.status.color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIconForType(trip.rideType),
                                color: trip.status.color,
                                size: 20,
                              ),
                            ),
                            title: Text(trip.dropLocation, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 const SizedBox(height: 4),
                                 Text(DateFormat.MMMEd().add_jm().format(trip.date), style: const TextStyle(fontSize: 12)),
                               ]
                            ), 
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(trip.fareAmount),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),

                                Text(
                                  trip.status.displayName,
                                  style: TextStyle(color: trip.status.color, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Edit or View Trip
                              // context.push('/trip/${trip.id}');
                            },
                          ),
                        )),
                      const SizedBox(height: 80), // Fab spacing
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-trip'),
        label: const Text('Book Ride'),
        icon: const Icon(Icons.local_taxi),
      ),
    );
  }


  IconData _getIconForType(RideType type) {
    switch (type) {
      case RideType.mini: return Icons.directions_car;
      case RideType.sedan: return Icons.airport_shuttle;
      case RideType.auto: return Icons.electric_rickshaw;
      case RideType.bike: return Icons.two_wheeler;
    }
  }
}

