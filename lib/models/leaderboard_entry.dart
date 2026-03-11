class LeaderboardEntry {
  final String cognitoId;
  final String userName;
  final int totalScore;
  final int gamesPlayed;
  final int rank;

  const LeaderboardEntry({
    required this.cognitoId,
    required this.userName,
    required this.totalScore,
    required this.gamesPlayed,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      cognitoId: json['cognitoId'] as String? ?? '',
      userName: (json['username'] ?? json['userName']) as String? ?? 'Unknown',
      totalScore: json['totalScore'] as int? ?? 0,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'cognitoId': cognitoId,
        'userName': userName,
        'totalScore': totalScore,
        'gamesPlayed': gamesPlayed,
        'rank': rank,
      };
}
