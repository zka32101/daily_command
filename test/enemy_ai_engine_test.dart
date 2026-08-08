import 'package:flutter_test/flutter_test.dart';
import 'package:daily_command/models/commander.dart';
import 'package:daily_command/viewmodels/commander_provider.dart';

void main() {
  Commander makeCommander(String personality) {
    return Commander(
      commanderId: 'test',
      name: 'テスト司令官',
      personality: personality,
      difficulty: 5,
      unitIds: ['a', 'b'],
      expiresAt: DateTime(2026, 7, 3),
    );
  }

  group('EnemyAIEngine.getEnemyAttackDamage', () {
    test('Aggressive は最も攻撃力が高い', () {
      final aggressive = EnemyAIEngine(makeCommander('Aggressive')).getEnemyAttackDamage();
      final defensive = EnemyAIEngine(makeCommander('Defensive')).getEnemyAttackDamage();
      final balanced = EnemyAIEngine(makeCommander('Balanced')).getEnemyAttackDamage();

      expect(aggressive, greaterThan(balanced));
      expect(balanced, greaterThan(defensive));
    });
  });

  group('EnemyAIEngine.getEnemyHP', () {
    test('Defensive は最もHPが高く、Aggressive は最も低い', () {
      final aggressive = EnemyAIEngine(makeCommander('Aggressive')).getEnemyHP();
      final defensive = EnemyAIEngine(makeCommander('Defensive')).getEnemyHP();
      final balanced = EnemyAIEngine(makeCommander('Balanced')).getEnemyHP();

      expect(defensive, greaterThan(balanced));
      expect(balanced, greaterThan(aggressive));
    });
  });

  group('EnemyAIEngine.getEnemyUnitPlacement', () {
    test('Aggressive は先頭2体のみ配置する', () {
      final commander = makeCommander('Aggressive');
      final placement = EnemyAIEngine(commander).getEnemyUnitPlacement();
      expect(placement.length, 2);
    });

    test('Balanced は全ユニットを配置する', () {
      final commander = makeCommander('Balanced');
      final placement = EnemyAIEngine(commander).getEnemyUnitPlacement();
      expect(placement, commander.unitIds);
    });
  });
}
