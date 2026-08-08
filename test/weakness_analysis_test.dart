import 'package:flutter_test/flutter_test.dart';
import 'package:daily_command/models/battle_log.dart';

void main() {
  group('WeaknessAnalysis.fromBattleLog', () {
    test('制限時間切れ（120秒到達）で敗北 → attack不足・Red推奨', () {
      final log = BattleLog(
        stageId: 2,
        victory: false,
        elapsedSeconds: 120,
        totalDamageDealt: 80,
        totalDamageTaken: 40,
        finalPlayerHP: 110,
        finalEnemyHP: 40,
        enemyHPMax: 120,
        unitLevels: {'warrior_1': 1},
      );

      final result = WeaknessAnalysis.fromBattleLog(log);

      expect(result.weakestStat, 'attack');
      expect(result.recommendedMineral, 'Red');
    });

    test('早期（60秒未満）にHPが尽きて敗北 → defense不足・Blue推奨', () {
      final log = BattleLog(
        stageId: 2,
        victory: false,
        elapsedSeconds: 45,
        totalDamageDealt: 30,
        totalDamageTaken: 150,
        finalPlayerHP: 0,
        finalEnemyHP: 90,
        enemyHPMax: 120,
        unitLevels: {'warrior_1': 1},
      );

      final result = WeaknessAnalysis.fromBattleLog(log);

      expect(result.weakestStat, 'defense');
      expect(result.recommendedMineral, 'Blue');
    });

    test('中盤以降（60秒以上）にHPが尽きて敗北 → health不足・Green推奨', () {
      final log = BattleLog(
        stageId: 2,
        victory: false,
        elapsedSeconds: 90,
        totalDamageDealt: 60,
        totalDamageTaken: 150,
        finalPlayerHP: 0,
        finalEnemyHP: 60,
        enemyHPMax: 120,
        unitLevels: {'warrior_1': 1},
      );

      final result = WeaknessAnalysis.fromBattleLog(log);

      expect(result.weakestStat, 'health');
      expect(result.recommendedMineral, 'Green');
    });

    test('recommendedUnitId が渡された場合はそのまま保持される', () {
      final log = BattleLog(
        stageId: 2,
        victory: false,
        elapsedSeconds: 120,
        totalDamageDealt: 80,
        totalDamageTaken: 40,
        finalPlayerHP: 110,
        finalEnemyHP: 40,
        enemyHPMax: 120,
        unitLevels: {'warrior_1': 1, 'archer_1': 3},
      );

      final result = WeaknessAnalysis.fromBattleLog(log, lowestLevelUnitId: 'warrior_1');

      expect(result.recommendedUnitId, 'warrior_1');
    });
  });

  group('BattleLog.lowestLevelUnitId', () {
    test('unitLevels が空なら null', () {
      final log = BattleLog(
        stageId: 2,
        victory: false,
        elapsedSeconds: 120,
        totalDamageDealt: 0,
        totalDamageTaken: 0,
        finalPlayerHP: 100,
        finalEnemyHP: 50,
        enemyHPMax: 100,
        unitLevels: const {},
      );
      expect(log.lowestLevelUnitId, isNull);
    });

    test('最もレベルが低いユニットのIDを返す', () {
      final log = BattleLog(
        stageId: 2,
        victory: false,
        elapsedSeconds: 120,
        totalDamageDealt: 0,
        totalDamageTaken: 0,
        finalPlayerHP: 100,
        finalEnemyHP: 50,
        enemyHPMax: 100,
        unitLevels: {'warrior_1': 3, 'mage_1': 1, 'archer_1': 5},
      );
      expect(log.lowestLevelUnitId, 'mage_1');
    });
  });

  group('BattleLog 判定プロパティ', () {
    test('timedOut は敗北かつ120秒到達時のみ true', () {
      final log = BattleLog(
        stageId: 1,
        victory: false,
        elapsedSeconds: 120,
        totalDamageDealt: 0,
        totalDamageTaken: 0,
        finalPlayerHP: 100,
        finalEnemyHP: 50,
        enemyHPMax: 100,
        unitLevels: {},
      );
      expect(log.timedOut, isTrue);
      expect(log.hpDepleted, isFalse);
    });

    test('victory が true の場合は timedOut も hpDepleted も false', () {
      final log = BattleLog(
        stageId: 1,
        victory: true,
        elapsedSeconds: 120,
        totalDamageDealt: 100,
        totalDamageTaken: 0,
        finalPlayerHP: 150,
        finalEnemyHP: 0,
        enemyHPMax: 100,
        unitLevels: {},
      );
      expect(log.timedOut, isFalse);
      expect(log.hpDepleted, isFalse);
    });

    test('wasCloseCall は敗北かつ敵HPが10%未満の場合のみ true', () {
      final log = BattleLog(
        stageId: 1,
        victory: false,
        elapsedSeconds: 120,
        totalDamageDealt: 0,
        totalDamageTaken: 0,
        finalPlayerHP: 50,
        finalEnemyHP: 5,
        enemyHPMax: 100,
        unitLevels: {},
      );
      expect(log.wasCloseCall, isTrue);
    });
  });
}
