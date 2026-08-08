/// ステージ戦闘のログ（1回の挑戦を記録）
class BattleLog {
  final int stageId;
  final bool victory;
  final int elapsedSeconds;
  final int totalDamageDealt;
  final int totalDamageTaken;
  final int finalPlayerHP;
  final int finalEnemyHP;
  final int enemyHPMax;
  final Map<String, int> unitLevels; // unitId -> level（強化度合いのばらつき判定用）

  BattleLog({
    required this.stageId,
    required this.victory,
    required this.elapsedSeconds,
    required this.totalDamageDealt,
    required this.totalDamageTaken,
    required this.finalPlayerHP,
    required this.finalEnemyHP,
    required this.enemyHPMax,
    required this.unitLevels,
  });

  /// 制限時間切れ（120秒到達）での敗北か
  bool get timedOut => !victory && elapsedSeconds >= 120;

  /// HPが尽きての敗北か（時間切れより前にHP0）
  bool get hpDepleted => !victory && finalPlayerHP <= 0 && !timedOut;

  /// あと一歩だったか（敵の残りHPが10%未満）
  bool get wasCloseCall => !victory && enemyHPMax > 0 && (finalEnemyHP / enemyHPMax) < 0.1;

  /// unitLevels の中で最もレベルが低いユニットのID（優先強化候補）
  /// unitLevels が空なら null
  String? get lowestLevelUnitId {
    if (unitLevels.isEmpty) return null;
    return unitLevels.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
  }
}

/// 弱点分析結果
class WeaknessAnalysis {
  final String weakestStat; // "attack" | "defense" | "health"
  final String recommendedMineral; // "Red" | "Green" | "Blue"
  final String? recommendedUnitId; // 最もレベルが低いユニット（優先強化候補）

  WeaknessAnalysis({
    required this.weakestStat,
    required this.recommendedMineral,
    this.recommendedUnitId,
  });

  /// ルールベース判定のフォールバック用固定テンプレート文言
  String getFallbackMessage() {
    switch (weakestStat) {
      case 'attack':
        return '攻撃力が足りていません。$recommendedMineral鉱石を優先装備しましょう。';
      case 'defense':
        return '防御力が心配です。$recommendedMineral鉱石で耐久力を強化しましょう。';
      case 'health':
      default:
        return 'HPに余裕がありません。$recommendedMineral鉱石でタフさを底上げしましょう。';
    }
  }

  /// 戦闘ログから弱点を分析する（ルールベース・API不要）
  factory WeaknessAnalysis.fromBattleLog(
    BattleLog log, {
    String? lowestLevelUnitId,
  }) {
    String weakestStat;
    String recommendedMineral;

    if (log.timedOut) {
      // 時間切れ＝火力不足
      weakestStat = 'attack';
      recommendedMineral = 'Red';
    } else if (log.hpDepleted && log.elapsedSeconds < 60) {
      // 早期にHPが尽きた＝防御不足
      weakestStat = 'defense';
      recommendedMineral = 'Blue';
    } else if (log.hpDepleted) {
      // 中盤以降にHPが尽きた＝タフさ（HP総量）不足
      weakestStat = 'health';
      recommendedMineral = 'Green';
    } else {
      // デフォルト（あと一歩だった場合など）は火力を推奨
      weakestStat = 'attack';
      recommendedMineral = 'Red';
    }

    return WeaknessAnalysis(
      weakestStat: weakestStat,
      recommendedMineral: recommendedMineral,
      recommendedUnitId: lowestLevelUnitId,
    );
  }
}
