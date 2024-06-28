import 'package:flutter/material.dart';

import '../main.dart';
import '../models/kanban_card.dart';
import '../services/email.dart';
import '../services/git_hub_commit_details.dart';
import '../services/singleton_data.dart';
import 'commit_details_dialog.dart';

class KanbanCardDialog extends StatefulWidget {
  final KanbanCard? card;
  final String columnName;
  final Function(KanbanCard) onSave;

  KanbanCardDialog({this.card, required this.columnName, required this.onSave});

  @override
  _KanbanCardDialogState createState() => _KanbanCardDialogState();
}

class _KanbanCardDialogState extends State<KanbanCardDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assigneeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.card?.description ?? '');
    _assigneeController =
        TextEditingController(text: widget.card?.assignee ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  void _showCommitDetailsDialog(GitHubCommitDetails commitDetails) {
    showDialog(
      context: context,
      builder: (context) => CommitDetailsDialog(commitDetails: commitDetails),
    );
  }

  Future<void> _fetchAndShowCommitDetails(KanbanCard card) async {
    try {
      // Assuming you have the necessary variables for owner, repo, sha, and token
      String owner = singletonData.username;
      String repo = singletonData.repo;
      String sha = card.sha;
      String token = retrieveString(singletonData.cm2git);

      GitHubCommitDetails commitDetails =
          await fetchCommitDetails(owner, repo, sha, token);
      _showCommitDetailsDialog(commitDetails);
    } catch (e) {
      print('Error fetching commit details: $e');
      // Optionally show an error dialog or message
    }
  }

  Widget _buildCommitDetails() {
    if (widget.card == null || widget.card!.files.isEmpty) {
      return const Text('No Commits');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.card!.files.map((commit) {
        return ListTile(
          title: Text(commit.message),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Author: ${commit.author.name}"),
              Text("Date: ${commit.author.date}"),
              Text("URL: ${commit.url}"),
              Text("Message: ${commit.message}"),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: singletonData.kPrimaryColor,
      title: Text(widget.card == null ? 'Add Card' : 'Edit Card'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: _assigneeController,
            decoration: const InputDecoration(labelText: 'Assignee'),
          ),
          const SizedBox(height: 20),
          const Text('Commit Details',
              style: TextStyle(fontWeight: FontWeight.bold)),
          _buildCommitDetails(),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.email),
          onPressed: () {
            launchEmail(widget.card!);
          },
          tooltip: 'Email Assignee',
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final card = KanbanCard(
              id: widget.card?.id ?? DateTime.now().millisecondsSinceEpoch,
              title: _titleController.text,
              description: _descriptionController.text,
              assignee: _assigneeController.text,
              status: widget.columnName,
              files: widget.card?.files ?? [],
              sha: widget.card?.sha ?? '',
            );
            widget.onSave(card);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
        if (widget.card != null)
          if (widget.card!.files.isNotEmpty)
            ElevatedButton(
              onPressed: () async {
                await _fetchAndShowCommitDetails(widget.card!);
              },
              child: Text('Files'),
            ),
      ],
    );
  }
}

/*
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/kanban_card.dart';
import '../services/email.dart';

class KanbanCardDialog extends StatefulWidget {
  final KanbanCard? card;
  final String columnName;
  final Function(KanbanCard) onSave;

  KanbanCardDialog({this.card, required this.columnName, required this.onSave});

  @override
  _KanbanCardDialogState createState() => _KanbanCardDialogState();
}

class _KanbanCardDialogState extends State<KanbanCardDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assigneeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.card?.description ?? '');
    _assigneeController =
        TextEditingController(text: widget.card?.assignee ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  Widget _buildCommitDetails() {
    if (widget.card == null || widget.card!.files.isEmpty) {
      return const Text('No Commits');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.card!.files.map((commit) {
        return ListTile(
          title: Text(commit.message),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Author: ${commit.author.name}"),
              Text("Date: ${commit.author.date}"),
              Text("URL: ${commit.url}"),
              Text("Message: ${commit.message}"),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: singletonData.kPrimaryColor,
      title: Text(widget.card == null ? 'Add Card' : 'Edit Card'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _assigneeController,
              decoration: const InputDecoration(labelText: 'Assignee'),
            ),
            const SizedBox(height: 20),
            const Text('Commit Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildCommitDetails(),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.email),
          onPressed: () {
            launchEmail(widget.card!);
          },
          tooltip: 'Email Assignee',
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final card = KanbanCard(
              id: widget.card?.id ?? DateTime.now().millisecondsSinceEpoch,
              title: _titleController.text,
              description: _descriptionController.text,
              assignee: _assigneeController.text,
              status: widget.columnName,
              files: widget.card?.files ?? [],
            );
            widget.onSave(card);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
*/
