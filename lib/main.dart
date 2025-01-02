import 'package:cm_2_git/services/singleton_data.dart';
import 'package:cm_2_git/services/state_manager_registry.dart';
import 'package:cm_2_git/views/kanban_view.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Use for the calendar

final SMReg smReg = SMReg();
late SingletonData singletonData;

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    singletonData = setSingles();
    singletonData.version = '.250';

    return MaterialApp(
      scaffoldMessengerKey: SingletonData().scaffoldMessengerKey,
      debugShowCheckedModeBanner: singletonData.kDebugMode,
      title: 'cm2git v ${singletonData.version}',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: singletonData.kPrimaryColor),
        useMaterial3: true,
      ),
      home: const AppFrame(), // Use AppFrame as the main screen
    );
  }
}

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
                  flex: 3,
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
                      ListTile(
                        title: const Text("Report: Blocked Cards"),
                        onTap: () {},
                      ),
                      ListTile(
                        title: const Text("Report: Cards Due Soon"),
                        onTap: () {},
                      ),
                    ],
                  ),
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



