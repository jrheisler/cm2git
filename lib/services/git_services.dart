import 'dart:convert';
import 'dart:html'; // For browser debugging
import 'package:http/http.dart' as http;

import '../models/kanban_board.dart';

//Explanation
// GitHubService Class: This class handles the interaction with GitHub's API.
// It includes methods to create branches, commits, pull requests, and tags.
// Workflow:
// Create a Branch: Creates a new branch from a base branch.
// Create a Commit: Commits changes to the new branch.
// Push Branch: (Implicit in commit step)
// Create Pull Request: Opens a pull request for the new branch.
// Create Tag: Tags the latest commit in the base branch.

//Example Workflow Summary
// Create Change Package: Obtain CPN-12345.
// Create Branch: git checkout -b feature/CPN-12345.
// Implement Changes: Edit files, commit with message CPN-12345: [description].
// Push Branch: git push origin feature/CPN-12345.
// Create PR: Title CPN-12345: [description], link to CPN.
// Code Review: Approve or request changes.
// Merge PR: git merge --no-ff feature/CPN-12345.
// Tag Change: git tag -a v1.0.0-CPN-12345 -m "Release including CPN-12345".
// Close Change Package: Update status in change management system.
// Documentation and Deployment: Document changes, deploy as needed.


class GitHubService {
  final String _token;
  final String _repoOwner;
  final String _repoName;
  final String _repoUrl;

  GitHubService(this._token, this._repoOwner, this._repoName, this._repoUrl);

