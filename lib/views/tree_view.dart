import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class GitHubFileTree extends StatefulWidget {
  final String githubUser;
  final String githubToken;
  final String githubRepo;

  GitHubFileTree({
    required this.githubUser,
    required this.githubToken,
    required this.githubRepo,
  });

  @override
  _GitHubFileTreeState createState() => _GitHubFileTreeState();
}

class _GitHubFileTreeState extends State<GitHubFileTree> {
  @override
  void initState() {
    super.initState();
    _showBranchesDialog(context);
  }

  void _showBranchesDialog(BuildContext context) async {
    try {
      List<String> branches = await _fetchBranches();
      if (branches.isNotEmpty) {
        String? selectedBranch = await _selectBranchDialog(context, branches);
        if (selectedBranch != null) {
          String commitSha = await _fetchBranchSha(selectedBranch);

          String treeSha = await _fetchTreeSha(commitSha);

          List<dynamic> fileTree = await _fetchFileTree(treeSha);
          _showFileTreeDialog(context, fileTree);
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<String>> _fetchBranches() async {
    final response = await http.get(
      Uri.https('api.github.com', '/repos/${widget.githubUser}/${widget.githubRepo}/branches'),
      headers: {
        'Authorization': 'token ${widget.githubToken}',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map<String>((branch) => branch['name'] as String).toList();
    } else {
      print('Failed to load branches: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load branches');
    }
  }

  Future<String?> _selectBranchDialog(BuildContext context, List<String> branches) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Branch'),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              children: branches.map((branch) {
                return ListTile(
                  title: Text(branch),
                  onTap: () {
                    Navigator.of(context).pop(branch);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<String> _fetchBranchSha(String branch) async {
    final response = await http.get(
      Uri.https('api.github.com', '/repos/${widget.githubUser}/${widget.githubRepo}/branches/$branch'),
      headers: {
        'Authorization': 'token ${widget.githubToken}',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['commit']['sha'];
    } else {
      print('Failed to load branch SHA: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load branch SHA');
    }
  }

  Future<String> _fetchTreeSha(String commitSha) async {
    final response = await http.get(
      Uri.https('api.github.com', '/repos/${widget.githubUser}/${widget.githubRepo}/git/commits/$commitSha'),
      headers: {
        'Authorization': 'token ${widget.githubToken}',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['tree']['sha'];
    } else {
      print('Failed to load commit: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load commit');
    }
  }

  Future<List<dynamic>> _fetchFileTree(String treeSha) async {
    final response = await http.get(
      Uri.https('api.github.com', '/repos/${widget.githubUser}/${widget.githubRepo}/git/trees/$treeSha', {
        'recursive': '1'
      }),
      headers: {
        'Authorization': 'token ${widget.githubToken}',
      },
    );


    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['tree'] is List<dynamic>) {
        return data['tree'];
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception('Failed to load file tree: ${response.statusCode} ${response.body}');
    }
  }

  void _showFileTreeDialog(BuildContext context, List<dynamic> fileTree) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('File Tree ${fileTree.length} entities'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Exit'),
            ),
          ],
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: _buildFileTree(fileTree),
          ),
        );
      },
    );
  }

  Widget _buildFileTree(List<dynamic> fileTree) {
    return ListView(
      children: fileTree.map<Widget>((file) {
        if (file is Map<String, dynamic>) {
          if (file['type'] == 'tree') {
            return ListTile(
              title: Text(file['path']),
              leading: const Icon(Icons.folder),
            );
          } else if (file['type'] == 'blob') {
            return ListTile(
              title: Text(file['path']),
              leading: const Icon(Icons.insert_drive_file),
            );
          }
        }
        return const ListTile(
          title: Text('Unknown file type'),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}


