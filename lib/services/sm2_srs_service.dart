// Spaced Repetition System (SRS) service using the SM-2 algorithm.
//
// SM-2 reference: https://www.supermemo.com/en/blog/application-of-a-computer-to-improve-the-results-obtained-in-working-with-the-supermemo-method
//
// TODO: persist SrsCard state to shared_preferences / backend once available.

/// Quality of a recall response (0–5 scale from SM-2 spec).
/// 0 = complete blackout, 5 = perfect response with no hesitation.
enum RecallQuality {
  blackout(0),
  wrong(1),
  wrongButFamiliar(2),
  hardCorrect(3),
  correctWithHesitation(4),
  perfect(5);

  const RecallQuality(this.value);
  final int value;
}

/// A single card tracked by the SRS engine.
class SrsCard {
  /// Unique identifier — can be a lesson ID, quiz ID, kana character, etc.
  final String id;

  /// Human-readable label (e.g. "あ", "Greetings Quiz 1").
  final String label;

  /// Ease factor (≥ 1.3). Starts at 2.5 per SM-2 spec.
  double easeFactor;

  /// Number of times reviewed successfully in a row.
  int repetitions;

  /// Days until next review.
  int intervalDays;

  /// Absolute date of the next scheduled review.
  DateTime nextReview;

  SrsCard({
    required this.id,
    required this.label,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    this.intervalDays = 0,
    DateTime? nextReview,
  }) : nextReview = nextReview ?? DateTime.now();

  bool get isDue =>
      DateTime.now().isAfter(nextReview) ||
      DateTime.now().isAtSameMomentAs(nextReview);

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'easeFactor': easeFactor,
        'repetitions': repetitions,
        'intervalDays': intervalDays,
        'nextReview': nextReview.toIso8601String(),
      };

  factory SrsCard.fromJson(Map<String, dynamic> json) => SrsCard(
        id: json['id'] as String,
        label: json['label'] as String,
        easeFactor: (json['easeFactor'] as num).toDouble(),
        repetitions: json['repetitions'] as int,
        intervalDays: json['intervalDays'] as int,
        nextReview: DateTime.parse(json['nextReview'] as String),
      );

  @override
  String toString() =>
      'SrsCard($id, reps=$repetitions, ef=$easeFactor, next=$nextReview)';
}

/// In-memory SM-2 engine for flashcard-style review (kana flashcards, IELTS vocab, etc.).
class Sm2SrsService {
  // In-memory store: cardId → SrsCard
  // TODO: hydrate from shared_preferences / backend on init.
  final Map<String, SrsCard> _cards = {};

  /// Register a card if it doesn't already exist.
  void addCard(SrsCard card) {
    _cards.putIfAbsent(card.id, () => card);
  }

  /// Register multiple cards at once.
  void addCards(List<SrsCard> cards) {
    for (final c in cards) {
      addCard(c);
    }
  }

  SrsCard? getCard(String id) => _cards[id];

  List<SrsCard> get allCards => List.unmodifiable(_cards.values);

  /// Returns cards that are due for review today.
  List<SrsCard> get dueCards => _cards.values.where((c) => c.isDue).toList()
    ..sort((a, b) => a.nextReview.compareTo(b.nextReview));

  /// Number of cards due today.
  int get dueCount => dueCards.length;

  /// Process a review for [cardId] with [quality].
  ///
  /// Returns the updated [SrsCard], or null if the card doesn't exist.
  SrsCard? review(String cardId, RecallQuality quality) {
    final card = _cards[cardId];
    if (card == null) return null;

    _applySmTwo(card, quality.value);

    // TODO: persist updated card to storage.
    return card;
  }

  /// Apply SM-2 update to [card] given an integer quality score (0–5).
  void _applySmTwo(SrsCard card, int q) {
    if (q < 3) {
      // Failed recall — reset repetitions and re-show soon.
      card.repetitions = 0;
      card.intervalDays = 1;
    } else {
      // Successful recall.
      if (card.repetitions == 0) {
        card.intervalDays = 1;
      } else if (card.repetitions == 1) {
        card.intervalDays = 6;
      } else {
        card.intervalDays = (card.intervalDays * card.easeFactor).round();
      }
      card.repetitions += 1;
    }

    // Update ease factor (clamped to minimum 1.3).
    final newEf =
        card.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    card.easeFactor = newEf < 1.3 ? 1.3 : newEf;

    card.nextReview =
        DateTime.now().add(Duration(days: card.intervalDays));
  }

  /// Simple stats snapshot.
  SrsStats get stats {
    final now = DateTime.now();
    int due = 0;
    int learning = 0; // repetitions < 2
    int young = 0; // intervalDays 1–20
    int mature = 0; // intervalDays > 20

    for (final c in _cards.values) {
      if (c.isDue) due++;
      if (c.repetitions < 2) {
        learning++;
      } else if (c.intervalDays <= 20) {
        young++;
      } else {
        mature++;
      }
    }

    final upcoming7 = _cards.values
        .where((c) =>
            c.nextReview.isAfter(now) &&
            c.nextReview.isBefore(now.add(const Duration(days: 7))))
        .length;

    return SrsStats(
      total: _cards.length,
      due: due,
      learning: learning,
      young: young,
      mature: mature,
      upcomingIn7Days: upcoming7,
    );
  }

  /// Export all cards to a JSON-serialisable list.
  /// TODO: call this when persisting to storage.
  List<Map<String, dynamic>> exportJson() =>
      _cards.values.map((c) => c.toJson()).toList();

  /// Import cards from a JSON list, overwriting any existing entries.
  /// TODO: call this when hydrating from storage.
  void importJson(List<Map<String, dynamic>> data) {
    for (final json in data) {
      final card = SrsCard.fromJson(json);
      _cards[card.id] = card;
    }
  }
}

/// Immutable stats snapshot.
class SrsStats {
  final int total;
  final int due;
  final int learning;
  final int young;
  final int mature;
  final int upcomingIn7Days;

  const SrsStats({
    required this.total,
    required this.due,
    required this.learning,
    required this.young,
    required this.mature,
    required this.upcomingIn7Days,
  });

  @override
  String toString() =>
      'SrsStats(total=$total, due=$due, learning=$learning, '
      'young=$young, mature=$mature, upcoming7=$upcomingIn7Days)';
}
