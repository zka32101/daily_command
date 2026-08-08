import 'package:flutter_test/flutter_test.dart';
import 'package:daily_command/models/clan.dart';

void main() {
  Clan makeClan({int memberCount = 5, int maxMembers = 20}) {
    return Clan(
      clanId: 'clan_1',
      name: 'テストクラン',
      description: 'テスト用',
      iconEmoji: '🛡️',
      memberCount: memberCount,
      maxMembers: maxMembers,
      weeklyContribution: 0,
    );
  }

  group('Clan.isFull', () {
    test('memberCount が maxMembers 未満なら false', () {
      final clan = makeClan(memberCount: 5, maxMembers: 20);
      expect(clan.isFull, isFalse);
    });

    test('memberCount が maxMembers と等しければ true', () {
      final clan = makeClan(memberCount: 20, maxMembers: 20);
      expect(clan.isFull, isTrue);
    });
  });

  group('Clan.copyWith', () {
    test('weeklyContribution のみ変更した場合、他フィールドは維持される', () {
      final clan = makeClan();
      final updated = clan.copyWith(weeklyContribution: 500);

      expect(updated.weeklyContribution, 500);
      expect(updated.name, 'テストクラン');
      expect(updated.memberCount, 5);
    });
  });

  group('ClanMember.isLeader', () {
    test('role が leader なら true', () {
      final member = ClanMember(userId: 'u1', displayName: 'A', role: 'leader', weeklyContribution: 0);
      expect(member.isLeader, isTrue);
    });

    test('role が member なら false', () {
      final member = ClanMember(userId: 'u1', displayName: 'A', role: 'member', weeklyContribution: 0);
      expect(member.isLeader, isFalse);
    });
  });

  group('ClanNameFilter.isValid', () {
    test('NGワードを含まない場合は true', () {
      expect(ClanNameFilter.isValid('勇者の集い'), isTrue);
    });

    test('NGワードを含む場合は false', () {
      expect(ClanNameFilter.isValid('死ねクラン'), isFalse);
    });
  });
}
