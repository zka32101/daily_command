import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

class GameState {
  final int currentStage;
  final int highestStageCleared;
  final bool ahaMomentReached;
  final bool isPlayingStage;

  GameState({
    this.currentStage = 1,
    this.highestStageCleared = 0,
    this.ahaMomentReached = false,
    this.isPlayingStage = false,
  });

  GameState copyWith({
    int? currentStage,
    int? highestStageCleared,
    bool? ahaMomentReached,
    bool? isPlayingStage,
  }) {
    return GameState(
      currentStage: currentStage ?? this.currentStage,
      highestStageCleared: highestStageCleared ?? this.highestStageCleared,
      ahaMomentReached: ahaMomentReached ?? this.ahaMomentReached,
      isPlayingStage: isPlayingStage ?? this.isPlayingStage,
    );
  }
}

// ゲーム状態プロバイダー（StateProvider）
final gameStateProvider = StateProvider<GameState>((ref) => GameState());

// ゲーム状態操作用の拡張プロバイダー（ヘルパーメソッド）
class GameStateHelper {
  static void setCurrentStage(WidgetRef ref, int stageId) {
    ref.read(gameStateProvider.notifier).state =
      ref.read(gameStateProvider).copyWith(
        currentStage: stageId,
        isPlayingStage: true,
      );
  }

  static void clearStage(WidgetRef ref, int stageId) {
    final current = ref.read(gameStateProvider);
    int newHighest = stageId > current.highestStageCleared
        ? stageId
        : current.highestStageCleared;
    ref.read(gameStateProvider.notifier).state =
      current.copyWith(
        highestStageCleared: newHighest,
        isPlayingStage: false,
      );
  }

  static void reachAhaMoment(WidgetRef ref) {
    ref.read(gameStateProvider.notifier).state =
      ref.read(gameStateProvider).copyWith(ahaMomentReached: true);
  }

  static void exitStage(WidgetRef ref) {
    ref.read(gameStateProvider.notifier).state =
      ref.read(gameStateProvider).copyWith(isPlayingStage: false);
  }
}
