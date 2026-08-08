import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../widgets/glow_button.dart';
import '../widgets/glass_panel.dart';
import '../widgets/radial_burst.dart';
import '../widgets/fresh_unit_banner.dart';
import 'stage_screen.dart';
import 'leaderboard_screen.dart';
import 'deck_editor_screen.dart';
import 'unit_dictionary_screen.dart';
import 'mining_screen.dart';
import 'pvp_home_screen.dart';
import 'clan_home_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Daily Command',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
            child: Column(
              children: [
                // タイトルロゴエリア（グロー装飾付き）
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const RadialBurst(color: ColorPalette.accentOrange, size: 240),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                ColorPalette.accentOrangeBright,
                                ColorPalette.accentOrange,
                                ColorPalette.goldBright,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'DAILY\nCOMMAND',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(color: Colors.black87, blurRadius: 12, offset: Offset(0, 4)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '毎日違う敵と対戦し、ユニットを育成しよう',
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorPalette.lightText,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // 鮮度ユニット（24h FOMO バナー）
                const FreshUnitBanner(),
                const SizedBox(height: 16),

                // ゲーム開始ボタン（主役ボタン・迫力大）
                GlowButton(
                  label: 'ゲーム開始',
                  icon: Icons.play_arrow_rounded,
                  gradient: ColorPalette.orangeAura,
                  glowColor: ColorPalette.accentOrange,
                  fontSize: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 22),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StageScreen(stageId: 1),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // メニューカード群
                _MenuCard(
                  label: 'クラン',
                  icon: Icons.groups_rounded,
                  accentColor: ColorPalette.victoryGreenBright,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ClanHomeScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _MenuCard(
                  label: 'PvP対戦',
                  icon: Icons.sports_kabaddi_rounded,
                  accentColor: ColorPalette.dangerBright,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PvpHomeScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _MenuCard(
                  label: '週間ランキング',
                  icon: Icons.leaderboard_rounded,
                  accentColor: ColorPalette.goldBright,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _MenuCard(
                  label: 'ユニット図鑑',
                  icon: Icons.collections_rounded,
                  accentColor: ColorPalette.turquoiseBright,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UnitDictionaryScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _MenuCard(
                  label: 'デッキ編集',
                  icon: Icons.dashboard_customize_rounded,
                  accentColor: ColorPalette.accentOrangeBright,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DeckEditorScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _MenuCard(
                  label: '採掘（鉱石獲得）',
                  icon: Icons.diamond_rounded,
                  accentColor: ColorPalette.goldBright,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MiningScreen(onMined: () {}),
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

/// グラスモーフィズム + アイコングロー円のメニューカード
class _MenuCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onPressed;

  const _MenuCard({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassPanel(
        borderColor: accentColor.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [accentColor.withValues(alpha: 0.35), accentColor.withValues(alpha: 0.05)],
                ),
                border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.5),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorPalette.lightText,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: accentColor.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}
