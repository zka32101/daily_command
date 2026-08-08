import 'package:flutter/material.dart';

/// 時間帯別ライティング（箱庭の背景グラデーション）
enum TimeOfDay { morning, daytime, evening, night }

class GardenLighting {
  // 時間帯を判定
  static TimeOfDay getCurrentTimeOfDay() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 11) {
      return TimeOfDay.morning;
    } else if (hour >= 11 && hour < 17) {
      return TimeOfDay.daytime;
    } else if (hour >= 17 && hour < 23) {
      return TimeOfDay.evening;
    } else {
      return TimeOfDay.night;
    }
  }

  // グラデーション色を取得
  static List<Color> getGradientColors(TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        // 朝（黄 → オレンジ）
        return [
          const Color(0xFFFFD700), // Gold（上）
          const Color(0xFFFF6B35), // Orange（下）
        ];

      case TimeOfDay.daytime:
        // 昼（青 → 紫）
        return [
          const Color(0xFF1E90FF), // Blue（上）
          const Color(0xFF8B00FF), // Purple（下）
        ];

      case TimeOfDay.evening:
        // 夜（紫 → 深紫）
        return [
          const Color(0xFF663399), // MediumPurple（上）
          const Color(0xFF1A0033), // DarkPurple（下）
        ];

      case TimeOfDay.night:
        // 夜中（深青 → 黒）
        return [
          const Color(0xFF001A4D), // DarkBlue（上）
          const Color(0xFF0A0A0A), // Black（下）
        ];
    }
  }

  // グラデーション方向
  static const AlignmentGeometry begin = Alignment.topCenter;
  static const AlignmentGeometry end = Alignment.bottomCenter;

  // ライティング説明テキスト
  static String getTimeOfDayLabel(TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return '朝（夜明け）';
      case TimeOfDay.daytime:
        return '昼（晴天）';
      case TimeOfDay.evening:
        return '夜（夕焼け）';
      case TimeOfDay.night:
        return '夜中（月光）';
    }
  }

  // グラデーション背景ウィジェット
  static Container createGradientBackground({
    required TimeOfDay timeOfDay,
    required Widget child,
  }) {
    final colors = getGradientColors(timeOfDay);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}
