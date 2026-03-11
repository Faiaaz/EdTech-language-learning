class GameSession {
  final String id;
  final String cognitoId;
  final String gameId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int durationSeconds;
  final DateTime completedAt;

  const GameSession({
    required this.id,
    required this.cognitoId,
    required this.gameId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.durationSeconds,
    required this.completedAt,
  });

  double get accuracy =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] as String? ?? '',
      cognitoId: json['cognitoId'] as String? ?? '',
      gameId: json['gameId'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cognitoId': cognitoId,
        'gameId': gameId,
        'score': score,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'durationSeconds': durationSeconds,
        'completedAt': completedAt.toIso8601String(),
      };
}
