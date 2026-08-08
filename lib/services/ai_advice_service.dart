import 'package:flutter/foundation.dart';
import '../models/battle_log.dart';

/// AI(Haiku)によるアドバイス生成結果
class AiAdviceResult {
  final String message;
  final bool fromAi; // true: AI生成成功 / false: フォールバックテンプレート

  AiAdviceResult({required this.message, required this.fromAi});
}

/// AIアドバイス生成サービス
///
/// 設計方針: 「弱点分析」自体はルールベース（WeaknessAnalysis）で完結させ、
/// AI(Haiku) は「言い回しのバリエーション生成」にのみ使う。
/// API 呼び出しに失敗・タイムアウトした場合は必ずフォールバック文言を返し、
/// ユーザー体験を止めない（可用性優先）。
class AiAdviceService {
  /// 実装時: Claude API (Haiku) クライアントをここに注入
  /// TODO: Firebase 本設定後、Cloud Functions 経由での呼び出しに切り替える
  /// （クライアント直呼びはAPIキー露出リスクがあるため暫定実装）

  Future<AiAdviceResult> generateAdvice({
    required WeaknessAnalysis analysis,
    required int consecutiveDefeats,
  }) async {
    try {
      final aiMessage = await _callHaikuApi(analysis, consecutiveDefeats)
          .timeout(const Duration(seconds: 5));
      return AiAdviceResult(message: aiMessage, fromAi: true);
    } catch (e) {
      debugPrint('[AiAdviceService] API呼び出し失敗、フォールバックを使用: $e');
      return AiAdviceResult(
        message: analysis.getFallbackMessage(),
        fromAi: false,
      );
    }
  }

  /// Haiku API 呼び出し（未実装・スタブ）
  /// 実装時はここで Anthropic API を呼び出し、
  /// analysis の内容を1文の励ましコメントに変換する
  Future<String> _callHaikuApi(
    WeaknessAnalysis analysis,
    int consecutiveDefeats,
  ) async {
    // TODO: 実際の Claude API (Haiku) 呼び出しに置き換える
    throw UnimplementedError(
      'Haiku API 連携は Firebase 本設定後に実装（現状はフォールバックのみ動作）',
    );
  }
}
