import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/command_button.dart';
import '../models/kanban_board.dart';
import '../models/kanban_card.dart';
import '../services/git_services.dart';
import '../services/local_storage_helper.dart';
import '../services/singleton_data.dart';
import 'git_command_dialog.dart';

void showStyledGitWorkflowDialog(BuildContext context, GitHubService gitHubService) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Git Workflow',
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 600, // Minimum width for the dialog
            maxWidth: 800, // Maximum width (optional)
          ),
          margin: const EdgeInsets.all(20), // 20-pixel border
          padding: const EdgeInsets.all(16), // Inner padding for content
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: GitWorkflowScreen(githubService: gitHubService),
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

void showGitWorkflowDialog(BuildContext context, GitHubService gitHubService) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // Adjust width
          height: MediaQuery.of(context).size.height * 0.6, // Adjust height
          child: GitWorkflowScreen(githubService: gitHubService),
        ),
      );
    },
  );
}


class GitWorkflowScreen extends StatefulWidget {
  final GitHubService githubService;

  const GitWorkflowScreen({required this.githubService, Key? key})
      : super(key: key);

  @override
  _GitWorkflowScreenState createState() => _GitWorkflowScreenState();
}

class _GitWorkflowScreenState extends State<GitWorkflowScreen> {
  final List<Map<String, dynamic>> commands = [];
  double buttonWidth = 0.0;

  @override
  void initState() {
    super.initState();

    // Define commands with their descriptions and actions
    commands.addAll([
      {
        "title": "Fetch Kanban Board",
        "icon": Icons.download,
        "tooltip": "Fetch the latest Kanban board from the repository.",
        "action": () async {
          // Open the selection dialog
          final selectedBoard = await showKanbanBoardSelector(context, widget.githubService);

          if (selectedBoard != null && selectedBoard.isNotEmpty) {
            final boardName = selectedBoard.endsWith('.json') ? selectedBoard : '$selectedBoard.json';

            final board = await widget.githubService.fetchBoard(boardName);
            print("Fetched board: $board");
            LocalStorageHelper.saveValue(
                'kanban_board', jsonEncode(board));
            SingletonData().kanbanBoard = KanbanBoard.fromJson(board);
            SingletonData().kanbanViewSetState!();
          }

        },
      },
      {
        "title": "Save Kanban Board",
        "icon": Icons.upload,
        "tooltip": "Save the current Kanban board to the repository.",
        "action": () async {
          try {
            final currentBoard = SingletonData().kanbanBoard;
            if (currentBoard != null) {
              await widget.githubService.saveBoard(
                currentBoard.toJson(),
                message: "Saved Kanban board: ${currentBoard.name}",
              );
              print("Kanban board saved successfully: ${currentBoard.name}");
            } else {
              print("No Kanban board loaded to save.");
            }
          } catch (e) {
            print("Error saving Kanban board: $e");
          }
        },
      },
      {
        "title": "Fetch Card",
        "icon": Icons.description,
        "tooltip": "Fetch details of a specific card from the repository.",
        "action": () async {
          // Example: Get all card IDs from the current board
          final currentBoard = SingletonData().kanbanBoard;
          if (currentBoard != null) {
            final cardIds = currentBoard.columns.expand((column) => column.cards.map((card) => card.id)).toList();
            if (cardIds.isNotEmpty) {
              try {
                for (final cardId in cardIds) {
                  final cardData = await widget.githubService.fetchCard(cardId.toString());
                  final fetchedCard = KanbanCard.fromJson(cardData);
                  // Update the local card data
                  final targetColumn = currentBoard.columns.firstWhere((col) =>
                      col.cards.any((card) => card.id == fetchedCard.id));
                  final index = targetColumn.cards.indexWhere((card) => card.id == fetchedCard.id);
                  targetColumn.cards[index] = fetchedCard;
                  print("Fetched card: ${fetchedCard.title}");
                }
              } catch (e) {
                print("Error fetching cards: $e");
              }
            } else {
              print("No cards available to fetch.");
            }
          } else {
            print("No Kanban board loaded.");
          }
        },
      },
      {
        "title": "Save Cards",
        "icon": Icons.save,
        "tooltip": "Save updates to cards in the repository.",
        "action": () async {
          final currentBoard = SingletonData().kanbanBoard;
          if (currentBoard != null) {
            final modifiedCards = currentBoard.getModifiedCards();
            if (modifiedCards.isNotEmpty) {
              try {
                for (final card in modifiedCards) {
                  await widget.githubService.saveCard(
                    card.id.toString(),
                    card.toJson(),
                    message: "Updated card: ${card.title}",
                  );
                  print("Saved card: ${card.title}");
                }
              } catch (e) {
                print("Error saving cards: $e");
              }
            } else {
              print("No modified cards to save.");
            }
          } else {
            print("No Kanban board loaded.");
          }
        },
      },
    ]);



    // Determine the largest button width
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        buttonWidth = commands
            .map((cmd) => _calculateButtonWidth(cmd["title"]))
            .reduce((a, b) => a > b ? a : b);
      });
    });
  }

  // Calculate button width based on text size
  double _calculateButtonWidth(String title) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size.width + 100; // Add padding
  }

  void _runCommand(String title, Future<void> Function() action) {
    showDialog(
      context: context,
      builder: (context) => GitCommandDialog(
        commands: [action],
        descriptions: [title],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch content to fill width
      children: [
        ...commands.map((command) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: CommandButton(
              title: command["title"],
              icon: command["icon"],
              tooltip: command["tooltip"],
              onPressed: () => _runCommand(command["title"], command["action"]),
              width: MediaQuery.of(context).size.width * 0.7 - 40, // Adjust for padding
            ),
          );
        }).toList(),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 80),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text(
              "Close",
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

}
