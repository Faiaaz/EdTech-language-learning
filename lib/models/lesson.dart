import 'package:ez_trainz/models/quiz.dart';

class LessonContent {
  final String body;
  final String type;

  const LessonContent({required this.body, required this.type});

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      body: json['body'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'body': body, 'type': type};
}

class Lesson {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final LessonContent content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Quiz> quizzes;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.quizzes = const [],
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      courseId: json['courseId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      content: LessonContent.fromJson(json['content'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      quizzes: (json['quizzes'] as List<dynamic>?)
              ?.map((q) => Quiz.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'title': title,
        'description': description,
        'content': content.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'quizzes': quizzes.map((q) => q.toJson()).toList(),
      };
}
