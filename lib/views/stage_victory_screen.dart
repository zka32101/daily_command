import 'package:flutter/material.dart';
import '../utils/color_palette.dart';
import '../widgets/unit_emotion_display.dart';
import '../widgets/glow_button.dart';
import '../widgets/glass_panel.dart';
import '../widgets/radial_burst.dart';
import 'share_screen.dart';

class StageVictoryScreen extends StatefulWidget {
  final int stageId;
  final int mineralReward;
  final int starsEarned;

  const StageVictoryScreen({
    super.key,
    required this.stageId,
    required this.mineralReward,
    this.starsEarned = 3,
  });

  @override
  State<StageVictoryScreen> createState() => _StageVictoryScreenState();
}

class _StageVictoryScreenState extends State<StageVictoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ステージクリア', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
            child: Column(
              children: [
                // バースト演出 + 感情表示
                SizedBox(
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const RadialBurst(color: ColorPalette.victoryGreen, size: 220),
                      const UnitEmotionDisplay(
                        emotion: UnitEmotion.happy,
                        duration: Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                ),

                // クリアメッセージ（グラデーションテキスト）
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [ColorPalette.victoryGreenBright, ColorPalette.victoryGreen],
                  ).createShader(bounds),
                  child: const Text(
                    'クリア！',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 4)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // スター評価（スタッガード出現アニメーション）
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final start = index * 0.2;
                    final end = (start + 0.5).clamp(0.0, 1.0);
                    final animation = CurvedAnimation(
                      parent: _starController,
                      curve: Interval(start, end, curve: Curves.elasticOut),
                    );
                    final filled = index < widget.starsEarned;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: ScaleTransition(
                        scale: animation,
                        child: Icon(
                          Icons.star_rounded,
                          size: 56,
                          color: filled ? ColorPalette.goldBright : Colors.grey[800],
                          shadows: filled
                              ? [
                                  Shadow(
                                    color: ColorPalette.gold.withValues(alpha: 0.8),
                                    blurRadius: 18,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // 報酬表示
                GlassPanel(
                  borderColor: ColorPalette.goldBright,
                  withGlow: true,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Text(
                        '獲得報酬',
                        style: TextStyle(
                          color: ColorPalette.lightText,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.diamond_rounded, color: ColorPalette.goldBright, size: 32),
                          const SizedBox(width: 8),
                          Text(
                            '+${widget.mineralReward} 鉱石',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: ColorPalette.goldBright,
                              shadows: [
                                Shadow(color: ColorPalette.gold, blurRadius: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // シェアボタン
                GlowButton(
                  label: '友達に共有',
                  icon: Icons.share_rounded,
                  gradient: ColorPalette.orangeAura,
                  glowColor: ColorPalette.accentOrange,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ShareScreen(
                          stageId: widget.stageId.toString(),
                          stars: widget.starsEarned,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // つづけるボタン
                GlowButton(
                  label: 'つづける',
                  icon: Icons.arrow_forward_rounded,
                  gradient: ColorPalette.victoryAura,
                  glowColor: ColorPalette.victoryGreen,
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
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
