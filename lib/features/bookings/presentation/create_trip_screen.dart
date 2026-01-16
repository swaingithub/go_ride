import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_ride/core/theme/app_theme.dart';
import 'package:go_ride/features/bookings/data/trip_repository.dart';
import 'package:go_ride/features/bookings/domain/ride_type.dart';
import 'package:go_ride/features/bookings/domain/trip_model.dart';
import 'package:go_ride/features/bookings/domain/trip_status.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _pickupController = TextEditingController(text: "Current Location");
  final _dropController = TextEditingController();
  RideType _selectedType = RideType.mini;
  double _estimatedFare = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calculateFare();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  void _calculateFare() {
    // Mock fare logic based on type
    double base = 0;
    switch (_selectedType) {
      case RideType.mini: base = 150; break;
      case RideType.sedan: base = 250; break;
      case RideType.auto: base = 80; break;
      case RideType.bike: base = 40; break;
    }
    // Add some random variance to simulate real-time pricing
    final random = Random();
    final variance = random.nextInt(20) - 10; // +/- 10
    setState(() {
      _estimatedFare = base + variance.toDouble();
    });
  }

  Future<void> _submit() async {
    if (_dropController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final trip = TripModel(
      id: const Uuid().v4(),
      pickupLocation: _pickupController.text,
      dropLocation: _dropController.text,
      rideType: _selectedType,
      fareAmount: _estimatedFare,
      date: DateTime.now(),
      status: TripStatus.requested,
    );

    await ref.read(tripRepositoryProvider).addTrip(trip);
    
    if (mounted) {
      context.pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride requested! Driver is on the way.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Let the sheet float or push up
      body: Stack(
        children: [
          // 1. Mock Map Background
          Positioned.fill(
            child: _MockMapBackground(),
          ),
          
          // 2. Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          // 3. Bottom Sheet UI
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Inputs
                    _LocationInputs(
                      pickupController: _pickupController, 
                      dropController: _dropController
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('Choose a Ride', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    
                    // Ride Type Selector
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: RideType.values.map((type) => _RideTypeCard(
                          type: type, 
                          isSelected: _selectedType == type,
                          onTap: () {
                            setState(() {
                              _selectedType = type;
                              _calculateFare();
                            });
                          },
                        )).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    
                    // Book Button
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Book Ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(
                                  NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(_estimatedFare),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                      ),
                    ),
                    // Padding for keyboard if needed, or let resize handle it? 
                    // Using resizeToAvoidBottomInset: false means we might cover inputs.
                    // Ideally we'd wrap this column in SingleChildScrollView + padding viewInsets
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationInputs extends StatelessWidget {
  final TextEditingController pickupController;
  final TextEditingController dropController;

  const _LocationInputs({required this.pickupController, required this.dropController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.my_location, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: pickupController,
                  decoration: const InputDecoration(
                    hintText: 'Pickup Location',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: dropController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Where to?',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RideTypeCard extends StatelessWidget {
  final RideType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _RideTypeCard({required this.type, required this.isSelected, required this.onTap});

  IconData _getIcon() {
    switch (type) {
      case RideType.mini: return Icons.directions_car;
      case RideType.sedan: return Icons.airport_shuttle;
      case RideType.auto: return Icons.electric_rickshaw;
      case RideType.bike: return Icons.two_wheeler;
    }
  }

  // Helper for mock logic
  double _getBaseEstimate() {
    switch (type) {
      case RideType.mini: return 150;
      case RideType.sedan: return 250;
      case RideType.auto: return 80;
      case RideType.bike: return 40;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.primaryColor : Colors.grey[200];
    final fgColor = isSelected ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.2), 
            width: 2
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(), color: isSelected ? Colors.white : Colors.black54, size: 32),
            const Spacer(),
            Text(
              type.displayName, 
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14
              )
            ),
            const SizedBox(height: 4),
            Text(
              '₹${_getBaseEstimate().toInt()}',
              style: TextStyle(
                color: isSelected ? Colors.white.withOpacity(0.8) : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockMapBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // A placeholder that looks like a map
    return Container(
      color: const Color(0xFFF2F4F6), // Light grey map bg
      child: Stack(
        children: [
          // Grid lines to simulate map streets
          ...List.generate(20, (i) => Positioned(
            top: i * 50.0,
            left: 0, 
            right: 0, 
            child: Container(height: (i % 5 == 0) ? 2 : 1, color: Colors.grey.withOpacity(0.1))
          )),
          ...List.generate(20, (i) => Positioned(
            left: i * 50.0,
            top: 0, 
            bottom: 0, 
            child: Container(width: (i % 5 == 0) ? 2 : 1, color: Colors.grey.withOpacity(0.1))
          )),
          // Random shapes "Parks"
          Positioned(
            top: 150, left: 50,
            child: Container(width: 100, height: 100, 
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20))),
          ),
           Positioned(
            top: 400, right: 80,
            child: Container(width: 120, height: 150, 
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20))),
          ),
          // Current location marker
          const Center(
            child: Icon(Icons.location_pin, color: AppTheme.primaryColor, size: 40),
          ),
          // Pulsing effect ring
          Center(
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          )
        ],
      ),
    );
  }
}
