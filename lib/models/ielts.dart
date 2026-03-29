/// IELTS data models for the English Language and Career (ELC) module.
///
/// Covers all 4 IELTS sections: Reading, Listening, Writing, Speaking.
/// Based on official IELTS band descriptors and top-scoring research.

// ── IELTS Section Enum ──────────────────────────────────────────────
enum IeltsSection { reading, listening, writing, speaking }

// ── Question Types ──────────────────────────────────────────────────
enum IeltsQuestionType {
  multipleChoice,
  trueFalseNotGiven,
  yesNoNotGiven,
  matchingHeadings,
  matchingInformation,
  sentenceCompletion,
  summaryCompletion,
  shortAnswer,
  fillInBlank,
  diagramLabelling,
  listSelection,
}

// ── Difficulty / Band Level ─────────────────────────────────────────
enum IeltsDifficulty { band5, band6, band7, band8, band9 }

// ── Reading Passage ─────────────────────────────────────────────────
class IeltsReadingPassage {
  final String id;
  final String title;
  final String passage;
  final String source;
  final IeltsDifficulty difficulty;
  final List<IeltsQuestion> questions;
  final int timeLimitMinutes;

  const IeltsReadingPassage({
    required this.id,
    required this.title,
    required this.passage,
    required this.source,
    required this.difficulty,
    required this.questions,
    this.timeLimitMinutes = 20,
  });
}

// ── Generic Question ────────────────────────────────────────────────
class IeltsQuestion {
  final String id;
  final IeltsQuestionType type;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String? tip;

  const IeltsQuestion({
    required this.id,
    required this.type,
    required this.questionText,
    this.options = const [],
    required this.correctAnswer,
    required this.explanation,
    this.tip,
  });
}

// ── Listening Section ───────────────────────────────────────────────
class IeltsListeningSection {
  final String id;
  final String title;
  final String description;
  final int sectionNumber; // 1-4
  final String context; // e.g. "conversation", "monologue"
  final List<IeltsQuestion> questions;
  final String transcript;

  const IeltsListeningSection({
    required this.id,
    required this.title,
    required this.description,
    required this.sectionNumber,
    required this.context,
    required this.questions,
    required this.transcript,
  });
}

// ── Writing Task ────────────────────────────────────────────────────
class IeltsWritingTask {
  final String id;
  final int taskNumber; // 1 or 2
  final String prompt;
  final String description;
  final IeltsDifficulty difficulty;
  final int wordLimit;
  final int timeLimitMinutes;
  final List<String> sampleOutline;
  final String modelAnswer;
  final List<IeltsWritingCriterion> criteria;

  const IeltsWritingTask({
    required this.id,
    required this.taskNumber,
    required this.prompt,
    required this.description,
    required this.difficulty,
    required this.wordLimit,
    required this.timeLimitMinutes,
    required this.sampleOutline,
    required this.modelAnswer,
    required this.criteria,
  });
}

class IeltsWritingCriterion {
  final String name;
  final String description;
  final double weight;

  const IeltsWritingCriterion({
    required this.name,
    required this.description,
    required this.weight,
  });
}

// ── Speaking Topic ──────────────────────────────────────────────────
class IeltsSpeakingTopic {
  final String id;
  final int part; // 1, 2, or 3
  final String topic;
  final List<String> questions;
  final List<String> sampleAnswerPoints;
  final String? cueCard; // For Part 2
  final int? thinkTimeSeconds; // For Part 2 (usually 60s)
  final int? speakTimeSeconds; // For Part 2 (usually 120s)
  final List<String> vocabularyTips;
  final List<String> grammarTips;

  const IeltsSpeakingTopic({
    required this.id,
    required this.part,
    required this.topic,
    required this.questions,
    required this.sampleAnswerPoints,
    this.cueCard,
    this.thinkTimeSeconds,
    this.speakTimeSeconds,
    this.vocabularyTips = const [],
    this.grammarTips = const [],
  });
}

// ── Vocabulary Item ─────────────────────────────────────────────────
class IeltsVocabulary {
  final String word;
  final String partOfSpeech;
  final String definition;
  final String exampleSentence;
  final String ieltsContext; // e.g. "Academic Writing", "Speaking Part 3"
  final List<String> synonyms;
  final List<String> collocations;
  final IeltsDifficulty bandLevel;

  const IeltsVocabulary({
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    required this.exampleSentence,
    required this.ieltsContext,
    this.synonyms = const [],
    this.collocations = const [],
    required this.bandLevel,
  });
}

// ── Band Score Descriptor ───────────────────────────────────────────
class IeltsBandDescriptor {
  final double band;
  final String level;
  final String description;
  final Map<IeltsSection, String> sectionDescriptors;

  const IeltsBandDescriptor({
    required this.band,
    required this.level,
    required this.description,
    required this.sectionDescriptors,
  });
}

// ── User Progress ───────────────────────────────────────────────────
class IeltsUserProgress {
  final String odId;
  final Map<IeltsSection, double> sectionScores;
  final int totalPracticeMinutes;
  final int readingPassagesCompleted;
  final int listeningTestsCompleted;
  final int writingTasksCompleted;
  final int speakingSessionsCompleted;
  final int vocabularyMastered;
  final int gamesPlayed;
  final DateTime lastPractice;

  const IeltsUserProgress({
    required this.odId,
    required this.sectionScores,
    this.totalPracticeMinutes = 0,
    this.readingPassagesCompleted = 0,
    this.listeningTestsCompleted = 0,
    this.writingTasksCompleted = 0,
    this.speakingSessionsCompleted = 0,
    this.vocabularyMastered = 0,
    this.gamesPlayed = 0,
    required this.lastPractice,
  });

  double get overallBand {
    if (sectionScores.isEmpty) return 0;
    final sum = sectionScores.values.fold(0.0, (a, b) => a + b);
    return (sum / sectionScores.length * 2).round() / 2; // Round to nearest 0.5
  }
}

// ── Mini Game Types ─────────────────────────────────────────────────
enum IeltsGameType {
  wordScramble,
  synonymMatch,
  sentenceBuilder,
  errorSpotting,
  speedReading,
  listeningBingo,
  collocationsMatch,
  bandPredictor,
}

class IeltsMiniGame {
  final String id;
  final IeltsGameType type;
  final String title;
  final String description;
  final String iconName;
  final IeltsDifficulty difficulty;
  final int durationSeconds;

  const IeltsMiniGame({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.iconName,
    required this.difficulty,
    this.durationSeconds = 120,
  });
}
