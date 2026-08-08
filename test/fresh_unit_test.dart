import 'package:flutter_test/flutter_test.dart';
import 'package:daily_command/models/fresh_unit.dart';

void main() {
  group('FreshUnit.generateForDate', () {
    test('同じ日付なら常に同じユニットが生成される（決定論的）', () {
      final date = DateTime(2026, 7, 2);
      final unitA = FreshUnit.generateForDate(date);
      final unitB = FreshUnit.generateForDate(date);

      expect(unitA.unitId, unitB.unitId);
      expect(unitA.unitType, unitB.unitType);
      expect(unitA.rarity, unitB.rarity);
    });

    test('異なる日付なら異なる unitId が生成される', () {
      final unitA = FreshUnit.generateForDate(DateTime(2026, 7, 2));
      final unitB = FreshUnit.generateForDate(DateTime(2026, 7, 3));

      expect(unitA.unitId, isNot(equals(unitB.unitId)));
    });

    test('expiresAt は配布翌日 09:00 に設定される', () {
      final unit = FreshUnit.generateForDate(DateTime(2026, 7, 2, 15, 30));

      expect(unit.expiresAt.year, 2026);
      expect(unit.expiresAt.month, 7);
      expect(unit.expiresAt.day, 3);
      expect(unit.expiresAt.hour, 9);
      expect(unit.expiresAt.minute, 0);
    });

    test('rarity は Rare/Epic/Legendary のいずれか', () {
      final unit = FreshUnit.generateForDate(DateTime(2026, 7, 2));
      expect(['Rare', 'Epic', 'Legendary'], contains(unit.rarity));
    });
  });

  group('FreshUnit.isExpired / remainingTime', () {
    test('expiresAt より前なら isExpired は false', () {
      final unit = FreshUnit(
        unitId: 'test',
        unitType: 'Warrior',
        rarity: 'Rare',
        expiresAt: DateTime(2026, 7, 3, 9, 0),
      );
      final now = DateTime(2026, 7, 3, 8, 59);
      expect(unit.isExpired(now), isFalse);
    });

    test('expiresAt を過ぎたら isExpired は true', () {
      final unit = FreshUnit(
        unitId: 'test',
        unitType: 'Warrior',
        rarity: 'Rare',
        expiresAt: DateTime(2026, 7, 3, 9, 0),
      );
      final now = DateTime(2026, 7, 3, 9, 1);
      expect(unit.isExpired(now), isTrue);
    });

    test('remainingTime は期限切れ後 Duration.zero を返す（負にならない）', () {
      final unit = FreshUnit(
        unitId: 'test',
        unitType: 'Warrior',
        rarity: 'Rare',
        expiresAt: DateTime(2026, 7, 3, 9, 0),
      );
      final now = DateTime(2026, 7, 3, 10, 0);
      expect(unit.remainingTime(now), Duration.zero);
    });

    test('remainingTime は期限前なら正しい残り時間を返す', () {
      final unit = FreshUnit(
        unitId: 'test',
        unitType: 'Warrior',
        rarity: 'Rare',
        expiresAt: DateTime(2026, 7, 3, 9, 0),
      );
      final now = DateTime(2026, 7, 3, 7, 0);
      expect(unit.remainingTime(now), const Duration(hours: 2));
    });
  });

  group('FreshUnit.statBoost', () {
    test('Legendary は 2.0 倍', () {
      final unit = FreshUnit(
        unitId: 'test', unitType: 'Warrior', rarity: 'Legendary',
        expiresAt: DateTime(2026, 7, 3),
      );
      expect(unit.statBoost, 2.0);
    });

    test('Epic は 1.5 倍', () {
      final unit = FreshUnit(
        unitId: 'test', unitType: 'Warrior', rarity: 'Epic',
        expiresAt: DateTime(2026, 7, 3),
      );
      expect(unit.statBoost, 1.5);
    });

    test('Rare は 1.2 倍', () {
      final unit = FreshUnit(
        unitId: 'test', unitType: 'Warrior', rarity: 'Rare',
        expiresAt: DateTime(2026, 7, 3),
      );
      expect(unit.statBoost, 1.2);
    });
  });
}
