class Commander {
  final String commanderId;
  final String name;
  final String personality; // Aggressive / Defensive / Balanced
  final int difficulty; // 1-10
  final List<String> unitIds; // 敵が持つユニットID
  final DateTime expiresAt; // 次日 00:00

  Commander({
    required this.commanderId,
    required this.name,
    required this.personality,
    required this.difficulty,
    required this.unitIds,
    required this.expiresAt,
  });

  // AI戦術に基づく敵ユニット配置
  List<String> getAIUnitPlacement() {
    // 簡易実装: personality に基づいて配置順序を変える
    switch (personality) {
      case 'Aggressive':
        // 強力なユニットを最初に配置
        return unitIds.take(2).toList();
      case 'Defensive':
        // バランスの取れた配置
        return unitIds.take(3).toList();
      case 'Balanced':
        // すべてのユニット
        return unitIds;
      default:
        return unitIds;
    }
  }

  bool isExpired() => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'commanderId': commanderId,
    'name': name,
    'personality': personality,
    'difficulty': difficulty,
    'unitIds': unitIds,
    'expiresAt': expiresAt.toIso8601String(),
  };

  factory Commander.fromJson(Map<String, dynamic> json) => Commander(
    commanderId: json['commanderId'] as String,
    name: json['name'] as String,
    personality: json['personality'] as String,
    difficulty: json['difficulty'] as int,
    unitIds: List<String>.from(json['unitIds'] as List),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );

  @override
  String toString() => 'Commander($name, difficulty: $difficulty)';
}
