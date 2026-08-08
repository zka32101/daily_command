class MiningLog {
  final String userId;
  final DateTime lastMiningAt;
  final int todayCount; // 0-1 (+ 課金で追加)
  final DateTime resetAt; // 次日 09:00 JST

  // 鉱石在庫
  final Map<String, int> minerals; // {Red, Green, Blue}

  MiningLog({
    required this.userId,
    required this.lastMiningAt,
    required this.todayCount,
    required this.resetAt,
    required this.minerals,
  });

  /// 採掘可能かどうかを判定
  bool canMine() {
    final now = DateTime.now();
    // 日付境界（resetAt）を過ぎていれば todayCount に関わらず採掘可能
    if (now.isAfter(resetAt)) return true;

    // 1日1回制限（16時間クールタイム）
    Duration elapsed = now.difference(lastMiningAt);
    return elapsed.inHours >= 16 && todayCount < 1;
  }

  /// 次の採掘可能時刻（JST 09:00）
  Duration timeUntilReset() {
    return resetAt.difference(DateTime.now());
  }

  /// 次日 09:00 JST を計算
  static DateTime _nextResetAfter(DateTime from) {
    final tomorrow = from.add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
  }

  /// 採掘実行（1回/日。日付境界を過ぎていれば todayCount と resetAt を再計算する）
  MiningLog mine() {
    if (!canMine()) return this;

    final now = DateTime.now();
    final crossedReset = now.isAfter(resetAt);

    final newMinerals = Map<String, int>.from(minerals);
    newMinerals['Red'] = (newMinerals['Red'] ?? 0) + 1;
    newMinerals['Green'] = (newMinerals['Green'] ?? 0) + 1;
    newMinerals['Blue'] = (newMinerals['Blue'] ?? 0) + 1;

    return MiningLog(
      userId: userId,
      lastMiningAt: now,
      todayCount: crossedReset ? 1 : todayCount + 1,
      resetAt: crossedReset ? _nextResetAfter(now) : resetAt,
      minerals: newMinerals,
    );
  }

  /// 鉱石を消費
  MiningLog consumeMinerals(Map<String, int> cost) {
    final newMinerals = Map<String, int>.from(minerals);
    cost.forEach((type, amount) {
      newMinerals[type] = (newMinerals[type] ?? 0) - amount;
      if (newMinerals[type]! < 0) {
        throw Exception('Not enough minerals: $type');
      }
    });
    return copyWith(minerals: newMinerals);
  }

  MiningLog copyWith({
    String? userId,
    DateTime? lastMiningAt,
    int? todayCount,
    DateTime? resetAt,
    Map<String, int>? minerals,
  }) {
    return MiningLog(
      userId: userId ?? this.userId,
      lastMiningAt: lastMiningAt ?? this.lastMiningAt,
      todayCount: todayCount ?? this.todayCount,
      resetAt: resetAt ?? this.resetAt,
      minerals: minerals ?? this.minerals,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'lastMiningAt': lastMiningAt.toIso8601String(),
    'todayCount': todayCount,
    'resetAt': resetAt.toIso8601String(),
    'minerals': minerals,
  };

  factory MiningLog.fromJson(Map<String, dynamic> json) => MiningLog(
    userId: json['userId'] as String,
    lastMiningAt: DateTime.parse(json['lastMiningAt'] as String),
    todayCount: json['todayCount'] as int,
    resetAt: DateTime.parse(json['resetAt'] as String),
    minerals: Map<String, int>.from(json['minerals'] as Map),
  );

  @override
  String toString() =>
      'Mining(user: $userId, count: $todayCount, Red: ${minerals['Red']}, Green: ${minerals['Green']}, Blue: ${minerals['Blue']})';
}
