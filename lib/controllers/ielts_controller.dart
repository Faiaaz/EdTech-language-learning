import 'dart:math';
import 'package:get/get.dart';

import 'package:ez_trainz/models/ielts.dart';
import 'package:ez_trainz/services/ielts_service.dart';
import 'package:ez_trainz/services/sm2_srs_service.dart';

/// GetX controller managing all IELTS module state.
///
/// Handles reading practice, listening practice, writing review,
/// speaking practice, vocabulary SRS, mini games, and score tracking.
class IeltsController extends GetxController {
  static IeltsController get to => Get.find();

  // ── SRS for vocabulary ────────────────────────────────────────────
  final _vocabSrs = Sm2SrsService();

  // ── Reactive state ────────────────────────────────────────────────
  final currentSection = Rx<IeltsSection?>(null);

  // Reading state
  final currentPassageIndex = 0.obs;
  final readingAnswers = <String, String>{}.obs;
  final readingSubmitted = false.obs;
  final readingScore = 0.obs;
  final readingTimeRemaining = 0.obs;

  // Listening state
  final currentListeningIndex = 0.obs;
  final listeningAnswers = <String, String>{}.obs;
  final listeningSubmitted = false.obs;
  final listeningScore = 0.obs;
  final showTranscript = false.obs;

  // Writing state
  final currentWritingIndex = 0.obs;
  final userEssay = ''.obs;
  final showModelAnswer = false.obs;
  final writingWordCount = 0.obs;

  // Speaking state
  final currentSpeakingIndex = 0.obs;
  final speakingTimer = 0.obs;
  final isSpeakingTimerRunning = false.obs;
  final showSpeakingTips = false.obs;

  // Vocabulary state
  final vocabDueCount = 0.obs;
  final vocabTotalCount = 0.obs;
  final currentVocabIndex = 0.obs;
  final vocabSessionQueue = <SrsCard>[].obs;
  final isVocabAnswerShown = false.obs;
  final vocabSessionReviewed = 0.obs;
  final vocabSessionCorrect = 0.obs;

  // Game state
  final currentGameType = Rx<IeltsGameType?>(null);
  final gameScore = 0.obs;
  final gameTimeRemaining = 0.obs;
  final isGameActive = false.obs;
  final gameItems = <Map<String, dynamic>>[].obs;
  final gameCurrentIndex = 0.obs;

  // Overall progress
  final totalReadingDone = 0.obs;
  final totalListeningDone = 0.obs;
  final totalWritingDone = 0.obs;
  final totalSpeakingDone = 0.obs;
  final totalGamesPlayed = 0.obs;

  // ── Data accessors ────────────────────────────────────────────────
  List<IeltsReadingPassage> get passages => IeltsService.readingPassages;
  List<IeltsListeningSection> get listeningSections => IeltsService.listeningSections;
  List<IeltsWritingTask> get writingTasks => IeltsService.writingTasks;
  List<IeltsSpeakingTopic> get speakingTopics => IeltsService.speakingTopics;
  List<IeltsVocabulary> get vocabulary => IeltsService.academicVocabulary;
  List<IeltsMiniGame> get miniGames => IeltsService.miniGames;
  List<IeltsBandDescriptor> get bandDescriptors => IeltsService.bandDescriptors;

  @override
  void onInit() {
    super.onInit();
    _loadVocabCards();
    _refreshVocabStats();
  }

  // ── Vocabulary SRS ────────────────────────────────────────────────

  void _loadVocabCards() {
    _vocabSrs.addCards(
      IeltsService.academicVocabulary.map((v) => SrsCard(
        id: 'ielts_vocab_${v.word}',
        label: v.word,
      )).toList(),
    );
  }

  void _refreshVocabStats() {
    vocabDueCount.value = _vocabSrs.dueCount;
    vocabTotalCount.value = _vocabSrs.allCards.length;
  }

  void startVocabSession() {
    final due = _vocabSrs.dueCards;
    vocabSessionQueue.assignAll(due);
    currentVocabIndex.value = 0;
    vocabSessionReviewed.value = 0;
    vocabSessionCorrect.value = 0;
    isVocabAnswerShown.value = false;
  }

  SrsCard? get currentVocabCard {
    if (vocabSessionQueue.isEmpty) return null;
    if (currentVocabIndex.value >= vocabSessionQueue.length) return null;
    return vocabSessionQueue[currentVocabIndex.value];
  }

  bool get vocabSessionDone =>
      vocabSessionQueue.isEmpty || currentVocabIndex.value >= vocabSessionQueue.length;

  void showVocabAnswer() => isVocabAnswerShown.value = true;

  void submitVocabRating(RecallQuality quality) {
    final card = currentVocabCard;
    if (card == null) return;
    _vocabSrs.review(card.id, quality);
    vocabSessionReviewed.value++;
    if (quality.value >= 3) vocabSessionCorrect.value++;
    currentVocabIndex.value++;
    isVocabAnswerShown.value = false;
    _refreshVocabStats();
  }

  IeltsVocabulary? vocabForCard(SrsCard card) {
    final word = card.id.replaceFirst('ielts_vocab_', '');
    return IeltsService.academicVocabulary.cast<IeltsVocabulary?>().firstWhere(
      (v) => v!.word == word,
      orElse: () => null,
    );
  }

  void endVocabSession() {
    vocabSessionQueue.clear();
    currentVocabIndex.value = 0;
    isVocabAnswerShown.value = false;
    _refreshVocabStats();
  }

  // ── Reading ───────────────────────────────────────────────────────

