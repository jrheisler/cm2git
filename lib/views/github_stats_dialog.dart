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
class _GitHubStatsDialogState extends State<GitHubStatsDialog>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  Map<String, dynamic> stats = {};
  Map<String, bool> isTabLoaded = {
    'contributors': false,
    'commit_activity': false,
    'code_frequency': false,
    'participation': false,
  };


  @override
  void initState() {
    super.initState();
    //fetchStats();
    fetchTabData('contributors'); // Preload the first tab's data
  }
  Future<void> fetchTabData(String tab) async {
    if (isTabLoaded[tab] == true) return;

    setState(() {
      isLoading = true;
    });

    try {
      dynamic data;
      switch (tab) {
        case 'contributors':
          data = await fetchGitHubData('/stats/contributors');
          break;
        case 'commit_activity':
          data = await fetchGitHubData('/stats/commit_activity');
          break;
        case 'code_frequency':
          data = await fetchGitHubData('/stats/code_frequency');
          break;
        case 'participation':
          data = await fetchGitHubData('/stats/participation');
          break;
      // Add more cases as needed
      }

      setState(() {
        stats[tab] = data;
        isTabLoaded[tab] = true;
      });
    } catch (error) {
      print('Error fetching $tab data: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchStats() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Initialize an empty stats map
      final tempStats = <String, dynamic>{};

      // Fetch each stat individually and update state progressively
      final contributors = await fetchGitHubData('/stats/contributors');
      setState(() {
        tempStats['contributors'] = contributors;
      });

      final commitActivity = await fetchGitHubData('/stats/commit_activity');
      setState(() {
        tempStats['commit_activity'] = commitActivity;
      });

      final codeFrequency = await fetchGitHubData('/stats/code_frequency');
      setState(() {
        tempStats['code_frequency'] = codeFrequency;
      });

      final participation = await fetchGitHubData('/stats/participation');
      setState(() {
        tempStats['participation'] = participation;
      });

      // Once all requests are done, update the main stats
      setState(() {
        stats = tempStats;
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
      title: Text('Git Statistics for ${widget.repo}'),
      content: DefaultTabController(
        length: 4,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                onTap: (index) {
                  // Lazy-load data for the selected tab
                  switch (index) {
                    case 0:
                      fetchTabData('contributors');
                      break;
                    case 1:
                      fetchTabData('commit_activity');
                      break;
                    case 2:
                      fetchTabData('code_frequency');
                      break;
                    case 3:
                      fetchTabData('participation');
                      break;
                  }
                },
                tabs: const [
                  Tab(text: 'Contributors'),
                  Tab(text: 'Commit Activity'),
                  Tab(text: 'Code Frequency'),
                  Tab(text: 'Participation'),
                  // Add more tabs as needed
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    isTabLoaded['contributors'] == true
                        ? ContributorsTab(data: stats['contributors'] ?? [])
                        : const Center(child: CircularProgressIndicator()),
                    isTabLoaded['commit_activity'] == true
                        ? CommitActivityTab(data: stats['commit_activity'] ?? [])
                        : const Center(child: CircularProgressIndicator()),
                    isTabLoaded['code_frequency'] == true
                        ? CodeFrequencyTab(data: stats['code_frequency'] ?? [])
                        : const Center(child: CircularProgressIndicator()),
                    isTabLoaded['participation'] == true
                        ? ParticipationTab(data: stats['participation'] ?? {})
                        : const Center(child: CircularProgressIndicator()),
                    // Add more tab views as needed
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