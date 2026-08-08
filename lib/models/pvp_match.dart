import 'dart:math';

/// プレイヤーのPvPレーティング
class PvpRanking {
  final int rating;
  final int wins;
  final int losses;
  final int winStreak;

  PvpRanking({
    this.rating = 1200,
    this.wins = 0,
    this.losses = 0,
    this.winStreak = 0,
  });

  PvpRanking copyWith({
    int? rating,
    int? wins,
    int? losses,
    int? winStreak,
  }) {
    return PvpRanking(
      rating: rating ?? this.rating,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      winStreak: winStreak ?? this.winStreak,
    );
  }
}

/// マッチング相手（モック）
class PvpOpponent {
  final String name;
  final int rating;

  PvpOpponent({required this.name, required this.rating});
}

/// ELOレーティング計算（design doc: PVP_DESIGN.md §5 準拠）
class EloCalculator {
  /// 期待勝率（0.0〜1.0）
  static double expectedScore(int ratingA, int ratingB) {
    return 1 / (1 + pow(10, (ratingB - ratingA) / 400));
  }

  /// Kファクター: 上級者帯（rating > 1800）は変動を小さく
  static int kFactor(int rating) => rating > 1800 ? 16 : 32;

  /// 対戦後の新レーティング
  static int newRating({
    required int currentRating,
    required int opponentRating,
    required bool won,
  }) {
    final expected = expectedScore(currentRating, opponentRating);
    final actual = won ? 1.0 : 0.0;
    final k = kFactor(currentRating);
    final delta = (k * (actual - expected)).round();
    return currentRating + delta;
  }
}

/// マッチメイキング・対戦解決ヘルパー
class PvpMatchmaker {
  /// レーティング ±150 の範囲で仮想対戦相手を生成（モック）
  static PvpOpponent generateOpponent(int myRating, {Random? random}) {
    final rand = random ?? Random();
    final offset = rand.nextInt(301) - 150; // -150 〜 +150
    final opponentRating = (myRating + offset).clamp(800, 3000);

    const names = ['勇敢な騎士', '疾風の弓使い', '知略の魔導士', '石壁の盾使い', '暗躍の刺客'];
    final name = names[rand.nextInt(names.length)];

    return PvpOpponent(name: name, rating: opponentRating);
  }

  /// 対戦結果を確率的に決定する（期待勝率に基づく）
  static bool resolveMatch(int myRating, PvpOpponent opponent, {Random? random}) {
    final rand = random ?? Random();
    final winProbability = EloCalculator.expectedScore(myRating, opponent.rating);
    return rand.nextDouble() < winProbability;
  }
}
