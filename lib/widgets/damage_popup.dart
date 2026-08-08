import 'package:flutter/material.dart';

/// ダメージ数値を1つ表す浮遊アニメーション（生成→上昇→フェードアウト）
class DamagePopupData {
  final int id;
  final int amount;
  final Color color;
  final bool isCritical;
  final bool isHeal;
  final Offset origin;

  DamagePopupData({
    required this.id,
    required this.amount,
    required this.color,
    this.isCritical = false,
    this.isHeal = false,
    this.origin = Offset.zero,
  });
}

class DamagePopup extends StatefulWidget {
  final DamagePopupData data;
  final VoidCallback onCompleted;

  const DamagePopup({
    super.key,
    required this.data,
    required this.onCompleted,
  });

  @override
  State<DamagePopup> createState() => _DamagePopupState();
}

class _DamagePopupState extends State<DamagePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rise;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _rise = Tween<double>(begin: 0, end: -70).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );
    _scale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.4, end: widget.data.isCritical ? 1.6 : 1.2)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 60),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
    ]).animate(_controller);

    _controller.forward().whenComplete(widget.onCompleted);
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
        return Positioned(
          left: widget.data.origin.dx,
          top: widget.data.origin.dy + _rise.value,
          child: Opacity(
            opacity: _fade.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Text(
                widget.data.isHeal
                    ? '+${widget.data.amount}'
                    : (widget.data.isCritical ? '${widget.data.amount}!' : '${widget.data.amount}'),
                style: TextStyle(
                  fontSize: widget.data.isCritical ? 34 : 24,
                  fontWeight: FontWeight.w900,
                  color: widget.data.color,
                  shadows: const [
                    Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
