import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../viewmodels/player_provider.dart';
import '../widgets/glass_panel.dart';
import 'skin_selection_screen.dart';

class UnitDictionaryScreen extends ConsumerWidget {
  const UnitDictionaryScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final playerData = ref.watch(playerDataProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ユニット図鑑', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            itemCount: playerData.units.length,
            itemBuilder: (context, index) {
              final unit = playerData.units[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SkinSelectionScreen(
                          unitId: unit.id,
                          unitType: unit.unitType,
                        ),
                      ),
                    );
                  },
                  child: GlassPanel(
                    borderColor: ColorPalette.turquoiseBright,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                ColorPalette.turquoise.withValues(alpha: 0.35),
                                ColorPalette.turquoise.withValues(alpha: 0.05),
                              ],
                            ),
                            border: Border.all(color: ColorPalette.turquoiseBright, width: 2),
                          ),
                          child: Center(
                            child: Text(_unitTypeEmoji(unit.unitType), style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    unit.unitType,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: ColorPalette.lightText,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: ColorPalette.accentOrange.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Text(
                                      'Lv.${unit.level}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: ColorPalette.accentOrangeBright,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _StatBadge(
                                    icon: Icons.local_fire_department_rounded,
                                    value: unit.getAttack(),
                                    color: ColorPalette.dangerBright,
                                  ),
                                  const SizedBox(width: 10),
                                  _StatBadge(
                                    icon: Icons.shield_rounded,
                                    value: unit.getDefense(),
                                    color: ColorPalette.turquoiseBright,
                                  ),
                                  const SizedBox(width: 10),
                                  _StatBadge(
                                    icon: Icons.favorite_rounded,
                                    value: unit.getHealth(),
                                    color: ColorPalette.victoryGreenBright,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: ColorPalette.turquoiseBright.withValues(alpha: 0.7)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;

  const _StatBadge({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 3),
        Text(
          '$value',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
