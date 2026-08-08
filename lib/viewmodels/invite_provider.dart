import 'package:riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../models/invite_code.dart';

/// 招待コード生成・管理
final inviteCodeProvider = StateProvider<InviteCode?>((ref) {
  return null; // 初期状態：なし
});

/// 招待機能ヘルパー
class InviteHelper {
  // 招待コード生成（ユニークなランダム文字列）
  static String generateCode() {
    const uuid = Uuid();
    // UUID の最初の 8 文字 + チェックサム
    final uniqueId = uuid.v4().replaceAll('-', '').substring(0, 8).toUpperCase();
    return 'DC-$uniqueId';
  }

  // 招待コード検証
  static bool validateCode(String code) {
    return code.startsWith('DC-') && code.length == 11;
  }

  // 招待コード作成
  static InviteCode createInviteCode({
    required String userId,
    required String userName,
  }) {
    return InviteCode(
      code: generateCode(),
      inviterUserId: userId,
      inviterName: userName,
      createdAt: DateTime.now(),
      usageCount: 0,
      isActive: true,
    );
  }

  // 招待コード消費（友人が参加）
  static InviteCode useInviteCode(InviteCode code) {
    return code.copyWith(usageCount: code.usageCount + 1);
  }
}

extension InviteCodeExt on InviteCode {
  InviteCode copyWith({
    String? code,
    String? inviterUserId,
    String? inviterName,
    DateTime? createdAt,
    int? usageCount,
    bool? isActive,
  }) {
    return InviteCode(
      code: code ?? this.code,
      inviterUserId: inviterUserId ?? this.inviterUserId,
      inviterName: inviterName ?? this.inviterName,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
      isActive: isActive ?? this.isActive,
    );
  }
}
