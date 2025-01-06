import 'package:cm_2_git/services/singleton_data.dart';
import 'package:flutter/material.dart';

import '../models/kanban_board.dart';
import '../models/kanban_card.dart';
import '../models/kanban_column.dart';

Future<void> moveCardToBoard(
    KanbanCard card,
    String targetBoardName,
    ) async {
  try {
    // Load target board
    final targetBoard =
    await SingletonData().gitHubService.fetchBoard(targetBoardName);

    // Ensure the target board has a valid structure
    if (targetBoard['columns'] == null || targetBoard['columns'].isEmpty) {
      throw Exception("Target board $targetBoardName has no columns.");
    }

    // Add card to the first column of the target board
    targetBoard['columns'].first['cards'].add(card.toJson());

    // Save the target board
    await SingletonData().gitHubService.saveBoard(
      targetBoard,
      message: "Added card ${card.id} to $targetBoardName",
    );

    // Remove card from source board only after successfully adding it to the target board
    for (var column in SingletonData().kanbanBoard.columns) {
      column.cards.removeWhere((c) => c.id == card.id);
    }

    // Save source board
    await SingletonData().gitHubService.saveBoard(
      SingletonData().kanbanBoard.toJson(),
      message:
      "Removed card ${card.id} from ${SingletonData().kanbanBoard.name}",
    );

    // Notify the user
    SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text("Moved card ${card.id} to $targetBoardName")),
    );

    // Refresh the Kanban view
    SingletonData().kanbanViewSetState?.call();
  } catch (e) {
    print("Error moving card ${card.id} to $targetBoardName: $e");
    SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text("Failed to move card: $e")),
    );
  }
}

Future<void> archiveCard(
    KanbanCard card,
    String sourceBoardName, {
      String? archiveBoardName,
    }) async {
  try {
    final targetArchiveBoardName =
        archiveBoardName ?? "Archive_${DateTime.now().millisecondsSinceEpoch}";

    KanbanBoard archiveBoard;

    // Check if archive board exists, if not, create a new one
    try {
      final archiveBoardData = await SingletonData()
          .gitHubService
          .fetchBoard(targetArchiveBoardName);
      archiveBoard = KanbanBoard.fromJson(archiveBoardData);
    } catch (_) {
      archiveBoard = KanbanBoard(
        name: targetArchiveBoardName,
        columns: [
          KanbanColumn(
            id: 1,
            name: "Archived",
            cards: [],
            maxCards: 0,
          ),
        ],
        gitUrl: SingletonData().kanbanBoard.gitUrl,
        gitUser: SingletonData().kanbanBoard.gitUser,
        gitRepo: SingletonData().kanbanBoard.gitRepo,
        gitString: SingletonData().kanbanBoard.gitString,
      );

      // Save the new archive board
      await SingletonData().gitHubService.saveBoard(
        archiveBoard.toJson(),
        message: "Created new archive board: $targetArchiveBoardName",
      );
    }

    // Add card to the archive board
    archiveBoard.columns.first.cards.add(card);

    // Save the updated archive board
    await SingletonData().gitHubService.saveBoard(
      archiveBoard.toJson(),
      message: "Archived card ${card.id} to $targetArchiveBoardName",
    );

    // Remove card from source board only after successfully archiving
    for (var column in SingletonData().kanbanBoard.columns) {
      column.cards.removeWhere((c) => c.id == card.id);
    }

    // Save the updated source board
    await SingletonData().gitHubService.saveBoard(
      SingletonData().kanbanBoard.toJson(),
      message:
      "Removed card ${card.id} from ${SingletonData().kanbanBoard.name}",
    );

    // Notify the user
    SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text("Archived card ${card.id} successfully")),
    );

    // Refresh the Kanban view
    SingletonData().kanbanViewSetState?.call();
  } catch (e) {
    print("Error archiving card ${card.id}: $e");
    SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text("Failed to archive card: $e")),
    );
  }
}


bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}


