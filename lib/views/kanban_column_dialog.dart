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

  @override
  void initState() {
    super.initState();
    if (widget.column != null) {
      _titleController.text = widget.column!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: singletonData.kPrimaryColor,
      title: Text(widget.column == null ? 'Add Column' : 'Edit Column'),
      content: TextField(
        controller: _titleController,
        decoration: const InputDecoration(labelText: 'Column Title'),
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
            final title = _titleController.text;
            if (title.isNotEmpty) {
              final column = KanbanColumn(
                id: widget.column?.id ?? DateTime.now().millisecondsSinceEpoch.toInt(),
                name: title,
                cards: widget.column?.cards ?? [],
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