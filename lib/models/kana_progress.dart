import 'dart:convert';

/// SM-2 spaced repetition data for a single kana character.
class KanaProgress {
  final String character;
  final String type; // 'hiragana' or 'katakana'

  /// SM-2 fields
  double easeFactor;
  int interval; // days until next review
  int repetitions; // consecutive correct answers
  DateTime nextReview;

  /// Lifetime stats
  int totalCorrect;
  int totalAttempts;

  KanaProgress({
    required this.character,
    required this.type,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    DateTime? nextReview,
    this.totalCorrect = 0,
    this.totalAttempts = 0,
  }) : nextReview = nextReview ?? DateTime.now();

  bool get isDue => DateTime.now().isAfter(nextReview);

  /// Mastery level 0.0–1.0 based on repetitions and ease factor.
  double get mastery {
    if (totalAttempts == 0) return 0.0;
    final repScore = (repetitions / 8).clamp(0.0, 0.5);
    final easeScore = ((easeFactor - 1.3) / (2.5 - 1.3) * 0.3).clamp(0.0, 0.3);
    final accScore = (totalCorrect / totalAttempts * 0.2).clamp(0.0, 0.2);
    return (repScore + easeScore + accScore).clamp(0.0, 1.0);
  }

  /// Apply SM-2 algorithm based on user quality rating (0–5).
  /// 0 = complete blackout, 3 = correct with difficulty, 5 = perfect
  void applyRating(int quality) {
    totalAttempts++;
    if (quality >= 3) totalCorrect++;

    // SM-2 core
    if (quality < 3) {
      repetitions = 0;
      interval = 1;
    } else {
      if (repetitions == 0) {
        interval = 1;
      } else if (repetitions == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round();
      }
      repetitions++;
    }

    easeFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (easeFactor < 1.3) easeFactor = 1.3;

    nextReview = DateTime.now().add(Duration(days: interval));
  }

  Map<String, dynamic> toJson() => {
        'character': character,
        'type': type,
        'easeFactor': easeFactor,
        'interval': interval,
        'repetitions': repetitions,
        'nextReview': nextReview.toIso8601String(),
        'totalCorrect': totalCorrect,
        'totalAttempts': totalAttempts,
      };

  factory KanaProgress.fromJson(Map<String, dynamic> json) => KanaProgress(
        character: json['character'] as String,
        type: json['type'] as String,
        easeFactor: (json['easeFactor'] as num).toDouble(),
        interval: json['interval'] as int,
        repetitions: json['repetitions'] as int,
        nextReview: DateTime.parse(json['nextReview'] as String),
        totalCorrect: json['totalCorrect'] as int,
        totalAttempts: json['totalAttempts'] as int,
      );

  static String encodeList(List<KanaProgress> list) =>
      jsonEncode(list.map((p) => p.toJson()).toList());

  static List<KanaProgress> decodeList(String jsonStr) =>
      (jsonDecode(jsonStr) as List)
          .map((e) => KanaProgress.fromJson(e as Map<String, dynamic>))
          .toList();
}
