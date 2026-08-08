import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/color_palette.dart';
import '../models/unit_skin.dart';
import '../viewmodels/unit_skin_provider.dart';

class SkinSelectionScreen extends ConsumerWidget {
  final String unitId;
  final String unitType;

  const SkinSelectionScreen({
    super.key,
    required this.unitId,
    required this.unitType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skins = SkinCatalog.getSkinsForUnitType(unitType);
    final equippedSkinId = SkinEquipHelper.getEquippedSkinForUnit(ref, unitId);
    final ownedSkins = ref.watch(playerOwnedSkinsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('スキン選択', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ColorPalette.backgroundGradient),
        child: SafeArea(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.95,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
            ),
            itemCount: skins.length,
            itemBuilder: (context, index) {
              final skin = skins[index];
              final isOwned = ownedSkins.contains(skin.skinId);
              final isEquipped = equippedSkinId == skin.skinId;
              final accent = isEquipped
                  ? ColorPalette.accentOrangeBright
                  : (isOwned ? ColorPalette.turquoiseBright : ColorPalette.goldBright);

              return _SkinCard(
                skin: skin,
                isOwned: isOwned,
                isEquipped: isEquipped,
                accent: accent,
                onTap: isOwned
                    ? () {
                        SkinEquipHelper.equipSkin(ref, unitId, skin.skinId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${skin.name}に変更しました')),
                        );
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${skin.name}を購入しますか？（¥${skin.price.toInt()}）')),
                        );
                      },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SkinCard extends StatefulWidget {
  final UnitSkin skin;
  final bool isOwned;
  final bool isEquipped;
  final Color accent;
  final VoidCallback onTap;

  const _SkinCard({
    required this.skin,
    required this.isOwned,
    required this.isEquipped,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_SkinCard> createState() => _SkinCardState();
}

class _SkinCardState extends State<_SkinCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: scale,
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
              color: widget.isEquipped ? widget.accent : widget.accent.withValues(alpha: 0.35),
              width: widget.isEquipped ? 2.5 : 1.2,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(alpha: widget.isEquipped ? 0.55 : 0.2),
                blurRadius: widget.isEquipped ? 24 : 10,
                spreadRadius: widget.isEquipped ? 1 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [widget.accent.withValues(alpha: 0.35), widget.accent.withValues(alpha: 0.05)],
                  ),
                ),
                child: Center(
                  child: Text(widget.skin.iconEmoji, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.skin.name,
                style: TextStyle(
                  fontWeight: widget.isEquipped ? FontWeight.w900 : FontWeight.w600,
                  color: widget.isEquipped ? widget.accent : ColorPalette.lightText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: widget.isOwned
                      ? ColorPalette.victoryGreen.withValues(alpha: 0.25)
                      : ColorPalette.gold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.isOwned ? ColorPalette.victoryGreenBright : ColorPalette.goldBright,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(
                  widget.isOwned
                      ? (widget.isEquipped ? '装備中' : '所有')
                      : '¥${widget.skin.price.toInt()}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: widget.isOwned ? ColorPalette.victoryGreenBright : ColorPalette.goldBright,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
