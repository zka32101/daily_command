import 'package:flutter/material.dart';
import '../utils/color_palette.dart';

enum UnitEmotion {
  happy,     // 喜び（クリア直後・強化成功時）
  angry,     // 怒り（戦闘中・攻撃時）
  sad,       // 悲しみ（敗北時）
  tired,     // 疲労（ダメージ受けた時）
  confident, // 自信（高レベル時）
  neutral,   // ニュートラル（通常）
}

class UnitEmotionDisplay extends StatefulWidget {
  final UnitEmotion emotion;
  final Duration duration;

  const UnitEmotionDisplay({
    super.key,
    this.emotion = UnitEmotion.neutral,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<UnitEmotionDisplay> createState() => _UnitEmotionDisplayState();
}

class _UnitEmotionDisplayState extends State<UnitEmotionDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(UnitEmotionDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emotion != widget.emotion) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      ),
      child: _buildEmotionIcon(),
    );
  }

  Widget _buildEmotionIcon() {
    switch (widget.emotion) {
      case UnitEmotion.happy:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withValues(alpha: 0.2),
            border: Border.all(color: Colors.green, width: 2),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.sentiment_very_satisfied, color: Colors.green, size: 32),
        );

      case UnitEmotion.angry:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorPalette.danger.withValues(alpha: 0.2),
            border: Border.all(color: ColorPalette.danger, width: 2),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.sentiment_very_dissatisfied, color: ColorPalette.danger, size: 32),
        );

      case UnitEmotion.sad:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withValues(alpha: 0.2),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.sentiment_dissatisfied, color: Colors.blue, size: 32),
        );

      case UnitEmotion.tired:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.withValues(alpha: 0.2),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.sentiment_neutral, color: Colors.orange, size: 32),
        );

      case UnitEmotion.confident:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorPalette.gold.withValues(alpha: 0.2),
            border: Border.all(color: ColorPalette.gold, width: 2),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.star, color: ColorPalette.gold, size: 32),
        );

      case UnitEmotion.neutral:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withValues(alpha: 0.2),
            border: Border.all(color: Colors.grey, width: 2),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.sentiment_satisfied, color: Colors.grey, size: 32),
        );
    }
  }
}
