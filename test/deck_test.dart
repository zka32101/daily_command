import 'package:flutter_test/flutter_test.dart';
import 'package:daily_command/models/deck.dart';

void main() {
  group('Deck.isValid', () {
    test('3体編成は有効', () {
      final deck = Deck(name: 'デッキ1', unitIds: ['a', 'b', 'c']);
      expect(deck.isValid, isTrue);
    });

    test('5体編成は有効', () {
      final deck = Deck(name: 'デッキ1', unitIds: ['a', 'b', 'c', 'd', 'e']);
      expect(deck.isValid, isTrue);
    });

    test('2体編成は無効（最小3体未満）', () {
      final deck = Deck(name: 'デッキ1', unitIds: ['a', 'b']);
      expect(deck.isValid, isFalse);
    });

    test('6体編成は無効（最大5体超過）', () {
      final deck = Deck(name: 'デッキ1', unitIds: ['a', 'b', 'c', 'd', 'e', 'f']);
      expect(deck.isValid, isFalse);
    });

    test('0体編成は無効', () {
      final deck = Deck(name: 'デッキ1', unitIds: []);
      expect(deck.isValid, isFalse);
    });
  });

  group('Deck.copyWith', () {
    test('unitIds のみ変更した場合、他フィールドは維持される', () {
      final deck = Deck(name: 'デッキ1', unitIds: ['a', 'b', 'c'], isActive: true);
      final updated = deck.copyWith(unitIds: ['x', 'y', 'z']);

      expect(updated.name, 'デッキ1');
      expect(updated.unitIds, ['x', 'y', 'z']);
      expect(updated.isActive, isTrue);
    });
  });
}
