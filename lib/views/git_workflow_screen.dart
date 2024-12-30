import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/command_button.dart';
import '../models/kanban_board.dart';
import '../models/kanban_card.dart';
import '../models/kanban_column.dart';
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
          height: 240, //MediaQuery.of(context).size.height * 0.6, // Adjust height
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
        "title": "Commit Board and Cards",
        "icon": Icons.commit,
        "tooltip": "Commit the board and all modified cards to the repository.",
        "action": () async {
          try {
            final currentBoard = SingletonData().kanbanBoard;
            if (currentBoard != null) {
              // Save the Kanban board
              await widget.githubService.saveBoard(
                currentBoard.toJson(),
                message: "Committed Kanban board: ${currentBoard.name}",
              );

              // Save all modified cards
              final modifiedCards = currentBoard.getModifiedCards();
              for (final card in modifiedCards) {
                print("Preparing to save card: ${card.toJson()}");

                try {
                  // Fetch SHA if missing
                  if (card.sha.isEmpty) {
                    card.sha = await widget.githubService.fetchFileSha('cards/${card.id}.json') ?? "";
                  }

                  if (card.sha.isEmpty) {
                    print("Card ${card.id} does not exist on GitHub. Creating a new file.");
                  } else {
                    print("Card ${card.id} exists. Updating the file with SHA: ${card.sha}");
                  }


                  if (card.sha.isEmpty) {
                    card.sha = await widget.githubService.fetchFileSha('cards/${card.id}.json') ?? "";
                  }

                  await widget.githubService.saveCard(
                    card.id.toString(),
                    card.toJson(),
                    message: "Updated card: ${card.title}",
                  );


                  print("Card saved successfully: ${card.id}");
                } catch (e) {
                  print("Error saving card ${card.id}: $e");
                  throw Exception("Failed to save card: ${card.id}");
                }
              }
              print("Committed board and modified cards successfully.");
            } else {
              print("No Kanban board loaded to commit.");
            }
          } catch (e) {
            print("Error committing board and cards: $e");
          }
        },
      },

      {
        "title": "Refresh Board and Cards",
        "icon": Icons.refresh,
        "tooltip": "Refresh the board and all cards from the repository.",
        "action": () async {
          try {
            // Select a Kanban board
            final selectedBoard = await showKanbanBoardSelector(context, widget.githubService);
            if (selectedBoard != null && selectedBoard.isNotEmpty) {
              final boardName = selectedBoard.endsWith('.json') ? selectedBoard : '$selectedBoard.json';

              // Fetch the Kanban board
              print("Fetching board: $boardName");
              final board = await widget.githubService.fetchBoard(boardName);

              print("Board fetched successfully.");
              printBoardData(board);

              SingletonData().kanbanBoard = KanbanBoard.fromJson(board);
              print("Kanban board set in SingletonData.");

              // Fetch all card IDs referenced in the board
              final cardIds = SingletonData().kanbanBoard?.columns
                  .expand((column) => column.cards.map((card) => card.id))
                  .toList();

              if (cardIds != null && cardIds.isNotEmpty) {
                print("Card IDs to fetch: ${cardIds.length}");

                for (final cardId in cardIds) {
                  try {
                    print("Fetching card with ID: $cardId");
                    final cardData = await widget.githubService.fetchCard(cardId.toString());

                    print("Card fetched successfully. ID: $cardId");
                    final fetchedCard = KanbanCard.fromJson(cardData);

                    // Update the card in the local state
                    final targetColumn = SingletonData().kanbanBoard?.columns
                        .firstWhereOrNull((col) => col.cards.any((card) => card.id == fetchedCard.id));

                    if (targetColumn != null) {
                      // Proceed with updates
                    } else {
                      print("Target column not found for card ID: ${fetchedCard.id}");
                    }



                    if (targetColumn != null) {
                      final index = targetColumn.cards.indexWhere((card) => card.id == fetchedCard.id);
                      if (index != -1) {
                        targetColumn.cards[index] = fetchedCard;
                        print("Updated card in column: ${targetColumn.name}");
                      } else {
                        print("Card not found in column: ${targetColumn.name}");
                      }
                    } else {
                      print("Target column not found for card ID: $cardId");
                    }
                  } catch (cardError) {
                    print("Error fetching or updating card with ID: $cardId. Error: $cardError");
                  }
                }
              } else {
                print("No card IDs found in the board.");
              }

              // Trigger a refresh in the UI
              SingletonData().kanbanViewSetState?.call();
              print("Refreshed board and cards successfully.");
            } else {
              print("No board selected for refresh.");
            }
          } catch (e) {
            print("Error refreshing board and cards: $e");
          }
        }
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


extension IterableExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}