
class KanbanDates {
  DateTime date;
  String status;

  KanbanDates({
    required this.date,
    required this.status,
  });

  factory KanbanDates.fromJson(Map<String, dynamic> json) {
    return KanbanDates(
      date: DateTime.parse(json['date']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'status': status,
      };
}

class KanbanCard {
  int id;
  String title;
  String description;
  String status;
  String assignee;
  String sha;
  List<dynamic> files;
  List<dynamic> pulls;
  List<dynamic> branches;
  List<KanbanDates> dates;
  DateTime needDate;
  bool blocked;
  String blockReason;

  // New property
  bool isModified;

  KanbanCard({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.assignee,
    required this.sha,
    this.files = const [],
    this.pulls = const [],
    this.branches = const [],
    this.dates = const [],
    required this.needDate,
    required this.blocked,
    required this.blockReason,
    this.isModified = false, // Default to false
  });

  factory KanbanCard.fromJson(Map<String, dynamic> json) {
    var datesFromJson = json['dates'] as List? ?? [];
    List<KanbanDates> datesList =
    datesFromJson.map((date) => KanbanDates.fromJson(date)).toList();
    return KanbanCard(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      assignee: json['assignee'],
      sha: json['sha'] ?? '',
      files: [],
      pulls: [],
      branches: [],
      dates: datesList,
      needDate: json['need_date'] != null
          ? DateTime.parse(json['need_date'])
          : DateTime.now(),
      blocked: json['blocked'] ?? false,
      blockReason: json['blockReason'] ?? '',
      isModified: json['isModified'] ?? false, // Initialize from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'assignee': assignee,
      'files': files,
      'pulls': pulls,
      'branches': branches,
      'sha': sha,
      'dates': dates.map((date) => date.toJson()).toList(),
      'need_date': needDate.toIso8601String(),
      'blocked': blocked,
      'blockReason': blockReason,
      'isModified': isModified, // Include in JSON output
    };
  }

  // Method to mark card as modified
  void markAsModified() {
    isModified = true;
  }

  // Method to reset modification state
  void resetModified() {
    isModified = false;
  }

  void updateFromJson(Map<String, dynamic> cardVersion) {
    // Update fields from the provided JSON
    id = cardVersion['id'] ?? id;
    title = cardVersion['title'] ?? title;
    description = cardVersion['description'] ?? description;
    status = cardVersion['status'] ?? status;
    assignee = cardVersion['assignee'] ?? assignee;
    sha = cardVersion['sha'] ?? sha;

    // Update files, pulls, and branches if provided
    files = cardVersion['files'] ?? files;
    pulls = cardVersion['pulls'] ?? pulls;
    branches = cardVersion['branches'] ?? branches;

    // Update dates
    if (cardVersion['dates'] != null) {
      dates = (cardVersion['dates'] as List)
          .map((date) => KanbanDates.fromJson(date))
          .toList();
    }

    // Update needDate
    if (cardVersion['need_date'] != null) {
      try {
        needDate = DateTime.parse(cardVersion['need_date']);
      } catch (e) {
        print("Failed to parse need_date: $e");
      }
    }

    // Update blocked state
    blocked = cardVersion['blocked'] ?? blocked;

    // Set the card as modified
    markAsModified();
  }



}
