// Firebase Analytics イベント定義
// OKR の Key Results を測定する KPI イベント 5個

class AnalyticsEvent {
  /// ユーザーがチュートリアルをクリア
  static const String onboardingComplete = 'onboarding_complete';

  /// Aha Moment に到達
  /// ステージ2敗北→推奨フロー表示→採掘→再挑戦→クリア の一連の流れが完了
  static const String ahaMomentReached = 'aha_moment_reached';

  /// ステージをクリア
  static const String stageCleared = 'stage_cleared';

  /// 採掘を実行
  static const String miningAttempted = 'mining_attempted';

  /// 課金成功時
  static const String monetizationEvent = 'monetization_event';
}

/// Analytics イベント計測用パラメータ
class AnalyticsEventParams {
  // onboarding_complete
  static const String timestamp = 'timestamp';

  // aha_moment_reached
  static const String stageId = 'stage_id';
  static const String timeTaken = 'time_taken_seconds';

  // stage_cleared
  static const String starCount = 'star_count';
  static const String mineralEarned = 'mineral_earned';

  // mining_attempted
  static const String success = 'success';
  static const String additive = 'additive';

  // monetization_event
  static const String productId = 'product_id';
  static const String price = 'price';
  static const String currency = 'currency';
}

/// Remote Config キー（A/B テスト・機能フラグ用）
class RemoteConfigKeys {
  // ペイウォール文言
  static const String payWallText = 'paywall_text';

  // ペイウォール表示タイミング
  static const String payWallTiming = 'paywall_timing';

  // ステージ難度スケーリング係数
  static const String difficultyScaler = 'difficulty_scaler';

  // 採掘クールタイム（時間）
  static const String miningCooltime = 'mining_cooltime_hours';

  // デイリーミッション報酬量
  static const String dailyMissionReward = 'daily_mission_reward';
}
