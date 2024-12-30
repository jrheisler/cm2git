//  void initState() {
//
//     super.initState();
//     final kanbanData = LocalStorageHelper.getValue('kanban_board');
//
//     if (kanbanData != null) {
//       kanbanBoard = KanbanBoard.fromJson(jsonDecode(kanbanData));
//     } else {
//       final kanbanBoardJson = getKanbanBoardJson();
//       kanbanBoard = KanbanBoard.fromJson(kanbanBoardJson['kanban_board']);
//     }
//   }

import 'dart:convert';
import 'package:cm_2_git/views/show_kanban_name_dialog.dart';
import 'package:cm_2_git/views/timeline_data.dart';
import 'package:cm_2_git/views/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import '../common/constants.dart';
import '../main.dart';
import '../models/kanban_board.dart';
import '../models/kanban_card.dart';
import '../models/kanban_column.dart';
import '../services/download_file.dart';
import '../services/git_services.dart';
import '../services/local_storage_helper.dart';
import '../services/mili.dart';
import '../services/singleton_data.dart';
import 'column_management_dialog.dart';
import 'delete_dialog.dart';
import 'git_command_dialog.dart';
import 'git_log.dart';
import 'git_workflow_screen.dart';
import 'github_stats_dialog.dart';
import 'kanban_card_dialog.dart';
import 'kanban_column_dialog.dart';

class KanbanBoardScreen extends StatefulWidget {
  const KanbanBoardScreen({
    super.key,
  });

  @override
  _KanbanBoardScreenState createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  late KanbanBoard kanbanBoard;
  final ScrollController _scrollController = ScrollController();
  bool move = false;
  bool _isSaving = false; // Add this to your class as a state variable
  @override
  void dispose() {
    _scrollController.dispose();
    print('dispose');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('init');
    final kanbanData = LocalStorageHelper.getValue('kanban_board');

    try {
      kanbanBoard = KanbanBoard.fromJson(jsonDecode(kanbanData!));
    } catch (e) {
      kanbanBoard = KanbanBoard.fromData();
    }

    SingletonData().kanbanBoard = kanbanBoard;
    SingletonData().registerkanbanViewSetState(() {
      setState(() {
        print('set state kanban view');
      }); // Trigger a rebuild when the callback is invoked
    });
    _refreshFiles();
    SingletonData().gitHubService = GitHubService(retrieveString(kanbanBoard.gitString),
        kanbanBoard.gitUser, kanbanBoard.gitRepo, kanbanBoard.gitUrl);

  }

