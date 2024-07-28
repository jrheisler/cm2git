import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class GitHubStatsDialog extends StatefulWidget {
  final String owner;
  final String repo;
  final String gitString;
  final String gitUrl;


  GitHubStatsDialog({required this.owner, required this.repo, required this.gitString, required this.gitUrl});

  @override
  _GitHubStatsDialogState createState() => _GitHubStatsDialogState();
}

class _GitHubStatsDialogState extends State<GitHubStatsDialog> {
  bool isLoading = true;
  Map<String, dynamic> stats = {};

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      final responses = await Future.wait([
        fetchGitHubData('/stats/contributors'),
        fetchGitHubData('/stats/commit_activity'),
        fetchGitHubData('/stats/code_frequency'),
        fetchGitHubData('/stats/participation'),
        //fetchGitHubData('/stats/punch_card'),
      ]);

      setState(() {
        stats = {
          'contributors': responses[0],
          'commit_activity': responses[1],
          'code_frequency': responses[2],
          'participation': responses[3],
          //'punch_card': responses[4],
        };
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching stats: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<dynamic> fetchGitHubData(String endpoint) async {
    final url = '${widget.gitUrl}/repos/${widget.owner}/${widget.repo}$endpoint';
    print('Fetching data from: $url'); // Debug print

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 202) {
      // Retry after delay if status code is 202
      await Future.delayed(const Duration(seconds: 5));
      return fetchGitHubData(endpoint);
    } else {
      print('Failed to load GitHub data. Status code: ${response.statusCode}, Response: ${response.body}'); // More details
      throw Exception('Failed to load GitHub data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('GitHub Statistics'),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
        length: 4,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Contributors'),
                  Tab(text: 'Commit Activity'),
                  Tab(text: 'Code Frequency'),
                  Tab(text: 'Participation'),
                  //Tab(text: 'Punch Card'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ContributorsTab(data: stats['contributors'] ?? []),
                    CommitActivityTab(data: stats['commit_activity'] ?? []),
                    CodeFrequencyTab(data: stats['code_frequency'] ?? []),
                    ParticipationTab(data: stats['participation'] ?? {}),
                    //PunchCardTab(data: stats['punch_card'] ?? []),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class ContributorsTab extends StatelessWidget {
  final List<dynamic> data;

  ContributorsTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final contributor = data[index];
        return ListTile(
          title: Text(contributor['author']['login']),
          subtitle: Text('Contributions: ${contributor['total']}'),
        );
      },
    );
  }
}

class CommitActivityTab extends StatelessWidget {
  final List<dynamic> data;

  CommitActivityTab({required this.data});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]['total'].toDouble()));
    }

    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
        ),
      ],
    ));
  }
}

class CodeFrequencyTab extends StatelessWidget {
  final List<dynamic> data;

  CodeFrequencyTab({required this.data});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> additionsSpots = [];
    List<FlSpot> deletionsSpots = [];
    for (var i = 0; i < data.length; i++) {
      additionsSpots.add(FlSpot(i.toDouble(), data[i][1].toDouble()));
      deletionsSpots.add(FlSpot(i.toDouble(), data[i][2].toDouble()));
    }

    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: additionsSpots,
          color: Colors.green,
        ),
        LineChartBarData(
          spots: deletionsSpots,
          color: Colors.red,
        ),
      ],
    ));
  }
}

class ParticipationTab extends StatelessWidget {
  final Map<String, dynamic> data;

  ParticipationTab({required this.data});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> allSpots = [];
    List<FlSpot> ownerSpots = [];
    try {
    for (var i = 0; i < (data['all'] as List).length; i++) {
      allSpots.add(FlSpot(i.toDouble(), (data['all'][i] as int).toDouble()));
      ownerSpots.add(FlSpot(i.toDouble(), (data['owner'][i] as int).toDouble()));
    }
    } catch (e) {
      print(210);
    }


    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: allSpots,
          color: Colors.blue,
        ),
        LineChartBarData(
          spots: ownerSpots,
          color: Colors.orange,
        ),
      ],
    ));
  }
}

class PunchCardTab extends StatelessWidget {
  final List<dynamic> data;

  PunchCardTab({required this.data});

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    for (var entry in data) {
      final day = entry[0];
      final hour = entry[1];
      final commits = entry[2];
      barGroups.add(BarChartGroupData(
        x: day * 24 + hour,
        barRods: [
          BarChartRodData(toY: commits.toDouble(), color: Colors.purple)
        ],
      ));
    }

    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final hour = value.toInt() % 24;
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(hour.toString()),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(value.toInt().toString()),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: barGroups,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceBetween,
        maxY: data.map((e) => e[2] as int).reduce((a, b) => a > b ? a : b).toDouble() + 10,
      ),
    );
  }
}