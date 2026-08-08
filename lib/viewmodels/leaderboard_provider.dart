import 'package:riverpod/legacy.dart';
import '../models/leaderboard.dart';

/// 週間リーダーボード取得
final leaderboardProvider = StateProvider<Leaderboard>((ref) {
  return _generateMockLeaderboard();
});

/// モック リーダーボード生成（デバッグ用）
Leaderboard _generateMockLeaderboard() {
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));

  final entries = [
    LeaderboardEntry(
      userId: 'user_001',
      displayName: '勇敢な騎士',
      rank: 1,
      weeklyScore: 8500,
      consecutiveLogins: 7,
      level: 15,
    ),
    LeaderboardEntry(
      userId: 'user_002',
      displayName: '知略の魔導士',
      rank: 2,
      weeklyScore: 7800,
      consecutiveLogins: 5,
      level: 12,
    ),
    LeaderboardEntry(
      userId: 'user_003',
      displayName: '疾風の弓使い',
      rank: 3,
      weeklyScore: 7200,
      consecutiveLogins: 6,
      level: 11,
    ),
    LeaderboardEntry(
      userId: 'user_004',
      displayName: 'あなた',
      rank: 4,
      weeklyScore: 6800,
      consecutiveLogins: 4,
      level: 9,
    ),
    LeaderboardEntry(
      userId: 'user_005',
      displayName: '暴れん坊の戦士',
      rank: 5,
      weeklyScore: 6200,
      consecutiveLogins: 3,
      level: 8,
    ),
    LeaderboardEntry(
      userId: 'user_006',
      displayName: '石壁の盾使い',
      rank: 6,
      weeklyScore: 5800,
      consecutiveLogins: 2,
      level: 7,
    ),
    LeaderboardEntry(
      userId: 'user_007',
      displayName: '炎の賢者',
      rank: 7,
      weeklyScore: 5200,
      consecutiveLogins: 1,
      level: 6,
    ),
    LeaderboardEntry(
      userId: 'user_008',
      displayName: '氷の精霊使い',
      rank: 8,
      weeklyScore: 4800,
      consecutiveLogins: 1,
      level: 5,
    ),
    LeaderboardEntry(
      userId: 'user_009',
      displayName: '光の守護者',
      rank: 9,
      weeklyScore: 4200,
      consecutiveLogins: 0,
      level: 4,
    ),
    LeaderboardEntry(
      userId: 'user_010',
      displayName: '影の刺客',
      rank: 10,
      weeklyScore: 3800,
      consecutiveLogins: 0,
      level: 3,
    ),
  ];

  return Leaderboard(
    entries: entries,
    currentUserRank: 4,
    weekStartDate: weekStart,
  );
}
