class Game {
  final String id;
  final String name;
  final String description;
  final String type;
  final String difficulty;
  final int maxScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Game({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.maxScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'easy',
      maxScore: json['maxScore'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type,
        'difficulty': difficulty,
        'maxScore': maxScore,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
