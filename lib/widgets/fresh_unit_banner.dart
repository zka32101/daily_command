import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../models/fresh_unit.dart';
import '../viewmodels/fresh_unit_provider.dart';
import 'glass_panel.dart';
import 'glow_button.dart';
import 'countdown_timer.dart';

class FreshUnitBanner extends ConsumerStatefulWidget {
  const FreshUnitBanner({super.key});

  @override
  ConsumerState<FreshUnitBanner> createState() => _FreshUnitBannerState();
}

class _FreshUnitBannerState extends ConsumerState<FreshUnitBanner>
    with SingleTickerProviderStateMixin {
  bool _expired = false;
  late AnimationController _dissolveController;

  @override
  void initState() {
    super.initState();
    _dissolveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _dissolveController.dispose();
    super.dispose();
  }

  void _onExpired() {
    if (!mounted) return;
    setState(() => _expired = true);
    _dissolveController.forward();
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'Legendary':
        return ColorPalette.goldBright;
      case 'Epic':
        return const Color(0xFFB388FF); // 紫（エピック定番色）
      case 'Rare':
      default:
        return ColorPalette.turquoiseBright;
    }
  }

  String _unitTypeEmoji(String unitType) {
    switch (unitType) {
      case 'Warrior':
        return '⚔️';
      case 'Mage':
        return '✨';
      case 'Archer':
        return '🏹';
      case 'Tank':
        return '🛡️';
      case 'Assassin':
        return '🗡️';
      default:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final freshUnit = ref.watch(freshUnitProvider);
    final claimed = ref.watch(freshUnitClaimedProvider);

    if (_expired) {
      return AnimatedBuilder(
        animation: _dissolveController,
        builder: (context, child) {
          final t = _dissolveController.value;
          return Opacity(
            opacity: 1 - t,
            child: Transform.scale(
              scale: 1 + (t * 0.3), // 粒子が拡散するような拡大フェード
              child: child,
            ),
          );
        },
        child: _buildContent(freshUnit, claimed, expiring: true),
      );
    }

    return _buildContent(freshUnit, claimed, expiring: false);
  }

  Widget _buildContent(FreshUnit freshUnit, bool claimed, {required bool expiring}) {
    final color = _rarityColor(freshUnit.rarity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GlassPanel(
        borderColor: color,
        withGlow: true,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.05)],
                ),
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(_unitTypeEmoji(freshUnit.unitType), style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.hourglass_bottom_rounded, color: color, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '本日限定 [${freshUnit.rarity}]',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${freshUnit.unitType}（ステータス+${((freshUnit.statBoost - 1) * 100).toInt()}%）',
                    style: const TextStyle(fontSize: 13, color: ColorPalette.lightText),
                  ),
                  const SizedBox(height: 4),
                  if (!expiring)
                    CountdownTimer(
                      expiresAt: freshUnit.expiresAt,
                      onExpired: _onExpired,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: ColorPalette.dangerBright,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!claimed && !expiring)
              SizedBox(
                width: 80,
                child: GlowButton(
                  label: '受取',
                  gradient: ColorPalette.goldAura,
                  glowColor: ColorPalette.gold,
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  onPressed: () => FreshUnitHelper.claim(ref),
                ),
              )
            else if (claimed)
              const Icon(Icons.check_circle_rounded, color: ColorPalette.victoryGreenBright, size: 24),
          ],
        ),
      ),
    );
  }
}
