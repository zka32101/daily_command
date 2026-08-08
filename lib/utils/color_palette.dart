import 'package:flutter/material.dart';

class ColorPalette {
  // ベース
  static const Color darkNavy = Color(0xFF1A1A2E);
  static const Color deeperNavy = Color(0xFF0D0D1A);
  static const Color midNavy = Color(0xFF252545);

  // アクセント
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentOrangeBright = Color(0xFFFF9558);

  // ユニット
  static const Color turquoise = Color(0xFF4ECDC4);
  static const Color turquoiseBright = Color(0xFF7EEAE2);

  // 課金通貨・鉱石
  static const Color gold = Color(0xFFFFD700);
  static const Color goldBright = Color(0xFFFFF3A0);

  // 危険・敵
  static const Color danger = Color(0xFFE63946);
  static const Color dangerBright = Color(0xFFFF5C6C);

  // 勝利
  static const Color victoryGreen = Color(0xFF2ECC71);
  static const Color victoryGreenBright = Color(0xFF7DFFA6);

  // その他
  static const Color lightText = Color(0xFFF5F5F5);

  // ── グラデーション ──────────────────────────

  /// 背景の基本グラデーション（深いネイビー→ミッドナイト紫）
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deeperNavy, darkNavy, Color(0xFF20203A)],
    stops: [0.0, 0.6, 1.0],
  );

  /// 迫力オーラ（オレンジ系・攻撃/主役ボタン用）
  static const LinearGradient orangeAura = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentOrangeBright, accentOrange, Color(0xFFE8501C)],
  );

  /// 勝利グロー（緑系）
  static const LinearGradient victoryAura = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [victoryGreenBright, victoryGreen, Color(0xFF1B9E4B)],
  );

  /// 危険グロー（赤系・敗北/敵用）
  static const LinearGradient dangerAura = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dangerBright, danger, Color(0xFFB01326)],
  );

  /// ゴールドグロー（報酬/課金用）
  static const LinearGradient goldAura = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldBright, gold, Color(0xFFDBA800)],
  );

  /// グラスモーフィズム用パネル色
  static Color glassPanel({double opacity = 0.35}) =>
      midNavy.withValues(alpha: opacity);
}
