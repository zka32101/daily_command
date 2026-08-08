import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import '../models/deck.dart';

/// 現在のデッキ編成（デフォルトは最初の3体）
final deckProvider = StateProvider<Deck>((ref) {
  return Deck(
    name: 'デッキ1',
    unitIds: ['warrior_1', 'mage_1', 'archer_1'],
  );
});

/// デッキ編成操作用ヘルパー
class DeckHelper {
  /// ユニットをデッキに追加（最大5体まで）
  static void addUnit(WidgetRef ref, String unitId) {
    final deck = ref.read(deckProvider);
    if (deck.unitIds.contains(unitId)) return;
    if (deck.unitIds.length >= Deck.maxSize) return;

    ref.read(deckProvider.notifier).state = deck.copyWith(
      unitIds: [...deck.unitIds, unitId],
    );
  }

  /// ユニットをデッキから除外（最小3体は維持）
  static void removeUnit(WidgetRef ref, String unitId) {
    final deck = ref.read(deckProvider);
    if (deck.unitIds.length <= Deck.minSize) return;

    ref.read(deckProvider.notifier).state = deck.copyWith(
      unitIds: deck.unitIds.where((id) => id != unitId).toList(),
    );
  }

  /// トグル（含まれていれば除外、なければ追加）
  static void toggleUnit(WidgetRef ref, String unitId) {
    final deck = ref.read(deckProvider);
    if (deck.unitIds.contains(unitId)) {
      removeUnit(ref, unitId);
    } else {
      addUnit(ref, unitId);
    }
  }
}
