class GitCommit {
  final String sha;
  final GitCommitDetail commit;

  GitCommit({required this.sha, required this.commit});

  factory GitCommit.fromJson(Map<String, dynamic> json) {
    return GitCommit(
      sha: json['sha'],
      commit: GitCommitDetail.fromJson(json['commit']),
    );
  }
}

class GitCommitDetail {
  final String message;

  GitCommitDetail({required this.message});

  factory GitCommitDetail.fromJson(Map<String, dynamic> json) {
    return GitCommitDetail(
      message: json['message'],
    );
  }
}
