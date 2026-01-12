import 'exercise.dart';

class Workout {
  final String id;
  final String name;
  final String difficulty; // Beginner, Intermediate, Advanced
  final int estimatedDurationMinutes;
  final List<Exercise> exercises;
  final String? description;

  const Workout({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.estimatedDurationMinutes,
    required this.exercises,
    this.description,
  });
}

