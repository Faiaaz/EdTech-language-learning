enum LessonChallengeType {
  selectCorrect,
  assist,
}

class LessonChallenge {
  const LessonChallenge({
    required this.id,
    required this.type,
    required this.prompt,
    required this.choices,
    required this.correctChoiceId,
    this.jp,
    this.romaji,
  });

  final String id;
  final LessonChallengeType type;

  /// Localised prompt text.
  final String prompt;

  /// Optional Japanese (kana/kanji) content to display prominently.
  final String? jp;

  /// Optional romaji to display when enabled.
  final String? romaji;

  final List<LessonChoice> choices;
  final String correctChoiceId;
}

class LessonChoice {
  const LessonChoice({required this.id, required this.label});

  final String id;
  final String label;
}

