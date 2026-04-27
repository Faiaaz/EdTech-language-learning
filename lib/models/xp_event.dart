/// Why the user earned XP. Used for the audit log / history and to
/// decide which celebration animation to trigger.
enum XpSource {
  quiz,
  game,
  lesson,
  dailyStreak,
  other;

  String get label => switch (this) {
        XpSource.quiz => 'Quiz complete',
        XpSource.game => 'Game finished',
        XpSource.lesson => 'Lesson complete',
        XpSource.dailyStreak => 'Daily streak',
        XpSource.other => 'Bonus',
      };
}

/// A single XP-granting event. Plural events are summed to get total XP.
///
/// Keeping this as a log (rather than a single counter) means we can
/// later migrate to "compute from existing game/quiz history API" by
/// transforming server-side events into `XpEvent`s without rewriting
/// any of the UI.
class XpEvent {
  const XpEvent({
    required this.id,
    required this.amount,
    required this.source,
    required this.earnedAt,
    this.note,
  });

  final String id;
  final int amount;
  final XpSource source;
  final DateTime earnedAt;
  final String? note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'source': source.name,
        'earnedAt': earnedAt.toIso8601String(),
        'note': note,
      };

  static XpEvent fromJson(Map<String, dynamic> json) {
    return XpEvent(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      source: XpSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => XpSource.other,
      ),
      earnedAt: DateTime.tryParse(json['earnedAt'] as String? ?? '') ??
          DateTime.now(),
      note: json['note'] as String?,
    );
  }
}
