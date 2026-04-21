import 'package:ez_trainz/utils/api_json.dart';

/// `GET /quiz/lesson/{lessonId}` response (also works when the same shape is embedded in `GET /quiz` rows).
class GamQuizDetail {
  GamQuizDetail({
    required this.id,
    required this.title,
    this.passingScore,
    required this.questions,
  });

  final String id;
  final String title;
  final int? passingScore;
  final List<GamQuizQuestion> questions;

  factory GamQuizDetail.fromJson(Map<String, dynamic> json) {
    final qs = ApiJson.mapList(json['questions']);
    return GamQuizDetail(
      id: ApiJson.str(json['id']) ?? '',
      title: ApiJson.str(json['title']) ?? 'Quiz',
      passingScore: ApiJson.intVal(json['passingScore']),
      questions: qs.map(GamQuizQuestion.fromJson).toList(),
    );
  }
}

class GamQuizQuestion {
  GamQuizQuestion({
    required this.id,
    required this.prompt,
    this.type,
    this.options,
    this.raw,
  });

  final String id;
  final String prompt;
  final String? type;
  final List<String>? options;
  final Map<String, dynamic>? raw;

  factory GamQuizQuestion.fromJson(Map<String, dynamic> json) {
    final id = ApiJson.str(json['questionId']) ??
        ApiJson.str(json['id']) ??
        '';
    final prompt = _firstNonEmpty([
          ApiJson.str(json['question']),
          ApiJson.str(json['prompt']),
          ApiJson.str(json['text']),
          ApiJson.str(json['body']),
          ApiJson.str(json['title']),
          ApiJson.str(json['label']),
        ]) ??
        'Question';

    List<String>? options;
    final o = json['options'] ?? json['choices'] ?? json['answers'];
    if (o is List) {
      options = o.map((e) => ApiJson.strOr(e, e.toString())).toList();
    }

    return GamQuizQuestion(
      id: id,
      prompt: prompt,
      type: ApiJson.str(json['type']),
      options: options,
      raw: json,
    );
  }

  static String? _firstNonEmpty(List<String?> parts) {
    for (final p in parts) {
      if (p != null && p.trim().isNotEmpty) return p.trim();
    }
    return null;
  }
}

/// Row from `GET /quiz`.
class GamQuizSummary {
  GamQuizSummary({
    required this.id,
    required this.title,
    this.lessonId,
    this.questionCount,
    this.embeddedDetail,
  });

  final String id;
  final String title;
  final String? lessonId;
  final int? questionCount;
  final GamQuizDetail? embeddedDetail;

  factory GamQuizSummary.fromJson(Map<String, dynamic> json) {
    final id = ApiJson.str(json['id']) ?? '';
    final qs = json['questions'];
    final count = qs is List ? qs.length : ApiJson.intVal(json['questionCount']);
    GamQuizDetail? embedded;
    if (qs is List && qs.isNotEmpty) {
      try {
        embedded = GamQuizDetail.fromJson(json);
      } catch (_) {
        embedded = null;
      }
    }
    return GamQuizSummary(
      id: id,
      title: ApiJson.str(json['title']) ?? 'Quiz',
      lessonId: ApiJson.str(json['lessonId']),
      questionCount: count,
      embeddedDetail: embedded,
    );
  }
}

/// `POST /quiz/submit` response.
class GamQuizSubmitResult {
  GamQuizSubmitResult({
    this.score,
    this.passed,
    this.correct,
    this.total,
    this.breakdown,
  });

  final double? score;
  final bool? passed;
  final int? correct;
  final int? total;
  final List<Map<String, dynamic>>? breakdown;

  factory GamQuizSubmitResult.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>>? bd;
    final b = json['breakdown'];
    if (b is List) {
      bd = b
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return GamQuizSubmitResult(
      score: ApiJson.doubleVal(json['score']),
      passed: json['passed'] is bool ? json['passed'] as bool : null,
      correct: ApiJson.intVal(json['correct']),
      total: ApiJson.intVal(json['total']),
      breakdown: bd,
    );
  }
}

/// Generic lesson payload for grammar / fill-gaps / matching lists.
class GamLessonPayload {
  GamLessonPayload({
    required this.kind,
    required this.id,
    required this.title,
    required this.items,
  });

  final String kind; // grammar | fillgaps | matching
  final String id;
  final String title;
  final List<Map<String, dynamic>> items;

  factory GamLessonPayload.grammar(Map<String, dynamic> json) {
    return GamLessonPayload(
      kind: 'grammar',
      id: ApiJson.str(json['id']) ?? '',
      title: ApiJson.str(json['title']) ?? 'Grammar',
      items: ApiJson.mapList(json['drills']),
    );
  }

  factory GamLessonPayload.fillGaps(Map<String, dynamic> json) {
    return GamLessonPayload(
      kind: 'fillgaps',
      id: ApiJson.str(json['id']) ?? '',
      title: ApiJson.str(json['title']) ?? 'Fill in the gaps',
      items: ApiJson.mapList(json['questions']),
    );
  }

  factory GamLessonPayload.matching(Map<String, dynamic> json) {
    return GamLessonPayload(
      kind: 'matching',
      id: ApiJson.str(json['id']) ?? '',
      title: ApiJson.str(json['title']) ?? 'Matching',
      items: ApiJson.mapList(json['pairs']),
    );
  }
}
