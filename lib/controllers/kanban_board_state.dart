
import 'dart:convert';

import '../models/kanban_board.dart';
import '../services/local_storage_helper.dart';
import '../services/state_abstract.dart';

class KanbanBoardState extends BaseStateManager {
  // The state data
  late KanbanBoard kanbanBoard;


  void update() {
    LocalStorageHelper.saveValue(
      'kanban_board',
      jsonEncode(kanbanBoard.toJson()),
    );
    onStateChanged?.call();
  }

}
