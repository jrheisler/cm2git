import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/singleton_data.dart';


class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _selectedDay = DateTime.now(); // Store the selected day
  DateTime _focusedDay = DateTime.now(); // Store the currently focused day

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: CalendarFormat.month,
      onDaySelected: (selectedDay, focusedDay) {
        if (mounted)
        setState(() {
          _selectedDay = selectedDay; // Highlight the selected day
          _focusedDay = focusedDay;

          final dueCards = SingletonData()
              .getAllCards()
              .where((card) =>
          card.status != "Done" &&
              isSameDay(card.needDate, selectedDay))
              .toList();

          if (dueCards.isNotEmpty) {
            SingletonData().dueDate = selectedDay;

          } else {
            SingletonData().dueDate = DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day);

          }
          SingletonData().triggerKanbanViewRefresh();
        });
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
        selectedDecoration: BoxDecoration(
          color: Colors.green, // Highlight selected day
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.orangeAccent,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markersAlignment: Alignment.bottomCenter,
      ),
      eventLoader: (day) {
        return SingletonData()
            .getAllCards()
            .where((card) =>
        card.status != "Done" && isSameDay(card.needDate, day))
            .toList();
      },
      calendarBuilders: CalendarBuilders(
        singleMarkerBuilder: (context, date, event) {
          return Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}
