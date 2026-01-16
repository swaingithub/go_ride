import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_ride/features/bookings/data/trip_repository.dart';
import 'package:go_ride/features/bookings/domain/trip_model.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class TripsListScreen extends ConsumerWidget {
  const TripsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(tripRepositoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () => _exportTrips(context, repo.getTrips()),
          ),
        ],
      ),
      body: StreamBuilder<List<TripModel>>(
        stream: repo.watchTrips(),
        initialData: repo.getTrips(),
        builder: (context, snapshot) {
          final trips = snapshot.data ?? [];
          if (trips.isEmpty) {
            return RefreshIndicator(
               onRefresh: () async {
                  // Re-fetch logic if needed, but stream handles it.
                  // Just delay to show spinner
                  await Future.delayed(const Duration(milliseconds: 500));
               },
               child: Stack(
                 children: [
                   ListView(), // Checked: RefreshIndicator needs a scrollable
                   const Center(child: Text('No trips found.')),
                 ],
               ),
            );
          }
          
          // Sort by date desc
          trips.sort((a, b) => b.date.compareTo(a.date));

          return RefreshIndicator(
            onRefresh: () async {
               await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
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
                    leading: CircleAvatar(
                       backgroundColor: trip.status.color.withOpacity(0.1),
                       child: Icon(Icons.history, color: trip.status.color),
                    ),
                    title: Text('${trip.pickupLocation} -> ${trip.dropLocation}', maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(DateFormat.yMMMd().add_jm().format(trip.date)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(trip.fareAmount), 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
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
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportTrips(BuildContext context, List<TripModel> trips) async {
    if (trips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No data to export')));
      return;
    }

    try {
      final List<List<dynamic>> rows = [];
      // Header
      rows.add([
        'ID',
        'Date',
        'Pickup',
        'Drop',
        'Type',
        'Status',
        'Fare',
      ]);

      // Data
      for (var trip in trips) {
        rows.add([
          trip.id,
          DateFormat('yyyy-MM-dd HH:mm').format(trip.date),
          trip.pickupLocation,
          trip.dropLocation,
          trip.rideType.displayName,
          trip.status.displayName,
          trip.fareAmount.toStringAsFixed(2),
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/trip_history_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csvData);

      // ignore: use_build_context_synchronously
      final box = context.findRenderObject() as RenderBox?;
      
      await Share.shareXFiles(
        [XFile(path)],
        text: 'My GoRide Trip History',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}
