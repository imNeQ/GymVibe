/// Model representing a user achievement/badge.
class Achievement {
  final String id;
  final String nameKey; // Localization key for name
  final String descriptionKey; // Localization key for description
  final String icon; // Icon name or emoji
  final bool unlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
    this.unlocked = false,
    this.unlockedAt,
  });

  /// Create a copy with updated unlocked status.
  Achievement copyWith({
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      nameKey: nameKey,
      descriptionKey: descriptionKey,
      icon: icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
