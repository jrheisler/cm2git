import 'package:cm_2_git/services/git_services.dart';

class KanbanCard {
  int id;
  String title;
  String description;
  String status;
  String assignee;
  String sha;
  List<CommitDetail> files;

  KanbanCard({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.assignee,
    required this.sha,
    this.files = const [],
  });

  factory KanbanCard.fromJson(Map<String, dynamic> json) {
    return KanbanCard(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      assignee: json['assignee'],
      sha: json['sha'] ?? '',
      //files: json['files'] != null ? List<CommitDetail>.from(json['files']) : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status,
    'assignee': assignee,
    'files': files,
    'sha': sha,
  };
}