import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubCommitDetails {
  final String sha;
  final List<CommitFile> files;

  GitHubCommitDetails({required this.sha, required this.files});

  factory GitHubCommitDetails.fromJson(Map<String, dynamic> json) {
    var filesList = json['files'] as List;
    List<CommitFile> files = filesList.map((i) => CommitFile.fromJson(i)).toList();

    return GitHubCommitDetails(
      sha: json['sha'],
      files: files,
    );
  }
}

class CommitFile {
  final String filename;
  final String status;
  final int additions;
  final int deletions;
  final int changes;
  final String patch;

  CommitFile({
    required this.filename,
    required this.status,
    required this.additions,
    required this.deletions,
    required this.changes,
    required this.patch,
  });

  factory CommitFile.fromJson(Map<String, dynamic> json) {
    return CommitFile(
      filename: json['filename'],
      status: json['status'],
      additions: json['additions'],
      deletions: json['deletions'],
      changes: json['changes'],
      patch: json['patch'] ?? '',
    );
  }
}

Future<GitHubCommitDetails> fetchCommitDetails(String owner, String repo, String sha, String token) async {
  final response = await http.get(
    Uri.parse('https://api.github.com/repos/$owner/$repo/commits/$sha'),
    headers: {
      'Authorization': 'token $token',
    },
  );

  if (response.statusCode == 200) {
    return GitHubCommitDetails.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load commit details');
  }
}
