import 'package:cm_2_git/models/kanban_board.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../services/git_hub_commit_details.dart';
import '../services/singleton_data.dart';
import 'file_history_dialog.dart';

class CommitDetailsDialog extends StatelessWidget {
  final GitHubCommitDetails commitDetails;
  final KanbanBoard kanbanBoard;

  CommitDetailsDialog({required this.commitDetails, required this.kanbanBoard});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: singletonData.kPrimaryColor,
      title: const Text('Commit Files'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: commitDetails.files.length,
          itemBuilder: (context, index) {
            final file = commitDetails.files[index];
            return ListTile(
              title: Text(file.filename),
              subtitle: Text('Additions: ${file.additions}, Deletions: ${file.deletions}, Changes: ${file.changes}'),
              isThreeLine: true,
              trailing: SizedBox(
                width: 80,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Open Source Code File',
                      icon: const Icon(Icons.code),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: singletonData.kPrimaryColor,
                            title: Text(file.filename),
                            content: SingleChildScrollView(
                              child: Text(file.patch),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Show File History',
                      icon: const Icon(Icons.history),
                      onPressed: () => _showCommitHistory(file.filename, context),
                    ),
                  ],
                ),
              ),
            );
          },
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

  void _showCommitHistory(String filePath, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FileHistoryDialog(
        githubUser: kanbanBoard.gitUser,
        githubToken: retrieveString(kanbanBoard.gitString),
        githubRepo: kanbanBoard.gitRepo,
        filePath: filePath,
        githubUrl: kanbanBoard.gitUrl,
      ),
    );
  }
}
