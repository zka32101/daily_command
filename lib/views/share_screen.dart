import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../models/invite_code.dart';
import '../viewmodels/invite_provider.dart';

class ShareScreen extends ConsumerStatefulWidget {
  final String stageId;
  final int stars;

  const ShareScreen({
    super.key,
    required this.stageId,
    required this.stars,
  });

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  late InviteCode _inviteCode;

  @override
  void initState() {
    super.initState();
    // デモ用: 招待コード生成
    _inviteCode = InviteHelper.createInviteCode(
      userId: 'user_demo',
      userName: 'あなた',
    );
  }

  void _shareToTwitter() {
    // 実装: url_launcher で Twitter シェア（Uri.encodeComponent でエンコード後に起動）
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Twitter シェア機能（実装予定）')),
    );
  }

  void _shareToLINE() {
    // 実装: url_launcher で LINE シェア（_inviteCode.getLINEText() を使用）
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('LINE シェア機能（実装予定）')),
    );
  }

  void _copyInviteCode() {
    // 実装: Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('コードをコピー: ${_inviteCode.code}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('友達を招待'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // クリア情報
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: ColorPalette.accentOrange),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'ステージをクリアしました！',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.accentOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.stars,
                        (i) => const Icon(
                          Icons.star,
                          color: ColorPalette.gold,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '招待コード: ${_inviteCode.code}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // QR コード表示（プレースホルダー）
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code, size: 80, color: Colors.black),
                    const SizedBox(height: 8),
                    Text(
                      _inviteCode.code,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // シェアテキスト
              Container(
                decoration: BoxDecoration(
                  color: ColorPalette.darkNavy.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                padding: const EdgeInsets.all(12),
                child: Text(
                  _inviteCode.getTwitterText(),
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // シェアボタン群
              ElevatedButton.icon(
                onPressed: _shareToTwitter,
                icon: const Icon(Icons.share),
                label: const Text('Twitter でシェア'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DA1F2),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _shareToLINE,
                icon: const Icon(Icons.share),
                label: const Text('LINE でシェア'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B900),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _copyInviteCode,
                icon: const Icon(Icons.copy),
                label: const Text('コードをコピー'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 32),

              // リーダーボード連携情報
              Container(
                decoration: BoxDecoration(
                  color: ColorPalette.darkNavy.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorPalette.gold, width: 2),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info,
                      color: ColorPalette.gold,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '招待された友人がこのコードで参加すると、',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'リーダーボードで「友人」としてリンク表示されます',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.accentOrange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // クローズボタン
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('閉じる'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
