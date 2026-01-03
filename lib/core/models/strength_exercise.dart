import 'exercise_set.dart';

/// Model representing a strength exercise with multiple sets.
/// Part of the GymVibe app's core data models.
class StrengthExercise {
  final String name; // Exercise name (e.g., "Przysiad", "Wyciskanie na ławce")
  final List<ExerciseSet> sets; // List of sets for this exercise

  const StrengthExercise({
    required this.name,
    required this.sets,
  });

  /// Convert to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets.map((set) => set.toJson()).toList(),
    };
  }

  /// Create from JSON.
  factory StrengthExercise.fromJson(Map<String, dynamic> json) {
    return StrengthExercise(
      name: json['name'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((setJson) => ExerciseSet.fromJson(setJson as Map<String, dynamic>))
          .toList(),
    );
  }
}
