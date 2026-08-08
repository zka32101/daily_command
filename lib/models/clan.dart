/// クラン（最小の所属感・CLAN_DESIGN.md準拠）
class Clan {
  final String clanId;
  final String name;
  final String description;
  final String iconEmoji;
  final int memberCount;
  final int maxMembers;
  final int weeklyContribution;
  final bool isPublic;

  static const int defaultMaxMembers = 20;

  Clan({
    required this.clanId,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.memberCount,
    this.maxMembers = defaultMaxMembers,
    required this.weeklyContribution,
    this.isPublic = true,
  });

  bool get isFull => memberCount >= maxMembers;

  Clan copyWith({
    String? clanId,
    String? name,
    String? description,
    String? iconEmoji,
    int? memberCount,
    int? maxMembers,
    int? weeklyContribution,
    bool? isPublic,
  }) {
    return Clan(
      clanId: clanId ?? this.clanId,
      name: name ?? this.name,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      memberCount: memberCount ?? this.memberCount,
      maxMembers: maxMembers ?? this.maxMembers,
      weeklyContribution: weeklyContribution ?? this.weeklyContribution,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}

/// クランメンバー
class ClanMember {
  final String userId;
  final String displayName;
  final String role; // "leader" | "member"
  final int weeklyContribution;

  ClanMember({
    required this.userId,
    required this.displayName,
    required this.role,
    required this.weeklyContribution,
  });

  bool get isLeader => role == 'leader';
}

/// クラン名・説明文の簡易NGワードフィルタ（CLAN_DESIGN.md §7準拠）
class ClanNameFilter {
  static const List<String> _ngWords = ['死ね', 'アホ', 'バカ野郎'];

  static bool isValid(String text) {
    for (final word in _ngWords) {
      if (text.contains(word)) return false;
    }
    return true;
  }
}
