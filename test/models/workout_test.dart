import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/models/workout.dart';
import 'package:trening_tracker/core/models/exercise.dart';

void main() {
  group('Workout', () {
    test('should create Workout with all fields', () {
      const workout = Workout(
        id: 'workout-1',
        name: 'Trening siłowy',
        difficulty: 'Intermediate',
        estimatedDurationMinutes: 45,
        exercises: [
          Exercise(name: 'Przysiad', sets: 3, reps: 10),
          Exercise(name: 'Wyciskanie', sets: 4, reps: 8),
        ],
        description: 'Trening na całe ciało',
      );
      
      expect(workout.id, 'workout-1');
      expect(workout.name, 'Trening siłowy');
      expect(workout.difficulty, 'Intermediate');
      expect(workout.estimatedDurationMinutes, 45);
      expect(workout.exercises.length, 2);
      expect(workout.description, 'Trening na całe ciało');
    });

    test('should create Workout without description', () {
      const workout = Workout(
        id: 'workout-2',
        name: 'Trening cardio',
        difficulty: 'Beginner',
        estimatedDurationMinutes: 30,
        exercises: [
          Exercise(name: 'Bieg', sets: 1, reps: 1),
        ],
      );
      
      expect(workout.id, 'workout-2');
      expect(workout.name, 'Trening cardio');
      expect(workout.difficulty, 'Beginner');
      expect(workout.estimatedDurationMinutes, 30);
      expect(workout.exercises.length, 1);
      expect(workout.description, isNull);
    });

    test('should create Workout with empty exercises list', () {
      const workout = Workout(
        id: 'workout-3',
        name: 'Pusty trening',
        difficulty: 'Advanced',
        estimatedDurationMinutes: 0,
        exercises: [],
      );
      
      expect(workout.exercises.isEmpty, true);
    });

    test('should handle different difficulty levels', () {
      const beginner = Workout(
        id: 'b1',
        name: 'Beginner',
        difficulty: 'Beginner',
        estimatedDurationMinutes: 20,
        exercises: [],
      );
      
      const intermediate = Workout(
        id: 'i1',
        name: 'Intermediate',
        difficulty: 'Intermediate',
        estimatedDurationMinutes: 45,
        exercises: [],
      );
      
      const advanced = Workout(
        id: 'a1',
        name: 'Advanced',
        difficulty: 'Advanced',
        estimatedDurationMinutes: 60,
        exercises: [],
      );
      
      expect(beginner.difficulty, 'Beginner');
      expect(intermediate.difficulty, 'Intermediate');
      expect(advanced.difficulty, 'Advanced');
    });
  });
}