  Future<List<String>> listKanbanBoards() async {
    final url = '$_repoUrl/repos/$_repoOwner/$_repoName/contents/kanban_boards';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'token $_token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> files = json.decode(response.body);
      return files.map((file) => file["name"] as String).toList();
    } else {
      throw Exception("Failed to list Kanban boards");
    }
  }
  bool isValidBase64(String base64String) {
    final sanitized = sanitizeBase64(base64String);
    final base64Pattern = r'^[A-Za-z0-9+/]*={0,2}$';
    return RegExp(base64Pattern).hasMatch(sanitized);
  }

  String sanitizeBase64(String base64String) {
    return base64String.replaceAll('\n', '').replaceAll('\r', '').trim();
  }


  Future<Map<String, dynamic>> fetchBoard(String downloadUrl) async {
    final url =
        'https://api.github.com/repos/jrheisler/cm2git/contents/kanban_boards/$downloadUrl';
    print("Fetching URL: $url");

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final responseJson = jsonDecode(response.body);

        // Ensure the content field is available
        if (responseJson['content'] == null) {
          throw Exception("Content field is null or missing.");
        }

        // Clean and decode Base64 content
        final rawBase64Content = responseJson['content'] as String;
        final cleanBase64Content = rawBase64Content.replaceAll(RegExp(r'\s+'), '');

        print("Cleaned Base64 Content Length: ${cleanBase64Content.length}");
        print("Cleaned Base64 Content Preview: ${cleanBase64Content.substring(0, 100)}");

        // Decode Base64 content
        final decodedBytes = base64.decode(cleanBase64Content);
        final decodedContent = utf8.decode(decodedBytes);

        print("Decoded Content Length: ${decodedContent.length}");
        print("Decoded Content Preview: ${decodedContent.substring(0, 100)}");

        // Parse JSON
        final boardData = jsonDecode(decodedContent) as Map<String, dynamic>;

        // Log all top-level keys
        print("Parsed JSON Keys: ${boardData.keys}");

        // Validate 'columns' key
        if (!boardData.containsKey('columns') || boardData['columns'] == null) {
          throw Exception("Missing or null 'columns' field in parsed JSON.");
        }
        if (boardData['columns'] is! List) {
          throw Exception("'columns' field is not a List. Found: ${boardData['columns'].runtimeType}");
        }

        // Debug each column
        for (var i = 0; i < (boardData['columns'] as List).length; i++) {
          final column = (boardData['columns'] as List)[i];
          print("Column $i: ${column['name']}, Cards Count: ${column['cards'].length}");
        }

        print(113);
        printBoardData(boardData);
        return boardData;
      } catch (e) {
        print("Error processing response: $e");
        throw Exception("Failed to process Kanban board response: $e");
      }
    } else {
      throw Exception("Failed to fetch Kanban board: ${response.statusCode}");
    }
  }

  /// Helper to check if a string is valid Base64
  bool isBase64(String input) {
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Regex.hasMatch(input);
  }

  Future<void> saveBoard(Map<String, dynamic> board, {required String message}) async {
    final boardName = board["name"];
    final path = 'kanban_boards/$boardName.json';
    final content = base64.encode(utf8.encode(json.encode(board)));

    // Fetch the current SHA for the file
    final sha = await _getFileSha(path);
    print('$boardName');
    final response = await http.put(
      Uri.parse('$_repoUrl/repos/$_repoOwner/$_repoName/contents/$path'),
      headers: {
        'Authorization': 'token $_token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "message": message,
        "content": content,
        if (sha != null) "sha": sha, // Include the SHA if the file already exists
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Kanban board saved successfully");
    } else {
      throw Exception("Failed to save Kanban board - ${response.statusCode} - ${response.body}");
    }
  }
  Future<String?> fetchFileSha(String path) async {
    try {
      final file = await fetchFile(path); // Assumes this fetches the file metadata
      final sha = file['sha'];
      print("Fetched SHA for $path: $sha");
      return sha;
    } catch (e) {
      print("Error fetching SHA for $path: $e");
      return null; // File doesn't exist or error occurred
    }
  }



  Future<Map<String, dynamic>> fetchCard(String cardId) async {
    final url = '$_repoUrl/repos/$_repoOwner/$_repoName/contents/cards/$cardId.json';
    print("Fetching card URL: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'token $_token'},
    );

    if (response.statusCode == 200) {
      try {
        // Parse the JSON response
        final responseJson = json.decode(response.body);
        print("Response JSON Keys: ${responseJson.keys}");
        final rawBase64Content = responseJson["content"];
        print("Raw Base64 Content Length: ${rawBase64Content.length}");
        print("Raw Base64 Content Preview: ${rawBase64Content.substring(0, 100)}");

        // Clean the Base64 content
        final cleanBase64Content = rawBase64Content.replaceAll(RegExp(r'\s+'), '');
        print("Cleaned Base64 Content Length: ${cleanBase64Content.length}");
        print("Cleaned Base64 Content Preview: ${cleanBase64Content.substring(0, 100)}");

        // Decode the Base64 content
        final decodedBytes = base64.decode(cleanBase64Content);
        print("Decoded Bytes Length: ${decodedBytes.length}");
        print("Decoded Bytes Preview: ${utf8.decode(decodedBytes).substring(0, 100)}");

        // Decode the UTF-8 content
        final decodedContent = json.decode(utf8.decode(decodedBytes));
        print("Decoded JSON Keys: ${decodedContent.keys}");

        return decodedContent;
      } catch (e) {
        print("Error decoding card content: $e");
        throw Exception("Failed to decode card content: $e");
      }
    } else {
      print("Failed to fetch card with status code: ${response.statusCode}");
      throw Exception("Failed to fetch card");
    }
  }


  Future<void> saveCard(String cardId, Map<String, dynamic> card, {required String message}) async {
    final url = '$_repoUrl/repos/$_repoOwner/$_repoName/contents/cards/$cardId.json';
    final content = base64.encode(utf8.encode(json.encode(card)));

    // Attempt to save the card
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final requestBody = {
          "message": message,
          "content": content,
          if (card["sha"].isNotEmpty) "sha": card["sha"],
        };

        final response = await http.put(
          Uri.parse(url),
          headers: {
            'Authorization': 'token $_token',
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          print("Card saved successfully: $cardId");
          return;
        } else if (response.statusCode == 409) {
          // Handle conflict by fetching the latest SHA
          final latestSha = await fetchFileSha('cards/$cardId.json');
          card["sha"] = latestSha ?? "";
          print("Conflict detected. Retrying with SHA: $latestSha");
        } else {
          throw Exception("Failed to save card: ${response.body}");
        }
      } catch (e) {
        if (attempt == 2) {
          throw Exception("Error saving card $cardId after multiple retries: $e");
        }
      }
    }
  }


  // Helper: Make authenticated requests
  Future<http.Response> _makeRequest(
      String method,
      String endpoint, {
        Map<String, dynamic>? body,
      }) async {
    final url = Uri.parse('$_repoUrl/repos/$_repoOwner/$_repoName/$endpoint');
    final headers = {
      'Authorization': 'token $_token',
      'Accept': 'application/vnd.github+json',
    };

    switch (method) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'PUT':
        return await http.put(url, headers: headers, body: jsonEncode(body));
      case 'POST':
        return await http.post(url, headers: headers, body: jsonEncode(body));
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // Fetch file content
  Future<Map<String, dynamic>> fetchFile(String path) async {
    final response = await _makeRequest('GET', 'contents/$path');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch file $path: ${response.body}');
    }
  }

  // Create or update file
  Future<void> updateFile({
    required String path,
    required String content,
    required String message,
    String? sha,
  }) async {
    final body = {
      'message': message,
      'content': base64Encode(utf8.encode(content)),
      if (sha != null) 'sha': sha,
    };

    final response = await _makeRequest('PUT', 'contents/$path', body: body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update file $path: ${response.body}');
    }
  }

  // Create a branch
  Future<void> createBranch(String newBranch, String baseBranch) async {
    final baseBranchInfo = await fetchBranch(baseBranch);
    final sha = baseBranchInfo['commit']['sha'];

    final response = await _makeRequest('POST', 'git/refs', body: {
      'ref': 'refs/heads/$newBranch',
      'sha': sha,
    });

    if (response.statusCode != 201) {
      throw Exception('Failed to create branch $newBranch: ${response.body}');
    }
  }

  // Fetch branch info
  Future<Map<String, dynamic>> fetchBranch(String branch) async {
    final response = await _makeRequest('GET', 'branches/$branch');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch branch $branch: ${response.body}');
    }
  }

  // List commits for a file
  Future<List<Map<String, dynamic>>> listCommits({String? path}) async {
    final endpoint = path != null ? 'commits?path=$path' : 'commits';
    final response = await _makeRequest('GET', endpoint);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to list commits: ${response.body}');
    }
  }
  Future<String?> _getFileSha(String path) async {
    try {
      final file = await fetchFile(path);
      return file['sha'];
    } catch (e) {
      return null; // File doesn't exist
    }
  }

  Future<List<GitCommit>> getCommits() async {
    final url = '$_repoUrl/repos/$_repoOwner/$_repoName/commits';
    final response = await http.get(
      Uri.parse(url),
        //headers: {'Authorization': 'token $t'},
      headers: {'Authorization': 'token $_token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> commitList = json.decode(response.body);
      return commitList.map((commit) => GitCommit.fromJson(commit)).toList();
    } else {
      throw Exception('Failed to load the commits ${response.statusCode}');
    }
  }

  Future<List<GitPullRequest>> getPullRequests() async {
    final url = '$_repoUrl/repos/$_repoOwner/$_repoName/pulls';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'token $_token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> pullRequestList = json.decode(response.body);
      return pullRequestList.map((pr) => GitPullRequest.fromJson(pr)).toList();
    } else {
      throw Exception('Failed to load pull requests');
    }
  }

  Future<List<GitBranch>> getBranches() async {
    final url = '$_repoUrl/repos/$_repoOwner/$_repoName/branches';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'token $_token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> branchList = json.decode(response.body);

      return branchList.map((branch) => GitBranch.fromJson(branch)).toList();
    } else {
      throw Exception('Failed to load branches');
    }
  }

  //sample
  //await gitHubService.createPullRequest(
  //     title: 'New Feature',
  //     head: 'feature-branch',
  //     base: 'main',
  //     body: 'This pull request introduces a new feature...',
  //   );

  Future<void> createPullRequest({
    required String title,
    required String head,
    required String base,
    required String body,
  }) async {
    final url = '$_repoUrl/repos/$_repoOwner/$_repoName/pulls';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'token $_token',
        'Accept': 'application/vnd.github.v3+json',
      },
      body: json.encode({
        'title': title,
        'head': head,
        'base': base,
        'body': body,
      }),
    );

    if (response.statusCode == 201) {
      print('Pull request created successfully');
    } else {
      print('Failed to create pull request: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}
void printBoardData(Map<String, dynamic> data, {String prefix = ''}) {
  data.forEach((key, value) {
    final fullKey = prefix.isNotEmpty ? '$prefix.$key' : key;
    if (value is Map<String, dynamic>) {
      print('Map: $fullKey');
      printBoardData(value, prefix: fullKey); // Recursively print nested map
    } else if (value is List) {
      print('List: $fullKey (Length: ${value.length})');
      for (var i = 0; i < value.length; i++) {
        print('$fullKey[$i]: ${value[i] is Map<String, dynamic> ? "Nested Map" : value[i]}');
        if (value[i] is Map<String, dynamic>) {
          printBoardData(value[i] as Map<String, dynamic>, prefix: '$fullKey[$i]');
        }
      }
    } else {
      print('$fullKey: $value');
    }
  });
}


class GitBranch {
  String name;
  GitCommit commit;
  bool protected;

  GitBranch({
    required this.name,
    required this.commit,
    required this.protected,
  });

  factory GitBranch.fromJson(Map<String, dynamic> json) {
    return GitBranch(
      name: json['name'] ?? '',
      commit: GitCommit.fromJson(json['commit']) ,
      protected: json['protected'] ?? '',
    );
  }
}




class GitPullRequest {
  int id;
  int number;
  String state;
  String title;
  User user;
  String body;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? closedAt;
  DateTime? mergedAt;

  GitPullRequest({
    required this.id,
    required this.number,
    required this.state,
    required this.title,
    required this.user,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
    this.mergedAt,
  });

  factory GitPullRequest.fromJson(Map<String, dynamic> json) {
    return GitPullRequest(
      id: json['id'],
      number: json['number'],
      state: json['state'],
      title: json['title'],
      user: User.fromJson(json['user']),
      body: json['body'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at']) : null,
      mergedAt: json['merged_at'] != null ? DateTime.parse(json['merged_at']) : null,
    );
  }
}

class GitCommit {
  String sha;
  String nodeId;
  CommitDetail commit;
  String url;
  String htmlUrl;
  String commentsUrl;
  User author;
  User committer;
  List<Parent> parents;

  GitCommit({
    required this.sha,
    required this.nodeId,
    required this.commit,
    required this.url,
    required this.htmlUrl,
    required this.commentsUrl,
    required this.author,
    required this.committer,
    required this.parents,
  });

  factory GitCommit.fromJson(Map<String, dynamic> json) {
    return GitCommit(
      sha: json['sha']?? '',
      nodeId: json['node_id']?? '',
      commit: CommitDetail.fromJson(json['commit'], json['sha']),
      url: json['url']?? '',
      htmlUrl: json['html_url']?? '',
      commentsUrl: json['comments_url']?? '',
      author: User.fromJson(json['author']?? ''),
      committer: User.fromJson(json['committer']?? ''),
      parents: (json['parents'] as List)
          .map((parent) => Parent.fromJson(parent))
          .toList() ?? [],
    );
  }
}

class Author {
  String name;
  String email;
  String date;

  Author({
    required this.name,
    required this.email,
    required this.date,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['name'],
      email: json['email'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'date': date,
  };
}

class Committer {
  String name;
  String email;
  String date;

  Committer({
    required this.name,
    required this.email,
    required this.date,
  });

  factory Committer.fromJson(Map<String, dynamic> json) {
    return Committer(
      name: json['name']?? '',
      email: json['email']?? '',
      date: json['date']?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'date': date,
  };
}

class Tree {
  String sha;
  String url;

  Tree({
    required this.sha,
    required this.url,
  });

  factory Tree.fromJson(Map<String, dynamic> json) {
    return Tree(
      sha: json['sha']?? '',
      url: json['url']?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'sha': sha,
    'url': url,
  };
}

class Verification {
  bool verified;
  String reason;
  String? signature;
  String? payload;

  Verification({
    required this.verified,
    required this.reason,
    this.signature,
    this.payload,
  });

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      verified: json['verified']?? '',
      reason: json['reason']?? '',
      signature: json['signature']?? '',
      payload: json['payload']?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'verified': verified,
    'reason': reason,
    'signature': signature,
    'payload': payload,
  };
}

class CommitDetail {
  Author author;
  Committer committer;
  String message;
  Tree tree;
  String url;
  int commentCount;
  Verification verification;
  String sha;

  CommitDetail({
    required this.author,
    required this.committer,
    required this.message,
    required this.tree,
    required this.url,
    required this.commentCount,
    required this.verification,
    required this.sha,
  });

  Map<String, dynamic> toJson() => {
    'author': author.toJson(),
    'committer': committer.toJson(),
    'message': message,
    'tree': tree.toJson(),
    'url': url,
    'commentCount': commentCount,
    'verification': verification.toJson(),
    'sha': sha,
  };

  factory CommitDetail.fromJson(Map<String, dynamic> json, String sha) {
    return CommitDetail(
      author: Author.fromJson(json['author']?? ''),
      committer: Committer.fromJson(json['committer'] ?? ''),
      message: json['message']?? '',
      tree: Tree.fromJson(json['tree']?? ''),
      url: json['url']?? '',
      commentCount: json['comment_count']?? '',
      verification: Verification.fromJson(json['verification']?? ''),
      sha: sha ?? '',
    );
  }
}


class User {
  String login;
  int id;
  String nodeId;
  String avatarUrl;
  String gravatarId;
  String url;
  String htmlUrl;
  String followersUrl;
  String followingUrl;
  String gistsUrl;
  String starredUrl;
  String subscriptionsUrl;
  String organizationsUrl;
  String reposUrl;
  String eventsUrl;
  String receivedEventsUrl;
  String type;
  bool siteAdmin;

  User({
    required this.login,
    required this.id,
    required this.nodeId,
    required this.avatarUrl,
    required this.gravatarId,
    required this.url,
    required this.htmlUrl,
    required this.followersUrl,
    required this.followingUrl,
    required this.gistsUrl,
    required this.starredUrl,
    required this.subscriptionsUrl,
    required this.organizationsUrl,
    required this.reposUrl,
    required this.eventsUrl,
    required this.receivedEventsUrl,
    required this.type,
    required this.siteAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['login'],
      id: json['id'],
      nodeId: json['node_id'],
      avatarUrl: json['avatar_url'],
      gravatarId: json['gravatar_id'],
      url: json['url'],
      htmlUrl: json['html_url'],
      followersUrl: json['followers_url'],
      followingUrl: json['following_url'],
      gistsUrl: json['gists_url'],
      starredUrl: json['starred_url'],
      subscriptionsUrl: json['subscriptions_url'],
      organizationsUrl: json['organizations_url'],
      reposUrl: json['repos_url'],
      eventsUrl: json['events_url'],
      receivedEventsUrl: json['received_events_url'],
      type: json['type'],
      siteAdmin: json['site_admin'],
    );
  }
}

class Parent {
  String sha;
  String url;
  String htmlUrl;

  Parent({
    required this.sha,
    required this.url,
    required this.htmlUrl,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      sha: json['sha'],
      url: json['url'],
      htmlUrl: json['html_url'],
    );
  }
}

// Parsing function for the entire list of commits
List<GitCommit> parseGitCommits(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<GitCommit>((json) => GitCommit.fromJson(json)).toList();
}

/*
class GitHubCommit {
  final String sha;
  final String message;
  final List<GitHubFile> files;

  GitHubCommit({required this.sha, required this.message, required this.files});

  factory GitHubCommit.fromJson(Map<String, dynamic> json) {
    print(json);
    final files = (json['files'] as List)
        .map((fileJson) => GitHubFile.fromJson(fileJson))
        .toList();
    return GitHubCommit(
      sha: json['sha'],
      message: json['commit']['message'],
      files: files,
    );
  }
}

class GitHubFile {
  final String filename;
  final String status;

  GitHubFile({required this.filename, required this.status});

  factory GitHubFile.fromJson(Map<String, dynamic> json) {
    return GitHubFile(
      filename: json['filename'],
      status: json['status'],
    );
  }
}
*/
/*

class GitHubService {
  final String _token;
  final String _repoOwner;
  final String _repoName;

  GitHubService(this._token, this._repoOwner, this._repoName);

  Future<List<GitHubCommit>> getCommits() async {
    final url = 'https://api.github.com/repos/$_repoOwner/$_repoName/commits';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'token $_token'},
    );
    print('$url token $_token');
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);
      final List<dynamic> commitList = json.decode(response.body);
      return commitList.map((commit) => GitHubCommit.fromJson(commit)).toList();
    } else {
      throw Exception('Failed to load commits');
    }
  }
}

class GitHubCommit {
  final String sha;
  final String message;
  final List<GitHubFile> files;

  GitHubCommit({required this.sha, required this.message, required this.files});

  factory GitHubCommit.fromJson(Map<String, dynamic> json) {
    final files = (json['files'] as List)
        .map((fileJson) => GitHubFile.fromJson(fileJson))
        .toList();
    return GitHubCommit(
      sha: json['sha'],
      message: json['commit']['message'],
      files: files,
    );
  }
}

class GitHubFile {
  final String filename;
  final String status;

  GitHubFile({required this.filename, required this.status});

  factory GitHubFile.fromJson(Map<String, dynamic> json) {
    return GitHubFile(
      filename: json['filename'],
      status: json['status'],
    );
  }
}
*/
