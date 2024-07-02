// Define a function to extract the timeline data
import 'package:cm_2_git/models/kanban_board.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/kanban_card.dart';

List<LineChartBarData> extractTimelineData(List<KanbanCard> kanbanCards) {
  List<LineChartBarData> lineBarsData = [];

  for (KanbanCard card in kanbanCards) {
    List<FlSpot> spots = [];
    int baseTimestamp = card.id;

    for (KanbanDates dateEntry in card.dates) {
      double daysSinceBase = dateEntry.date
          .difference(DateTime.fromMillisecondsSinceEpoch(baseTimestamp))
          .inDays
          .toDouble();
      spots.add(FlSpot(daysSinceBase, card.id.toDouble()));
    }

    lineBarsData.add(LineChartBarData(
      spots: spots,
      isCurved: true,
      color: Colors.blue,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
    ));
  }

  return lineBarsData;
}

class TimelineChart extends StatelessWidget {
  final KanbanBoard kanban;
  final String status;

  const TimelineChart({super.key, required this.kanban, required this.status});

  @override
  Widget build(BuildContext context) {
    List<KanbanCard> cards = [];
    for (var col in kanban.columns) {
      if (col.name == status) {
        for (var card in col.cards) {
          cards.add(card);
        }
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Kanban Cards Timeline'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            lineBarsData: extractTimelineData(cards),
            titlesData: FlTitlesData(
              //bottomTitles: SideTitles(showTitles: true),
              //leftTitles: SideTitles(showTitles: true),
            ),
          ),
        ),
      ),
    );
  }
}
