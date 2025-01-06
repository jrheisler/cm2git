import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../common/pie_chart_dialog.dart';
import '../services/singleton_data.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Widget _buildExpandableReportTile({
    required String title,
    required String subtitle,
    required List<Map<String, String>> reports,
    required BuildContext context,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.deepPurple, width: 1.0), // Separation line
        ),
      ),
      child: ExpansionTile(
        title: Text(title),
        subtitle: Text(subtitle),
        children: reports
            .map(
              (report) => ListTile(
                title: Text(report["title"]!),
                subtitle: Text(report["subtitle"]!),
                onTap: () {
                  // Handle individual report tap actions here
                  print("${report["title"]} tapped!");
                },
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildExpandableReportTileWorkFlow(
          title: "Report: Workflow Progress",
          subtitle: "Details about workflow state",
          context: context,
        ),
        _buildExpandableReportTile(
          title: "Report: Blocked Cards",
          subtitle: "Cards that are currently blocked",
          reports: [
            {"title": "Blocked Cards Report", "subtitle": "5 cards blocked"},
            {
              "title": "Top 3 Reasons for Blocking",
              "subtitle": "Summary of causes"
            },
          ],
          context: context,
        ),
        _buildExpandableReportTile(
          title: "Report: Cards Due Soon",
          subtitle: "Cards with approaching due dates",
          reports: [
            {"title": "Due in 3 Days", "subtitle": "2 cards due soon"},
            {"title": "Due in a Week", "subtitle": "5 cards due"},
          ],
          context: context,
        ),
        _buildExpandableReportTile(
          title: "Report: Assignee Overview",
          subtitle: "Card distribution among team members",
          reports: [
            {"title": "Top Assignees", "subtitle": "Summary of workloads"},
            {
              "title": "Unassigned Cards",
              "subtitle": "3 cards need assignment"
            },
          ],
          context: context,
        ),
        _buildExpandableReportTile(
          title: "Report: Branch Coverage",
          subtitle: "Branches linked to cards",
          reports: [
            {"title": "Active Branches", "subtitle": "4 branches active"},
            {
              "title": "Branches Without Cards",
              "subtitle": "2 branches orphaned"
            },
          ],
          context: context,
        ),
        _buildExpandableReportTile(
          title: "Report: Commit Trends",
          subtitle: "Recent activity and commit frequency",
          reports: [
            {
              "title": "Weekly Commit Overview",
              "subtitle": "25 commits last week"
            },
            {"title": "Commits Per Assignee", "subtitle": "Summary by member"},
          ],
          context: context,
        ),
        _buildExpandableReportTile(
          title: "Report: Pull Request Insights",
          subtitle: "PR-related statistics",
          reports: [
            {"title": "Open PRs", "subtitle": "3 open pull requests"},
            {"title": "Merged PRs", "subtitle": "5 pull requests merged"},
          ],
          context: context,
        ),
      ],
    );
  }

  Widget _buildExpandableReportTileWorkFlow({
    required String title,
    required String subtitle,
    required BuildContext context,
  }) {
    // Example data for column counts (replace with dynamic data retrieval)
    final kanbanBoard = SingletonData().kanbanBoard;
    final columns = kanbanBoard.columns;

    // Calculate column card counts
    final List<Map<String, dynamic>> columnData = columns.map((column) {
      return {"name": column.name, "count": column.cards.length};
    }).toList();

    final List<Map<String, dynamic>> reports = columnData.map((column) {
      return {"title": column["name"], "subtitle": "${column["count"]} cards"};
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.deepPurple, width: 1.0), // Separation line
        ),
      ),
      child: ExpansionTile(
        title: Text(
          title,
        ),
        subtitle: Text(
          subtitle,
        ),
        //backgroundColor: Colors.deepPurple.withAlpha(13), // Light purple background for expansion
        //collapsedBackgroundColor: Colors.deepPurple.withAlpha(25), // Slightly darker for collapsed state
        //iconColor: Colors.deepPurple, // Purple for the expand/collapse icon
        //collapsedIconColor: Colors.deepPurple, // Purple for the collapsed icon
        children: reports
            .map(
              (report) => ListTile(
            title: Text(
              report["title"]!,
            ),
            subtitle: Text(
              report["subtitle"]!,
            ),
            onTap: () {
              // Show pie chart dialog
              showDialog(
                context: context,
                builder: (context) => PieChartDialog(
                  title: report["title"]!,
                  data: columnData,
                ),
              );
            },
          ),
        )
            .toList(),
      ),
    );


  }
 }



