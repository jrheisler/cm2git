import 'package:flutter/material.dart';

import '../main.dart';
import '../services/email.dart';
import '../services/git_services.dart';
import '../services/singleton_data.dart';

class BranchListScreen extends StatefulWidget {

  const BranchListScreen({super.key});

  @override
  _BranchListScreenState createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  late Future<List<GitBranch>> _branches;

  @override
  void initState() {
    super.initState();
    _branches = GitHubService(
        retrieveString(singletonData.cm2git), 'jrheisler', 'cm2git').getBranches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Branches'),
      ),
      body: FutureBuilder<List<GitBranch>>(
        future: _branches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].name),
                  subtitle: GestureDetector(
                    onTap: () => launchUrl(snapshot.data![index].commit.url),
                    child: const Text(
                      "URL Click to Open: url",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text("No branches found"));
          }
        },
      ),
    );
  }
}