  // Handle file open request from JavaScript
  Future<void> handleFileOpen(String fileContent) async {
    try {
      // Parse JSON content
      try {
        kanbanBoard = KanbanBoard.fromJson(jsonDecode(fileContent));
      } catch (e) {
        kanbanBoard = KanbanBoard.fromData();
      }
      setState(() {});
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  void _addCard(String columnName) {
    showDialog(
      context: context,
      builder: (context) {
        return KanbanCardDialog(
          kanban: kanbanBoard,
          columnName: columnName,
          onDelete: () {
            Navigator.of(context).pop();
          },
          onSave: (card) {
            setState(() {
              kanbanBoard.columns
                  .firstWhere((column) => column.name == columnName)
                  .cards
                  .add(card);

              card.dates
                  .add(KanbanDates(date: DateTime.now(), status: card.status));
              LocalStorageHelper.saveValue(
                  'kanban_board', jsonEncode(kanbanBoard.toJson()));
              card.isModified = true;
              SingletonData().isSaveNeeded = true;
            });
          },
        );
      },
    );
  }

  void _editCard(KanbanCard card) {
    showDialog(
      context: context,
      builder: (context) {
        return KanbanCardDialog(
          kanban: kanbanBoard,
          card: card,
          columnName: card.status,
          onDelete: () async {
            await showDeleteDialog(context, () {
              for (var col in kanbanBoard.columns) {
                col.cards.remove(card);
              }
              LocalStorageHelper.saveValue(
                'kanban_board',
                jsonEncode(kanbanBoard.toJson()),
              );
              card.isModified = true;
              SingletonData().isSaveNeeded = true;
              Navigator.of(context).pop();
            });
            setState(() {});
          },
          onSave: (updatedCard) {
            setState(() {
              var column = kanbanBoard.columns
                  .firstWhere((column) => column.name == updatedCard.status);

              // Find the index of the card to be updated
              int index =
                  column.cards.indexWhere((c) => c.id == updatedCard.id);

              if (index != -1) {
                // Remove the card from the list
                column.cards.removeAt(index);

                // Insert the updated card back at the same index
                column.cards.insert(index, updatedCard);
              }
              LocalStorageHelper.saveValue(
                'kanban_board',
                jsonEncode(kanbanBoard.toJson()),
              );
              updatedCard.isModified = true;
              SingletonData().isSaveNeeded = true;
            });
          },
        );
      },
    );
  }

  void _addColumn() {
    showDialog(
      context: context,
      builder: (context) {
        return KanbanColumnDialog(
          onSave: (column) {
            setState(() {
              kanbanBoard.columns.add(column);
              LocalStorageHelper.saveValue(
                  'kanban_board', jsonEncode(kanbanBoard.toJson()));
              SingletonData().isSaveNeeded = true;
            });
          },
          onDelete: (deletedColumn) {
            setState(() {
              kanbanBoard.columns.remove(deletedColumn);
              LocalStorageHelper.saveValue(
                  'kanban_board', jsonEncode(kanbanBoard.toJson()));
              SingletonData().isSaveNeeded = true;
            });
          },
        );
      },
    );
  }

  void _editColumn(KanbanColumn column) {
    showDialog(
      context: context,
      builder: (context) {
        return KanbanColumnDialog(
          column: column,
          onSave: (updatedColumn) {
            setState(() {
              int index = kanbanBoard.columns.indexOf(column);
              kanbanBoard.columns[index] = updatedColumn;
              LocalStorageHelper.saveValue(
                  'kanban_board', jsonEncode(kanbanBoard.toJson()));
              SingletonData().isSaveNeeded = true;
            });
          },
          onDelete: (deletedColumn) {
            setState(() {
              kanbanBoard.columns.remove(deletedColumn);
              LocalStorageHelper.saveValue(
                  'kanban_board', jsonEncode(kanbanBoard.toJson()));
              SingletonData().isSaveNeeded = true;
            });
          },
        );
      },
    );
  }

  void _onCardDropped(KanbanCard card, KanbanColumn targetColumn) {
    if (targetColumn.cards.length < targetColumn.maxCards) {
      setState(() {
        // Remove the card from its original column
        for (var column in kanbanBoard.columns) {
          column.cards.removeWhere((c) => c.id == card.id);
        }

        final newCard = KanbanCard(
          id: card.id ?? DateTime.now().millisecondsSinceEpoch,
          title: card.title,
          description: card.description,
          assignee: card.assignee,
          status: targetColumn.name,
          files: card.files ?? [],
          sha: card.sha ?? '',
          dates: card.dates,
          needDate: card.needDate,
          blocked: card.blocked,
          isModified: true,
        );

        KanbanDates kd =
            KanbanDates(date: DateTime.now(), status: targetColumn.name);
        newCard.dates.add(kd);

        // Add the card to the new column
        targetColumn.cards.add(newCard);
        LocalStorageHelper.saveValue(
            'kanban_board', jsonEncode(kanbanBoard.toJson()));
        SingletonData().isSaveNeeded = true;
      });
    } else {
      SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
            content: Text("You can't add more cards to this column")),
      );
    }
  }

  void _deleteColumn(KanbanColumn column) {
    setState(() {
      kanbanBoard.columns.removeWhere((col) => col.id == column.id);
      LocalStorageHelper.saveValue(
          'kanban_board', jsonEncode(kanbanBoard.toJson()));
      SingletonData().isSaveNeeded = true;
    });
  }

  void _manageColumns() {
    showDialog(
      context: context,
      builder: (context) {
        return ColumnManagementDialog(
          columns: kanbanBoard.columns,
          onAddColumn: _addColumn,
          onEditColumn: _editColumn,
          onDeleteColumn: _deleteColumn,
        );
      },
    );
  }

