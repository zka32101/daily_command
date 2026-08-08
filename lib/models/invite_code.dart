class InviteCode {
  final String code;
  final String inviterUserId;
  final String inviterName;
  final DateTime createdAt;
  final int usageCount;
  final bool isActive;

  InviteCode({
    required this.code,
    required this.inviterUserId,
    required this.inviterName,
    required this.createdAt,
    this.usageCount = 0,
    this.isActive = true,
  });

  // シェア用 URL
  String getShareUrl(String baseUrl) {
    return '$baseUrl?invite_code=$code';
  }

  // QR コード用テキスト
  String getQRContent(String baseUrl) {
    return getShareUrl(baseUrl);
  }

  // Twitter シェアテキスト
  String getTwitterText() {
    return '$inviterName司令官を撃破！招待コード: $code\n'
        'Daily Command で一緒に遊ぼう!\n'
        '#DailyCommand';
  }

  // LINE シェアテキスト
  String getLINEText() {
    return '$inviterName司令官を撃破！\n'
        '招待コード: $code\n'
        'Daily Command で遊ぼう!';
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'inviterUserId': inviterUserId,
    'inviterName': inviterName,
    'createdAt': createdAt.toIso8601String(),
    'usageCount': usageCount,
    'isActive': isActive,
  };

  factory InviteCode.fromJson(Map<String, dynamic> json) => InviteCode(
    code: json['code'] as String,
    inviterUserId: json['inviterUserId'] as String,
    inviterName: json['inviterName'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    usageCount: json['usageCount'] as int? ?? 0,
    isActive: json['isActive'] as bool? ?? true,
  );
}
