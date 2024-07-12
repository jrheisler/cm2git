import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For using Clipboard
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../main.dart';

class GitHubFileTree extends StatefulWidget {
  final String githubUser;
  final String githubToken;
  final String githubRepo;

  const GitHubFileTree({
    required this.githubUser,
    required this.githubToken,
    required this.githubRepo,
    Key? key,
  }) : super(key: key);

  @override
  _GitHubFileTreeState createState() => _GitHubFileTreeState();
}

class _GitHubFileTreeState extends State<GitHubFileTree> {
  Future<List<FileSystemEntity>>? _fileSystemFuture;
  String _fileContent = ''; // Define _fileContent variable here
  String _branchName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptBranchSelection();
    });
  }

  void _promptBranchSelection() async {
    List<String> branches = await _fetchBranches();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select a Branch"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: branches.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(branches[index]),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _branchName = branches[index];
                      _fileSystemFuture = fetchFileSystem(branches[index]);
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<List<String>> _fetchBranches() async {
    final response = await http.get(
      Uri.https('api.github.com', '/repos/${widget.githubUser}/${widget.githubRepo}/branches'),
      headers: {
        'Authorization': 'Bearer ${widget.githubToken}',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body) as List;
      return data.map((branch) => branch['name'] as String).toList();
    } else {
      print('Failed to load branches: ${response.statusCode} ${response.body}');
      return [];
    }
  }

  Future<List<FileSystemEntity>> fetchFileSystem(String branch) async {
    final response = await http.get(
      Uri.https('api.github.com', '/repos/${widget.githubUser}/${widget.githubRepo}/git/trees/$branch', {'recursive': 'true'}),
      headers: {
        'Authorization': 'Bearer ${widget.githubToken}',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<FileSystemEntity> fileSystem = [];
      for (var item in data['tree']) {
        if (item['type'] == 'blob' || item['type'] == 'tree') {
          fileSystem.add(FileSystemEntity(
            path: item['path'],
            type: item['type'],
            sha: item['sha'],
            url: item['url'],
          ));
        }
      }
      return fileSystem;
    } else {
      throw Exception('Failed to load file system for branch $branch');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Tree for ${widget.githubRepo} / $_branchName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _promptBranchSelection,
          ),
        ],
      ),
      body: _fileSystemFuture == null
          ? const SizedBox.shrink()
          : FutureBuilder<List<FileSystemEntity>>(
        future: _fileSystemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return ListView(
              children: buildDirectoryStructure(snapshot.data!, ''),
            );
          }
        },
      ),
    );
  }

  List<Widget> buildDirectoryStructure(List<FileSystemEntity> fileSystem, String path) {
    var filteredFiles = fileSystem.where((file) => file.path.startsWith(path)).toList();
    Map<String, List<FileSystemEntity>> directoryMap = {};

    for (var file in filteredFiles) {
      var parts = file.path.substring(path.length).split('/');
      var firstPart = parts.first;
      if (!directoryMap.containsKey(firstPart)) {
        directoryMap[firstPart] = [];
      }
      directoryMap[firstPart]!.add(file);
    }

    return directoryMap.entries.map<Widget>((entry) {
      if (entry.value.any((file) => file.path.substring(path.length + entry.key.length).contains('/'))) {
        // It's a directory
        return ExpansionTile(
          leading: const Icon(Icons.folder),
          title: Text(entry.key),
          children: buildDirectoryStructure(fileSystem, '$path${entry.key}/'),
        );
      } else {
        // It's a file
        return ListTile(
          leading: entry.value.first.type == 'tree'
              ? const Icon(Icons.folder)
              : const Icon(Icons.insert_drive_file),
          title: Text(entry.value.first.path.split('/').last),
          subtitle: entry.value.first.type == 'blob' ? Text('SHA: ${entry.value.first.sha}') : null,
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _showFileContent(entry.value.first.url),
          ),
          onTap: () => _openFile(entry.value.first.url),
        );
      }
    }).toList();
  }

  void _openFile(String url) {
    print('Opening file at $url');
  }

  void _showFileContent(String url) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: singletonData.kPrimaryColor,
          title: const Text('File Content'),
          content: FutureBuilder<String>(
            future: fetchFileContent(url),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                _fileContent = snapshot.data ?? ""; // Update the file content
                return SingleChildScrollView(
                  child: Text(_fileContent),
                );
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Copy'),
              onPressed: () {
                if (_fileContent.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: _fileContent));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Content copied to clipboard!')),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> fetchFileContent(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.githubToken}',
        'Accept': 'application/vnd.github.v3.raw',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load file content: ${response.statusCode}');
    }
  }
}

class FileSystemEntity {
  final String path;
  final String type;
  final String sha;
  final String url;

  FileSystemEntity({
    required this.path,
    required this.type,
    required this.sha,
    required this.url,
  });
}
