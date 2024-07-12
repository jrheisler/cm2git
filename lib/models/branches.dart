class Branch {
  final String name;
  final Commit lastCommit;

  Branch({required this.name, required this.lastCommit});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      name: json['name'],
      lastCommit: Commit.fromJson(json['commit']['commit']),
    );
  }
}

class Commit {
  final String sha;
  final String message;
  final String date;
  final String author;

  Commit({required this.sha, required this.message, required this.date, required this.author});

  factory Commit.fromJson(Map<String, dynamic> json) {
    return Commit(
      sha: json['sha'],
      message: json['message'],
      date: json['author']['date'],
      author: json['author']['name'],
    );
  }
}
