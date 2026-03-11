class Game {
  final String id;
  final String title;
  final String description;
  final String type;
  final String lessonId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Game({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.lessonId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? '',
      lessonId: json['lessonId'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'lessonId': lessonId,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
