class Stage {
  final int stageId;
  final int difficulty; // 1-10
  final int enemyHealth;
  final List<String> enemyUnitIds; // 敵が持つユニットID
  final int mineralReward; // 鉱石報酬

  Stage({
    required this.stageId,
    required this.difficulty,
    required this.enemyHealth,
    required this.enemyUnitIds,
    required this.mineralReward,
  });

  // 難度スケーリング計算
  double getDifficultyMultiplier(int playerLevel) {
    double base = 1.0 + (difficulty * 0.1);
    double playerAdjust = playerLevel > 5 ? 0.95 : 1.05;
    return base * playerAdjust;
  }

  int getScaledEnemyHealth(int playerLevel) {
    return (enemyHealth * getDifficultyMultiplier(playerLevel)).toInt();
  }

  Map<String, dynamic> toJson() => {
    'stageId': stageId,
    'difficulty': difficulty,
    'enemyHealth': enemyHealth,
    'enemyUnitIds': enemyUnitIds,
    'mineralReward': mineralReward,
  };

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
    stageId: json['stageId'] as int,
    difficulty: json['difficulty'] as int,
    enemyHealth: json['enemyHealth'] as int,
    enemyUnitIds: List<String>.from(json['enemyUnitIds'] as List),
    mineralReward: json['mineralReward'] as int,
  );

  @override
  String toString() => 'Stage(id: $stageId, difficulty: $difficulty)';
}
