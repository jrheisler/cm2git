import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void showStyledPieChartDialog(BuildContext context, String title, List<Map<String, dynamic>> data) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 600, // Minimum width for the dialog
              maxWidth: 800, // Maximum width
              maxHeight: 460, // Limit the height of the dialog
            ),
            margin: const EdgeInsets.all(4), // Outer margin
            padding: const EdgeInsets.all(16), // Inner padding
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
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
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 20.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: curvedAnimation,
          child: child,
        ),
      );
    },
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

