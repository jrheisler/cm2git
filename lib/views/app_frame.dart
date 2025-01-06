import 'dart:convert';
import 'package:cm_2_git/views/reports.dart';
import 'package:flutter/material.dart';
import '../models/kanban_board.dart';
import '../models/kanban_card.dart';
import '../services/git_services.dart';
import '../services/local_storage_helper.dart';
import '../services/singleton_data.dart';
import 'calendar_widget.dart';
import 'kanban_view.dart';

class AppFrame extends StatefulWidget {
  const AppFrame({super.key});

  @override
  State<AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends State<AppFrame> {
  List<KanbanCard> allCards = SingletonData()
      .kanbanBoard
      .columns
      .expand((column) => column.cards)
      .toList();
  @override

  void initState() {
    SingletonData().registerAppFrameSetStateCallback(() {
      if (mounted)
      setState(() {
      }); // Trigger a rebuild when the callback is invoked
    });
    final kanbanData = LocalStorageHelper.getValue('kanban_board');

    try {
      SingletonData().kanbanBoard = KanbanBoard.fromJson(jsonDecode(kanbanData!));
    } catch (e) {
      SingletonData().kanbanBoard = KanbanBoard.fromData();
    }

    SingletonData().gitHubService = GitHubService(
        retrieveString(SingletonData().kanbanBoard.gitString),
        SingletonData().kanbanBoard.gitUser,
        SingletonData().kanbanBoard.gitRepo,
        SingletonData().kanbanBoard.gitUrl);

    super.initState();
  }

  @override
  void dispose() {
    SingletonData().appFrameSetState = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('-----------------------build app frame');
    return Scaffold(
      body: Row(
        children: [
          // Left-hand column
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: CalendarWidget(),
                    ),
                  ),
                  const Divider(color: Colors.deepPurple,),
                  const Expanded(
                    flex: 3,
                    child: ReportsPage(),
                  ),
                ],
              ),
            ),
          ),
          // Main content area
          const Expanded(
            child: KanbanBoardScreen(),
          ),
        ],
      ),
    );



  }
}