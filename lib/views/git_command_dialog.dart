import 'package:flutter/material.dart';

import '../services/git_services.dart';

class GitCommandDialog extends StatefulWidget {
  final List<Future<void> Function()> commands; // A list of async Git operations
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
      setState(() {
        currentCommandIndex = i;
        currentCommandDescription = widget.descriptions[i];
        commandOutput = "Processing...";
      });

      try {
        await widget.commands[i](); // Execute the command
        setState(() {
          commandOutput = "Command completed successfully.";
        });
      } catch (e) {
        setState(() {
          commandOutput = "Error: $e";
        });
        break; // Stop further execution on error
      }

      await Future.delayed(const Duration(seconds: 1)); // Pause briefly before the next command
    }

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


void runGitCommands(BuildContext context, GitHubService githubService) {
  showDialog(
    context: context,
    builder: (context) => GitCommandDialog(
      commands: [
            () async {
          final board = await githubService.fetchBoard();
          print("Fetched board: $board");
        },
            () async {
          await githubService.saveBoard({
            "name": "Updated Kanban",
            "columns": []
          }, message: "Updated Kanban board");
        },
            () async {
          final card = await githubService.fetchCard("12345");
          print("Fetched card: $card");
        },
            () async {
          await githubService.saveCard("12345", {
            "id": "12345",
            "title": "Updated Task",
            "description": "Updated task details",
          }, message: "Updated card details");
        },
      ],
      descriptions: [
        "Fetching Kanban board...",
        "Saving Kanban board...",
        "Fetching a specific card...",
        "Saving updated card details...",
      ],
    ),
  );
}
