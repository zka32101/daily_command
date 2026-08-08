import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../models/battle_log.dart';
import '../viewmodels/mining_provider.dart';
import '../viewmodels/ai_advice_provider.dart';
import '../services/ai_advice_service.dart';
import '../widgets/glow_button.dart';
import '../widgets/glass_panel.dart';
import '../widgets/radial_burst.dart';
import 'mining_screen.dart';

class StageDefeatScreen extends ConsumerStatefulWidget {
  final int stageId;
  final BattleLog? battleLog;

  const StageDefeatScreen({
    super.key,
    required this.stageId,
    this.battleLog,
  });

  @override
  ConsumerState<StageDefeatScreen> createState() => _StageDefeatScreenState();
}

class _StageDefeatScreenState extends ConsumerState<StageDefeatScreen> {
  AiAdviceResult? _advice;
  bool _loadingAdvice = true;

  @override
  void initState() {
    super.initState();
    _loadAdvice();
  }

  Future<void> _loadAdvice() async {
    final log = widget.battleLog;
    if (log == null) {
      setState(() => _loadingAdvice = false);
      return;
    }

    final analysis = WeaknessAnalysis.fromBattleLog(
      log,
      lowestLevelUnitId: log.lowestLevelUnitId,
    );
    final service = ref.read(aiAdviceServiceProvider);
    final result = await service.generateAdvice(
      analysis: analysis,
      consecutiveDefeats: 1,
    );

    if (mounted) {
      setState(() {
        _advice = result;
        _loadingAdvice = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final miningLog = ref.watch(miningLogProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('敗北', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: [
                SizedBox(
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const RadialBurst(color: ColorPalette.danger, size: 180),
                      const Icon(Icons.close_rounded, color: ColorPalette.dangerBright, size: 64),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 敗北メッセージ
                const Text(
                  'あと少しで勝てた…',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: ColorPalette.dangerBright,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                const Text(
                  'ユニットを強化すれば\n次は勝てる',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: ColorPalette.lightText),
                ),
                const SizedBox(height: 20),

                // AIアドバイス（弱点分析コメント）
                if (_loadingAdvice)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_advice != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassPanel(
                      borderColor: ColorPalette.turquoiseBright,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy_rounded, color: ColorPalette.turquoiseBright, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _advice!.message,
                              style: const TextStyle(fontSize: 13, color: ColorPalette.lightText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                // 推奨フロー（ハイライト表示）
                GlassPanel(
                  borderColor: ColorPalette.accentOrange,
                  withGlow: true,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.bolt_rounded, color: ColorPalette.accentOrangeBright),
                          SizedBox(width: 8),
                          Text(
                            '推奨フロー',
                            style: TextStyle(
                              color: ColorPalette.accentOrangeBright,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildFlowStep(
                        number: 1,
                        title: '採掘で鉱石を獲得',
                        icon: Icons.diamond_rounded,
                        enabled: miningLog.canMine(),
                      ),
                      const SizedBox(height: 14),
                      _buildFlowStep(
                        number: 2,
                        title: 'ユニットを強化',
                        icon: Icons.upgrade_rounded,
                        enabled: true,
                      ),
                      const SizedBox(height: 14),
                      _buildFlowStep(
                        number: 3,
                        title: 'ステージに再挑戦',
                        icon: Icons.refresh_rounded,
                        enabled: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 採掘ボタン
                GlowButton(
                  label: '採掘をする',
                  icon: Icons.diamond_rounded,
                  gradient: ColorPalette.orangeAura,
                  glowColor: ColorPalette.accentOrange,
                  onPressed: miningLog.canMine()
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MiningScreen(
                                onMined: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          );
                        }
                      : null,
                ),
                const SizedBox(height: 14),

                // ホーム画面に戻るボタン
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'ホームに戻る',
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

  Widget _buildFlowStep({
    required int number,
    required String title,
    required IconData icon,
    required bool enabled,
  }) {
    final color = enabled ? ColorPalette.accentOrangeBright : Colors.grey[700]!;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: enabled ? ColorPalette.orangeAura : null,
            color: enabled ? null : Colors.grey[800],
            boxShadow: enabled
                ? [BoxShadow(color: ColorPalette.accentOrange.withValues(alpha: 0.5), blurRadius: 10)]
                : null,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: enabled ? ColorPalette.lightText : Colors.grey[600],
            ),
          ),
        ),
        Icon(icon, color: color),
      ],
    );
  }
}
