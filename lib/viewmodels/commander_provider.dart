import 'package:riverpod/legacy.dart';
import '../models/index.dart';

/// 本日の敵司令官を取得
final commanderProvider = StateProvider<Commander>((ref) {
  return _generateTodaysCommander();
});

/// 敵司令官を生成（日替わり）
Commander _generateTodaysCommander() {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

  // 日付をシードにして、敵司令官を決定
  final commaderIndex = dayOfYear % 3; // 3種類のパターン

  switch (commaderIndex) {
    case 0:
      return _createAggressiveCommander();
    case 1:
      return _createDefensiveCommander();
    case 2:
    default:
      return _createBalancedCommander();
  }
}

/// 攻撃型司令官
Commander _createAggressiveCommander() {
  return Commander(
    commanderId: 'aggressive_commander',
    name: '暴れん坊の騎士',
    personality: 'Aggressive',
    difficulty: 7,
    unitIds: ['warrior_strong', 'warrior_strong', 'archer'],
    expiresAt: DateTime.now().add(const Duration(days: 1)),
  );
}

/// 防御型司令官
Commander _createDefensiveCommander() {
  return Commander(
    commanderId: 'defensive_commander',
    name: '石壁の盾使い',
    personality: 'Defensive',
    difficulty: 6,
    unitIds: ['warrior', 'mage', 'mage_shield'],
    expiresAt: DateTime.now().add(const Duration(days: 1)),
  );
}

/// バランス型司令官
Commander _createBalancedCommander() {
  return Commander(
    commanderId: 'balanced_commander',
    name: '知略の魔導士',
    personality: 'Balanced',
    difficulty: 6,
    unitIds: ['warrior', 'archer', 'mage'],
    expiresAt: DateTime.now().add(const Duration(days: 1)),
  );
}

/// 敵AI戦術エンジン
class EnemyAIEngine {
  final Commander commander;

  EnemyAIEngine(this.commander);

  /// 敵の攻撃ダメージを計算（性格に基づく）
  int getEnemyAttackDamage() {
    switch (commander.personality) {
      case 'Aggressive':
        return 15; // 攻撃力が高い
      case 'Defensive':
        return 8; // 攻撃力が低い（防御重視）
      case 'Balanced':
      default:
        return 10; // バランス
    }
  }

  /// 敵のHP（性格に基づくバリエーション）
  int getEnemyHP() {
    switch (commander.personality) {
      case 'Aggressive':
        return 100; // 攻撃型は HP が低い
      case 'Defensive':
        return 150; // 防御型は HP が高い
      case 'Balanced':
      default:
        return 120; // バランス
    }
  }

  /// 敵の配置戦術（性格に基づく）
  List<String> getEnemyUnitPlacement() {
    switch (commander.personality) {
      case 'Aggressive':
        // 強力なユニットを最初に配置（即座に攻撃）
        return commander.unitIds.take(2).toList();
      case 'Defensive':
        // 防御ユニットを前に配置
        return commander.unitIds;
      case 'Balanced':
      default:
        // すべてのユニット
        return commander.unitIds;
    }
  }

  /// 敵の説明文を生成
  String getCommanderDescription() {
    switch (commander.personality) {
      case 'Aggressive':
        return '${commander.name}は猛烈な攻撃で襲いかかる。';
      case 'Defensive':
        return '${commander.name}は堅固な防御で耐え抜く。';
      case 'Balanced':
      default:
        return '${commander.name}は巧妙な戦術を駆使する。';
    }
  }
}
