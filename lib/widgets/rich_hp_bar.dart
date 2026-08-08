import 'package:flutter/material.dart';

/// グロー + スムーズアニメーション + ハイライトが流れるHPバー
class RichHpBar extends StatelessWidget {
  final int current;
  final int max;
  final Color color;
  final Color glowColor;
  final double height;

  const RichHpBar({
    super.key,
    required this.current,
    required this.max,
    required this.color,
    Color? glowColor,
    this.height = 26,
  }) : glowColor = glowColor ?? color;

  @override
  Widget build(BuildContext context) {
    final ratio = (current / max).clamp(0.0, 1.0);
    final isLow = ratio < 0.25;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: Colors.black.withValues(alpha: 0.55),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: isLow ? 0.6 : 0.35),
            blurRadius: isLow ? 18 : 10,
            spreadRadius: isLow ? 1 : 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Stack(
          children: [
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              widthFactor: ratio,
              heightFactor: 1.0,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(color, Colors.white, 0.35)!,
                      color,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
