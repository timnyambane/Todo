class Task {
  int? id;
  String title;
  String? description;
  int dateCreated;
  int? dueDate;
  bool? isStarred;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.dateCreated,
    this.dueDate,
    this.isStarred,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateCreated': dateCreated,
      'dueDate': dueDate,
      'isStarred': isStarred == true ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dateCreated: map['dateCreated'],
      dueDate: map['dueDate'],
      isStarred: map['isStarred'] == 1,
    );
  }
}
