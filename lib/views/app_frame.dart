import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'kanban_view.dart';

class AppFrame extends StatefulWidget {
  const AppFrame({super.key});

  @override
  State<AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends State<AppFrame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left-hand column
          SizedBox(
            width: 300,
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: DateTime.now(),
                      calendarFormat: CalendarFormat.month,
                      onDaySelected: (selectedDay, focusedDay) {
                        print("Selected day: $selectedDay");
                      },
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  flex: 3,
                  child: ListView(
                    children: [
                      ExpansionTile(
                        title: const Text("Report: Blocked Cards"),
                        subtitle: const Text("Cards that are currently blocked"),
                        children: [
                          ListTile(
                            title: const Text("Blocked Cards Report"),
                            subtitle: const Text("5 cards blocked"),
                            onTap: () {
                              // Handle blocked cards report tap
                            },
                          ),
                          ListTile(
                            title: const Text("Top 3 Reasons for Blocking"),
                            subtitle: const Text("Summary of causes"),
                            onTap: () {
                              // Handle top 3 reasons report tap
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: const Text("Report: Cards Due Soon"),
                        subtitle: const Text("Cards with approaching due dates"),
                        children: [
                          ListTile(
                            title: const Text("Due in 3 Days"),
                            subtitle: const Text("2 cards due soon"),
                            onTap: () {
                              // Handle due in 3 days report tap
                            },
                          ),
                          ListTile(
                            title: const Text("Due in a Week"),
                            subtitle: const Text("5 cards due"),
                            onTap: () {
                              // Handle due in a week report tap
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: const Text("Report: Workflow Progress"),
                        subtitle: const Text("Details about workflow state"),
                        children: [
                          ListTile(
                            title: const Text("Cards in WIP"),
                            subtitle: const Text("12 cards in progress"),
                            onTap: () {
                              // Handle WIP cards report tap
                            },
                          ),
                          ListTile(
                            title: const Text("Testing Phase"),
                            subtitle: const Text("4 cards in testing"),
                            onTap: () {
                              // Handle testing phase report tap
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: const Text("Report: Assignee Overview"),
                        subtitle: const Text("Card distribution among team members"),
                        children: [
                          ListTile(
                            title: const Text("Top Assignees"),
                            subtitle: const Text("Summary of workloads"),
                            onTap: () {
                              // Handle top assignees report tap
                            },
                          ),
                          ListTile(
                            title: const Text("Unassigned Cards"),
                            subtitle: const Text("3 cards need assignment"),
                            onTap: () {
                              // Handle unassigned cards report tap
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: const Text("Report: Branch Coverage"),
                        subtitle: const Text("Branches linked to cards"),
                        children: [
                          ListTile(
                            title: const Text("Active Branches"),
                            subtitle: const Text("4 branches active"),
                            onTap: () {
                              // Handle active branches report tap
                            },
                          ),
                          ListTile(
                            title: const Text("Branches Without Cards"),
                            subtitle: const Text("2 branches orphaned"),
                            onTap: () {
                              // Handle branches without cards report tap
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: const Text("Report: Commit Trends"),
                        subtitle: const Text("Recent activity and commit frequency"),
                        children: [
                          ListTile(
                            title: const Text("Weekly Commit Overview"),
                            subtitle: const Text("25 commits last week"),
                            onTap: () {
                              // Handle weekly commit overview tap
                            },
                          ),
                          ListTile(
                            title: const Text("Commits Per Assignee"),
                            subtitle: const Text("Summary by member"),
                            onTap: () {
                              // Handle commits per assignee report tap
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: const Text("Report: Pull Request Insights"),
                        subtitle: const Text("PR-related statistics"),
                        children: [
                          ListTile(
                            title: const Text("Open PRs"),
                            subtitle: const Text("3 open pull requests"),
                            onTap: () {
                              // Handle open PRs report tap
                            },
                          ),
                          ListTile(
                            title: const Text("Merged PRs"),
                            subtitle: const Text("5 pull requests merged"),
                            onTap: () {
                              // Handle merged PRs report tap
                            },
                          ),
                        ],
                      ),
                    ],
                  )

                ),
              ],
            ),
          ),
          // Main content area
          const Expanded(
            child: KanbanBoardScreen(),
          ),
        ],
      ),
    );
  }
}