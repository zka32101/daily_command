import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

/// プレイヤーが装備しているスキン（ユニット毎、`unitId` → `skinId`）
final playerEquippedSkinsProvider = StateProvider<Map<String, String>>((ref) {
  // デモ: すべてのユニットがデフォルトスキンを装備
  return {
    'warrior_1': 'warrior_default',
    'mage_1': 'mage_default',
    'archer_1': 'archer_default',
    'tank_1': 'tank_default',
    'assassin_1': 'assassin_default',
    'healer_1': 'healer_default',
  };
});

/// プレイヤーが所有しているスキン（購入済み `skinId` の集合）
final playerOwnedSkinsProvider = StateProvider<Set<String>>((ref) {
  // デモ: デフォルトスキンのみ所有
  return {
    'warrior_default',
    'mage_default',
    'archer_default',
    'tank_default',
    'assassin_default',
    'healer_default',
  };
});

/// スキン装備変更
class SkinEquipHelper {
  static void equipSkin(
    WidgetRef ref,
    String unitId,
    String skinId,
  ) {
    final currentEquipped = ref.read(playerEquippedSkinsProvider);
    final newEquipped = Map<String, String>.from(currentEquipped);
    newEquipped[unitId] = skinId;
    ref.read(playerEquippedSkinsProvider.notifier).state = newEquipped;
  }

  /// スキン購入（デモ）
  static void purchaseSkin(WidgetRef ref, String skinId) {
    final currentOwned = ref.read(playerOwnedSkinsProvider);
    if (!currentOwned.contains(skinId)) {
      final newOwned = Set<String>.from(currentOwned);
      newOwned.add(skinId);
      ref.read(playerOwnedSkinsProvider.notifier).state = newOwned;
    }
  }

  /// スキン所有確認
  static bool ownsSkin(WidgetRef ref, String skinId) {
    return ref.read(playerOwnedSkinsProvider).contains(skinId);
  }

  /// 装備中のスキン取得
  static String getEquippedSkinForUnit(WidgetRef ref, String unitId) {
    return ref.read(playerEquippedSkinsProvider)[unitId] ?? 'warrior_default';
  }
}
