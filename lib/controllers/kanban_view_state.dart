

import 'package:cm_2_git/models/kanban_board.dart';

import '../services/state_abstract.dart';

class KanbanViewState  extends BaseStateManager {
  // The state data
  //bool _openScript = false;
  late KanbanBoard kanbanBoard;
  String s = 'to string';

  // Methods to modify the state data
  void incrementCounter() {
    //_counter++;
    // Call the callback to update the UI
    onStateChanged?.call();
  }
  void update() {
    // Call the callback to update the UI
    onStateChanged?.call();
  }

  void closeTheScript() {
    //_openScript = false;
    // Call the callback to update the UI
    onStateChanged?.call();
  }

  // Getter to retrieve the state data

  //int get counter => _counter;
}