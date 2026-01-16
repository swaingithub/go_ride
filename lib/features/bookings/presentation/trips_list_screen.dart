import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_ride/features/bookings/data/trip_repository.dart';
import 'package:go_ride/features/bookings/domain/trip_model.dart';
import 'package:intl/intl.dart';

class TripsListScreen extends ConsumerWidget {
  const TripsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(tripRepositoryProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Your Trips')),
      body: StreamBuilder<List<TripModel>>(
        stream: repo.watchTrips(),
        initialData: repo.getTrips(),
        builder: (context, snapshot) {
          final trips = snapshot.data ?? [];
          if (trips.isEmpty) {
            return const Center(child: Text('No trips found.'));
          }
          
          // Sort by date desc
          trips.sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Dismissible(
                key: Key(trip.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  repo.deleteTrip(trip.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Trip deleted'), action: SnackBarAction(label: 'Undo', onPressed: () {
                      repo.addTrip(trip);
                    })),
                  );
                },
                child: ListTile(
                  title: Text('${trip.pickupLocation} -> ${trip.dropLocation}'),
                  subtitle: Text(DateFormat.yMMMd().add_jm().format(trip.date)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(trip.rideType.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        trip.status.displayName,
                        style: TextStyle(color: trip.status.color, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
