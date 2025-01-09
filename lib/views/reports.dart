import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../common/pie_chart_dialog.dart';
import '../models/kanban_card.dart';
import '../services/singleton_data.dart';
import 'kanban_card_widget.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  void initState() {
    SingletonData().registerReportSetStateCallback(() {
      if (mounted) {
        setState(() {}); // Trigger a rebuild when the callback is invoked
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    SingletonData().reportSetState = null;
    super.dispose();
  }

  Widget _buildExpandableReportTile({
    required String title,
    required String subtitle,
    required List<Map<String, String>> reports,
    required BuildContext context,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: Colors.deepPurple, width: 1.0), // Separation line
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
                  if (report["title"] == "Reasons for Blocking") {
                    List<String> blockReasons =
                        SingletonData().reasonBlockedCards();
                    blockReasons.forEach((action) => print(action));
                    _showStyledStringListDialog(
                        context, blockReasons, report["title"]!);
                  } else if (report["title"] == "Cards Due Soon") {
                    _showCardsDueSoonDialog(context);
                  } else if (report["title"] == 'Assignees') {
                    _showAssigneeOverviewDialog(context);
                  } else if (report["title"] == "Unassigned Cards") {
                    _showKanbanCardListDialog(context, SingletonData().unAssignedCards());

                  }
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
            {
              "title": "Blocked Cards Report",
              "subtitle": "${SingletonData().blockedCards()}"
            },
            {"title": "Reasons for Blocking", "subtitle": "Summary of causes"},
          ],
          context: context,
        ),
        _buildExpandableReportTile(
          title: "Report: Cards Due Soon",
          subtitle: "Cards with approaching due dates",
          reports: [
            {"title": "Cards Due Soon", "subtitle": "Visualize"},
          ],
          context: context,
        ),
        _buildExpandableReportTile(
          title: "Report: Assignee Overview",
          subtitle: "Card distribution among team members",
          reports: [
            {"title": "Assignees", "subtitle": "Summary of workloads"},
            {
              "title": "Unassigned Cards",
              "subtitle": "${SingletonData().unAssignedCardsCount()} cards need assignment"
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
          bottom: BorderSide(
              color: Colors.deepPurple, width: 1.0), // Separation line
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
                  showStyledPieChartDialog(
                    context,
                    report["title"]!,
                    columnData,
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Map<String, int> getAssigneeCounts() {
    List<KanbanCard> allCards = SingletonData().getAllCards();
    Map<String, int> assigneeCounts = {};

    for (var card in allCards) {
      final assignee = card.assignee.isNotEmpty ? card.assignee : "Unassigned";
      assigneeCounts[assignee] = (assigneeCounts[assignee] ?? 0) + 1;
    }

    return assigneeCounts;
  }

  void _showKanbanCardListDialog(
      BuildContext context, List<KanbanCard> cards) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Kanban Cards',
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
                  const Text(
                    'Kanban Cards',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: KanbanCardWidget(
                            card: cards[index],
                          ),
                        );
                      },
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

  void _showAssigneeOverviewDialog(BuildContext context) {
    final assigneeCounts = getAssigneeCounts();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Assignee Overview',
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
                  const Text(
                    'Assignee Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: assigneeCounts.entries.map((entry) {
                          return BarChartGroupData(
                            x: assigneeCounts.keys.toList().indexOf(entry.key),
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.toDouble(),
                                color: Colors.green,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < assigneeCounts.keys.length) {
                                  return Text(
                                    assigneeCounts.keys.elementAt(index),
                                    style: const TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            //tooltipBgColor: Colors.deepPurpleAccent,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final assignee = assigneeCounts.keys.elementAt(group.x.toInt());
                              return BarTooltipItem(
                                '$assignee\n${rod.toY.toInt()} cards',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
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

  void _showCardsDueSoonDialog(BuildContext context) {
    // Fetch all cards
    List<KanbanCard> allCards = SingletonData().getAllCards();

    // Group cards by time intervals
    DateTime now = DateTime.now();
    Map<String, int> dueBuckets = {
      "Today": allCards.where((card) => isSameDay(card.needDate, now)).length,
      "This Week": allCards
          .where((card) =>
              card.needDate.isAfter(now) &&
              card.needDate.isBefore(now.add(Duration(days: 7))))
          .length,
      "Next Week": allCards
          .where((card) =>
              card.needDate.isAfter(now.add(Duration(days: 7))) &&
              card.needDate.isBefore(now.add(Duration(days: 14))))
          .length,
      "Later": allCards
          .where((card) => card.needDate.isAfter(now.add(Duration(days: 14))))
          .length,
    };

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cards Due Soon',
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
              margin: const EdgeInsets.all(4),
              // Outer margin
              padding: const EdgeInsets.all(16),
              // Inner padding
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
                  const Text(
                    "Cards Due Soon",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, _) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                final keys = dueBuckets.keys.toList();
                                return Text(
                                  keys[value.toInt()],
                                  style: const TextStyle(color: Colors.white),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        barGroups: dueBuckets.entries.map((entry) {
                          return BarChartGroupData(
                            x: dueBuckets.keys.toList().indexOf(entry.key),
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.toDouble(),
                                color: Colors.deepPurpleAccent,
                              ),
                            ],
                          );
                        }).toList(),
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

// Utility function to check if two dates are on the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showStyledStringListDialog(
      BuildContext context, List<String> items, String report) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: report,
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
              margin: const EdgeInsets.all(4),
              // Outer margin
              padding: const EdgeInsets.all(16),
              // Inner padding
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
                    report,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              items[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: const Icon(
                              Icons.label,
                              color: Colors.white,
                            ),
                            hoverColor: Colors.deepPurple.withOpacity(0.8),
                          ),
                        );
                      },
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
}

class CIReportsPage extends StatefulWidget {
  const CIReportsPage({Key? key}) : super(key: key);

  @override
  State<CIReportsPage> createState() => _CIReportsPageState();
}

class _CIReportsPageState extends State<CIReportsPage> {
  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(20.0),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchCIMetrics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white, // Matches the overall theme
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final metrics = snapshot.data!;
          return _buildMetricsList(metrics);
        },
      ),
    );
  }

  Widget _buildMetricsList(Map<String, dynamic> metrics) {
    final totalCIs = metrics["totalCIs"];
    final growthRate = metrics["growthRate"];
    final orphanedCIs = metrics["orphanedCIs"];
    final mostChangedCIs = metrics["mostChangedCIs"];
    final impact = metrics["impactAnalysis"];

    return Material(
      color: Colors.transparent, // Maintain the existing purple background
      child: ListView(
        children: [
          _buildStyledListTile(
            title: "Total CIs",
            subtitle: "$totalCIs items under CM",
            icon: Icons.info_outline,
          ),
          _buildStyledListTile(
            title: "CI Growth Rate",
            subtitle: "${growthRate.toStringAsFixed(2)}% increase this month",
            icon: Icons.trending_up,
            onTap: () => _showLineChartDialog(
              context,
              "Growth Rate Over Time",
              growthRate,
            ),
          ),
          _buildStyledListTile(
            title: "Orphaned CIs",
            subtitle: "${orphanedCIs.length} items unlinked to tasks",
            icon: Icons.link_off,
            onTap: () => _showPieChartDialog(
              context,
              "Orphaned CIs",
              orphanedCIs.length,
            ),
          ),
          _buildStyledListTile(
            title: "Most Frequently Changed CIs",
            subtitle: "View detailed change frequency",
            icon: Icons.change_circle,
            onTap: () => _showBarChartDialog(
              context,
              "CI Change Frequency",
              mostChangedCIs,
            ),
          ),
          _buildStyledListTile(
            title: "Impact Analysis",
            subtitle: "$impact dependencies on key CIs",
            icon: Icons.analytics,
            onTap: () => _showPieChartDialog(
              context,
              "Impact Analysis",
              impact,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70),
      ),
      tileColor: Colors.deepPurple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      leading: Icon(icon, color: Colors.white),
      hoverColor: Colors.deepPurpleAccent.withAlpha(200),
      onTap: onTap,
    );
  }

  Future<Map<String, dynamic>> _fetchCIMetrics() async {
    final totalCIs = await SingletonData().gitHubService.fetchAllFiles();
    final growthRate =
        await SingletonData().gitHubService.calculateCIGrowthRate();
    final orphanedCIs = await SingletonData()
        .gitHubService
        .findOrphanedCIs(['fileA.dart', 'fileB.dart']);
    final mostChangedCIs =
        await SingletonData().gitHubService.fetchMostChangedCIs();
    final impact =
        await SingletonData().gitHubService.performImpactAnalysis('fileA.dart');
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
    return showStyledPieChartDialog(
      context,
      title,
      [
        {"name": title, "count": dataCount},
        {"name": "Other", "count": 100 - dataCount},
      ],
    );
  }

  void _showBarChartDialog(
      BuildContext context, String title, Map<String, int> data) {
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
