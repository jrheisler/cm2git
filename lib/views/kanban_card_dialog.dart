import 'package:cm_2_git/models/kanban_board.dart';
import 'package:cm_2_git/views/timeline_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/kanban_card.dart';
import '../services/email.dart';
import '../services/git_hub_commit_details.dart';
import '../services/mili.dart';
import '../services/singleton_data.dart';
import 'commit_details_dialog.dart';

class KanbanCardDialog extends StatefulWidget {
  final KanbanCard? card;
  final String columnName;
  final Function(KanbanCard) onSave;
  final VoidCallback onDelete;
  KanbanBoard kanban;

  KanbanCardDialog({
    this.card,
    required this.columnName,
    required this.onSave,
    required this.onDelete,
    required this.kanban,
  });

  @override
  _KanbanCardDialogState createState() => _KanbanCardDialogState();
}

class _KanbanCardDialogState extends State<KanbanCardDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assigneeController;
  late TextEditingController _needDateController;
  bool _blocked = false;





  @override
  void initState() {
    super.initState();
    SingletonData().registerSetStateCallback(() {
      setState(() {}); // Trigger a rebuild when the callback is invoked
    });
    _titleController = TextEditingController(text: widget.card?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.card?.description ?? '');
    _assigneeController =
        TextEditingController(text: widget.card?.assignee ?? '');
    _needDateController = TextEditingController(
      text: widget.card != null
          ? widget.card!.needDate != null
              ? DateFormat('yyyy-MM-dd').format(widget.card!.needDate!)
              : DateFormat('yyyy-MM-dd').format(DateTime.now())
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _blocked = widget.card?.blocked ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    _needDateController.dispose();
    SingletonData().kanbanCardDialogSetState = null;
    super.dispose();
  }

  void _showCommitDetailsDialog(GitHubCommitDetails commitDetails) {
    showDialog(
      context: context,
      builder: (context) => CommitDetailsDialog(commitDetails: commitDetails, kanbanBoard: widget.kanban),
    );
  }

  Future<void> _fetchAndShowCommitDetails(String inSha) async {
    try {
      // Assuming you have the necessary variables for owner, repo, sha, and token
      String owner = singletonData.username;
      String repo = singletonData.repo;
      String sha = inSha;
      String token = retrieveString(widget.kanban.gitString);
      String gitUrl = widget.kanban.gitUrl;

      GitHubCommitDetails commitDetails =
          await fetchCommitDetails(owner, repo, sha, token, gitUrl);
      _showCommitDetailsDialog(commitDetails);
    } catch (e) {
      print('Error fetching commit details: $e');
      // Optionally show an error dialog or message
    }
  }

  Widget _buildBranchDetails() {
    if (widget.card == null || widget.card!.branches.isEmpty) {
      return const Text('No Branches');
    }

    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.card!.branches.length,
        itemBuilder: (context, index) {
          final commit = widget.card!.branches[index];
          return ListTile(
            title: Text(commit.message),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Author: ${commit.author.name}"),
                Text("Date: ${commit.author.date}"),
                GestureDetector(
                  onTap: () => launchUrl(commit.url),
                  child: Text(
                    "URL Click to Open: ${commit.url}",
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text("Message: ${commit.message}"),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    await _fetchAndShowCommitDetails(commit.sha);
                  },
                  child: const Text('Files'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildPullDetails() {
    if (widget.card == null || widget.card!.pulls.isEmpty) {
      return const Text('No Pulls');
    }

    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.card!.pulls.length,
        itemBuilder: (context, index) {
          final commit = widget.card!.pulls[index];
          return ListTile(
            title: Text(commit.message),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Author: ${commit.author.name}"),
                Text("Date: ${commit.author.date}"),
                GestureDetector(
                  onTap: () => launchUrl(commit.url),
                  child: Text(
                    "URL Click to Open: ${commit.url}",
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text("Message: ${commit.message}"),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    await _fetchAndShowCommitDetails(commit.sha);
                  },
                  child: const Text('Files'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildCommitDetails() {
    if (widget.card == null || widget.card!.files.isEmpty) {
      return const Text('No Commits');
    }

    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.card!.files.length,
        itemBuilder: (context, index) {
          final commit = widget.card!.files[index];
          return ListTile(
            title: Text(commit.message),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Author: ${commit.author.name}"),
                Text("Date: ${commit.author.date}"),
                GestureDetector(
                  onTap: () => launchUrl(commit.url),
                  child: Text(
                    "URL Click to Open: ${commit.url}",
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text("Message: ${commit.message}"),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    await _fetchAndShowCommitDetails(commit.sha);
                  },
                  child: const Text('Files'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: singletonData.kPrimaryColor,
      title: Text(widget.card == null ? 'Add Card' : 'Edit Card'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
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
                maxLines: 10,
              ),
              TextField(
                controller: _assigneeController,
                decoration: const InputDecoration(labelText: 'Assignee'),
              ),
              TextField(
                controller: _needDateController,
                decoration: const InputDecoration(labelText: 'Need Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _needDateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
              CheckboxListTile(
              tileColor: _blocked ? Colors.redAccent: singletonData.kPrimaryColor,
                title: const Text('Blocked'),
                value: _blocked,
                onChanged: (bool? value) {
                  setState(() {
                    _blocked = value ?? false;
                  });
                },
              ),
              widget.card != null
                  ? Text(
                      'Create Date: ${convertMilliToDateTime(widget.card!.id)}')
                  : const SizedBox.shrink(),
              const SizedBox(height: 20),
              const Divider(),
              const Text('Status and Dates',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildCommitDates(),
              const SizedBox(height: 20),
              const Divider(),
              const Text('Commit Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildCommitDetails(),
              const Divider(),
              const Text('Pull Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildPullDetails(),
              const Divider(),
              const Text('Branches Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildBranchDetails(),
            ],
          ),
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
              sha: widget.card?.sha ?? '',
              dates: widget.card?.dates ?? [],
              needDate: DateTime.parse(_needDateController.text),
              blocked: _blocked, // Add the blocked field
            );
            widget.onSave(card);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: widget.onDelete,
        ),
      ],
    );
  }

  Widget _buildCommitDates() {
    try {
      return Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.card!.dates.length,
          itemBuilder: (context, index) {
            final date = widget.card!.dates[index];
            return ListTile(
              title: Text(date.status),
              subtitle: Text("${date.date}"),
            );
          },
        ),
      );
    } catch (e) {
      return const Text('No Dates');
    }
  }
}
