/// Model representing exercise information with category/muscle group.
/// Used for exercise search functionality.
class ExerciseInfo {
  final String name;
  final String category; // e.g., "Klatka piersiowa", "Nogi", "Plecy"
  final String? muscleGroup; // Optional more specific muscle group

  const ExerciseInfo({
    required this.name,
    required this.category,
    this.muscleGroup,
  });

  /// Get full category display (category + muscle group if available).
  String getCategoryDisplay() {
    if (muscleGroup != null && muscleGroup!.isNotEmpty) {
      return '$category - $muscleGroup';
    }
    return category;
  }
}
