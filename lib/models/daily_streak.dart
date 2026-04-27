class DailyGoal {
  final int minutesTarget;

  const DailyGoal({this.minutesTarget = 5});

  Map<String, dynamic> toJson() => {
        'minutesTarget': minutesTarget,
      };

  factory DailyGoal.fromJson(Map<String, dynamic> json) => DailyGoal(
        minutesTarget: (json['minutesTarget'] as num?)?.toInt() ?? 5,
      );
}

class DailyStreakState {
  /// Date string in `YYYY-MM-DD` local time.
  final String? lastCompletedDate;
  final int streakCount;
  final int streakFreezes;

  const DailyStreakState({
    required this.lastCompletedDate,
    required this.streakCount,
    required this.streakFreezes,
  });

  static const defaults =
      DailyStreakState(lastCompletedDate: null, streakCount: 0, streakFreezes: 0);

  Map<String, dynamic> toJson() => {
        'lastCompletedDate': lastCompletedDate,
        'streakCount': streakCount,
        'streakFreezes': streakFreezes,
      };

  factory DailyStreakState.fromJson(Map<String, dynamic> json) => DailyStreakState(
        lastCompletedDate: json['lastCompletedDate'] as String?,
        streakCount: (json['streakCount'] as num?)?.toInt() ?? 0,
        streakFreezes: (json['streakFreezes'] as num?)?.toInt() ?? 0,
      );
}

