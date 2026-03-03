import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportPieChart extends StatelessWidget {
  final double totalSpent;
  final Map<String, double> categoryTotals;
  final List<String> sortedCatKeys;
  final List<Color> colors;

  const ReportPieChart({
    super.key,
    required this.totalSpent,
    required this.categoryTotals,
    required this.sortedCatKeys,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    if (totalSpent <= 0 || sortedCatKeys.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No data for this period')),
      );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 70,
          borderData: FlBorderData(show: false),
          sections: sortedCatKeys.asMap().entries.map((entry) {
            final index = entry.key;
            final catId = entry.value;
            final val = categoryTotals[catId]!;
            final color = colors[index % colors.length];
            final pct = (val / totalSpent * 100).toStringAsFixed(0);

            return PieChartSectionData(
              color: color,
              value: val,
              title: pct == '0' ? '' : '$pct%',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
