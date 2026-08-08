import 'package:flutter_test/flutter_test.dart';
import 'package:daily_command/models/mining.dart';

void main() {
  group('MiningLog.canMine / mine — 日次リセット', () {
    test('初回（16時間経過・todayCount=0）は採掘可能', () {
      final log = MiningLog(
        userId: 'u1',
        lastMiningAt: DateTime.now().subtract(const Duration(hours: 20)),
        todayCount: 0,
        resetAt: DateTime.now().add(const Duration(hours: 12)),
        minerals: {'Red': 0, 'Green': 0, 'Blue': 0},
      );
      expect(log.canMine(), isTrue);
    });

    test('採掘直後（todayCount=1・resetAt未到来）は採掘不可', () {
      final log = MiningLog(
        userId: 'u1',
        lastMiningAt: DateTime.now(),
        todayCount: 1,
        resetAt: DateTime.now().add(const Duration(hours: 10)),
        minerals: {'Red': 1, 'Green': 1, 'Blue': 1},
      );
      expect(log.canMine(), isFalse);
    });

    test('【回帰テスト】resetAt を過ぎていれば todayCount=1 でも採掘可能になる', () {
      // 過去に修正されたバグ: todayCount をリセットする仕組みが存在せず、
      // 一度採掘すると永久に採掘不可能になっていた。
      final log = MiningLog(
        userId: 'u1',
        lastMiningAt: DateTime.now().subtract(const Duration(hours: 30)),
        todayCount: 1,
        resetAt: DateTime.now().subtract(const Duration(hours: 1)), // 既に過ぎている
        minerals: {'Red': 1, 'Green': 1, 'Blue': 1},
      );
      expect(log.canMine(), isTrue);
    });

    test('resetAt を過ぎた状態で mine() すると todayCount が 1 に再設定され、resetAt が翌日に更新される', () {
      final pastResetAt = DateTime.now().subtract(const Duration(hours: 1));
      final log = MiningLog(
        userId: 'u1',
        lastMiningAt: DateTime.now().subtract(const Duration(hours: 30)),
        todayCount: 1,
        resetAt: pastResetAt,
        minerals: {'Red': 1, 'Green': 1, 'Blue': 1},
      );

      final result = log.mine();

      expect(result.todayCount, 1);
      expect(result.resetAt.isAfter(pastResetAt), isTrue);
      expect(result.minerals['Red'], 2); // 既存の鉱石に加算される
    });

    test('resetAt未到来・todayCount=0 で mine() すると todayCount=1・resetAt は変わらない', () {
      final futureResetAt = DateTime.now().add(const Duration(hours: 10));
      final log = MiningLog(
        userId: 'u1',
        lastMiningAt: DateTime.now().subtract(const Duration(hours: 20)),
        todayCount: 0,
        resetAt: futureResetAt,
        minerals: {'Red': 0, 'Green': 0, 'Blue': 0},
      );

      final result = log.mine();

      expect(result.todayCount, 1);
      expect(result.resetAt, futureResetAt);
    });

    test('採掘不可な状態で mine() を呼んでも状態は変化しない', () {
      final log = MiningLog(
        userId: 'u1',
        lastMiningAt: DateTime.now(),
        todayCount: 1,
        resetAt: DateTime.now().add(const Duration(hours: 10)),
        minerals: {'Red': 1, 'Green': 1, 'Blue': 1},
      );

      final result = log.mine();

      expect(identical(result, log), isTrue);
    });
  });

  group('MiningLog.consumeMinerals', () {
    test('十分な鉱石があれば消費できる', () {
      final log = MiningLog(
        userId: 'u1',
        lastMiningAt: DateTime.now(),
        todayCount: 0,
        resetAt: DateTime.now(),
        minerals: {'Red': 5, 'Green': 5, 'Blue': 5},
      );

      final result = log.consumeMinerals({'Red': 3});
      expect(result.minerals['Red'], 2);
    });

    test('鉱石が不足していると例外を投げる', () {
      final log = MiningLog(
        userId: 'u1',
        lastMiningAt: DateTime.now(),
        todayCount: 0,
        resetAt: DateTime.now(),
        minerals: {'Red': 1},
      );

      expect(() => log.consumeMinerals({'Red': 5}), throwsException);
    });
  });
}
