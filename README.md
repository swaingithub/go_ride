# GoRide - Flutter Booking Simulator

A cross-platform Flutter app that simulates a real-time ride booking platform with trip management, live updates, and basic analytics.

## Features
- **Dashboard**: View total trips, spending, recent activity, and charts.
- **Trip Management**: Book, view, and delete trips.
- **Real-Time Simulation**: Rides automatically progress (Requested -> Driver Assigned -> Started -> Completed) with dynamic fare updates.
- **Spending Limits**: Set monthly budgets per ride category with visual alerts.
- **Dark Mode**: Fully supported premium adaptable theme.

## Architecture & Tech Stack
- **Framework**: Flutter 3.x
- **State Management**: Riverpod (for dependency injection and reactive state)
- **Navigation**: GoRouter
- **Local Storage**: Hive (NoSQL database for persistence)
- **Charts**: FL Chart
- **Pattern**: Clean Architecture (Split into `presentation`, `domain`, `data`, `application` layers).

### Structure
- `lib/core`: Shared utilities, theme, router.
- `lib/features/bookings`: Trip logic, models, repository, simulation service.
- `lib/features/dashboard`: Dashboard UI, stats calculation, settings.

## Real-Time Simulation Approach
A `RideSimulationService` runs in the background (kept alive by Riverpod). It uses a periodic `Timer` (every 3 seconds) to iterate through active trips stored in Hive.
- **Status Transitions**: Random probabilities determine if a ride progresses to the next stage.
- **Fare Updates**: Fare slightly increases during the "Ride Started" phase.
- **Events**: Status changes emit events via a `Stream`, which the UI listens to for showing in-app notifications.

## Setup Instructions
1. **Prerequisites**: Flutter SDK installed.
2. **Clone & Install**:
   ```bash
   git clone <repo>
   cd go_ride
   flutter pub get
   ```
3. **Generate Hive Adapters** (if needed):
   ```bash
   dart run build_runner build
   ```
4. **Run**:
   ```bash
   flutter run
   ```

## Testing
- **Unit Tests**: Coverage for `TripRepository` and basic CRUD operations.
- **Widget Tests**: Basic smoke test.
Run tests with: `flutter test`
