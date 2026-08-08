import 'package:riverpod/legacy.dart';
import '../models/index.dart';

class PlayerData {
  final List<Unit> units;
  final int level;
  final int xp;

  PlayerData({
    required this.units,
    this.level = 1,
    this.xp = 0,
  });

  PlayerData copyWith({
    List<Unit>? units,
    int? level,
    int? xp,
  }) {
    return PlayerData(
      units: units ?? this.units,
      level: level ?? this.level,
      xp: xp ?? this.xp,
    );
  }
}

// プレイヤーデータプロバイダー（デフォルトユニット3体でスタート）
final playerDataProvider = StateProvider<PlayerData>((ref) {
  return PlayerData(
    units: [
      Unit(
        id: 'warrior_1',
        unitType: 'Warrior',
        level: 1,
        xp: 0,
        equipped: {},
        createdAt: DateTime.now(),
      ),
      Unit(
        id: 'mage_1',
        unitType: 'Mage',
        level: 1,
        xp: 0,
        equipped: {},
        createdAt: DateTime.now(),
      ),
      Unit(
        id: 'archer_1',
        unitType: 'Archer',
        level: 1,
        xp: 0,
        equipped: {},
        createdAt: DateTime.now(),
      ),
      Unit(
        id: 'tank_1',
        unitType: 'Tank',
        level: 1,
        xp: 0,
        equipped: {},
        createdAt: DateTime.now(),
      ),
      Unit(
        id: 'assassin_1',
        unitType: 'Assassin',
        level: 1,
        xp: 0,
        equipped: {},
        createdAt: DateTime.now(),
      ),
      Unit(
        id: 'healer_1',
        unitType: 'Healer',
        level: 1,
        xp: 0,
        equipped: {},
        createdAt: DateTime.now(),
      ),
    ],
  );
});
