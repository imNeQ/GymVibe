/// Model representing a single exercise in a workout.
/// Part of the GymVibe app's core data models.
class Exercise {
  final String name;
  final int sets;
  final int reps;
  final int? restSeconds; // Optional rest time in seconds

  const Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.restSeconds,
  });
}

