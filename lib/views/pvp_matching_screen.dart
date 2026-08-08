import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../viewmodels/pvp_provider.dart';
import '../widgets/radial_burst.dart';
import 'pvp_result_screen.dart';

class PvpMatchingScreen extends ConsumerStatefulWidget {
  const PvpMatchingScreen({super.key});

  @override
  ConsumerState<PvpMatchingScreen> createState() => _PvpMatchingScreenState();
}

class _PvpMatchingScreenState extends ConsumerState<PvpMatchingScreen> {
  @override
  void initState() {
    super.initState();
    _startMatching();
  }

  Future<void> _startMatching() async {
    // マッチング検索演出（モック: 実際のマッチングはFirebase本設定後に実装）
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final opponent = PvpHelper.findOpponent(ref);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PvpResultScreen(opponent: opponent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const RadialBurst(color: ColorPalette.accentOrange, size: 200),
                      const Icon(Icons.search_rounded, color: ColorPalette.accentOrangeBright, size: 64),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '対戦相手を探しています…',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: ColorPalette.lightText,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル', style: TextStyle(color: ColorPalette.lightText)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
