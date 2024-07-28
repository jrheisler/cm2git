import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../common/constants.dart';
import '../main.dart';
import '../services/download_file.dart';

class GitLogDialog extends StatefulWidget {
  final String githubUser;
  final String githubRepo;
  final String githubToken;
  final String githubUrl;

  const GitLogDialog({
    Key? key,
    required this.githubUser,
    required this.githubRepo,
    required this.githubToken,
    required this.githubUrl,
  }) : super(key: key);

  @override
  _GitLogDialogState createState() => _GitLogDialogState();
}

class _GitLogDialogState extends State<GitLogDialog> {
  bool _isLoading = true;
  List<dynamic> _commits = [];

  @override
  void initState() {
    super.initState();
    _fetchCommits();
  }

  Future<void> _fetchCommits() async {
    final url = Uri.https(widget.githubUrl.substring(8), '/repos/${widget.githubUser}/${widget.githubRepo}/commits');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'token ${widget.githubToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _commits = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;  // handle error state appropriately
      });
      print('Failed to fetch commits: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Git Log for ${widget.githubRepo}'),
      content: _isLoading
          ? const CircularProgressIndicator()
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _commits.map<Widget>((commit) => Container(
            decoration: simpleBoxDec(singletonData.kPrimaryColor),
            child: ListTile(
              title: Text(
                "${commit['commit']['author']['name']} - ${commit['commit']['author']['date']}\nMessage: ${commit['commit']['message']}\n",
                style: const TextStyle(fontSize: 12),
              ),
            ),
          )).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            String s = '';
            for (var commit in _commits) {
              s = "$s\n${commit['commit']['author']['name']} - ${commit['commit']['author']['date']}\nMessage: ${commit['commit']['message']}\n";
            }

            downloadFile(s, 'GitLog.txt');

          },
          child: const Text('Download'),
        ),
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


/*
 var projJson = kanbanBoard.toJson();
    var encoded = jsonEncode(projJson);

    downloadFile(encoded, kanbanBoard.name);
 */