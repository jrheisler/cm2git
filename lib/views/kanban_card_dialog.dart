import 'package:cm_2_git/models/kanban_board.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/kanban_card.dart';
import '../services/email.dart';
import '../services/git_hub_commit_details.dart';
import '../services/helpers.dart';
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
      builder: (context) => CommitDetailsDialog(
          commitDetails: commitDetails, kanbanBoard: widget.kanban),
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
                tileColor:
                    _blocked ? Colors.redAccent : singletonData.kPrimaryColor,
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
        IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'View Card History',
          onPressed: () async {
            try {
              final cardId = widget.card?.id?.toString() ?? '';
              if (cardId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid card ID.")),
                );
                return;
              }

              // Fetch history for the selected card
              final history =
                  await SingletonData().gitHubService.fetchCardHistory(cardId);

              if (history.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("No history available for this card.")),
                );
                return;
              }

              // Show history dialog
              final selectedCommit = await showDialog<String>(
                context: context,
                builder: (context) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final dateFormat = DateFormat('MMMM d, y • h:mm a');

                  return Dialog(
                    child: Container(
                      width: screenWidth * 0.8,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "History for Card: ${widget.card?.title}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: history.map((commit) {
                                  String formattedDate;
                                  try {
                                    final dateTimeUtc =
                                        DateTime.parse(commit['date'] ?? '')
                                            .toUtc();
                                    final dateTimeLocal = dateTimeUtc.toLocal();
                                    formattedDate =
                                        dateFormat.format(dateTimeLocal);
                                  } catch (_) {
                                    formattedDate = 'Unknown date';
                                  }

                                  final commitId = commit['commit'];
                                  if (commitId == null || commitId is! String) {
                                    return const ListTile(
                                        title: Text("Invalid commit data"));
                                  }

                                  return ListTile(
                                    title:
                                        Text(commit['message'] ?? 'No message'),
                                    subtitle: Text(formattedDate),
                                    onTap: () {
                                      Navigator.of(context).pop(commitId);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

              if (selectedCommit != null) {
                print("Fetching card version for commit: $selectedCommit");

                final cardVersion = await SingletonData().gitHubService.fetchCardVersion(selectedCommit, cardId);

                if (cardVersion == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to load card version.")),
                  );
                  return;
                }

                // Show card details in a dialog
                final action = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Card Details",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("ID: ${cardVersion['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text("Title: ${cardVersion['title']}"),
                                    const SizedBox(height: 8),
                                    Text("Description: ${cardVersion['description']}"),
                                    const SizedBox(height: 8),
                                    Text("Status: ${cardVersion['status']}"),
                                    const SizedBox(height: 8),
                                    Text("Assignee: ${cardVersion['assignee']}"),
                                    const SizedBox(height: 8),
                                    Text("Need Date: ${cardVersion['need_date']}"),
                                    const SizedBox(height: 8),
                                    Text("Blocked: ${cardVersion['blocked'] ? 'Yes' : 'No'}"),
                                    const SizedBox(height: 16),
                                    const Text("Files:"),
                                    ...?cardVersion['files']?.map((file) => Text("- $file")).toList(),
                                    const SizedBox(height: 16),
                                    const Text("Branches:"),
                                    ...?cardVersion['branches']?.map((branch) => Text("- $branch")).toList(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop("import"),
                                  child: const Text("Import"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop("cancel"),
                                  child: const Text("Cancel"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                if (action == "import") {
                  setState(() {
                    widget.card!.updateFromJson(cardVersion);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Card version imported successfully.")),
                  );
                } else {
                  print("Import canceled.");
                }
              }

            } catch (e) {
              print("Error fetching card history: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error loading card history: $e")),
              );
            }
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'Move') {
              // Open move dialog
              await _showMoveCardDialog(context, widget.card!);
            } else if (value == 'Archive') {
              // Archive card
              await _archiveCard(widget.card!);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Move', child: Text('Move to Board')),
            const PopupMenuItem(value: 'Archive', child: Text('Archive')),
          ],
        ),

      ],
    );
  }
  Future<void> _archiveCard(KanbanCard card) async {
    final archives = await SingletonData().gitHubService.listArchiveBoards(); // Fetch all archive boards
    final selectedArchive = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Archive Card'),
          children: [
            ...archives.map((archive) {
              return SimpleDialogOption(
                onPressed: () => Navigator.pop(context, archive),
                child: Text(archive),
              );
            }),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Create New Archive Board'),
            ),
          ],
        );
      },
    );

    final archiveBoardName = selectedArchive ?? "Archive_${DateTime.now().millisecondsSinceEpoch}";
    await archiveCard(card, SingletonData().kanbanBoard.name, archiveBoardName: archiveBoardName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Card archived to $archiveBoardName')),
    );
  }

  Future<void> _showMoveCardDialog(BuildContext context, KanbanCard card) async {
    final boards = await SingletonData().gitHubService.listKanbanBoards(); // Fetch all active boards
    final selectedBoard = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Move Card to Board'),
          children: boards.map((board) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, board),
              child: Text(board),
            );
          }).toList(),
        );
      },
    );

    if (selectedBoard != null) {
      await moveCardToBoard(card,selectedBoard);
      SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Card moved to $selectedBoard')),
      );
    }
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
