/// 鮮度ユニット（②24h FOMO・毎朝1体配布・24時間で消滅）
class FreshUnit {
  final String unitId;
  final String unitType;
  final String rarity; // "Rare" | "Epic" | "Legendary"
  final DateTime expiresAt; // 配布翌日 09:00 JST

  FreshUnit({
    required this.unitId,
    required this.unitType,
    required this.rarity,
    required this.expiresAt,
  });

  bool isExpired(DateTime now) => now.isAfter(expiresAt);

  /// 残り時間（負にはならない。期限切れなら Duration.zero）
  Duration remainingTime(DateTime now) {
    final diff = expiresAt.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  static const List<String> _rarityOrder = ['Rare', 'Epic', 'Legendary'];
  static const List<String> _unitTypes = [
    'Warrior', 'Mage', 'Archer', 'Tank', 'Assassin',
  ];

  /// 日付をシードにした決定論的な生成（同じ日は同じ端末なら常に同じユニット）
  factory FreshUnit.generateForDate(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;

    final rarity = _rarityOrder[dayOfYear % _rarityOrder.length];
    final unitType = _unitTypes[dayOfYear % _unitTypes.length];

    // 次日 09:00 JST が配布終了時刻
    final tomorrow = date.add(const Duration(days: 1));
    final expiresAt = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);

    return FreshUnit(
      unitId: 'fresh_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
      unitType: unitType,
      rarity: rarity,
      expiresAt: expiresAt,
    );
  }

  /// レアリティに応じたステータス倍率（強力なユニットとして配布する演出）
  double get statBoost {
    switch (rarity) {
      case 'Legendary':
        return 2.0;
      case 'Epic':
        return 1.5;
      case 'Rare':
      default:
        return 1.2;
    }
  }
}
