/// Model representing user profile information.
/// Part of the GymVibe app's core data models.
class UserProfile {
  final String? name;
  final String? goal;

  const UserProfile({
    this.name,
    this.goal,
  });

  /// Check if profile is empty (no data).
  bool get isEmpty => name == null || name!.isEmpty;

  /// Get display name or default placeholder.
  String getDisplayName(String defaultPlaceholder) {
    if (name == null || name!.trim().isEmpty) {
      return defaultPlaceholder;
    }
    return name!;
  }

  /// Get display goal or default placeholder.
  String getDisplayGoal(String defaultPlaceholder) {
    if (goal == null || goal!.trim().isEmpty) {
      return defaultPlaceholder;
    }
    return goal!;
  }

  /// Convert to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'goal': goal,
    };
  }

  /// Create from JSON.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String?,
      goal: json['goal'] as String?,
    );
  }

  /// Create a copy with updated fields.
  UserProfile copyWith({
    String? name,
    String? goal,
  }) {
    return UserProfile(
      name: name ?? this.name,
      goal: goal ?? this.goal,
    );
  }
}