  Future<void> _refreshFiles() async {
    try {
      final List<GitCommit> commits = await SingletonData().gitHubService.getCommits();
      final List<GitPullRequest> pulls = await SingletonData().gitHubService.getPullRequests();
      //final List<GitBranch> branches = await _gitHubService.getBranches();
      setState(() {
        for (var column in kanbanBoard.columns) {
          for (var card in column.cards) {
            card.files = [];
            for (var commit in commits) {
              if (commit.commit.message.contains('${card.id}')) {
                card.files.add(commit.commit);
                card.sha = commit.sha;
              }
            }
          }
        }

        for (var column in kanbanBoard.columns) {
          for (var card in column.cards) {
            card.pulls = [];
            for (var pull in pulls) {
              if (pull.body.contains('${card.id}')) {
                card.pulls.add(pull);
                card.sha = '';
              }
            }
          }
        }
        /*
        for (var column in kanbanBoard.columns) {
          for (var card in column.cards) {
            card.files = [];
            for (var branch in branches) {
              if (branch.commit.commit.message.contains('${card.id}')) {
                card.files.add(branch.commit);
                card.sha = branch.commit.commit.sha;
              }
            }
          }
        }
*/
        SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Refreshed')),
        );
        LocalStorageHelper.saveValue(
            'kanban_board', jsonEncode(kanbanBoard.toJson()));
      });
    } catch (e) {
      print('Failed to load files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('-----------------------build-------------------------');
    kanbanBoard = SingletonData().kanbanBoard;
    int i = 0;

    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          title: ElevatedButton(
            onPressed: () async {
              KanbanBoard _kanbanBoard =
                  (await showNameDialog(context, kanbanBoard))!;
              if (_kanbanBoard != null) {
                setState(() {
                  kanbanBoard = _kanbanBoard;
                  LocalStorageHelper.saveValue(
                      'kanban_board', jsonEncode(kanbanBoard.toJson()));
                  SingletonData().isSaveNeeded = true;
                });
              } else {
                print("Dialog was canceled.");
              }
            },
            child: Text(
              '${kanbanBoard.name} - ${kanbanBoard.gitRepo}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            // Save to Git Icon
            if (SingletonData().isSaveNeeded)
              IconButton(
                icon: const Icon(Icons.save, color: Colors.red),
                onPressed: _saveToGit,
                tooltip: 'Save to Git',
              ),
            IconButton(
              icon: const Icon(
                Icons.integration_instructions_sharp,
              ),
              onPressed: () => showGitWorkflowDialog(context, SingletonData().gitHubService),
              tooltip: 'Git Integration',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshFiles,
              tooltip: 'Refresh Files',
            ),
            IconButton(
              icon: const Icon(Icons.list_alt_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => GitLogDialog(
                    githubUser: kanbanBoard.gitUser,
                    githubToken: retrieveString(kanbanBoard.gitString),
                    githubRepo: kanbanBoard.gitRepo,
                    githubUrl: kanbanBoard.gitUrl,
                  ),
                );
              },
              tooltip: 'Show Git Log',
            ),
            IconButton(
              icon: const Icon(Icons.streetview_sharp),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return GitHubFileTree(
                        githubUser: kanbanBoard.gitUser,
                        githubToken: retrieveString(kanbanBoard.gitString),
                        githubRepo: kanbanBoard.gitRepo,
                        githubUrl: kanbanBoard.gitUrl,
                      );
                    });
              },
              tooltip: 'Tree View',
            ),
            IconButton(
              icon: const Icon(Icons.graphic_eq_sharp),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return TimelineChart(kanban: kanbanBoard);
                    });
              },
              tooltip: 'Timeline Chart',
            ),
            IconButton(
                tooltip: 'Git Status',
                icon: const Icon(Icons.auto_graph),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => GitHubStatsDialog(
                        owner: kanbanBoard.gitUser,
                        repo: kanbanBoard.gitRepo,
                        gitUrl: kanbanBoard.gitUrl,
                        gitString: kanbanBoard.gitString),
                  );
                }),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadKanban,
              tooltip: 'Download Kanban',
            ),
            IconButton(
              icon: const Icon(Icons.import_export_sharp),
              onPressed: _importKanban,
              tooltip: 'Import a Kanban From File',
            ),
            IconButton(
              icon: const Icon(Icons.view_column),
              onPressed: _manageColumns,
              tooltip: 'Manage Columns',
            ),
            SizedBox(
              width: 40,
              child: Tooltip(
                message: move ? 'Turn Drag/Drop off' : 'Turn Drag/Drop on',
                child: Checkbox(
                    value: move,
                    onChanged: (b) {
                      setState(() {
                        move = b!;
                      });
                    }),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
        body: Scrollbar(
          thickness: 12,
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: kanbanBoard.columns.map((column) {
                i++;
                return Container(
                  decoration: newBoxDec(),
                  width: 300,
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _editColumn(column),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                column.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          i == 1
                              ? IconButton(
                                  tooltip: 'Add a Card',
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    if (column.maxCards == 0 ||
                                        column.maxCards > column.cards.length) {
                                      _addCard(column.name);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "You can't add more cards to this column")),
                                      );
                                    }
                                  },
                                )
                              : IconButton(
                                  tooltip:
                                      'You can only add cards to the first column',
                                  icon: const Icon(
                                      color: Colors.black45,
                                      Icons.check_box_outline_blank),
                                  onPressed: () => setState(() {}),
                                ),
                          Text(
                            '${column.cards.length}/${column.maxCards}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: DragTarget<KanbanCard>(
                          onWillAccept: (card) => true,
                          onAccept: (card) {
                            _onCardDropped(card, column);
                          },
                          builder: (context, candidateData, rejectedData) {
                            return ListView(
                              children: column.cards.map((card) {
                                if (move) {
                                  return Draggable<KanbanCard>(
                                    data: card,
                                    feedback: Material(
                                      child: KanbanCardWidget(
                                        card: card,
                                        onEdit: () {},
                                      ),
                                    ),
                                    childWhenDragging: Container(),
                                    child: KanbanCardWidget(
                                      card: card,
                                      onEdit: () {
                                        _editCard(card);
                                      },
                                    ),
                                  );
                                } else {
                                  return KanbanCardWidget(
                                    card: card,
                                    onEdit: () {
                                      _editCard(card);
                                    },
                                  );
                                }
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      if (_isSaving)
        Container(
          color: Colors.black54, // Semi-transparent background
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
    ]);
  }

  void _saveToGit() async {
    setState(() {
      _isSaving = true; // Show the progress indicator
    });

    try {
      final currentBoard = SingletonData().kanbanBoard;
      if (currentBoard != null) {
        // Save the Kanban board
        await SingletonData().gitHubService.saveBoard(
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
              card.sha = await SingletonData().gitHubService.fetchFileSha(
                  'cards/${card.id}.json') ?? "";
            }

            if (card.sha.isEmpty) {
              print("Card ${card.id} does not exist on GitHub. Creating a new file.");
            } else {
              print("Card ${card.id} exists. Updating the file with SHA: ${card.sha}");
            }

            await SingletonData().gitHubService.saveCard(
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

        SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text("Committed board and modified cards successfully."),
          ),
        );

        setState(() {
          resetCardsNotModified(currentBoard);
        });

        print("Committed board and modified cards successfully.");
      } else {
        print("No Kanban board loaded to commit.");
      }
    } catch (e) {
      print("Error committing board and cards: $e");
      SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false; // Hide the progress indicator
      });
    }
  }
  void _downloadKanban() {
    var projJson = kanbanBoard.toJson();
    var encoded = jsonEncode(projJson);

    downloadFile(encoded, '${kanbanBoard.name}.json');
  }

  void _importKanban() {
    // HTML input element
    html.InputElement uploadInput =
        html.FileUploadInputElement() as html.InputElement..accept = '*/json';
    uploadInput.click();

    uploadInput.onChange.listen(
      (changeEvent) {
        final file = uploadInput.files!.first;
        final reader = html.FileReader();

        reader.readAsText(file);

        reader.onLoadEnd.listen(
            // After file finish reading and loading, it will be uploaded to firebase storage
            (loadEndEvent) async {
          var json = reader.result;
          kanbanBoard = KanbanBoard.fromJson(jsonDecode(json.toString()));
          SingletonData().kanbanBoard = kanbanBoard;
          setState(() {
            LocalStorageHelper.saveValue(
                'kanban_board', jsonEncode(kanbanBoard.toJson()));
          });
        });
      },
    );
  }
}

void resetCardsNotModified(KanbanBoard kanbanBoard) {
  if (kanbanBoard == null) {
    print("KanbanBoard is null, nothing to reset.");
    return;
  }

  for (final column in kanbanBoard.columns) {
    for (final card in column.cards) {
      card.isModified = false;
    }
  }
  SingletonData().isSaveNeeded = false;
  print("All cards in the Kanban board have been reset to not modified.");
}

class KanbanColumnWidget extends StatelessWidget {
  final KanbanColumn column;
  final Function(KanbanCard, KanbanColumn) onCardDropped;
  final Function(KanbanCard) onEditCard;
  final Function(KanbanCard) onDeleteCard;
  final Function(String) onAddCard;

  const KanbanColumnWidget({
    Key? key,
    required this.column,
    required this.onCardDropped,
    required this.onEditCard,
    required this.onDeleteCard,
    required this.onAddCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(8),
      decoration: newBoxDec(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  column.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => onAddCard(column.name),
                ),
              ],
            ),
          ),
          Divider(
            color: singletonData.kPrimaryColor,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: column.cards.length,
              itemBuilder: (context, index) {
                final card = column.cards[index];
                return Draggable<KanbanCard>(
                  data: card,
                  feedback: Material(
                    child: Opacity(
                      opacity: 0.7,
                      child: KanbanCardWidget(
                        card: card,
                        onEdit: () {},
                      ),
                    ),
                  ),
                  childWhenDragging: Container(),
                  child: KanbanCardWidget(
                    card: card,
                    onEdit: () => onEditCard(card),
                  ),
                );
              },
            ),
          ),
          DragTarget<KanbanCard>(
            onAccept: (card) => onCardDropped(card, column),
            builder: (context, candidateData, rejectedData) {
              return Container(
                height: 50,
                color: candidateData.isNotEmpty
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.transparent,
                child: Center(
                  child: Text(
                    candidateData.isNotEmpty ? 'Drop here' : '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class KanbanCardWidget extends StatelessWidget {
  final KanbanCard card;
  final VoidCallback onEdit;

  KanbanCardWidget({required this.card, required this.onEdit});

  void _copyToClipboard(BuildContext context) {
    final text = 'Card ID: ${card.id}';
    Clipboard.setData(ClipboardData(text: text));
    SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text('Copied to clipboard: $text')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: card.blocked ? Colors.redAccent : singletonData.kPrimaryColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ID: ${card.id}'),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(context),
                ),
              ],
            ),
            Text('Title: ${card.title}'),
            const Divider(),
            Text('Description: ${card.description}'),
            const Divider(),
            Text('Assignee: ${card.assignee}'),
            const Divider(),
            Text('Status: ${card.status}'),
            const Divider(),
            Text('Create Date: ${convertMilliToDateTime(card.id)}'),
            const Divider(),
            card.needDate!.isBefore(DateTime.now())
                ? Text(
                    'Need Date: ${DateFormat('yyyy-MM-dd').format(card.needDate!)}',
                    style: card.blocked
                        ? const TextStyle(color: Colors.black)
                        : const TextStyle(color: Colors.red),
                  )
                : Text(
                    'Need Date: ${DateFormat('yyyy-MM-dd').format(card.needDate!)}'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class KanbanCardData {
  final KanbanCard card;
  final KanbanColumn column;

  KanbanCardData({required this.card, required this.column});
}

Map<String, dynamic> getKanbanBoardJson() {
  const kanbanBoardJson = '''
  {
    "kanban_board": {
      "columns": [
        {
          "id": 1,
          "name": "PRODUCT BACKLOG",
          "cards": [
            {
              "id": 101,
              "title": "Research API Integration",
              "description": "Investigate the integration with external API services",
              "assignee": "Alice",
              "status": "PRODUCT BACKLOG",
            },
            {
              "id": 102,
              "title": "Design Database Schema",
              "description": "Create initial database schema for the project",
              "assignee": "Bob",
              "status": "PRODUCT BACKLOG",              
            }
          ]
        },
        {
          "id": 2,
          "name": "SPRINT BACKLOG",
          "cards": [
            {
              "id": 201,
              "title": "Setup Development Environment",
              "description": "Install and configure development tools and libraries",
              "assignee": "Charlie",
              "status": "SPRINT BACKLOG",              
            },
            {
              "id": 202,
              "title": "Create User Stories",
              "description": "Write detailed user stories for the upcoming sprint",
              "assignee": "Dave",
              "status": "SPRINT BACKLOG",
            }
          ]
        },
        {
          "id": 3,
          "name": "WIP",
          "cards": [
            {
              "id": 301,
              "title": "Implement Login Feature",
              "description": "Develop the login feature for the application",
              "assignee": "Eve",
              "status": "WIP",              
            },
            {
              "id": 302,
              "title": "Setup CI/CD Pipeline",
              "description": "Configure continuous integration and deployment",
              "assignee": "Frank",
              "status": "WIP",              
            }
          ]
        },
        {
          "id": 4,
          "name": "TESTING",
          "cards": [
            {
              "id": 401,
              "title": "Write Unit Tests for Authentication",
              "description": "Develop unit tests for the authentication module",
              "assignee": "Grace",
              "status": "TESTING",              
            },
            {
              "id": 402,
              "title": "Test Payment Gateway Integration",
              "description": "Perform end-to-end testing for payment gateway",
              "assignee": "Hank",
              "status": "TESTING",              
            }
          ]
        },
        {
          "id": 5,
          "name": "DONE",
          "cards": [
            {
              "id": 501,
              "title": "Complete Project Setup",
              "description": "Finish initial project setup and configuration",
              "assignee": "Ivy",
              "status": "DONE",              
            },
            {
              "id": 502,
              "title": "Deploy First Version",
              "description": "Deploy the first version of the application to production",
              "assignee": "Jack",
              "status": "DONE",              
            }
          ]
        }
      ]
    }
  }
  ''';

  return jsonDecode(kanbanBoardJson);
}
