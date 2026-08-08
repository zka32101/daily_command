import 'package:riverpod/legacy.dart';
import '../models/mining.dart';

DateTime _getNextReset() {
  DateTime now = DateTime.now();
  // 次日 09:00 JST を計算
  DateTime tomorrow = now.add(const Duration(days: 1));
  return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
}

// 採掘ログプロバイダー
final miningLogProvider = StateProvider<MiningLog>((ref) {
  return MiningLog(
    userId: 'demo_user',
    lastMiningAt: DateTime.now().subtract(const Duration(hours: 20)),
    todayCount: 0,
    resetAt: _getNextReset(),
    minerals: {'Red': 0, 'Green': 0, 'Blue': 0},
  );
});
