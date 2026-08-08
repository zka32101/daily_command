import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../models/pvp_match.dart';
import '../viewmodels/pvp_provider.dart';
import '../widgets/glass_panel.dart';
import '../widgets/glow_button.dart';
import '../widgets/radial_burst.dart';

class PvpResultScreen extends ConsumerStatefulWidget {
  final PvpOpponent opponent;

  const PvpResultScreen({super.key, required this.opponent});

  @override
  ConsumerState<PvpResultScreen> createState() => _PvpResultScreenState();
}

class _PvpResultScreenState extends ConsumerState<PvpResultScreen> {
  late bool _won;
  late int _ratingBefore;
  late int _ratingAfter;

  @override
  void initState() {
    super.initState();
    _ratingBefore = ref.read(pvpRankingProvider).rating;
    _won = PvpHelper.resolveMatch(ref, widget.opponent);
    _ratingAfter = ref.read(pvpRankingProvider).rating;
  }

  @override
  Widget build(BuildContext context) {
    final delta = _ratingAfter - _ratingBefore;
    final resultColor = _won ? ColorPalette.victoryGreenBright : ColorPalette.dangerBright;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('対戦結果', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      RadialBurst(
                        color: _won ? ColorPalette.victoryGreen : ColorPalette.danger,
                        size: 200,
                      ),
                      Icon(
                        _won ? Icons.emoji_events_rounded : Icons.close_rounded,
                        color: resultColor,
                        size: 72,
                      ),
                    ],
                  ),
                ),

                Text(
                  _won ? '勝利！' : '敗北…',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: resultColor,
                    shadows: [Shadow(color: resultColor.withValues(alpha: 0.8), blurRadius: 20)],
                  ),
                ),
                const SizedBox(height: 24),

                GlassPanel(
                  borderColor: resultColor,
                  withGlow: true,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_rounded, color: ColorPalette.lightText, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.opponent.name}（Rating ${widget.opponent.rating}）',
                            style: const TextStyle(color: ColorPalette.lightText, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_ratingBefore',
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_rounded, color: ColorPalette.lightText, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            '$_ratingAfter',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: resultColor),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            delta >= 0 ? '(+$delta)' : '($delta)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: resultColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                GlowButton(
                  label: 'ホームに戻る',
                  icon: Icons.home_rounded,
                  gradient: ColorPalette.orangeAura,
                  glowColor: ColorPalette.accentOrange,
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
