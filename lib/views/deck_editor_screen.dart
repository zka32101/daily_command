import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../models/index.dart';
import '../viewmodels/player_provider.dart';
import '../viewmodels/deck_provider.dart';
import '../widgets/glow_button.dart';
import '../widgets/glass_panel.dart';

class DeckEditorScreen extends ConsumerWidget {
  const DeckEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerData = ref.watch(playerDataProvider);
    final deck = ref.watch(deckProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('デッキ編集', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // 選択中デッキスロット表示
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassPanel(
                  borderColor: deck.isValid ? ColorPalette.accentOrange : ColorPalette.dangerBright,
                  withGlow: true,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            deck.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: ColorPalette.accentOrangeBright,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${deck.unitIds.length} / ${Deck.maxSize}',
                            style: TextStyle(
                              color: deck.isValid ? ColorPalette.lightText : ColorPalette.dangerBright,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 64,
                        child: Row(
                          children: List.generate(Deck.maxSize, (index) {
                            final hasUnit = index < deck.unitIds.length;
                            final unit = hasUnit
                                ? playerData.units.firstWhere(
                                    (u) => u.id == deck.unitIds[index],
                                    orElse: () => playerData.units.first,
                                  )
                                : null;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: hasUnit
                                          ? ColorPalette.turquoiseBright
                                          : Colors.grey[700]!,
                                      width: hasUnit ? 2 : 1,
                                      style: hasUnit ? BorderStyle.solid : BorderStyle.solid,
                                    ),
                                    color: hasUnit
                                        ? ColorPalette.turquoise.withValues(alpha: 0.15)
                                        : Colors.black26,
                                  ),
                                  child: Center(
                                    child: hasUnit
                                        ? Text(
                                            _unitTypeEmoji(unit!.unitType),
                                            style: const TextStyle(fontSize: 24),
                                          )
                                        : Icon(Icons.add, color: Colors.grey[600], size: 20),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      if (!deck.isValid)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '最低 ${Deck.minSize} 体は必要です',
                            style: const TextStyle(fontSize: 12, color: ColorPalette.dangerBright),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '所有ユニット（タップで選択・解除）',
                    style: TextStyle(color: ColorPalette.lightText, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 所有ユニット一覧グリッド
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: playerData.units.length,
                  itemBuilder: (context, index) {
                    final unit = playerData.units[index];
                    final isSelected = deck.unitIds.contains(unit.id);

                    return _UnitCard(
                      unit: unit,
                      isSelected: isSelected,
                      onTap: () => DeckHelper.toggleUnit(ref, unit.id),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlowButton(
                  label: '保存',
                  icon: Icons.check_rounded,
                  gradient: ColorPalette.victoryAura,
                  glowColor: ColorPalette.victoryGreen,
                  onPressed: deck.isValid
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('デッキを保存しました')),
                          );
                          Navigator.of(context).pop();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _unitTypeEmoji(String unitType) {
    switch (unitType) {
      case 'Warrior':
        return '⚔️';
      case 'Mage':
        return '✨';
      case 'Archer':
        return '🏹';
      case 'Tank':
        return '🛡️';
      case 'Assassin':
        return '🗡️';
      case 'Healer':
        return '💚';
      default:
        return '❓';
    }
  }
}

class _UnitCard extends StatelessWidget {
  final Unit unit;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitCard({
    required this.unit,
    required this.isSelected,
    required this.onTap,
  });

  String _unitTypeEmoji(String unitType) {
    switch (unitType) {
      case 'Warrior':
        return '⚔️';
      case 'Mage':
        return '✨';
      case 'Archer':
        return '🏹';
      case 'Tank':
        return '🛡️';
      case 'Assassin':
        return '🗡️';
      case 'Healer':
        return '💚';
      default:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = isSelected ? ColorPalette.accentOrangeBright : ColorPalette.turquoiseBright;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
          border: Border.all(
            color: isSelected ? accent : accent.withValues(alpha: 0.3),
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 18)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_unitTypeEmoji(unit.unitType), style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              unit.unitType,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? accent : ColorPalette.lightText,
              ),
            ),
            Text(
              'Lv.${unit.level}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.check_circle_rounded, color: accent, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
