import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import '../models/pvp_match.dart';

/// プレイヤーのPvPレーティング（モック・ローカル管理）
/// 実装時: Firebase 本設定後は pvpRankings/{userId} と同期する
final pvpRankingProvider = StateProvider<PvpRanking>((ref) => PvpRanking());

class PvpHelper {
  /// マッチング相手を生成
  static PvpOpponent findOpponent(WidgetRef ref) {
    final ranking = ref.read(pvpRankingProvider);
    return PvpMatchmaker.generateOpponent(ranking.rating);
  }

  /// 対戦を解決し、レーティングを更新して勝敗を返す
  static bool resolveMatch(WidgetRef ref, PvpOpponent opponent) {
    final ranking = ref.read(pvpRankingProvider);
    final won = PvpMatchmaker.resolveMatch(ranking.rating, opponent);

    final newRating = EloCalculator.newRating(
      currentRating: ranking.rating,
      opponentRating: opponent.rating,
      won: won,
    );

    ref.read(pvpRankingProvider.notifier).state = ranking.copyWith(
      rating: newRating,
      wins: won ? ranking.wins + 1 : ranking.wins,
      losses: won ? ranking.losses : ranking.losses + 1,
      winStreak: won ? ranking.winStreak + 1 : 0,
    );

    return won;
  }
}
