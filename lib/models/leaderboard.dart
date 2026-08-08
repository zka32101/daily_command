class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int rank;
  final int weeklyScore;
  final int consecutiveLogins;
  final int level;

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.rank,
    required this.weeklyScore,
    required this.consecutiveLogins,
    required this.level,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'displayName': displayName,
    'rank': rank,
    'weeklyScore': weeklyScore,
    'consecutiveLogins': consecutiveLogins,
    'level': level,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
    userId: json['userId'] as String,
    displayName: json['displayName'] as String,
    rank: json['rank'] as int,
    weeklyScore: json['weeklyScore'] as int,
    consecutiveLogins: json['consecutiveLogins'] as int,
    level: json['level'] as int,
  );

  @override
  String toString() => '$displayName (Rank: $rank, Score: $weeklyScore)';
}

class Leaderboard {
  final List<LeaderboardEntry> entries;
  final int? currentUserRank;
  final DateTime weekStartDate;

  Leaderboard({
    required this.entries,
    this.currentUserRank,
    required this.weekStartDate,
  });

  // 週のスコアに基づくランキング
  List<LeaderboardEntry> getTopPlayers({int limit = 10}) {
    return entries.take(limit).toList();
  }

  // 現在のユーザーの周辺ランキング
  List<LeaderboardEntry> getNearbyRanks(int userRank, {int range = 2}) {
    final start = (userRank - range - 1).clamp(0, entries.length - 1);
    final end = (userRank + range).clamp(0, entries.length);
    return entries.sublist(start, end);
  }
}
