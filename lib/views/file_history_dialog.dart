import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../common/constants.dart';
import '../main.dart';

class FileHistoryDialog extends StatefulWidget {
  final String githubUser;
  final String githubRepo;
  final String githubToken;
  final String githubUrl;
  final String filePath;

  const FileHistoryDialog({
    required this.githubUser,
    required this.githubRepo,
    required this.githubToken,
    required this.githubUrl,
    required this.filePath,
    Key? key,
  }) : super(key: key);

  @override
  _FileHistoryDialogState createState() => _FileHistoryDialogState();
}

class _FileHistoryDialogState extends State<FileHistoryDialog> {
  List<dynamic> _commits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFileCommits();
  }

  Future<void> _fetchFileCommits() async {

    final response = await http.get(
      Uri.https(widget.githubUrl.substring(8), '/repos/${widget.githubUser}/${widget.githubRepo}/commits', {
        'path': widget.filePath,
      }),
      headers: {
        'Authorization': 'Bearer ${widget.githubToken}',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _commits = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      // Log errors or show an error message
      print('Failed to fetch commit history: ${response.statusCode}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Commit History for ${widget.filePath}'),
      content: _isLoading
          ? const CircularProgressIndicator()
          : SingleChildScrollView(
        child: Column(
          children: _commits.map((commit) => Container(
            decoration: simpleBoxDec(singletonData.kPrimaryColor),
            child: ListTile(
              title: Text(commit['commit']['message']),
              subtitle: Text('By ${commit['commit']['author']['name']} on ${commit['commit']['author']['date']}'),
            ),
          )).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