  IeltsReadingPassage get currentPassage =>
      passages[currentPassageIndex.value % passages.length];

  void selectPassage(int index) {
    currentPassageIndex.value = index;
    readingAnswers.clear();
    readingSubmitted.value = false;
    readingScore.value = 0;
    readingTimeRemaining.value = passages[index].timeLimitMinutes * 60;
  }

  void setReadingAnswer(String questionId, String answer) {
    readingAnswers[questionId] = answer;
  }

  void submitReading() {
    int correct = 0;
    for (final q in currentPassage.questions) {
      if (readingAnswers[q.id]?.trim().toLowerCase() ==
          q.correctAnswer.trim().toLowerCase()) {
        correct++;
      }
    }
    readingScore.value = correct;
    readingSubmitted.value = true;
    totalReadingDone.value++;
  }

  // ── Listening ─────────────────────────────────────────────────────

  IeltsListeningSection get currentListening =>
      listeningSections[currentListeningIndex.value % listeningSections.length];

  void selectListening(int index) {
    currentListeningIndex.value = index;
    listeningAnswers.clear();
    listeningSubmitted.value = false;
    listeningScore.value = 0;
    showTranscript.value = false;
  }

  void setListeningAnswer(String questionId, String answer) {
    listeningAnswers[questionId] = answer;
  }

  void submitListening() {
    int correct = 0;
    for (final q in currentListening.questions) {
      if (listeningAnswers[q.id]?.trim().toLowerCase() ==
          q.correctAnswer.trim().toLowerCase()) {
        correct++;
      }
    }
    listeningScore.value = correct;
    listeningSubmitted.value = true;
    totalListeningDone.value++;
  }

  void toggleTranscript() {
    showTranscript.value = !showTranscript.value;
  }

  // ── Writing ───────────────────────────────────────────────────────

  IeltsWritingTask get currentWritingTask =>
      writingTasks[currentWritingIndex.value % writingTasks.length];

  void selectWritingTask(int index) {
    currentWritingIndex.value = index;
    userEssay.value = '';
    showModelAnswer.value = false;
    writingWordCount.value = 0;
  }

  void updateEssay(String text) {
    userEssay.value = text;
    writingWordCount.value = text.trim().isEmpty
        ? 0
        : text.trim().split(RegExp(r'\s+')).length;
  }

  void toggleModelAnswer() {
    showModelAnswer.value = !showModelAnswer.value;
    if (showModelAnswer.value) totalWritingDone.value++;
  }

  // ── Speaking ──────────────────────────────────────────────────────

  IeltsSpeakingTopic get currentSpeakingTopic =>
      speakingTopics[currentSpeakingIndex.value % speakingTopics.length];

  void selectSpeakingTopic(int index) {
    currentSpeakingIndex.value = index;
    speakingTimer.value = 0;
    isSpeakingTimerRunning.value = false;
    showSpeakingTips.value = false;
  }

  void toggleSpeakingTips() {
    showSpeakingTips.value = !showSpeakingTips.value;
  }

  void completeSpeakingSession() {
    totalSpeakingDone.value++;
    isSpeakingTimerRunning.value = false;
  }

  // ── Games ─────────────────────────────────────────────────────────

  void startSynonymGame() {
    currentGameType.value = IeltsGameType.synonymMatch;
    gameScore.value = 0;
    gameCurrentIndex.value = 0;
    isGameActive.value = true;

    final pairs = List<Map<String, String>>.from(IeltsService.synonymPairs)..shuffle(Random());
    gameItems.assignAll(pairs.take(10).map((p) => Map<String, dynamic>.from(p)));
    gameTimeRemaining.value = 90;
  }

  void startErrorSpottingGame() {
    currentGameType.value = IeltsGameType.errorSpotting;
    gameScore.value = 0;
    gameCurrentIndex.value = 0;
    isGameActive.value = true;

    final data = List<Map<String, String>>.from(IeltsService.errorSpottingData)..shuffle(Random());
    gameItems.assignAll(data.take(8).map((d) => Map<String, dynamic>.from(d)));
    gameTimeRemaining.value = 120;
  }

  void startSentenceBuilderGame() {
    currentGameType.value = IeltsGameType.sentenceBuilder;
    gameScore.value = 0;
    gameCurrentIndex.value = 0;
    isGameActive.value = true;

    final data = List<Map<String, dynamic>>.from(IeltsService.sentenceBuilderData)..shuffle(Random());
    gameItems.assignAll(data);
    gameTimeRemaining.value = 150;
  }

  void startCollocationGame() {
    currentGameType.value = IeltsGameType.collocationsMatch;
    gameScore.value = 0;
    gameCurrentIndex.value = 0;
    isGameActive.value = true;

    final pairs = List<Map<String, String>>.from(IeltsService.collocationPairs)..shuffle(Random());
    gameItems.assignAll(pairs.take(10).map((p) => Map<String, dynamic>.from(p)));
    gameTimeRemaining.value = 90;
  }

  void scoreGamePoint() {
    gameScore.value++;
  }

  void nextGameItem() {
    if (gameCurrentIndex.value < gameItems.length - 1) {
      gameCurrentIndex.value++;
    } else {
      endGame();
    }
  }

  void endGame() {
    isGameActive.value = false;
    totalGamesPlayed.value++;
  }

  // ── Band Score Calculator ─────────────────────────────────────────

  double calculateOverall(double r, double l, double w, double s) {
    return IeltsService.calculateOverallBand(r, l, w, s);
  }
}
