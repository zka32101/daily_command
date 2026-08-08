import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import '../models/clan.dart';

/// 現在所属しているクラン（未所属なら null・モックデータ）
/// 実装時: Firebase 本設定後は clans/{clanId} と同期する
final myClanProvider = StateProvider<Clan?>((ref) => null);

/// おすすめクラン一覧（モックデータ）
final recommendedClansProvider = Provider<List<Clan>>((ref) {
  return [
    Clan(
      clanId: 'clan_dragon',
      name: '竜の巣',
      description: '毎日コツコツ育成する仲間を募集',
      iconEmoji: '🐉',
      memberCount: 8,
      weeklyContribution: 4200,
    ),
    Clan(
      clanId: 'clan_phoenix',
      name: '不死鳥の羽ばたき',
      description: '初心者歓迎！わいわい楽しむクラン',
      iconEmoji: '🔥',
      memberCount: 12,
      weeklyContribution: 6800,
    ),
    Clan(
      clanId: 'clan_owl',
      name: '梟の知恵',
      description: '戦略談義が好きな人向け',
      iconEmoji: '🦉',
      memberCount: 5,
      weeklyContribution: 2100,
    ),
  ];
});

/// クランメンバー一覧（モックデータ）
final clanMembersProvider = Provider<List<ClanMember>>((ref) {
  final clan = ref.watch(myClanProvider);
  if (clan == null) return [];

  return [
    ClanMember(userId: 'u_me', displayName: 'あなた', role: 'leader', weeklyContribution: 850),
    ClanMember(userId: 'u_1', displayName: '勇敢な騎士', role: 'member', weeklyContribution: 1200),
    ClanMember(userId: 'u_2', displayName: '疾風の弓使い', role: 'member', weeklyContribution: 640),
  ];
});

class ClanHelper {
  /// クランに参加（モック）
  static void joinClan(WidgetRef ref, Clan clan) {
    ref.read(myClanProvider.notifier).state = clan.copyWith(
      memberCount: clan.memberCount + 1,
    );
  }

  /// クランを新規作成（モック）
  static bool createClan(WidgetRef ref, String name, String description, String iconEmoji) {
    if (!ClanNameFilter.isValid(name) || !ClanNameFilter.isValid(description)) {
      return false;
    }

    ref.read(myClanProvider.notifier).state = Clan(
      clanId: 'clan_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      iconEmoji: iconEmoji,
      memberCount: 1,
      weeklyContribution: 0,
    );
    return true;
  }

  /// クランを脱退
  static void leaveClan(WidgetRef ref) {
    ref.read(myClanProvider.notifier).state = null;
  }
}
