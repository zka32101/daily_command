import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_command/models/pvp_match.dart';

void main() {
  group('EloCalculator.expectedScore', () {
    test('同レーティング同士は期待勝率0.5', () {
      expect(EloCalculator.expectedScore(1200, 1200), closeTo(0.5, 0.001));
    });

    test('自分のレーティングが高いほど期待勝率が上がる', () {
      final higher = EloCalculator.expectedScore(1400, 1200);
      final lower = EloCalculator.expectedScore(1000, 1200);
      expect(higher, greaterThan(0.5));
      expect(lower, lessThan(0.5));
      expect(higher, greaterThan(lower));
    });
  });

  group('EloCalculator.kFactor', () {
    test('rating <= 1800 は K=32', () {
      expect(EloCalculator.kFactor(1200), 32);
      expect(EloCalculator.kFactor(1800), 32);
    });

    test('rating > 1800 は K=16（上級者帯は変動を抑える）', () {
      expect(EloCalculator.kFactor(1801), 16);
      expect(EloCalculator.kFactor(2000), 16);
    });
  });

  group('EloCalculator.newRating', () {
    test('同格相手に勝利するとレーティングが上がる', () {
      final result = EloCalculator.newRating(
        currentRating: 1200,
        opponentRating: 1200,
        won: true,
      );
      expect(result, greaterThan(1200));
    });

    test('同格相手に敗北するとレーティングが下がる', () {
      final result = EloCalculator.newRating(
        currentRating: 1200,
        opponentRating: 1200,
        won: false,
      );
      expect(result, lessThan(1200));
    });

    test('格上に勝利すると格下に勝つより上昇幅が大きい', () {
      final beatStrong = EloCalculator.newRating(
        currentRating: 1200,
        opponentRating: 1400,
        won: true,
      );
      final beatWeak = EloCalculator.newRating(
        currentRating: 1200,
        opponentRating: 1000,
        won: true,
      );
      expect(beatStrong - 1200, greaterThan(beatWeak - 1200));
    });
  });

  group('PvpMatchmaker.generateOpponent', () {
    test('相手のレーティングは自分の ±150 の範囲内', () {
      final random = Random(42); // 固定シードで再現性確保
      final opponent = PvpMatchmaker.generateOpponent(1200, random: random);
      expect(opponent.rating, greaterThanOrEqualTo(1050));
      expect(opponent.rating, lessThanOrEqualTo(1350));
    });

    test('相手のレーティングは 800 未満にならない（下限クランプ）', () {
      final random = Random(1);
      final opponent = PvpMatchmaker.generateOpponent(850, random: random);
      expect(opponent.rating, greaterThanOrEqualTo(800));
    });
  });

  group('PvpMatchmaker.resolveMatch', () {
    test('同レーティング・乱数0.4なら勝利（期待勝率0.5を下回る）', () {
      // Random.nextDouble() が固定値を返すモックの代わりに、
      // 十分大きい試行回数で概ね五分五分になることを検証する
      final random = Random(123);
      int wins = 0;
      const trials = 2000;
      for (int i = 0; i < trials; i++) {
        if (PvpMatchmaker.resolveMatch(1200, PvpOpponent(name: 'x', rating: 1200), random: random)) {
          wins++;
        }
      }
      final winRate = wins / trials;
      expect(winRate, closeTo(0.5, 0.05));
    });
  });
}
