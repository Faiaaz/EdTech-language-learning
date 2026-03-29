import 'package:get/get.dart';

import 'package:ez_trainz/models/kana.dart';
import 'package:ez_trainz/services/sm2_srs_service.dart';

/// GetX controller that wraps [Sm2SrsService] and exposes reactive state.
///
/// Pre-loads all Hiragana and Katakana from [KanaData] on init.
/// Registered as a permanent singleton in main.dart.
class SrsController extends GetxController {
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
    _loadKanaCards();
    _refreshStats();
  }

  // ── Setup ────────────────────────────────────────────────────────

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
    sessionReviewed.value++;
    if (quality.value >= 3) sessionCorrect.value++;

    currentIndex.value++;
    isAnswerShown.value = false;
    _refreshStats();
  }

  void endSession() {
    sessionQueue.clear();
    currentIndex.value = 0;
    isAnswerShown.value = false;
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
