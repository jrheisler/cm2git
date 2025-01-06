import 'package:flutter/material.dart';

import '../main.dart';
import '../models/kanban_column.dart';

class KanbanColumnDialog extends StatefulWidget {
  final KanbanColumn? column;
  final Function(KanbanColumn) onSave;
  final Function(KanbanColumn) onDelete;

  KanbanColumnDialog({this.column, required this.onSave, required this.onDelete});

  @override
  _KanbanColumnDialogState createState() => _KanbanColumnDialogState();
}

class _KanbanColumnDialogState extends State<KanbanColumnDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _maxCards = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.column != null) {
      _titleController.text = widget.column!.name;
      _maxCards.text = widget.column!.maxCards.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: singletonData.kPrimaryColor,
      title: Text(widget.column == null ? 'Add Column' : 'Edit Column'),
      content: SizedBox(
        height: 200,
        width: 400,
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Column Title', enabled: widget.column == null),
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: _maxCards,
              decoration: const InputDecoration(labelText: 'Max Cards 0 is unlimited'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_maxCards.text.isEmpty) {
              _maxCards.text = '0';
            }
            final title = _titleController.text;
            if (title.isNotEmpty) {
              final column = KanbanColumn(
                id: widget.column?.id ?? DateTime.now().millisecondsSinceEpoch.toInt(),
                name: title,
                cards: [],
                maxCards: int.parse(_maxCards.text),
              );
              widget.onSave(column);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}