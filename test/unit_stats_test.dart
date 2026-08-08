import 'package:flutter_test/flutter_test.dart';
import 'package:daily_command/models/unit.dart';

void main() {
  Unit makeUnit(String unitType, {int level = 5, Map<String, int>? equipped}) {
    return Unit(
      id: 'test_unit',
      unitType: unitType,
      level: level,
      xp: 0,
      equipped: equipped ?? {},
      createdAt: DateTime(2026, 1, 1),
    );
  }

  group('ユニットタイプ別ステータス倍率', () {
    test('Warrior は基準倍率（1.0）どおりの計算結果になる', () {
      final unit = makeUnit('Warrior', level: 5);
      expect(unit.getAttack(), 25); // 5 * 5 * 1.0
      expect(unit.getDefense(), 15); // 5 * 3 * 1.0
      expect(unit.getHealth(), 50); // 5 * 10 * 1.0
    });

    test('Tank は高Defense・高Health・低Attack', () {
      final unit = makeUnit('Tank', level: 5);
      final warrior = makeUnit('Warrior', level: 5);

      expect(unit.getDefense(), greaterThan(warrior.getDefense()));
      expect(unit.getHealth(), greaterThan(warrior.getHealth()));
      expect(unit.getAttack(), lessThan(warrior.getAttack()));
    });

    test('Assassin は高Attack・低Defense・低Health', () {
      final unit = makeUnit('Assassin', level: 5);
      final warrior = makeUnit('Warrior', level: 5);

      expect(unit.getAttack(), greaterThan(warrior.getAttack()));
      expect(unit.getDefense(), lessThan(warrior.getDefense()));
      expect(unit.getHealth(), lessThan(warrior.getHealth()));
    });

    test('未知の unitType は倍率1.0（フォールバック）で計算される', () {
      final unit = makeUnit('UnknownType', level: 5);
      expect(unit.getAttack(), 25);
      expect(unit.getDefense(), 15);
      expect(unit.getHealth(), 50);
    });
  });

  group('Unit.getHealAmount', () {
    test('レベル1のHealer回復量は 15 + 1*3 = 18', () {
      final unit = makeUnit('Healer', level: 1);
      expect(unit.getHealAmount(), 18);
    });

    test('レベル5のHealer回復量は 15 + 5*3 = 30', () {
      final unit = makeUnit('Healer', level: 5);
      expect(unit.getHealAmount(), 30);
    });

    test('レベルが上がるほど回復量が増える', () {
      final low = makeUnit('Healer', level: 2).getHealAmount();
      final high = makeUnit('Healer', level: 8).getHealAmount();
      expect(high, greaterThan(low));
    });
  });

  group('鉱石補正', () {
    test('Red鉱石を装備すると getAttack が加算される', () {
      final unit = makeUnit('Warrior', level: 5, equipped: {'Red': 3});
      expect(unit.getAttack(), 25 + 6); // 3個 * 2 = 6ボーナス
    });

    test('鉱石を装備していない場合はボーナスなし', () {
      final unit = makeUnit('Warrior', level: 5);
      expect(unit.getAttack(), 25);
    });
  });
}
