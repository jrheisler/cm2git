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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/constants.dart';
import '../main.dart';
import '../models/kanban_board.dart';
import '../models/kanban_card.dart';
import '../models/kanban_column.dart';
import '../services/git_services.dart';
import '../services/local_storage_helper.dart';
import '../services/singleton_data.dart';
import 'column_management_dialog.dart';
import 'delete_dialog.dart';
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
  final GitHubService _gitHubService = GitHubService(
      retrieveString(singletonData.cm2git), 'jrheisler', 'cm2git');
  bool move = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final kanbanData = LocalStorageHelper.getValue('kanban_board');

    if (kanbanData != null) {
      kanbanBoard = KanbanBoard.fromJson(jsonDecode(kanbanData));
    } else {
      final kanbanBoardJson = getKanbanBoardJson();
      kanbanBoard = KanbanBoard.fromJson(kanbanBoardJson['kanban_board']);
    }
    _refreshFiles();
  }


  void _addCard(String columnName) {
    showDialog(
      context: context,
      builder: (context) {
        return KanbanCardDialog(
          columnName: columnName,
          onSave: (card) {
            setState(() {
              kanbanBoard.columns
                  .firstWhere((column) => column.name == columnName)
                  .cards
                  .add(card);
              LocalStorageHelper.saveValue(
                  'kanban_board', jsonEncode(kanbanBoard.toJson()));
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
          card: card,
          columnName: card.status,
          onSave: (updatedCard) {
            setState(() {
              kanbanBoard.columns
                  .firstWhere((column) => column.name == updatedCard.status)
                  .cards
                  .removeWhere((c) => c.id == updatedCard.id);
              kanbanBoard.columns
                  .firstWhere((column) => column.name == updatedCard.status)
                  .cards
                  .add(updatedCard);
              LocalStorageHelper.saveValue(
                  'kanban_board', jsonEncode(kanbanBoard.toJson()));
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
            });
          },
          onDelete: (deletedColumn) {
            setState(() {
              kanbanBoard.columns.remove(deletedColumn);
              LocalStorageHelper.saveValue(
                  'kanban_board', jsonEncode(kanbanBoard.toJson()));
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
            });
          },
          onDelete: (deletedColumn) {
            setState(() {
              kanbanBoard.columns.remove(deletedColumn);
              LocalStorageHelper.saveValue(
                  'kanban_board', jsonEncode(kanbanBoard.toJson()));
            });
          },
        );
      },
    );
  }

  void _onCardDropped(KanbanCard card, KanbanColumn targetColumn) {
    setState(() {
      // Remove the card from its original column
      kanbanBoard.columns.forEach((column) {
        column.cards.removeWhere((c) => c.id == card.id);
      });

      // Add the card to the new column
      targetColumn.cards.add(card);
      LocalStorageHelper.saveValue(
          'kanban_board', jsonEncode(kanbanBoard.toJson()));
    });
  }

  void _deleteColumn(KanbanColumn column) {
    setState(() {
      kanbanBoard.columns.removeWhere((col) => col.id == column.id);
      LocalStorageHelper.saveValue(
          'kanban_board', jsonEncode(kanbanBoard.toJson()));
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
      final List<GitCommit> commits = await _gitHubService.getCommits();
      setState(() {
        for (var column in kanbanBoard.columns) {
          for (var card in column.cards) {
            card.files.clear();
            for (var commit in commits) {
              if (commit.commit.message.contains('${card.id}')) {
                card.files.add(commit.commit);
                card.sha = commit.sha;
              }
            }
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanban Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshFiles,
            tooltip: 'Refresh Files',
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
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _addCard(column.name),
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
                                      onDelete: () {},
                                    ),
                                  ),
                                  childWhenDragging: Container(),
                                  child: KanbanCardWidget(
                                    card: card,
                                    onEdit: () {
                                      _editCard(card);
                                    },
                                    onDelete: () async {
                                      await showDeleteDialog(context, () {
                                        column.cards.remove(card);
                                        LocalStorageHelper.saveValue(
                                          'kanban_board',
                                          jsonEncode(kanbanBoard.toJson()),
                                        );
                                      });
                                      setState(() {});
                                    },
                                  ),
                                );
                              } else {
                                return KanbanCardWidget(
                                  card: card,
                                  onEdit: () {
                                    _editCard(card);
                                  },
                                  onDelete: () async {
                                    await showDeleteDialog(context, () {
                                      column.cards.remove(card);
                                      LocalStorageHelper.saveValue(
                                        'kanban_board',
                                        jsonEncode(kanbanBoard.toJson()),
                                      );
                                    });
                                    setState(() {});
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
    );
  }
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
                        onDelete: () {},
                      ),
                    ),
                  ),
                  childWhenDragging: Container(),
                  child: KanbanCardWidget(
                    card: card,
                    onEdit: () => onEditCard(card),
                    onDelete: () => onDeleteCard(card),
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
  final VoidCallback onDelete;

  KanbanCardWidget(
      {required this.card, required this.onEdit, required this.onDelete});

  void _copyToClipboard(BuildContext context) {
    final text = 'Card ID: ${card.id}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard: $text')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: singletonData.kPrimaryColor,
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
            Text('Description: ${card.description}'),
            Text('Assignee: ${card.assignee}'),
            Text('Status: ${card.status}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
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
              "filesChanged": []
            },
            {
              "id": 102,
              "title": "Design Database Schema",
              "description": "Create initial database schema for the project",
              "assignee": "Bob",
              "status": "PRODUCT BACKLOG",
              "filesChanged": []
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
              "filesChanged": []
            },
            {
              "id": 202,
              "title": "Create User Stories",
              "description": "Write detailed user stories for the upcoming sprint",
              "assignee": "Dave",
              "status": "SPRINT BACKLOG",
              "filesChanged": []
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
              "filesChanged": [
                "lib/screens/login_screen.dart",
                "lib/widgets/login_form.dart",
                "lib/services/auth_service.dart"
              ]
            },
            {
              "id": 302,
              "title": "Setup CI/CD Pipeline",
              "description": "Configure continuous integration and deployment",
              "assignee": "Frank",
              "status": "WIP",
              "filesChanged": [
                ".github/workflows/ci.yml",
                "scripts/deploy.sh"
              ]
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
              "filesChanged": [
                "test/auth_test.dart"
              ]
            },
            {
              "id": 402,
              "title": "Test Payment Gateway Integration",
              "description": "Perform end-to-end testing for payment gateway",
              "assignee": "Hank",
              "status": "TESTING",
              "filesChanged": []
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
              "filesChanged": [
                "README.md",
                "setup/config.json"
              ]
            },
            {
              "id": 502,
              "title": "Deploy First Version",
              "description": "Deploy the first version of the application to production",
              "assignee": "Jack",
              "status": "DONE",
              "filesChanged": [
                "scripts/deploy.sh",
                "docker/Dockerfile"
              ]
            }
          ]
        }
      ]
    }
  }
  ''';

  return jsonDecode(kanbanBoardJson);
}
