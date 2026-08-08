class UnitSkin {
  final String skinId;
  final String name;
  final String description;
  final String unitType; // Warrior / Mage / Archer
  final bool isDefault;
  final double price; // ¥ / 0 = free
  final String iconEmoji; // UI用アイコン

  UnitSkin({
    required this.skinId,
    required this.name,
    required this.description,
    required this.unitType,
    this.isDefault = false,
    this.price = 0,
    this.iconEmoji = '👕',
  });

  bool get isPaid => price > 0;

  Map<String, dynamic> toJson() => {
    'skinId': skinId,
    'name': name,
    'description': description,
    'unitType': unitType,
    'isDefault': isDefault,
    'price': price,
    'iconEmoji': iconEmoji,
  };

  factory UnitSkin.fromJson(Map<String, dynamic> json) => UnitSkin(
    skinId: json['skinId'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    unitType: json['unitType'] as String,
    isDefault: json['isDefault'] as bool? ?? false,
    price: (json['price'] as num?)?.toDouble() ?? 0,
    iconEmoji: json['iconEmoji'] as String? ?? '👕',
  );
}

/// スキン カタログ（全スキン定義）
class SkinCatalog {
  static final Map<String, List<UnitSkin>> skinsByUnitType = {
    'Warrior': [
      UnitSkin(
        skinId: 'warrior_default',
        name: 'デフォルト',
        description: '元々の姿',
        unitType: 'Warrior',
        isDefault: true,
        price: 0,
        iconEmoji: '⚔️',
      ),
      UnitSkin(
        skinId: 'warrior_royal',
        name: '騎士の正装',
        description: '王族の騎士のような豪華な甲冑',
        unitType: 'Warrior',
        isDefault: false,
        price: 120,
        iconEmoji: '👑',
      ),
      UnitSkin(
        skinId: 'warrior_berserker',
        name: 'バーサーカー',
        description: '獰猛な戦士の装備',
        unitType: 'Warrior',
        isDefault: false,
        price: 120,
        iconEmoji: '🗡️',
      ),
    ],
    'Mage': [
      UnitSkin(
        skinId: 'mage_default',
        name: 'デフォルト',
        description: '元々の姿',
        unitType: 'Mage',
        isDefault: true,
        price: 0,
        iconEmoji: '✨',
      ),
      UnitSkin(
        skinId: 'mage_ritual',
        name: '魔導士の儀式衣',
        description: '古い魔法の儀式に使う優雅な衣装',
        unitType: 'Mage',
        isDefault: false,
        price: 120,
        iconEmoji: '🔮',
      ),
      UnitSkin(
        skinId: 'mage_shadow',
        name: '暗黒魔導士',
        description: '禁断の魔法を扱う者の衣装',
        unitType: 'Mage',
        isDefault: false,
        price: 120,
        iconEmoji: '👻',
      ),
    ],
    'Archer': [
      UnitSkin(
        skinId: 'archer_default',
        name: 'デフォルト',
        description: '元々の姿',
        unitType: 'Archer',
        isDefault: true,
        price: 0,
        iconEmoji: '🏹',
      ),
      UnitSkin(
        skinId: 'archer_hunter',
        name: 'ハンター',
        description: '自然と一体になった狩人の装備',
        unitType: 'Archer',
        isDefault: false,
        price: 120,
        iconEmoji: '🦅',
      ),
      UnitSkin(
        skinId: 'archer_assassin',
        name: 'アサシン',
        description: '暗殺者の黒い身軽な衣装',
        unitType: 'Archer',
        isDefault: false,
        price: 120,
        iconEmoji: '🐱',
      ),
    ],
    'Tank': [
      UnitSkin(
        skinId: 'tank_default',
        name: 'デフォルト',
        description: '元々の姿',
        unitType: 'Tank',
        isDefault: true,
        price: 0,
        iconEmoji: '🛡️',
      ),
    ],
    'Assassin': [
      UnitSkin(
        skinId: 'assassin_default',
        name: 'デフォルト',
        description: '元々の姿',
        unitType: 'Assassin',
        isDefault: true,
        price: 0,
        iconEmoji: '🗡️',
      ),
    ],
    'Healer': [
      UnitSkin(
        skinId: 'healer_default',
        name: 'デフォルト',
        description: '元々の姿',
        unitType: 'Healer',
        isDefault: true,
        price: 0,
        iconEmoji: '💚',
      ),
    ],
  };

  static List<UnitSkin> getSkinsForUnitType(String unitType) {
    return skinsByUnitType[unitType] ?? [];
  }

  static UnitSkin? getSkinById(String skinId) {
    for (final skins in skinsByUnitType.values) {
      final skin = skins.firstWhere(
        (s) => s.skinId == skinId,
        orElse: () => UnitSkin(
          skinId: '',
          name: '',
          description: '',
          unitType: '',
        ),
      );
      if (skin.skinId.isNotEmpty) {
        return skin;
      }
    }
    return null;
  }

  static UnitSkin getDefaultSkinForUnitType(String unitType) {
    final skins = getSkinsForUnitType(unitType);
    return skins.firstWhere(
      (s) => s.isDefault,
      orElse: () => skins.first,
    );
  }
}
