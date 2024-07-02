import 'kanban_card.dart';
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
        KanbanColumn(id: 1, name: 'Product Backlog', cards: [
          KanbanCard(id: 100,
              title: 'Sample',
              description: 'description',
              status: 'Product Backlog',
              assignee: 'assignee',
              sha: 'sha',
            needDate: DateTime.now(),
              blocked: false

          ),
          KanbanCard(id: 101,
              title: 'Sample',
              description: 'description',
              status: 'Product Backlog',
              assignee: 'assignee',
              sha: 'sha',
              needDate: DateTime.now(),
              blocked: false)
        ]),
        KanbanColumn(id: 2, name: 'Sprint Backlog', cards: [
          KanbanCard(id: 200,
              title: 'Sample',
              description: 'description',
              status: 'Sprint Backlog',
              assignee: 'assignee',
              sha: 'sha',
              needDate: DateTime.now(),     blocked: false),
          KanbanCard(id: 201,
              title: 'Sample',
              description: 'description',
              status: 'Sprint Backlog',
              assignee: 'assignee',
              sha: 'sha',
              needDate: DateTime.now(),     blocked: false)
        ]),
        KanbanColumn(id: 3,
            name: 'WIP',
            cards: [
              KanbanCard(id: 301,
                  title: 'Sample',
                  description: 'description',
                  status: 'WIP',
                  assignee: 'assignee',
                  sha: 'sha',
                  needDate: DateTime.now(),     blocked: false)
            ]),
        KanbanColumn(id: 4,
            name: 'Testing',
            cards: [
              KanbanCard(id: 401,
                  title: 'Sample',
                  description: 'description',
                  status: 'WIP',
                  assignee: 'assignee',
                  sha: 'sha',
                  needDate: DateTime.now(),
                  blocked: false)
            ]),
        KanbanColumn(id: 5,
            name: 'Done',
            cards: [
              KanbanCard(id: 501,
                  title: 'Sample',
                  description: 'description',
                  status: 'Done',
                  assignee: 'assignee',
                  sha: 'sha',
                  needDate: DateTime.now(),
                  blocked: false
              )
            ])
      ]);
    } catch (e) {
      return KanbanBoard(columns: []);
    };
  }
}
