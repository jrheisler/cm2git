import 'kanban_card.dart';
import 'kanban_column.dart';

class KanbanBoard {
  String name;
  List<KanbanColumn> columns;
  String gitUrl;
  String gitRepo;
  String gitUser;
  String gitString;

  KanbanBoard({
    required this.columns,
    required this.name,
    required this.gitUrl,
    required this.gitUser,
    required this.gitRepo,
    required this.gitString,
  });

  factory KanbanBoard.fromJson(Map<String, dynamic> json) {
    return KanbanBoard(
      columns: (json['columns'] as List)
          .map((column) => KanbanColumn.fromJson(column))
          .toList(),
      name: json['name'] ?? 'Kanban',
      gitUrl: json['gitUrl'] ?? 'https://api.github.com',
      gitUser: json['gitUser'] ?? 'jrheisler',
      gitRepo: json['gitRepo'] ?? 'cm2git',
      gitString: json['gitString'] ??
          'iru]-24l;sfLJKPJasd2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dhjksakilkj809ja09sL',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'columns': columns.map((column) => column.toJson()).toList(),
    'gitUrl': gitUrl,
    'gitRepo': gitRepo,
    'gitUser': gitUser,
    'gitString': gitString,
  };

  factory KanbanBoard.fromData() {
    try {
      return KanbanBoard(
        name: 'Main Kanban',
        gitUrl: 'https://api.github.com',
        gitRepo: 'cm2git',
        gitUser: 'jrheisler',
        gitString:
        'iru]-24l;sfLJKPJasd2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dhjksakilkj809ja09sL',
        columns: [
          KanbanColumn(id: 1, name: 'Product Backlog', cards: [], maxCards: 0),
          KanbanColumn(id: 2, name: 'Sprint Backlog', cards: [], maxCards: 0),
          KanbanColumn(id: 3, name: 'WIP', cards: [], maxCards: 0),
          KanbanColumn(id: 4, name: 'Testing', cards: [], maxCards: 0),
          KanbanColumn(id: 5, name: 'Done', cards: [], maxCards: 0),
        ],
      );
    } catch (e) {
      return KanbanBoard(
        name: 'Main Kanban',
        gitUrl: 'https://api.github.com',
        gitUser: 'jrheisler',
        gitString:
        'iru]-24l;sfLJKPJasd2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dhjksakilkj809ja09sL',
        gitRepo: 'cm2git',
        columns: [],
      );
    }
  }

  // Method to retrieve all modified cards across columns
  List<KanbanCard> getModifiedCards() {
    return columns.expand((column) => column.getModifiedCards()).toList();
  }
}
