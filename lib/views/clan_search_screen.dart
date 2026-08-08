import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../viewmodels/clan_provider.dart';
import '../widgets/glass_panel.dart';
import '../widgets/glow_button.dart';

class ClanSearchScreen extends ConsumerWidget {
  const ClanSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommended = ref.watch(recommendedClansProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('クラン検索', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlowButton(
                  label: '新しいクランを作る',
                  icon: Icons.add_circle_rounded,
                  gradient: ColorPalette.victoryAura,
                  glowColor: ColorPalette.victoryGreen,
                  fontSize: 16,
                  onPressed: () => _showCreateClanDialog(context, ref),
                ),
              ),
              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'おすすめのクラン',
                    style: TextStyle(color: ColorPalette.lightText, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recommended.length,
                  itemBuilder: (context, index) {
                    final clan = recommended[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: clan.isFull
                            ? null
                            : () {
                                ClanHelper.joinClan(ref, clan);
                                Navigator.of(context).pop();
                              },
                        child: GlassPanel(
                          borderColor: ColorPalette.turquoiseBright,
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Text(clan.iconEmoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      clan.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: ColorPalette.lightText,
                                      ),
                                    ),
                                    Text(
                                      clan.description,
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                    Text(
                                      '${clan.memberCount}/${clan.maxMembers}人',
                                      style: const TextStyle(fontSize: 11, color: ColorPalette.turquoiseBright),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                clan.isFull ? Icons.block_rounded : Icons.chevron_right_rounded,
                                color: clan.isFull ? Colors.grey : ColorPalette.turquoiseBright,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateClanDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ColorPalette.midNavy,
        title: const Text('クランを作成', style: TextStyle(color: ColorPalette.lightText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: ColorPalette.lightText),
              decoration: const InputDecoration(labelText: 'クラン名'),
            ),
            TextField(
              controller: descController,
              style: const TextStyle(color: ColorPalette.lightText),
              decoration: const InputDecoration(labelText: '説明文'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final success = ClanHelper.createClan(
                ref,
                nameController.text.trim().isEmpty ? '新しいクラン' : nameController.text.trim(),
                descController.text.trim(),
                '🛡️',
              );
              Navigator.of(dialogContext).pop();
              if (success) {
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('クラン名または説明文に使用できない言葉が含まれています')),
                );
              }
            },
            child: const Text('作成する'),
          ),
        ],
      ),
    );
  }
}
