import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_ride/features/bookings/domain/ride_type.dart';

class TripChart extends StatefulWidget {
  final Map<RideType, int> tripsByType;

  const TripChart({super.key, required this.tripsByType});

  @override
  State<TripChart> createState() => _TripChartState();
}

class _TripChartState extends State<TripChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.tripsByType.isEmpty || widget.tripsByType.values.every((v) => v == 0)) {
       return SizedBox(
         height: 200,
         child: Center(
           child: Text(
             "No ride data yet",
             style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
           ),
         ),
       );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: ApiPieChart(
                tripsByType: widget.tripsByType,
                touchedIndex: touchedIndex,
                onTouch: (index) {
                   setState(() {
                     touchedIndex = index;
                   });
                }
              ),
            ),
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }
}

class ApiPieChart extends StatelessWidget {
  final Map<RideType, int> tripsByType;
  final int touchedIndex;
  final Function(int) onTouch;

  const ApiPieChart({super.key, required this.tripsByType, required this.touchedIndex, required this.onTouch});
  
  // Helper to map ride type to color
  Color getColor(RideType type) {
    switch (type) {
      case RideType.mini: return Colors.blue;
      case RideType.sedan: return Colors.purple;
      case RideType.auto: return Colors.amber;
      case RideType.bike: return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
      return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            if (!event.isInterestedForInteractions ||
                pieTouchResponse == null ||
                pieTouchResponse.touchedSection == null) {
              onTouch(-1);
              return;
            }
            onTouch(pieTouchResponse.touchedSection!.touchedSectionIndex);
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections: showingSections(),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    int total = tripsByType.values.fold(0, (sum, v) => sum + v);
    if (total == 0) return [];
    
    // Sort to keep consistent order or usage RideType.values
    List<PieChartSectionData> sections = [];
    int i = 0;
    for (var type in RideType.values) {
       final count = tripsByType[type] ?? 0;
       if (count == 0) continue;
       
       final isTouched = i == touchedIndex;
       final fontSize = isTouched ? 25.0 : 16.0;
       final radius = isTouched ? 60.0 : 50.0;
       final percentage = (count / total * 100).toStringAsFixed(1);
       
       sections.add(PieChartSectionData(
          color: getColor(type),
          value: count.toDouble(),
          title: '$percentage%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ));
       i++; // Needs to match touchedIndex logic, which FLChart uses index of section 
       // Wait, FLChart index matches the order in list. So if I skip 0 counts, indices shift.
       // touchedIndex corresponds to the index in the sections list.
    }
    
    // Fix: Touched index logic needs to handle skipped items? 
    // Usually I should pass `i` based on filtered list index.
    // The loop above generates filtered list.
    
    return sections;
  }
}
