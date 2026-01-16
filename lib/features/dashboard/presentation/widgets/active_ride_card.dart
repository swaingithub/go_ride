import 'package:flutter/material.dart';
import 'package:go_ride/features/bookings/domain/trip_model.dart';
import 'package:go_ride/features/bookings/domain/trip_status.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


class ActiveRideCard extends StatelessWidget {
  final TripModel trip;

  const ActiveRideCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
         GoRouter.of(context).push('/tracking', extra: trip);
      },
      child: Card(
        elevation: 4,

      shadowColor: trip.status.color.withOpacity(0.4),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              trip.status.color.withOpacity(0.1),
              Colors.white.withOpacity(0.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: trip.status.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.directions_car, color: trip.status.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Ride',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        trip.status.displayName.toUpperCase(),
                        style: TextStyle(
                          color: trip.status.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(trip.fareAmount),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.my_location, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(trip.pickupLocation, style: const TextStyle(fontWeight: FontWeight.w500))),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 7),
              height: 20,
              width: 2,
              color: Colors.grey.withOpacity(0.3),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(child: Text(trip.dropLocation, style: const TextStyle(fontWeight: FontWeight.w500))),
              ],
            ),
            
            if (trip.status == TripStatus.rideStarted) ...[
               const SizedBox(height: 16),
               LinearProgressIndicator(color: trip.status.color, backgroundColor: trip.status.color.withOpacity(0.1)),
            ]
          ],
        ),
        ),
      ),
    );
  }
}


