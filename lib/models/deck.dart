class Deck {
  final String name;
  final List<String> unitIds; // 選択中のユニットID（順序=配置スロット）
  final bool isActive;

  static const int minSize = 3;
  static const int maxSize = 5;

  Deck({
    required this.name,
    required this.unitIds,
    this.isActive = true,
  });

  bool get isValid => unitIds.length >= minSize && unitIds.length <= maxSize;

  Deck copyWith({
    String? name,
    List<String>? unitIds,
    bool? isActive,
  }) {
    return Deck(
      name: name ?? this.name,
      unitIds: unitIds ?? this.unitIds,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'unitIds': unitIds,
    'isActive': isActive,
  };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
    name: json['name'] as String,
    unitIds: List<String>.from(json['unitIds'] as List),
    isActive: json['isActive'] as bool? ?? true,
  );
}
