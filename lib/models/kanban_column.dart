
import 'kanban_card.dart';

class KanbanColumn {
  final int id;
  final String name;
  final List<KanbanCard> cards;
  final int maxCards;

  KanbanColumn({
    required this.id,
    required this.name,
    required this.cards,
    required this.maxCards,
  });

  factory KanbanColumn.fromJson(Map<String, dynamic> json) {
    var list = json['cards'] as List;
    List<KanbanCard> cardList = list.map((i) => KanbanCard.fromJson(i)).toList();

    return KanbanColumn(
      id: json['id'],
      name: json['name'] ?? '',
      cards: cardList,
      maxCards: json['maxCards'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cards': cards.map((e) => e.toJson()).toList(),
      'maxCards': maxCards,
    };
  }
}
