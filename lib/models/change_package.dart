class ChangePackage {
  final String id;
  final String title;
  final String description;

  ChangePackage({required this.id, required this.title, required this.description});

  factory ChangePackage.fromJson(Map<String, dynamic> json) {
    return ChangePackage(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}

