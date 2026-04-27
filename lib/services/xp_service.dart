import 'package:ez_trainz/models/xp_event.dart';

/// Catalog of XP rewards per event type. Centralized here so the product
/// team can tune values without hunting through UI code.
class XpRewards {
  static const int perQuiz = 50;
  static const int perGame = 75;
  static const int perLesson = 40;
  static const int perDailyStreak = 25;
  static const int bonus = 20;

  static int forSource(XpSource source) => switch (source) {
        XpSource.quiz => perQuiz,
        XpSource.game => perGame,
        XpSource.lesson => perLesson,
        XpSource.dailyStreak => perDailyStreak,
        XpSource.other => bonus,
      };
}

/// Pure helpers for turning an event log into totals / deltas.
///
/// Decoupled from storage and GetX so it's easy to unit-test and, later,
/// to swap the data source from local cache to a server endpoint.
class XpService {
  static int totalFromEvents(Iterable<XpEvent> events) =>
      events.fold(0, (sum, e) => sum + e.amount);

  /// Returns (previousTotal, newTotal) after appending [amount].
  static (int, int) projectAfterAdding(int currentTotal, int amount) =>
      (currentTotal, currentTotal + amount);
}
