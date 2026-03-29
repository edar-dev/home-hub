import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/entities/chart_data_point.dart';

class LocationPieChart extends StatelessWidget {
  const LocationPieChart({super.key, required this.points});

  final List<ChartDataPoint> points;

  static const _colors = [
    Color(0xFF6750A4),
    Color(0xFF625B71),
    Color(0xFF7D5260),
    Color(0xFFB3261E),
    Color(0xFF386A20),
    Color(0xFF006A6A),
  ];

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Nessun dato')),
      );
    }
    final total = points.fold<double>(0, (a, b) => a + b.value);
    if (total <= 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Nessun dato')),
      );
    }
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: List.generate(points.length, (i) {
                  final p = points[i];
                  final pct = (p.value / total * 100);
                  return PieChartSectionData(
                    color: _colors[i % _colors.length],
                    value: p.value,
                    title: '${pct.toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: points.length,
              itemBuilder: (context, i) {
                final p = points[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _colors[i % _colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
