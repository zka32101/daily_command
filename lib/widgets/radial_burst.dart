import 'package:flutter/material.dart';

/// 勝利/クリア演出用の放射状グロー・バースト（背景に敷く装飾）
class RadialBurst extends StatefulWidget {
  final Color color;
  final double size;

  const RadialBurst({super.key, required this.color, this.size = 260});

  @override
  State<RadialBurst> createState() => _RadialBurstState();
}

class _RadialBurstState extends State<RadialBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = 0.85 + (0.15 * (1 - (2 * _controller.value - 1).abs()));
        return Container(
          width: widget.size * pulse,
          height: widget.size * pulse,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.color.withValues(alpha: 0.45),
                widget.color.withValues(alpha: 0.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
