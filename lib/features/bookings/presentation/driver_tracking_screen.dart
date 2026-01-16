import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_ride/features/bookings/domain/trip_model.dart';
import 'package:go_ride/features/bookings/domain/trip_status.dart';
import 'package:go_ride/core/theme/app_theme.dart';

class DriverTrackingScreen extends StatefulWidget {
  final TripModel trip;
  const DriverTrackingScreen({super.key, required this.trip});

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  // 0.0 to 1.0 representing progress from Pickup to Drop
  double _progress = 0.0;
  Timer? _timer;
  String _eta = "12 mins";

  @override
  void initState() {
    super.initState();
    _startTracking();
  }
  
  void _startTracking() {
    // Simulate movement
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progress < 1.0) {
           _progress += 0.02; // 50 seconds to complete visualization
           
           // Update mock ETA
           int mins = ((1.0 - _progress) * 15).ceil();
           _eta = "$mins mins";
        } else {
           _progress = 1.0;
           _eta = "Arrived";
           timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Ride"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Map (Mock)
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE5E5E5),
              child: CustomPaint(
                painter: _MapRoutePainter(progress: _progress),
              ),
            ),
          ),
          
          // 2. Info Card
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Driver", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text("Ramesh Kumar", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const Text(" 4.8", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                        // Car Image/Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.directions_car, size: 32, color: AppTheme.primaryColor),
                        )
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _InfoItem(icon: Icons.access_time, label: "ETA", value: _eta),
                        _InfoItem(icon: Icons.speed, label: "Speed", value: "45 km/h"), 
                        _InfoItem(icon: Icons.pin_drop, label: "Distance", value: "3.2 km"), 
                      ],
                    ),
                    if (widget.trip.status == TripStatus.completed) ...[
                       const SizedBox(height: 16),
                       SizedBox(
                         width: double.infinity,
                         child: FilledButton(
                           onPressed: () => context.pop(), 
                           child: const Text("Ride Completed")
                         ),
                       )
                    ]
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

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MapRoutePainter extends CustomPainter {
  final double progress;
  _MapRoutePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
      
    final Paint routePaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final Paint passedRoutePaint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
      
    // Define a simple curve path
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.8, size.height * 0.2);
    
    // Draw Road Background
    canvas.drawPath(path, roadPaint);
    
    // Draw Route Line
    canvas.drawPath(path, routePaint);
    
    // Extract path metrics to draw progress
    final metrics = path.computeMetrics().first;
    final extractPath = metrics.extractPath(0.0, metrics.length * progress);
    canvas.drawPath(extractPath, passedRoutePaint);
    
    // Draw Car
    final tangent = metrics.getTangentForOffset(metrics.length * progress);
    if (tangent != null) {
      final carPos = tangent.position;
      canvas.drawCircle(carPos, 10, Paint()..color = Colors.black);
      canvas.drawCircle(carPos, 5, Paint()..color = AppTheme.primaryColor);
    }
    
    // Start/End points
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), 8, Paint()..color = Colors.green);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 8, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant _MapRoutePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
