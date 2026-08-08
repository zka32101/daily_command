import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Analytics イベント記録用サービス
/// 実装時: Firebase Analytics に接続
class AnalyticsRepository {
  // TODO: Firebase Analytics インスタンスを注入

  /// チュートリアル完了イベント
  Future<void> logOnboardingComplete() async {
    // Analytics インスタンス.logEvent(
    //   name: AnalyticsEvent.onboardingComplete,
    //   parameters: {
    //     AnalyticsEventParams.timestamp: DateTime.now().toIso8601String(),
    //   },
    // );
    debugPrint('[Analytics] onboarding_complete');
  }

  /// Aha Moment 到達イベント
  Future<void> logAhaMomentReached({
    required int stageId,
    required int timeTakenSeconds,
  }) async {
    // Analytics インスタンス.logEvent(
    //   name: AnalyticsEvent.ahaMomentReached,
    //   parameters: {
    //     AnalyticsEventParams.stageId: stageId,
    //     AnalyticsEventParams.timeTaken: timeTakenSeconds,
    //   },
    // );
    debugPrint('[Analytics] aha_moment_reached - stage: $stageId, time: ${timeTakenSeconds}s');
  }

  /// ステージクリアイベント
  Future<void> logStageCleared({
    required int stageId,
    required int starCount,
    required int mineralEarned,
  }) async {
    // Analytics インスタンス.logEvent(
    //   name: AnalyticsEvent.stageCleared,
    //   parameters: {
    //     AnalyticsEventParams.stageId: stageId,
    //     AnalyticsEventParams.starCount: starCount,
    //     AnalyticsEventParams.mineralEarned: mineralEarned,
    //   },
    // );
    debugPrint('[Analytics] stage_cleared - stage: $stageId, stars: $starCount, mineral: $mineralEarned');
  }

  /// 採掘実行イベント
  Future<void> logMiningAttempted({
    required bool success,
    required bool additive,
  }) async {
    // Analytics インスタンス.logEvent(
    //   name: AnalyticsEvent.miningAttempted,
    //   parameters: {
    //     AnalyticsEventParams.success: success,
    //     AnalyticsEventParams.additive: additive,
    //   },
    // );
    debugPrint('[Analytics] mining_attempted - success: $success, additive: $additive');
  }

  /// 課金イベント
  Future<void> logMonetizationEvent({
    required String productId,
    required double price,
    required String currency,
  }) async {
    // Analytics インスタンス.logEvent(
    //   name: AnalyticsEvent.monetizationEvent,
    //   parameters: {
    //     AnalyticsEventParams.productId: productId,
    //     AnalyticsEventParams.price: price,
    //     AnalyticsEventParams.currency: currency,
    //   },
    // );
    debugPrint('[Analytics] monetization_event - product: $productId, price: $price $currency');
  }
}

// Analytics リポジトリプロバイダー
final analyticsProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository();
});
