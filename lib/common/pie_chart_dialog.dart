import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartDialog extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const PieChartDialog({required this.title, required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        height: 300,
        child: PieChart(
          PieChartData(
            sections: data.map((entry) {
              return PieChartSectionData(
                color: _generateColor(entry["name"]),
                value: entry["count"].toDouble(),
                title: entry["name"], // Display column name as title
                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                radius: 80, // Adjust radius for better title visibility
              );
            }).toList(),
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }

  // Generate color based on column name
  Color _generateColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];
    return colors[name.hashCode % colors.length];
  }
}
