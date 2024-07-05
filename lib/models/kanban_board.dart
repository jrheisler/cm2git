import 'kanban_column.dart';

class KanbanBoard {
  List<KanbanColumn> columns;

  KanbanBoard({required this.columns});

  factory KanbanBoard.fromJson(Map<String, dynamic> json) {
    return KanbanBoard(
      columns: (json['columns'] as List)
          .map((column) => KanbanColumn.fromJson(column))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'columns': columns.map((column) => column.toJson()).toList(),
  };

  factory KanbanBoard.fromData() {
    try {
      return KanbanBoard(columns: [
        KanbanColumn(id: 1, name: 'Product Backlog', cards: [], maxCards: 0),
        KanbanColumn(id: 2, name: 'Sprint Backlog', cards: [], maxCards: 0),
        KanbanColumn(id: 3,
            name: 'WIP',
            cards: [], maxCards: 0),
        KanbanColumn(id: 4,
            name: 'Testing',
            cards: [], maxCards: 0),
        KanbanColumn(id: 5,
            name: 'Done',
            cards: [], maxCards: 0)
      ]);
    } catch (e) {
      return KanbanBoard(columns: []);
    };
  }
}
