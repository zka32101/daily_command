import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../utils/garden_lighting.dart';
import '../viewmodels/mining_provider.dart';
import '../services/analytics_provider.dart';
import '../widgets/glow_button.dart';
import '../widgets/glass_panel.dart';
import '../widgets/radial_burst.dart';

class MiningScreen extends ConsumerStatefulWidget {
  final VoidCallback onMined;

  const MiningScreen({
    super.key,
    required this.onMined,
  });

  @override
  ConsumerState<MiningScreen> createState() => _MiningScreenState();
}

class _MiningScreenState extends ConsumerState<MiningScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isMining = false;
  bool _mined = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startMining() {
    if (_isMining) return;
    setState(() => _isMining = true);

    _animationController.forward().then((_) {
      final currentMining = ref.read(miningLogProvider);
      final minedLog = currentMining.mine();
      final success = !identical(minedLog, currentMining);
      ref.read(miningLogProvider.notifier).state = minedLog;

      // KPI計測: 採掘実行イベント
      ref.read(analyticsProvider).logMiningAttempted(
            success: success,
            additive: false,
          );

      setState(() {
        _mined = true;
        _isMining = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final miningLog = ref.watch(miningLogProvider);
    final timeOfDay = GardenLighting.getCurrentTimeOfDay();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('採掘', style: TextStyle(fontWeight: FontWeight.w900)),
            Text(
              GardenLighting.getTimeOfDayLabel(timeOfDay),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: GardenLighting.createGradientBackground(
        timeOfDay: timeOfDay,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            child: Column(
              children: [
                // 採掘アイコン + バースト演出
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isMining || _mined)
                        RadialBurst(
                          color: _mined ? ColorPalette.victoryGreen : ColorPalette.goldBright,
                          size: 220,
                        ),
                      if (!_mined)
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                            CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
                          ),
                          child: Icon(
                            Icons.diamond_rounded,
                            size: 100,
                            color: _isMining
                                ? ColorPalette.goldBright.withValues(alpha: 0.8)
                                : ColorPalette.goldBright,
                            shadows: [
                              Shadow(color: ColorPalette.gold.withValues(alpha: 0.9), blurRadius: 30),
                            ],
                          ),
                        )
                      else
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 100,
                          color: ColorPalette.victoryGreenBright,
                          shadows: [
                            Shadow(color: ColorPalette.victoryGreen, blurRadius: 24),
                          ],
                        ),
                    ],
                  ),
                ),

                // メッセージ
                Text(
                  _mined ? '採掘完了！' : '採掘できます',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: _mined ? ColorPalette.victoryGreenBright : ColorPalette.goldBright,
                    shadows: [
                      Shadow(
                        color: (_mined ? ColorPalette.victoryGreen : ColorPalette.gold).withValues(alpha: 0.7),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 鉱石表示
                if (_mined)
                  GlassPanel(
                    borderColor: ColorPalette.goldBright,
                    withGlow: true,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const Text(
                          '獲得した鉱石',
                          style: TextStyle(
                            color: ColorPalette.lightText,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMineralDisplay('Red', miningLog.minerals['Red'] ?? 0, ColorPalette.dangerBright),
                            _buildMineralDisplay('Green', miningLog.minerals['Green'] ?? 0, ColorPalette.victoryGreenBright),
                            _buildMineralDisplay('Blue', miningLog.minerals['Blue'] ?? 0, ColorPalette.turquoiseBright),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // ボタン
                if (!_mined)
                  GlowButton(
                    label: _isMining ? '採掘中...' : '採掘する',
                    icon: Icons.diamond_rounded,
                    gradient: ColorPalette.goldAura,
                    glowColor: ColorPalette.gold,
                    onPressed: _isMining ? null : _startMining,
                  )
                else
                  GlowButton(
                    label: 'ユニットを強化する',
                    icon: Icons.upgrade_rounded,
                    gradient: ColorPalette.victoryAura,
                    glowColor: ColorPalette.victoryGreen,
                    onPressed: () {
                      widget.onMined();
                      Navigator.of(context).pop();
                    },
                  ),
                const SizedBox(height: 14),

                // キャンセルボタン
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'キャンセル',
                    style: TextStyle(color: ColorPalette.lightText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMineralDisplay(String mineralType, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.05)],
            ),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 16),
            ],
          ),
          child: Icon(Icons.diamond_rounded, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(mineralType, style: const TextStyle(color: ColorPalette.lightText, fontSize: 12)),
        Text(
          '+$count',
          style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 16),
        ),
      ],
    );
  }
}
