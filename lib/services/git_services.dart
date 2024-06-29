import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

class GitHubApi {
  final String baseUrl = "https://api.github.com";
  final String token;

  GitHubApi(this.token);

  Map<String, String> get headers => {
        "Authorization": "token $token",
        "Accept": "application/vnd.github.v3+json",
      };

  // User Endpoints
  Future<http.Response> getAuthenticatedUser() async {
    return await http.get(Uri.parse('$baseUrl/user'), headers: headers);
  }

  Future<http.Response> getUser(String username) async {
    return await http.get(Uri.parse('$baseUrl/users/$username'),
        headers: headers);
  }

  Future<http.Response> getAllUsers() async {
    return await http.get(Uri.parse('$baseUrl/users'), headers: headers);
  }

  // Repository Endpoints
  Future<http.Response> getAuthenticatedUserRepos() async {
    return await http.get(Uri.parse('$baseUrl/user/repos'), headers: headers);
  }

  Future<http.Response> getUserRepos(String username) async {
    return await http.get(Uri.parse('$baseUrl/users/$username/repos'),
        headers: headers);
  }

  Future<http.Response> getRepo(String owner, String repo) async {
    return await http.get(Uri.parse('$baseUrl/repos/$owner/$repo'),
        headers: headers);
  }

  Future<http.Response> createRepo(Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse('$baseUrl/user/repos'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> deleteRepo(String owner, String repo) async {
    return await http.delete(Uri.parse('$baseUrl/repos/$owner/$repo'),
        headers: headers);
  }

  // Issues Endpoints
  Future<http.Response> getRepoIssues(String owner, String repo) async {
    return await http.get(Uri.parse('$baseUrl/repos/$owner/$repo/issues'),
        headers: headers);
  }

  Future<http.Response> getIssue(
      String owner, String repo, int issueNumber) async {
    return await http.get(
        Uri.parse('$baseUrl/repos/$owner/$repo/issues/$issueNumber'),
        headers: headers);
  }

  Future<http.Response> createIssue(
      String owner, String repo, Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse('$baseUrl/repos/$owner/$repo/issues'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> updateIssue(String owner, String repo, int issueNumber,
      Map<String, dynamic> data) async {
    return await http.patch(
      Uri.parse('$baseUrl/repos/$owner/$repo/issues/$issueNumber'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> getIssueComments(
      String owner, String repo, int issueNumber) async {
    return await http.get(
        Uri.parse('$baseUrl/repos/$owner/$repo/issues/$issueNumber/comments'),
        headers: headers);
  }

  // Pull Requests Endpoints
  Future<http.Response> getRepoPullRequests(String owner, String repo) async {
    return await http.get(Uri.parse('$baseUrl/repos/$owner/$repo/pulls'),
        headers: headers);
  }

  Future<http.Response> getPullRequest(
      String owner, String repo, int pullNumber) async {
    return await http.get(
        Uri.parse('$baseUrl/repos/$owner/$repo/pulls/$pullNumber'),
        headers: headers);
  }

  Future<http.Response> createPullRequest(
      String owner, String repo, Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse('$baseUrl/repos/$owner/$repo/pulls'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> updatePullRequest(String owner, String repo,
      int pullNumber, Map<String, dynamic> data) async {
    return await http.patch(
      Uri.parse('$baseUrl/repos/$owner/$repo/pulls/$pullNumber'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  // Branches Endpoints
  Future<http.Response> getRepoBranches(String owner, String repo) async {
    return await http.get(Uri.parse('$baseUrl/repos/$owner/$repo/branches'),
        headers: headers);
  }

  Future<http.Response> getBranch(
      String owner, String repo, String branch) async {
    return await http.get(
        Uri.parse('$baseUrl/repos/$owner/$repo/branches/$branch'),
        headers: headers);
  }

  // Commits Endpoints
  Future<http.Response> getRepoCommits(String owner, String repo) async {
    return await http.get(Uri.parse('$baseUrl/repos/$owner/$repo/commits'),
        headers: headers);
  }

  Future<http.Response> getCommit(String owner, String repo, String ref) async {
    return await http.get(Uri.parse('$baseUrl/repos/$owner/$repo/commits/$ref'),
        headers: headers);
  }

  Future<http.Response> createCommitComment(
      String owner, String repo, String ref, Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse('$baseUrl/repos/$owner/$repo/commits/$ref/comments'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  // Gists Endpoints
  Future<http.Response> getGists() async {
    return await http.get(Uri.parse('$baseUrl/gists'), headers: headers);
  }

  Future<http.Response> getGist(String gistId) async {
    return await http.get(Uri.parse('$baseUrl/gists/$gistId'),
        headers: headers);
  }

  Future<http.Response> createGist(Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse('$baseUrl/gists'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> updateGist(
      String gistId, Map<String, dynamic> data) async {
    return await http.patch(
      Uri.parse('$baseUrl/gists/$gistId'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  // Organizations Endpoints
  Future<http.Response> getUserOrgs() async {
    return await http.get(Uri.parse('$baseUrl/user/orgs'), headers: headers);
  }

  Future<http.Response> getOrg(String org) async {
    return await http.get(Uri.parse('$baseUrl/orgs/$org'), headers: headers);
  }

  Future<http.Response> getOrgRepos(String org) async {
    return await http.get(Uri.parse('$baseUrl/orgs/$org/repos'),
        headers: headers);
  }

  // Miscellaneous Endpoints
  Future<http.Response> getRateLimit() async {
    return await http.get(Uri.parse('$baseUrl/rate_limit'), headers: headers);
  }

  Future<http.Response> getZen() async {
    return await http.get(Uri.parse('$baseUrl/zen'), headers: headers);
  }

  Future<http.Response> getOctocat() async {
    return await http.get(Uri.parse('$baseUrl/octocat'), headers: headers);
  }
}

void mainGitHubApiUsage() async {
  // Replace 'YOUR_GITHUB_TOKEN' with your actual GitHub token.
  final gitHubApi = GitHubApi('YOUR_GITHUB_TOKEN');

  // Fetch and print authenticated user details.
  final response = await gitHubApi.getAuthenticatedUser();
  if (response.statusCode == 200) {
    if (singletonData.kDebugMode) {
      print('User: ${response.body}');
    }
  } else {
    if (singletonData.kDebugMode) {
      print('Failed to fetch user: ${response.statusCode}');
    }
  }
}

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

  GitHubService(this._token, this._repoOwner, this._repoName);

  Future<List<GitCommit>> getCommits() async {
    final url = 'https://api.github.com/repos/$_repoOwner/$_repoName/commits';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'token $_token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> commitList = json.decode(response.body);
      return commitList.map((commit) => GitCommit.fromJson(commit)).toList();
    } else {
      throw Exception('Failed to load commits');
    }
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
      sha: json['sha'],
      nodeId: json['node_id'],
      commit: CommitDetail.fromJson(json['commit'], json['sha']),
      url: json['url'],
      htmlUrl: json['html_url'],
      commentsUrl: json['comments_url'],
      author: User.fromJson(json['author']),
      committer: User.fromJson(json['committer']),
      parents: (json['parents'] as List)
          .map((parent) => Parent.fromJson(parent))
          .toList(),
    );
  }
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
      author: Author.fromJson(json['author']),
      committer: Committer.fromJson(json['committer']),
      message: json['message'],
      tree: Tree.fromJson(json['tree']),
      url: json['url'],
      commentCount: json['comment_count'],
      verification: Verification.fromJson(json['verification']),
      sha: sha,
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

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'date': date,
  };

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['name'],
      email: json['email'],
      date: json['date'],
    );
  }
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

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'date': date,
  };

  factory Committer.fromJson(Map<String, dynamic> json) {
    return Committer(
      name: json['name'],
      email: json['email'],
      date: json['date'],
    );
  }
}

class Tree {
  String sha;
  String url;

  Tree({
    required this.sha,
    required this.url,
  });

  Map<String, dynamic> toJson() => {
    'sha': sha,
    'url': url,
  };

  factory Tree.fromJson(Map<String, dynamic> json) {
    return Tree(
      sha: json['sha'],
      url: json['url'],
    );
  }
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

  Map<String, dynamic> toJson() => {
    'verified': verified,
    'reason': reason,
    'signature': signature,
    'payload': payload,
  };

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      verified: json['verified'],
      reason: json['reason'],
      signature: json['signature'],
      payload: json['payload'],
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
