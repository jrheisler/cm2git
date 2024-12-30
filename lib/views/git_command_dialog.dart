import 'package:cm_2_git/models/kanban_board.dart';
import 'package:cm_2_git/services/singleton_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/git_services.dart';

class GitCommandDialog extends StatefulWidget {
  final List<Future<void> Function()>
      commands; // A list of async Git operations
  final List<String> descriptions; // Descriptions for the commands

  const GitCommandDialog({
    required this.commands,
    required this.descriptions,
    Key? key,
  }) : super(key: key);

  @override
  _GitCommandDialogState createState() => _GitCommandDialogState();
}

class _GitCommandDialogState extends State<GitCommandDialog> {
  int currentCommandIndex = 0;
  String currentCommandDescription = "";
  String commandOutput = "";
  bool isProcessing = true;

  @override
  void initState() {
    super.initState();
    _processCommands();
  }

  Future<void> _processCommands() async {
    for (int i = 0; i < widget.commands.length; i++) {
      if (mounted) {
        setState(() {
          currentCommandIndex = i;
          currentCommandDescription = widget.descriptions[i];
          commandOutput = "Processing...";
        });
      }

      try {
        await widget.commands[i](); // Execute the command
        if (mounted)
          setState(() {
            commandOutput = "Command completed successfully.";
          });
      } catch (e) {
        setState(() {
          commandOutput = "Error: $e";
        });
        break; // Stop further execution on error
      }

      await Future.delayed(
          const Duration(seconds: 1)); // Pause briefly before the next command
    }

    if (mounted)
      setState(() {
        isProcessing = false; // Mark all commands as processed
      });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Git Commands in Progress"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Current Command: $currentCommandDescription"),
          const SizedBox(height: 10),
          if (isProcessing)
            const CircularProgressIndicator()
          else
            const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(height: 10),
          Text("Output:\n$commandOutput"),
        ],
      ),
      actions: [
        if (!isProcessing)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
      ],
    );
  }
}

KanbanBoard getCurrentKanbanBoard() {
  // Example: Retrieve the board from a singleton or local storage
  final kanbanBoard =
      SingletonData().kanbanBoard as KanbanBoard; // Ensure proper typing
  return kanbanBoard;
}

Future<String?> showKanbanBoardSelector(
    BuildContext context, GitHubService githubService) async {
  final boards = await githubService.listKanbanBoards();

  return showDialog<String>(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;

      return Dialog(
        child: Container(
          width: screenWidth * 0.8, // 80% of the screen width
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Kanban Board",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: boards.map((board) {
                      return ListTile(
                        title: Text(board),
                        trailing: IconButton(
                          icon: const Icon(Icons.history),
                          onPressed: () async {
                            // Fetch history for the selected board
                            final history = await githubService.fetchBoardHistory(board);

                            // Define a date format
                            final dateFormat = DateFormat(
                                'MMMM d, y • h:mm a'); // Example: December 27, 2024 • 7:33 AM

                            // Show history dialog
                            final selectedCommit = await showDialog<String>(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Container(
                                    width: screenWidth * 0.8,
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "History for $board",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: history.map((commit) {
                                                // Parse and format the date
                                                String formattedDate;
                                                try {
                                                  final dateTimeUtc =
                                                  DateTime.parse(commit['date'] ?? '')
                                                      .toUtc();
                                                  final dateTimeLocal =
                                                  dateTimeUtc.toLocal(); // Convert to user's local timezone
                                                  formattedDate =
                                                      dateFormat.format(dateTimeLocal);
                                                } catch (_) {
                                                  formattedDate = 'Unknown date';
                                                }

                                                return ListTile(
                                                  title: Text(commit['message'] ??
                                                      'No message'),
                                                  subtitle: Text(formattedDate),
                                                  onTap: () {
                                                    Navigator.of(context)
                                                        .pop(commit['commit']);
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Close"),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            // If a commit is selected, fetch the board version
                            if (selectedCommit != null) {
                              try {
                                final boardData =
                                await githubService.fetchBoardVersion(
                                    selectedCommit);
                                Navigator.of(context).pop(boardData);
                              } catch (e) {
                                print("Error fetching board version: $e");
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Error"),
                                      content: Text(
                                          "Failed to fetch the selected board version. Error: $e"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Close"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                        ),
                        onTap: () => Navigator.of(context).pop(board),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
}


/*
Future<String?> showKanbanBoardSelector(
    BuildContext context, GitHubService githubService) async {
  final boards = await githubService.listKanbanBoards(); // Fetch list of boards
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select Kanban Board"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: boards.map((board) {
              return ListTile(
                title: Text(board),
                onTap: () => Navigator.of(context).pop(board),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );
}*/
