class GameSession {
  final String id;
  final String cognitoId;
  final String username;
  final String gameId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int durationSeconds;
  final bool isBestScore;
  final String gameTitle;
  final String gameType;
  final DateTime completedAt;

  const GameSession({
    required this.id,
    required this.cognitoId,
    required this.username,
    required this.gameId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.durationSeconds,
    required this.isBestScore,
    required this.gameTitle,
    required this.gameType,
    required this.completedAt,
  });

  double get accuracy =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  factory GameSession.fromJson(Map<String, dynamic> json) {
    final game = json['game'] is Map<String, dynamic>
        ? (json['game'] as Map<String, dynamic>)
        : const <String, dynamic>{};

    // History endpoint uses `playedAt`; older payloads might use `completedAt`.
    final completedAtRaw =
        (json['playedAt'] as String?) ?? (json['completedAt'] as String?);

    return GameSession(
      id: json['id'] as String? ?? '',
      cognitoId: json['cognitoId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      gameId: json['gameId'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      isBestScore: json['isBestScore'] as bool? ?? false,
      gameTitle: (json['gameTitle'] as String?) ??
          (game['title'] as String?) ??
          '',
      gameType: (json['gameType'] as String?) ??
          (game['type'] as String?) ??
          '',
      completedAt:
          completedAtRaw != null ? DateTime.parse(completedAtRaw) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cognitoId': cognitoId,
        'username': username,
        'gameId': gameId,
        'score': score,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'durationSeconds': durationSeconds,
        'isBestScore': isBestScore,
        'gameTitle': gameTitle,
        'gameType': gameType,
        'completedAt': completedAt.toIso8601String(),
      };
}
