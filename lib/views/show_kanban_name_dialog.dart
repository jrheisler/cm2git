import 'package:cm_2_git/models/kanban_board.dart';
import 'package:flutter/material.dart';

import '../common/constants.dart';
import '../main.dart';
import '../services/singleton_data.dart';

Future<KanbanBoard?> showNameDialog(BuildContext context, KanbanBoard kanban) async {
  TextEditingController _nameController = TextEditingController(text: kanban.name);
  TextEditingController _gitStringController = TextEditingController(text: retrieveString(kanban.gitString));
  TextEditingController _gitUrlController = TextEditingController(text: kanban.gitUrl);
  TextEditingController _gitUserController = TextEditingController(text: kanban.gitUser);
  TextEditingController _gitRepoController = TextEditingController(text: kanban.gitRepo);
  return showDialog<KanbanBoard>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: singletonData.kPrimaryColor,
        title: const Text("This Kanban's Information"),
        content: SizedBox(
          height: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kanban Name:'),
              TextField(
                onChanged: (value) {
                  kanban.name = value;
                },
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Kanban Name',
                ),
              ),
              const SizedBox(height: 20,),
              const Text('Git URL:'),
              TextField(
                onChanged: (value) {
                  kanban.gitUrl = value;
                },
                controller: _gitUrlController,
                decoration: const InputDecoration(
                  hintText: 'https://api.github.com/',
                ),
              ),
              const SizedBox(height: 20,),
              const Text('Git User:'),
              TextField(
                onChanged: (value) {
                  kanban.gitUser = value;
                },
                controller: _gitUserController,
                decoration: const InputDecoration(
                  hintText: 'Git User',
                ),
              ),
              const SizedBox(height: 20,),
              const Text('Git Repo:'),
              TextField(
                onChanged: (value) {
                  kanban.gitRepo = value;
                },
                controller: _gitRepoController,
                decoration: const InputDecoration(
                  hintText: 'Repo Name',
                ),
              ),
              const SizedBox(height: 20,),
              const Text('Git Token:'),
              TextField(
                obscureText: true,
                onChanged: (value) {
                  kanban.gitString = 'iru]-24l;sfLJKPJasd2${value}dhjksakilkj809ja09sL';
                },
                controller: _gitStringController,
                decoration: const InputDecoration(
                  hintText: 'Git Token',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context, kanban);  // Return the text to the caller
            },
          ),
        ],
      );
    },
  );
}
