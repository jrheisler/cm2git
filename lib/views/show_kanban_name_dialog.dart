import 'package:flutter/material.dart';

Future<String?> showNameDialog(BuildContext context, String name) async {
  TextEditingController _nameController = TextEditingController(text: name);

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter Name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Name',
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);  // Dismiss the dialog without returning text
            },
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context, _nameController.text);  // Return the text to the caller
            },
          ),
        ],
      );
    },
  );
}
