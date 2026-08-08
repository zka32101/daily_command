import 'dart:ui';
import 'package:flutter/material.dart';

/// グラスモーフィズム パネル（半透明 + ぼかし + グロー境界線）
class GlassPanel extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool withGlow;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderColor = Colors.white24,
    this.borderWidth = 1.5,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.withGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
