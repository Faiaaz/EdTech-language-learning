import 'package:ez_trainz/utils/api_json.dart';

/// One row from `GET /courses`.
class LmsCourseSummary {
  LmsCourseSummary({
    required this.id,
    required this.title,
    this.level,
    this.description,
    required this.lessons,
  });

  final String id;
  final String title;
  final String? level;
  final String? description;
  final List<LmsLessonRef> lessons;

  factory LmsCourseSummary.fromJson(Map<String, dynamic> json) {
    final id = ApiJson.str(json['id']) ?? ApiJson.str(json['courseId']) ?? '';
    final title = ApiJson.str(json['title']) ?? 'Course';
    final lessonsRaw = json['lessons'];
    final lessons = <LmsLessonRef>[];
    if (lessonsRaw is List) {
      for (final e in lessonsRaw) {
        if (e is Map) {
          lessons.add(LmsLessonRef.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return LmsCourseSummary(
      id: id,
      title: title,
      level: ApiJson.str(json['level']),
      description: ApiJson.str(json['description']) ?? ApiJson.str(json['summary']),
      lessons: lessons,
    );
  }
}

class LmsLessonRef {
  LmsLessonRef({required this.id, required this.title});

  final String id;
  final String title;

  factory LmsLessonRef.fromJson(Map<String, dynamic> json) {
    final id = ApiJson.str(json['id']) ?? ApiJson.str(json['lessonId']) ?? '';
    final title = ApiJson.str(json['title']) ?? 'Lesson';
    return LmsLessonRef(id: id, title: title);
  }
}

/// One row from `GET /courses/my`.
class LmsMyEnrollment {
  LmsMyEnrollment({
    required this.courseId,
    this.enrolledAt,
    this.raw,
  });

  final String courseId;
  final String? enrolledAt;
  final Map<String, dynamic>? raw;

  factory LmsMyEnrollment.fromJson(Map<String, dynamic> json) {
    final courseId =
        ApiJson.str(json['courseId']) ?? ApiJson.str(json['id']) ?? '';
    return LmsMyEnrollment(
      courseId: courseId,
      enrolledAt: ApiJson.str(json['enrolledAt']) ?? ApiJson.str(json['createdAt']),
      raw: json,
    );
  }
}
