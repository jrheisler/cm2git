import 'package:flutter/material.dart';

import '../main.dart';
import '../services/git_hub_commit_details.dart';

class CommitDetailsDialog extends StatelessWidget {
  final GitHubCommitDetails commitDetails;

  CommitDetailsDialog({required this.commitDetails});

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
              trailing: IconButton(
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
}
