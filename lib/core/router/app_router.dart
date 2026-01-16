import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_ride/features/dashboard/presentation/dashboard_screen.dart';
import 'package:go_ride/features/bookings/presentation/create_trip_screen.dart';
import 'package:go_ride/features/dashboard/presentation/settings_screen.dart';
import 'package:go_ride/features/bookings/presentation/trips_list_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/create-trip',
      builder: (context, state) => const CreateTripScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/trips',
      builder: (context, state) => const TripsListScreen(),
    ),
  ],
);
