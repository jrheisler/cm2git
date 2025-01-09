import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/kanban_card.dart';
import '../services/helpers.dart';
import '../services/local_storage_helper.dart';
import '../services/mili.dart';
import '../services/singleton_data.dart';
import 'delete_dialog.dart';
import 'kanban_card_dialog.dart';

class KanbanCardWidget extends StatefulWidget {
  final KanbanCard card;

  KanbanCardWidget({
    required this.card,
  });

  @override
  _KanbanCardWidgetState createState() => _KanbanCardWidgetState();
}


class _KanbanCardWidgetState extends State<KanbanCardWidget> {
  bool _isHovered = false; // To track if the card is hovered (mouse down)

  @override
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _editCard,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Card(
          color: widget.card.blocked
              ? Colors.redAccent
              : isSameDay(widget.card.needDate, SingletonData().dueDate)
              ? Colors.blueGrey
              : SingletonData().kPrimaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Allow the widget to shrink within constraints
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ID: ${widget.card.id}'),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(context),
                    ),
                  ],
                ),
                Text('Title: ${widget.card.title}'),
                const Divider(),
                Text('Description: ${widget.card.description}'),
                const Divider(),
                Text('Assignee: ${widget.card.assignee}'),
                const Divider(),
                Text('Status: ${widget.card.status}'),
                const Divider(),
                Text('Create Date: ${convertMilliToDateTime(widget.card.id)}'),
                const Divider(),
                widget.card.needDate!.isBefore(DateTime.now())
                    ? Text(
                  'Need Date: ${DateFormat('yyyy-MM-dd').format(widget.card.needDate!)}',
                  style: widget.card.blocked
                      ? const TextStyle(color: Colors.black)
                      : const TextStyle(color: Colors.redAccent),
                )
                    : Text(
                    'Need Date: ${DateFormat('yyyy-MM-dd').format(widget.card.needDate!)}'),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _copyToClipboard(BuildContext context) {
    final text = 'Card ID: ${widget.card.id}';
    Clipboard.setData(ClipboardData(text: text));
    SingletonData().scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text('Copied to clipboard: $text')),
    );
  }

  void _editCard() {
    showDialog(
      context: context,
      builder: (context) {
        return KanbanCardDialog(
          kanban: SingletonData().kanbanBoard,
          card: widget.card,
          columnName: widget.card.status,
          onDelete: () async {
            await showDeleteDialog(context, () {
              for (var col in SingletonData().kanbanBoard.columns) {
                col.cards.remove(widget.card);
              }
              LocalStorageHelper.saveValue(
                'kanban_board',
                jsonEncode(SingletonData().kanbanBoard.toJson()),
              );
              widget.card.isModified = true;

              SingletonData().markSaveNeeded();
              Navigator.of(context).pop();
            });
            if (mounted) setState(() {});
            SingletonData().markSaveNeeded();
          },
          onSave: (updatedCard) {
            if (mounted) {
              setState(() {
                var column = SingletonData().kanbanBoard.columns
                    .firstWhere((column) => column.name == updatedCard.status);

                // Find the index of the card to be updated
                int index =
                column.cards.indexWhere((c) => c.id == updatedCard.id);

                if (index != -1) {
                  // Remove the card from the list
                  column.cards.removeAt(index);

                  // Insert the updated card back at the same index
                  column.cards.insert(index, updatedCard);
                }
                LocalStorageHelper.saveValue(
                  'kanban_board',
                  jsonEncode(SingletonData().kanbanBoard.toJson()),
                );
                updatedCard.isModified = true;
                SingletonData().markSaveNeeded();
              });
            }
          },
        );
      },
    );
  }
}