
import 'kanban_card.dart';

class KanbanColumn {
  final int id;
  final String name;
  final List<KanbanCard> cards;

  KanbanColumn({
    required this.id,
    required this.name,
    required this.cards,
  });

  factory KanbanColumn.fromJson(Map<String, dynamic> json) {
    var list = json['cards'] as List;
    List<KanbanCard> cardList = list.map((i) => KanbanCard.fromJson(i)).toList();

    return KanbanColumn(
      id: json['id'],
      name: json['name'] ?? '',
      cards: cardList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cards': cards.map((e) => e.toJson()).toList(),
    };
  }
}
