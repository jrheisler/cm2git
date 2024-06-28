import 'package:flutter/material.dart';

import '../main.dart';
import '../models/kanban_column.dart';

class ColumnManagementDialog extends StatelessWidget {
  final List<KanbanColumn> columns;
  final VoidCallback onAddColumn;
  final Function(KanbanColumn) onEditColumn;
  final Function(KanbanColumn) onDeleteColumn;

  ColumnManagementDialog({
    required this.columns,
    required this.onAddColumn,
    required this.onEditColumn,
    required this.onDeleteColumn,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: singletonData.kPrimaryColor,
      title: const Text('Manage Columns'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: columns.length,
          itemBuilder: (context, index) {
            final column = columns[index];
            return ListTile(
              title: Text(column.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onEditColumn(column);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      onDeleteColumn(column);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: onAddColumn,
          child: const Text('Add Column'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
