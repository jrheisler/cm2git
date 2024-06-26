import 'package:flutter/material.dart';

Future<void> showDeleteDialog(BuildContext context, VoidCallback onDelete) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete the Card'),
        content: const Text('Are you sure you want to delete the card?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
              onDelete(); // Call the delete function
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
