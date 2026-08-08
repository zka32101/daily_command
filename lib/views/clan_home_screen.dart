import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../viewmodels/clan_provider.dart';
import '../widgets/glass_panel.dart';
import '../widgets/glow_button.dart';
import 'clan_search_screen.dart';

class ClanHomeScreen extends ConsumerWidget {
  const ClanHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clan = ref.watch(myClanProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('クラン', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
        child: SafeArea(
          child: clan == null ? _buildNoClan(context) : _buildClanDetail(context, ref, clan),
        ),
      ),
    );
  }

  Widget _buildNoClan(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
      child: Column(
        children: [
          const Icon(Icons.groups_rounded, size: 72, color: ColorPalette.turquoiseBright),
          const SizedBox(height: 16),
          const Text(
            'クランに所属していません',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ColorPalette.lightText),
          ),
          const SizedBox(height: 8),
          const Text(
            '仲間と一緒に週間貢献度を競い合おう',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          GlowButton(
            label: 'クランを探す',
            icon: Icons.search_rounded,
            gradient: ColorPalette.orangeAura,
            glowColor: ColorPalette.accentOrange,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ClanSearchScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClanDetail(BuildContext context, WidgetRef ref, clan) {
    final members = ref.watch(clanMembersProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Column(
        children: [
          GlassPanel(
            borderColor: ColorPalette.accentOrange,
            withGlow: true,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(clan.iconEmoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  clan.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ColorPalette.lightText),
                ),
                Text(
                  '${clan.memberCount} / ${clan.maxMembers} 人',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.diamond_rounded, color: ColorPalette.goldBright, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '週間貢献度 ${clan.weeklyContribution}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.goldBright,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'メンバー（貢献度順）',
              style: TextStyle(color: ColorPalette.lightText, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassPanel(
                    borderColor: member.isLeader ? ColorPalette.goldBright : Colors.white24,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        if (member.isLeader)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(Icons.star_rounded, color: ColorPalette.goldBright, size: 18),
                          ),
                        Expanded(
                          child: Text(
                            member.displayName,
                            style: const TextStyle(color: ColorPalette.lightText, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${member.weeklyContribution}',
                          style: const TextStyle(color: ColorPalette.goldBright, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          TextButton(
            onPressed: () => ClanHelper.leaveClan(ref),
            child: const Text('クランを脱退する', style: TextStyle(color: ColorPalette.dangerBright)),
          ),
        ],
      ),
    );
  }
}
