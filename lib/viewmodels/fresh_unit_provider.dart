import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import '../models/fresh_unit.dart';

/// 本日の鮮度ユニット
final freshUnitProvider = StateProvider<FreshUnit>((ref) {
  return FreshUnit.generateForDate(DateTime.now());
});

/// 受け取り済みかどうか（1日1回のみ受け取り可能）
final freshUnitClaimedProvider = StateProvider<bool>((ref) => false);

class FreshUnitHelper {
  static void claim(WidgetRef ref) {
    ref.read(freshUnitClaimedProvider.notifier).state = true;
  }
}
