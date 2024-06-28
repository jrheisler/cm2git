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
}
