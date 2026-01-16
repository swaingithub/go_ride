import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_ride/core/constants/hive_constants.dart';
import 'package:go_ride/core/router/app_router.dart';
import 'package:go_ride/core/theme/app_theme.dart';
import 'package:go_ride/features/bookings/domain/ride_type.dart';
import 'package:go_ride/features/bookings/domain/trip_model.dart';
import 'package:go_ride/features/bookings/domain/trip_status.dart';
import 'package:go_ride/features/bookings/data/trip_repository.dart';
import 'package:go_ride/features/dashboard/domain/spending_limit_model.dart';
import 'package:go_ride/core/theme/theme_provider.dart';

import 'package:hive_flutter/hive_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(RideTypeAdapter());
  Hive.registerAdapter(TripStatusAdapter());
  Hive.registerAdapter(TripModelAdapter());
  Hive.registerAdapter(SpendingLimitModelAdapter()); // This will be available after build

  // Open Boxes
  final tripBox = await Hive.openBox<TripModel>(HiveConstants.tripBox);
  await Hive.openBox<SpendingLimitModel>(HiveConstants.settingsBox);

  // Seed Data if empty
  await TripRepository(tripBox).checkAndSeed();

  runApp(const ProviderScope(child: GoRideApp()));

}



class GoRideApp extends ConsumerWidget {
  const GoRideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'GoRide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
    );
  }
}

