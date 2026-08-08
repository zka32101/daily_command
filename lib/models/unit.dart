class Unit {
  final String id;
  final String unitType; // Warrior / Mage / Archer / Tank / Assassin / Healer
  final int level; // 1-10
  final int xp;

  // 装備鉱石
  final Map<String, int> equipped; // {mineralType: count}
  // mineralType: "Red" / "Green" / "Blue"

  final DateTime createdAt;

  Unit({
    required this.id,
    required this.unitType,
    required this.level,
    required this.xp,
    required this.equipped,
    required this.createdAt,
  });

  /// ユニットタイプ別の基礎ステータス倍率
  /// Warrior/Mage/Archer は元々の基礎値（倍率1.0相当）に合わせている
  static const Map<String, double> _attackMultiplier = {
    'Warrior': 1.0,
    'Mage': 0.8,
    'Archer': 1.1,
    'Tank': 0.6,
    'Assassin': 1.4,
    'Healer': 0.5,
  };

  static const Map<String, double> _defenseMultiplier = {
    'Warrior': 1.0,
    'Mage': 0.7,
    'Archer': 0.8,
    'Tank': 1.8,
    'Assassin': 0.6,
    'Healer': 0.9,
  };

  static const Map<String, double> _healthMultiplier = {
    'Warrior': 1.0,
    'Mage': 0.8,
    'Archer': 0.9,
    'Tank': 1.6,
    'Assassin': 0.7,
    'Healer': 1.1,
  };

  double _multiplierFor(Map<String, double> table) => table[unitType] ?? 1.0;

  // ステータス計算（ユニットタイプ別倍率 + 属性補正）
  int getAttack() {
    int base = (level * 5 * _multiplierFor(_attackMultiplier)).round();
    int bonus = _getMineralBonus('Red');
    return base + bonus;
  }

  int getDefense() {
    int base = (level * 3 * _multiplierFor(_defenseMultiplier)).round();
    int bonus = _getMineralBonus('Blue');
    return base + bonus;
  }

  int getHealth() {
    int base = (level * 10 * _multiplierFor(_healthMultiplier)).round();
    int bonus = _getMineralBonus('Green');
    return base + bonus;
  }

  int _getMineralBonus(String mineralType) {
    return (equipped[mineralType] ?? 0) * 2;
  }

  // 強化に必要な鉱石
  int getMineralsNeeded() {
    if (level >= 10) return 0;
    return level + 1;
  }

  /// Healer の回復量（レベルに応じてスケーリング）
  int getHealAmount() => 15 + (level * 3);

  Unit copyWith({
    String? id,
    String? unitType,
    int? level,
    int? xp,
    Map<String, int>? equipped,
    DateTime? createdAt,
  }) {
    return Unit(
      id: id ?? this.id,
      unitType: unitType ?? this.unitType,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      equipped: equipped ?? this.equipped,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'unitType': unitType,
    'level': level,
    'xp': xp,
    'equipped': equipped,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
    id: json['id'] as String,
    unitType: json['unitType'] as String,
    level: json['level'] as int,
    xp: json['xp'] as int,
    equipped: Map<String, int>.from(json['equipped'] as Map),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  @override
  String toString() => 'Unit(id: $id, type: $unitType, level: $level)';
}
