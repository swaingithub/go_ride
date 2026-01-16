import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_ride/features/bookings/data/trip_repository.dart';
import 'package:go_ride/features/bookings/domain/ride_type.dart';
import 'package:go_ride/features/bookings/domain/trip_model.dart';
import 'package:go_ride/features/bookings/domain/trip_status.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _fareController = TextEditingController();
  RideType _selectedType = RideType.mini;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  void _calculateMockFare() {
    // Simple mock logic
    double base = 50;
    switch (_selectedType) {
      case RideType.mini: base = 50; break;
      case RideType.sedan: base = 80; break;
      case RideType.auto: base = 30; break;
      case RideType.bike: base = 20; break;
    }
    // Add random variance
    final fare = base + (base * 0.2); 
    _fareController.text = fare.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    _calculateMockFare();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final trip = TripModel(
        id: const Uuid().v4(),
        pickupLocation: _pickupController.text,
        dropLocation: _dropController.text,
        rideType: _selectedType,
        fareAmount: double.parse(_fareController.text),
        date: DateTime.now(),
        status: TripStatus.requested,
      );

      await ref.read(tripRepositoryProvider).addTrip(trip);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Ride')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _pickupController,
                decoration: const InputDecoration(labelText: 'Pickup Location', prefixIcon: Icon(Icons.my_location)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dropController,
                decoration: const InputDecoration(labelText: 'Drop Location', prefixIcon: Icon(Icons.location_on)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RideType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Ride Type', prefixIcon: Icon(Icons.directions_car)),
                items: RideType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayName))).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _selectedType = v;
                      _calculateMockFare();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fareController,
                decoration: const InputDecoration(labelText: 'Fare Amount', prefixIcon: Icon(Icons.attach_money)),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid Amount' : null,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
