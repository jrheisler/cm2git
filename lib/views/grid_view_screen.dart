import 'package:flutter/material.dart';
import '../models/kanban_card.dart';
import '../services/singleton_data.dart';
import 'kanban_card_widget.dart';

class GridViewScreen extends StatefulWidget {
  @override
  _GridViewScreenState createState() => _GridViewScreenState();
}

class _GridViewScreenState extends State<GridViewScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedSort = 'title'; // Default sorting criteria

  @override
  Widget build(BuildContext context) {
    List<KanbanCard> allCards = SingletonData().getAllCards();
    _sortCards(allCards); // Ensure cards are sorted based on the selected criteria

    return Scaffold(
      body: Column(
        children: [
          // Toolbar for sorting
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            height: 40, // Toolbar height
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(8.0), // Add rounding here
            ),
            child: Row(
              children: [
                const Text(
                  'Sort by: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Ensure text is visible on the purple background
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedSort,
                  dropdownColor: Colors.deepPurpleAccent, // Matches the theme
                  items: const [
                    DropdownMenuItem(
                      value: 'title',
                      child: Text('Title', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 'status',
                      child: Text('Status', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 'assignee',
                      child: Text('Assignee', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 'needDate',
                      child: Text('Need Date', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSort = value!;
                      _sortCards(allCards);
                    });
                  },
                ),
                const SizedBox(width: 20),
                Text(
                  'Total Cards: ${SingletonData().getAllCards().length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Ensure text is visible on the purple background
                  ),
                ),
              ],
            ),
          ),

          // Grid of cards
          Expanded(
            child: Scrollbar(
              thickness: 12,
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allCards.length,
                  itemBuilder: (context, index) {
                    final card = allCards[index];
                    return GestureDetector(
                      onTap: () => _showCardDetails(context, card),
                      child: KanbanCardWidget(card: card),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sorting logic
  void _sortCards(List<KanbanCard> cards) {
    switch (_selectedSort) {
      case 'title':
        cards.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'status':
        cards.sort((a, b) => a.status.compareTo(b.status));
        break;
      case 'assignee':
        cards.sort((a, b) => a.assignee.compareTo(b.assignee));
        break;
      case 'needDate':
        cards.sort((a, b) => a.needDate.compareTo(b.needDate));
        break;
    }
  }

  // Show detailed view for a card
  void _showCardDetails(BuildContext context, KanbanCard card) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: KanbanCardWidget(card: card),
          ),
        );
      },
    );
  }
}
