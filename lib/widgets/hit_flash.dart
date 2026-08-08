import 'package:flutter/material.dart';

/// trigger() 呼び出しで画面全体を一瞬フラッシュさせるオーバーレイ
class HitFlashController {
  _HitFlashState? _state;
  void _attach(_HitFlashState state) => _state = state;
  void trigger({Color color = Colors.red}) => _state?._flash(color);
}

class HitFlash extends StatefulWidget {
  final Widget child;
  final HitFlashController controller;

  const HitFlash({super.key, required this.child, required this.controller});

  @override
  State<HitFlash> createState() => _HitFlashState();
}

class _HitFlashState extends State<HitFlash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Color _color = Colors.red;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
  }

  void _flash(Color color) {
    _color = color;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final opacity = (1 - _controller.value) * 0.35 * (_controller.isAnimating || _controller.value < 1 ? 1 : 0);
              return Container(
                color: _color.withValues(alpha: _controller.value >= 1 ? 0 : opacity),
              );
            },
          ),
        ),
      ],
    );
  }
}
