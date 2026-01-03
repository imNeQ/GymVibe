/// Model representing a single set of an exercise with weight and reps.
/// Part of the GymVibe app's core data models.
class ExerciseSet {
  final double? weight; // Weight in kg (optional)
  final int reps; // Number of repetitions

  const ExerciseSet({
    this.weight,
    required this.reps,
  });

  /// Convert to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      if (weight != null) 'weight': weight,
      'reps': reps,
    };
  }

  /// Create from JSON.
  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      weight: (json['weight'] as num?)?.toDouble(),
      reps: json['reps'] as int,
    );
  }
}
