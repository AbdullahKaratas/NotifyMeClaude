class Reminder {
  final String id;
  final String title;
  final String? description;
  final DateTime dueAt;
  final DateTime createdAt;
  final bool isDone;

  Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.dueAt,
    required this.createdAt,
    this.isDone = false,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueAt: DateTime.parse(json['due_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      isDone: json['is_done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_at': dueAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_done': isDone,
    };
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueAt,
    DateTime? createdAt,
    bool? isDone,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      isDone: isDone ?? this.isDone,
    );
  }

  /// Check if reminder is overdue
  bool get isOverdue => !isDone && dueAt.isBefore(DateTime.now());

  /// Check if reminder is due today
  bool get isDueToday {
    final now = DateTime.now();
    return dueAt.year == now.year &&
        dueAt.month == now.month &&
        dueAt.day == now.day;
  }

  /// Check if reminder is due tomorrow
  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueAt.year == tomorrow.year &&
        dueAt.month == tomorrow.month &&
        dueAt.day == tomorrow.day;
  }
}
