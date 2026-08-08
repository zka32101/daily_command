import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../viewmodels/pvp_provider.dart';
import '../widgets/glass_panel.dart';
import '../widgets/glow_button.dart';
import '../widgets/radial_burst.dart';
import 'pvp_matching_screen.dart';

class PvpHomeScreen extends ConsumerWidget {
  const PvpHomeScreen({super.key});

  String _rankLabel(int rating) {
    if (rating >= 1800) return 'マスター';
    if (rating >= 1500) return 'ゴールド';
    if (rating >= 1200) return 'シルバー';
    return 'ブロンズ';
  }

  Color _rankColor(int rating) {
    if (rating >= 1800) return ColorPalette.goldBright;
    if (rating >= 1500) return const Color(0xFFFFD54F);
    if (rating >= 1200) return const Color(0xFFD8D8E8);
    return const Color(0xFFE0995E);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranking = ref.watch(pvpRankingProvider);
    final rankColor = _rankColor(ranking.rating);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('PvP対戦', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            child: Column(
              children: [
                SizedBox(
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      RadialBurst(color: rankColor, size: 200),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _rankLabel(ranking.rating),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: rankColor,
                              shadows: [Shadow(color: rankColor.withValues(alpha: 0.8), blurRadius: 16)],
                            ),
                          ),
                          Text(
                            '${ranking.rating}',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: ColorPalette.lightText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                GlassPanel(
                  borderColor: ColorPalette.accentOrange,
                  withGlow: true,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatColumn(label: '勝利', value: '${ranking.wins}', color: ColorPalette.victoryGreenBright),
                      _StatColumn(label: '敗北', value: '${ranking.losses}', color: ColorPalette.dangerBright),
                      _StatColumn(
                        label: '連勝',
                        value: '${ranking.winStreak}',
                        color: ColorPalette.goldBright,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  '※ 現在はモックデータ版です。実際のマッチングはFirebase本設定後に有効になります。',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                GlowButton(
                  label: '対戦する',
                  icon: Icons.sports_kabaddi_rounded,
                  gradient: ColorPalette.orangeAura,
                  glowColor: ColorPalette.accentOrange,
                  fontSize: 20,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PvpMatchingScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: ColorPalette.lightText)),
      ],
    );
  }
}