class CIReportsPage extends StatefulWidget {
  const CIReportsPage({Key? key}) : super(key: key);

  @override
  State<CIReportsPage> createState() => _CIReportsPageState();
}

class _CIReportsPageState extends State<CIReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchCIMetrics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final metrics = snapshot.data!;
          final totalCIs = metrics["totalCIs"];
          final growthRate = metrics["growthRate"];
          final orphanedCIs = metrics["orphanedCIs"];
          final mostChangedCIs = metrics["mostChangedCIs"];
          final impact = metrics["impactAnalysis"];

          return Container(
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      "Total CIs",
                      style: const TextStyle(
                        color: Colors.white, // Light text for contrast
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "$totalCIs items under CM",
                      style: const TextStyle(
                        color: Colors.white70, // Slightly muted for subtitles
                      ),
                    ),
                    tileColor: Colors.deepPurple, // Explicitly set primary color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    leading: const Icon(
                      Icons.info_outline,
                      color: Colors.white, // Icon matches text color
                    ),
                    hoverColor: Colors.deepPurpleAccent.withOpacity(0.8), // Subtle hover effect
                  ),
                  ListTile(
                    title: Text(
                      "CI Growth Rate",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${growthRate.toStringAsFixed(2)}% increase this month",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    tileColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    leading: const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                    ),
                    hoverColor: Colors.deepPurpleAccent.withOpacity(0.8),
                    onTap: () => _showLineChartDialog(
                      context,
                      "Growth Rate Over Time",
                      growthRate,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Orphaned CIs",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${orphanedCIs.length} items unlinked to tasks",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    tileColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    leading: const Icon(
                      Icons.link_off,
                      color: Colors.white,
                    ),
                    hoverColor: Colors.deepPurpleAccent.withOpacity(0.8),
                    onTap: () => _showPieChartDialog(
                      context,
                      "Orphaned CIs",
                      orphanedCIs.length,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Most Frequently Changed CIs",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      "View detailed change frequency",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    tileColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    leading: const Icon(
                      Icons.change_circle,
                      color: Colors.white,
                    ),
                    hoverColor: Colors.deepPurpleAccent.withOpacity(0.8),
                    onTap: () => _showBarChartDialog(
                      context,
                      "CI Change Frequency",
                      mostChangedCIs,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Impact Analysis",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "$impact dependencies on key CIs",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    tileColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    leading: const Icon(
                      Icons.analytics,
                      color: Colors.white,
                    ),
                    hoverColor: Colors.deepPurpleAccent.withOpacity(0.8),
                    onTap: () => _showPieChartDialog(
                      context,
                      "Impact Analysis",
                      impact,
                    ),
                  ),

                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 80),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchCIMetrics() async {
    final totalCIs = await SingletonData().gitHubService.fetchAllFiles();
    final growthRate = await SingletonData().gitHubService.calculateCIGrowthRate();
    final orphanedCIs = await SingletonData().gitHubService.findOrphanedCIs(['fileA.dart', 'fileB.dart']);
    final mostChangedCIs = await SingletonData().gitHubService.fetchMostChangedCIs();
    final impact = await SingletonData().gitHubService.performImpactAnalysis('fileA.dart');
    return {
      "totalCIs": totalCIs.length,
      "growthRate": growthRate,
      "orphanedCIs": orphanedCIs,
      "mostChangedCIs": mostChangedCIs,
      "impactAnalysis": impact,
    };
  }

  void _showLineChartDialog(BuildContext context, String title, double value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.maxFinite,
              height: 420,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Growth Rate (%)',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('0%');
                            case 1:
                              return const Text('20%');
                            case 2:
                              return const Text('40%');
                            case 3:
                              return const Text('60%');
                            case 4:
                              return const Text('80%');
                            case 5:
                              return const Text('100%');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          '',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Start');
                            case 1:
                              return const Text('Midpoint');
                            case 2:
                              return const Text('End');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 2,
                  minY: 0,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 0),
                        FlSpot(1, value),
                        FlSpot(2, value * 1.1),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPieChartDialog(BuildContext context, String title, int dataCount) {
    showDialog(
      context: context,
      builder: (context) => PieChartDialog(
        title: title,
        data: [
          {"name": title, "count": dataCount},
          {"name": "Other", "count": 100 - dataCount},
        ],
      ),
    );
  }

  void _showBarChartDialog(BuildContext context, String title, Map<String, int> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: data.entries.map((entry) {
                return BarChartGroupData(
                  x: data.keys.toList().indexOf(entry.key),
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.toDouble(),
                      color: Colors.green,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
