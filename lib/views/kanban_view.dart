import 'dart:convert';
import 'package:cm_2_git/views/reports.dart';
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
import '../services/helpers.dart';
import '../services/local_storage_helper.dart';
import '../services/mili.dart';
import '../services/singleton_data.dart';
import 'column_management_dialog.dart';
import 'delete_dialog.dart';
import 'git_log.dart';
import 'git_workflow_screen.dart';
import 'github_stats_dialog.dart';
import 'grid_view_screen.dart';
import 'kanban_card_dialog.dart';
import 'kanban_card_widget.dart';
import 'kanban_column_dialog.dart';

class KanbanBoardScreen extends StatefulWidget {
  const KanbanBoardScreen({
    super.key,
  });

  @override
  _KanbanBoardScreenState createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen>
    with SingleTickerProviderStateMixin {
  late KanbanBoard kanbanBoard;
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  bool _isSaving = false; // Add this to your class as a state variable
  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    print('dispose');
    super.dispose();
  }

  @override
  void initState() {
    kanbanBoard = SingletonData().kanbanBoard;
    SingletonData().registerkanbanViewSetState(() {
      if (mounted) {
        setState(() {
          print('set state kanban view');
        }); // Trigger a rebuild when the callback is invoked
      }
    });
    _refreshFiles();

    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      if (mounted) setState(() {});
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
            if (mounted) {
              setState(() {
                kanbanBoard.columns
                    .firstWhere((column) => column.name == columnName)
                    .cards
                    .add(card);
                card.dates.add(
                    KanbanDates(date: DateTime.now(), status: card.status));
                LocalStorageHelper.saveValue(
                    'kanban_board', jsonEncode(kanbanBoard.toJson()));
                card.isModified = true;
                SingletonData().markSaveNeeded();
              });
            }
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
            if (mounted) {
              setState(() {
                print(179);
                kanbanBoard.columns.add(column);
                print(181);
                LocalStorageHelper.saveValue(
                    'kanban_board', jsonEncode(kanbanBoard.toJson()));
                print(184);
                SingletonData().markSaveNeeded();
                print(186);
              });
            }
          },
          onDelete: (deletedColumn) {
            if (mounted) {
              setState(() {
                kanbanBoard.columns.remove(deletedColumn);
                LocalStorageHelper.saveValue(
                    'kanban_board', jsonEncode(kanbanBoard.toJson()));
                SingletonData().markSaveNeeded();
              });
            }
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
            if (mounted) {
              setState(() {
                int index = kanbanBoard.columns.indexOf(column);
                kanbanBoard.columns[index] = updatedColumn;
                LocalStorageHelper.saveValue(
                    'kanban_board', jsonEncode(kanbanBoard.toJson()));
                SingletonData().markSaveNeeded();
              });
            }
          },
          onDelete: (deletedColumn) {
            if (mounted) {
              setState(() {
                kanbanBoard.columns.remove(deletedColumn);
                LocalStorageHelper.saveValue(
                    'kanban_board', jsonEncode(kanbanBoard.toJson()));
                SingletonData().markSaveNeeded();
              });
            }
          },
        );
      },
    );
  }

  void _onCardDropped(KanbanCard card, KanbanColumn targetColumn) {
    if (targetColumn.cards.length < targetColumn.maxCards) {
      if (mounted) {
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
            blockReason: '',
          );

          KanbanDates kd =
              KanbanDates(date: DateTime.now(), status: targetColumn.name);
          newCard.dates.add(kd);

          // Add the card to the new column
          targetColumn.cards.add(newCard);
          LocalStorageHelper.saveValue(
              'kanban_board', jsonEncode(kanbanBoard.toJson()));
          SingletonData().markSaveNeeded();
        });
      }
    } else {
      SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
                content: Text("You can't add more cards to this column", style: TextStyle(color: Colors.white),),
              duration: const Duration(milliseconds: 750),),
          );
    }
  }

  void _deleteColumn(KanbanColumn column) {
    if (mounted) {
      setState(() {
        kanbanBoard.columns.removeWhere((col) => col.id == column.id);
        LocalStorageHelper.saveValue(
            'kanban_board', jsonEncode(kanbanBoard.toJson()));
        SingletonData().markSaveNeeded();
      });
    }
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
      final List<GitCommit> commits =
          await SingletonData().gitHubService.getCommits();
      final List<GitPullRequest> pulls =
          await SingletonData().gitHubService.getPullRequests();
      //final List<GitBranch> branches = await _gitHubService.getBranches();
      if (mounted) {
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
          SingletonData().clearSaveNeeded();
          SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  backgroundColor: SingletonData().kPrimaryColor,
                  content: const Text(
                    'Refreshed',
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: const Duration(milliseconds: 750),
                ),
              );
          LocalStorageHelper.saveValue(
              'kanban_board', jsonEncode(kanbanBoard.toJson()));
        });
      }
    } catch (e) {
      print('Failed to load files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('-----------------------build-------------------------');
    kanbanBoard = SingletonData().kanbanBoard;

    return Stack(children: [
      Scaffold(
        appBar: appBar(),
        body: DefaultTabController(
          length: 2, // Two tabs: Kanban and Grid View
          child: TabBarView(
            controller: _tabController,
            children: [
              kanbanView(),
              GridViewScreen(),
            ],
          ),
        ),
        bottomNavigationBar: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Kanban View"),
            Tab(text: "Grid View"),
          ],
          labelColor: Colors.blue,
          // Customize as needed
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.label,
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
    if (mounted) {
      setState(() {
        _isSaving = true; // Show the progress indicator
      });
    }

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
              card.sha = await SingletonData()
                      .gitHubService
                      .fetchFileSha('cards/${card.id}.json') ??
                  "";
            }

            if (card.sha.isEmpty) {
              print(
                  "Card ${card.id} does not exist on GitHub. Creating a new file.");
            } else {
              print(
                  "Card ${card.id} exists. Updating the file with SHA: ${card.sha}");
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
                content:
                    Text("Committed board and modified cards successfully."),
              ),
            );
        if (mounted) {
          setState(() {
            resetCardsNotModified(currentBoard);
          });
        }

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
      if (mounted) {
        setState(() {
          _isSaving = false; // Hide the progress indicator
        });
      }
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
            // After file finish reading and loading, it will be uploaded to local storage
            (loadEndEvent) async {
          var json = reader.result;
          kanbanBoard = KanbanBoard.fromJson(jsonDecode(json.toString()));
          SingletonData().kanbanBoard = kanbanBoard;
          if (mounted) {
            setState(() {
              LocalStorageHelper.saveValue(
                  'kanban_board', jsonEncode(kanbanBoard.toJson()));
            });
          }
          SingletonData().clearSaveNeeded();
        });
      },
    );
  }

  Widget kanbanView() {
    int i = 0;
    return Scrollbar(
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
              width: SingletonData().kanbanBoard.columns.length > 1
                  ? 300
                  : MediaQuery.of(context).size.width - 310,
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
                              icon: const Icon(Icons.add_circle_sharp, color: Colors.green,),
                              onPressed: () {
                                if (column.maxCards == 0 ||
                                    column.maxCards > column.cards.length) {
                                  _addCard(column.name);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                            if (SingletonData().move) {
                              return Draggable<KanbanCard>(
                                data: card,
                                feedback: Material(
                                  child: KanbanCardWidget(
                                    card: card,
                                  ),
                                ),
                                childWhenDragging: Container(),
                                child: KanbanCardWidget(
                                  card: card,
                                ),
                              );
                            } else {
                              return KanbanCardWidget(
                                card: card,
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
    );
  }

  void showStyledCIReportsDialog(BuildContext context) {
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
              maxHeight: 460, // Limit the height of the dialog
            ),
            margin: const EdgeInsets.all(4), // 20-pixel border
            padding: const EdgeInsets.all(4), // Inner padding for content
            child: const CIReportsPage(),
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

  AppBar appBar() {
    return AppBar(
      title: ElevatedButton(
        onPressed: () async {
          KanbanBoard _kanbanBoard =
              (await showNameDialog(context, kanbanBoard))!;
          if (mounted) {
            setState(() {
              kanbanBoard = _kanbanBoard;
              LocalStorageHelper.saveValue(
                  'kanban_board', jsonEncode(kanbanBoard.toJson()));
              SingletonData().markSaveNeeded();
            });
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
          onPressed: () =>
              showGitWorkflowDialog(context, SingletonData().gitHubService),
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
          icon: const Icon(Icons.analytics),
          tooltip: "View CI Reports",
          onPressed: () {
            showStyledCIReportsDialog(context);
          },
        ),

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
            message: SingletonData().move
                ? 'Turn Drag/Drop off'
                : 'Turn Drag/Drop on',
            child: Checkbox(
                value: SingletonData().move,
                onChanged: (b) {
                  if (mounted) {
                    setState(() {
                      SingletonData().move = b!;
                    });
                  }
                }),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
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
                      ),
                    ),
                  ),
                  childWhenDragging: Container(),
                  child: KanbanCardWidget(
                    card: card,
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

class KanbanCardData {
  final KanbanCard card;
  final KanbanColumn column;

  KanbanCardData({required this.card, required this.column});
}
