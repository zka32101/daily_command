import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../viewmodels/leaderboard_provider.dart';
import '../widgets/glass_panel.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('週間ランキング', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50),

              // ヘッダー（週の情報）
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassPanel(
                  borderColor: ColorPalette.accentOrange,
                  withGlow: true,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [ColorPalette.accentOrangeBright, ColorPalette.goldBright],
                        ).createShader(bounds),
                        child: const Text(
                          '週間ランキング',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${leaderboard.weekStartDate.month}/${leaderboard.weekStartDate.day} - '
                        '${leaderboard.weekStartDate.add(const Duration(days: 6)).month}/'
                        '${leaderboard.weekStartDate.add(const Duration(days: 6)).day}',
                        style: const TextStyle(fontSize: 12, color: ColorPalette.lightText),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // トップ3 ハイライト
              if (leaderboard.entries.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (leaderboard.entries.length > 1)
                        _buildTopThreeCard(
                          rank: 2,
                          entry: leaderboard.entries[1],
                          icon: Icons.looks_two_rounded,
                        ),
                      if (leaderboard.entries.isNotEmpty)
                        _buildTopThreeCard(
                          rank: 1,
                          entry: leaderboard.entries[0],
                          icon: Icons.looks_one_rounded,
                          isFirst: true,
                        ),
                      if (leaderboard.entries.length > 2)
                        _buildTopThreeCard(
                          rank: 3,
                          entry: leaderboard.entries[2],
                          icon: Icons.looks_3_rounded,
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // ランキングリスト
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: leaderboard.entries.length,
                  itemBuilder: (context, index) {
                    final entry = leaderboard.entries[index];
                    final isCurrentUser = entry.rank == leaderboard.currentUserRank;
                    final rankColor = _getRankColor(entry.rank);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: GlassPanel(
                        borderColor: isCurrentUser ? ColorPalette.accentOrange : Colors.white24,
                        borderWidth: isCurrentUser ? 2 : 1,
                        withGlow: isCurrentUser,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [rankColor.withValues(alpha: 0.4), rankColor.withValues(alpha: 0.1)],
                                ),
                                border: Border.all(color: rankColor, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.rank}',
                                  style: TextStyle(fontWeight: FontWeight.w900, color: rankColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.displayName,
                                    style: TextStyle(
                                      fontWeight: isCurrentUser ? FontWeight.w900 : FontWeight.w600,
                                      color: ColorPalette.lightText,
                                    ),
                                  ),
                                  Text(
                                    'Lv.${entry.level} • ログイン ${entry.consecutiveLogins}日',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${entry.weeklyScore}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: ColorPalette.goldBright,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopThreeCard({
    required int rank,
    required dynamic entry,
    required IconData icon,
    bool isFirst = false,
  }) {
    final color = _getRankColor(rank);
    final size = isFirst ? 84.0 : 68.0;

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, Color.lerp(color, Colors.black, 0.3)!],
            ),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: isFirst ? 28 : 16, spreadRadius: 1),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: isFirst ? 42 : 32),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: isFirst ? 92 : 78,
          child: Text(
            entry.displayName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: ColorPalette.lightText),
          ),
        ),
        Text(
          '${entry.weeklyScore}',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: color,
            fontSize: isFirst ? 15 : 12,
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return ColorPalette.goldBright;
      case 2:
        return const Color(0xFFD8D8E8); // Silver
      case 3:
        return const Color(0xFFE0995E); // Bronze
      default:
        return Colors.grey[500]!;
    }
  }
}
