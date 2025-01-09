import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      if (mounted) {
        setState(() {
          _commits = json.decode(response.body);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false; // Handle error state appropriately
        });
      }
      print('Failed to fetch commits: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(constraints: const BoxConstraints(
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
            'Git Log for ${widget.githubRepo}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _commits.map<Widget>((commit) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        title: Text(
                          "${commit['commit']['author']['name']} - ${commit['commit']['author']['date']}\nMessage: ${commit['commit']['message']}\n",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        hoverColor: Colors.deepPurple.withOpacity(0.8),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    String s = '';
                    for (var commit in _commits) {
                      s =
                      "$s\n${commit['commit']['author']['name']} - ${commit['commit']['author']['date']}\nMessage: ${commit['commit']['message']}\n";
                    }

                    downloadFile(s, 'GitLog.txt');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 20.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Download',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}



void showStyledGitLogDialog(BuildContext context, String githubUser, String githubRepo, String githubToken, String githubUrl) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Git Log',
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
            child: GitLogDialog(
              githubUser: githubUser,
              githubRepo: githubRepo,
              githubToken: githubToken,
              githubUrl: githubUrl,
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
