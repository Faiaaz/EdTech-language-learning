import 'package:get/get.dart';

import 'package:ez_trainz/models/kana.dart';
import 'package:ez_trainz/services/sm2_srs_service.dart';
import 'package:ez_trainz/services/srs_storage_service.dart';

/// GetX controller that wraps [Sm2SrsService] and exposes reactive state.
///
/// Pre-loads all Hiragana and Katakana from [KanaData] on init.
/// Registered as a permanent singleton in main.dart.
class SrsController extends GetxController {
  static SrsController get to => Get.find();
  final _service = Sm2SrsService();

  // Reactive stats
  final dueCount = 0.obs;
  final totalCount = 0.obs;

  // Current review session
  final sessionQueue = <SrsCard>[].obs;
  final currentIndex = 0.obs;
  final sessionReviewed = 0.obs;
  final sessionCorrect = 0.obs;
  final isAnswerShown = false.obs;

  @override
  void onInit() {
    super.onInit();
    // ignore: discarded_futures
    _hydrate();
  }

  // ── Setup ────────────────────────────────────────────────────────

  Future<void> _hydrate() async {
    final saved = await SrsStorageService.loadSm2Cards();
    if (saved.isNotEmpty) {
      _service.importJson(saved);
    }
    _loadKanaCards();
    _refreshStats();
  }

  void _loadKanaCards() {
    // Register all hiragana
    _service.addCards(KanaData.hiragana.map((k) => SrsCard(
          id: 'hiragana_${k.character}',
          label: k.character,
        )).toList());

    // Register all katakana
    _service.addCards(KanaData.katakana.map((k) => SrsCard(
          id: 'katakana_${k.character}',
          label: k.character,
        )).toList());
  }

  void _refreshStats() {
    dueCount.value = _service.dueCount;
    totalCount.value = _service.allCards.length;
  }

  List<SrsCard> get dueCards => _service.dueCards;

  SrsCard? getCard(String id) => _service.getCard(id);

  // ── Session management ───────────────────────────────────────────

  /// Starts a review session with all currently due cards.
  void startSession() {
    final due = _service.dueCards;
    sessionQueue.assignAll(due);
    currentIndex.value = 0;
    sessionReviewed.value = 0;
    sessionCorrect.value = 0;
    isAnswerShown.value = false;
  }

  SrsCard? get currentCard {
    if (sessionQueue.isEmpty) return null;
    if (currentIndex.value >= sessionQueue.length) return null;
    return sessionQueue[currentIndex.value];
  }

  bool get sessionDone =>
      sessionQueue.isEmpty || currentIndex.value >= sessionQueue.length;

  double get sessionProgress =>
      sessionQueue.isEmpty ? 0 : currentIndex.value / sessionQueue.length;

  void showAnswer() => isAnswerShown.value = true;

  /// Called after user rates their recall.
  void submitRating(RecallQuality quality) {
    final card = currentCard;
    if (card == null) return;

    _service.review(card.id, quality);
    // ignore: discarded_futures
    SrsStorageService.saveSm2Cards(_service.exportJson());
    sessionReviewed.value++;
    if (quality.value >= 3) sessionCorrect.value++;

    currentIndex.value++;
    isAnswerShown.value = false;
    _refreshStats();
  }

  void reviewCard(String cardId, RecallQuality quality) {
    _service.review(cardId, quality);
    // ignore: discarded_futures
    SrsStorageService.saveSm2Cards(_service.exportJson());
    _refreshStats();
  }

  void endSession() {
    sessionQueue.clear();
    currentIndex.value = 0;
    isAnswerShown.value = false;
    _refreshStats();
  }

  /// Register review cards for LMS lesson/quiz items.
  /// This allows the daily session to pull them into SRS over time.
  void registerLmsCards({
    required String lessonId,
    required String lessonTitle,
    required List<String> quizTitles,
  }) {
    final cards = <SrsCard>[];
    for (var i = 0; i < quizTitles.length; i++) {
      final qt = quizTitles[i].trim();
      if (qt.isEmpty) continue;
      cards.add(SrsCard(
        id: 'lms_${lessonId}_quiz_$i',
        label: '$lessonTitle • $qt',
      ));
    }
    if (cards.isEmpty) return;
    _service.addCards(cards);
    // ignore: discarded_futures
    SrsStorageService.saveSm2Cards(_service.exportJson());
    _refreshStats();
  }

  // ── Kana lookup (for review screen) ─────────────────────────────

  /// Returns the [Kana] data for a given card ID, or null if not found.
  Kana? kanaForCard(SrsCard card) {
    if (card.id.startsWith('hiragana_')) {
      return KanaData.hiragana.firstWhereOrNull(
          (k) => 'hiragana_${k.character}' == card.id);
    } else {
      return KanaData.katakana.firstWhereOrNull(
          (k) => 'katakana_${k.character}' == card.id);
    }
  }
}
