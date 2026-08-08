import 'dart:math';
import 'package:flutter/material.dart';

/// コントローラーで trigger() すると画面を数百ミリ秒揺らす
class ScreenShakeController {
  _ScreenShakeState? _state;

  void _attach(_ScreenShakeState state) => _state = state;

  void trigger({double intensity = 8}) => _state?._shake(intensity);
}

class ScreenShake extends StatefulWidget {
  final Widget child;
  final ScreenShakeController controller;

  const ScreenShake({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<ScreenShake> createState() => _ScreenShakeState();
}

class _ScreenShakeState extends State<ScreenShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _intensity = 8;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
  }

  void _shake(double intensity) {
    _intensity = intensity;
    _controller.forward(from: 0);
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
      builder: (context, child) {
        final progress = _controller.value;
        final damping = (1 - progress);
        final dx = sin(progress * 40) * _intensity * damping;
        final dy = cos(progress * 35) * (_intensity * 0.6) * damping;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
