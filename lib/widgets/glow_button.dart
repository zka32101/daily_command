import 'package:flutter/material.dart';

/// グラデーション + グロー + 押下バウンスの迫力ボタン
class GlowButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Gradient gradient;
  final Color glowColor;
  final VoidCallback? onPressed;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const GlowButton({
    super.key,
    required this.label,
    required this.gradient,
    required this.glowColor,
    this.icon,
    this.onPressed,
    this.fontSize = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => _controller.forward(),
      onTapUp: disabled
          ? null
          : (_) {
              _controller.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: disabled ? null : () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: disabled ? null : widget.gradient,
            color: disabled ? Colors.grey[800] : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: disabled ? 0.05 : 0.3),
              width: 1.5,
            ),
            boxShadow: disabled
                ? []
                : [
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: 0.55),
                      blurRadius: 24,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: 0.25),
                      blurRadius: 48,
                      spreadRadius: 4,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: widget.fontSize + 4),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: const [
                    Shadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
