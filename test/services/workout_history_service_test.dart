import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/services/workout_history_service.dart';
import 'package:trening_tracker/core/models/completed_workout.dart';
import 'package:trening_tracker/core/models/strength_exercise.dart';
import 'package:trening_tracker/core/models/exercise_set.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WorkoutHistoryService', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    test('should save and retrieve completed workout', () async {
      final workout = CompletedWorkout(
        workoutId: 'workout-1',
        completedAt: DateTime(2024, 1, 15),
        activityType: ActivityType.gym,
      );
      
      await WorkoutHistoryService.saveCustomWorkout(workout);
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      
      expect(workouts.length, 1);
      expect(workouts[0].workoutId, 'workout-1');
      expect(workouts[0].activityType, ActivityType.gym);
    });

    test('should save multiple workouts', () async {
      final workout1 = CompletedWorkout(
        completedAt: DateTime(2024, 1, 15),
        activityType: ActivityType.gym,
      );
      final workout2 = CompletedWorkout(
        completedAt: DateTime(2024, 1, 16),
        activityType: ActivityType.running,
        distance: 5.0,
      );
      
      await WorkoutHistoryService.saveCustomWorkout(workout1);
      await WorkoutHistoryService.saveCustomWorkout(workout2);
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      
      expect(workouts.length, 2);
    });

    test('should update existing workout', () async {
      final original = CompletedWorkout(
        completedAt: DateTime(2024, 1, 15, 10, 0),
        activityType: ActivityType.gym,
        notes: 'Stara notatka',
      );
      
      await WorkoutHistoryService.saveCustomWorkout(original);
      
      final updated = CompletedWorkout(
        completedAt: DateTime(2024, 1, 15, 10, 0),
        activityType: ActivityType.gym,
        notes: 'Nowa notatka',
      );
      
      await WorkoutHistoryService.updateWorkout(original, updated);
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      
      expect(workouts.length, 1);
      expect(workouts[0].notes, 'Nowa notatka');
    });

    test('should delete workout', () async {
      final workout = CompletedWorkout(
        completedAt: DateTime(2024, 1, 15),
        activityType: ActivityType.gym,
      );
      
      await WorkoutHistoryService.saveCustomWorkout(workout);
      final deleted = await WorkoutHistoryService.deleteWorkout(workout);
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      
      expect(deleted, true);
      expect(workouts.length, 0);
    });

    test('should return 0 workouts this week when empty', () async {
      final count = await WorkoutHistoryService.getWorkoutsThisWeek();
      expect(count, 0);
    });

    test('should count workouts this week correctly', () async {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      
      // Add workout from this week
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: monday.add(const Duration(days: 1)),
          activityType: ActivityType.gym,
        ),
      );
      
      // Add workout from last week
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: monday.subtract(const Duration(days: 1)),
          activityType: ActivityType.gym,
        ),
      );
      
      final count = await WorkoutHistoryService.getWorkoutsThisWeek();
      expect(count, 1);
    });

    test('should get recent workouts with limit', () async {
      for (int i = 0; i < 10; i++) {
        await WorkoutHistoryService.saveCustomWorkout(
          CompletedWorkout(
            completedAt: DateTime(2024, 1, 15 + i),
            activityType: ActivityType.gym,
          ),
        );
      }
      
      final recent = await WorkoutHistoryService.getRecentWorkouts(limit: 5);
      
      expect(recent.length, 5);
      // Should be sorted by date descending (newest first)
      expect(recent[0].completedAt.isAfter(recent[1].completedAt), true);
    });

    test('should get total workouts count', () async {
      for (int i = 0; i < 5; i++) {
        await WorkoutHistoryService.saveCustomWorkout(
          CompletedWorkout(
            completedAt: DateTime(2024, 1, 15 + i),
            activityType: ActivityType.gym,
          ),
        );
      }
      
      final total = await WorkoutHistoryService.getTotalWorkouts();
      expect(total, 5);
    });

    test('should get all exercise names from strength workouts', () async {
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime(2024, 1, 15),
          activityType: ActivityType.gym,
          strengthExercises: [
            StrengthExercise(
              name: 'Przysiad',
              sets: [ExerciseSet(weight: 50.0, reps: 10)],
            ),
            StrengthExercise(
              name: 'Wyciskanie',
              sets: [ExerciseSet(weight: 80.0, reps: 5)],
            ),
          ],
        ),
      );
      
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime(2024, 1, 16),
          activityType: ActivityType.gym,
          strengthExercises: [
            StrengthExercise(
              name: 'Przysiad', // Duplicate
              sets: [ExerciseSet(weight: 60.0, reps: 8)],
            ),
          ],
        ),
      );
      
      final exerciseNames = await WorkoutHistoryService.getAllExerciseNames();
      
      expect(exerciseNames.length, 2);
      expect(exerciseNames.contains('Przysiad'), true);
      expect(exerciseNames.contains('Wyciskanie'), true);
    });

    test('should get exercise progress', () async {
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime(2024, 1, 15),
          activityType: ActivityType.gym,
          strengthExercises: [
            StrengthExercise(
              name: 'Przysiad',
              sets: [
                ExerciseSet(weight: 50.0, reps: 10),
                ExerciseSet(weight: 60.0, reps: 8),
              ],
            ),
          ],
        ),
      );
      
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime(2024, 1, 20),
          activityType: ActivityType.gym,
          strengthExercises: [
            StrengthExercise(
              name: 'Przysiad',
              sets: [
                ExerciseSet(weight: 70.0, reps: 6),
              ],
            ),
          ],
        ),
      );
      
      final progress = await WorkoutHistoryService.getExerciseProgress('Przysiad');
      
      expect(progress.length, 2);
      expect(progress[0]['maxWeight'], 60.0); // Max from first workout
      expect(progress[1]['maxWeight'], 70.0); // Max from second workout
    });

    test('should get distance last 7 days', () async {
      final now = DateTime.now();
      
      // Add running workout from 3 days ago
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: now.subtract(const Duration(days: 3)),
          activityType: ActivityType.running,
          distance: 5.0,
        ),
      );
      
      // Add cycling workout from 5 days ago
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: now.subtract(const Duration(days: 5)),
          activityType: ActivityType.cycling,
          distance: 10.0,
        ),
      );
      
      // Add running workout from 10 days ago (should not be included)
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: now.subtract(const Duration(days: 10)),
          activityType: ActivityType.running,
          distance: 3.0,
        ),
      );
      
      final distance = await WorkoutHistoryService.getDistanceLast7Days();
      expect(distance, 15.0);
    });

    test('should get time last 7 days', () async {
      final now = DateTime.now();
      
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: now.subtract(const Duration(days: 2)),
          activityType: ActivityType.running,
          durationMinutes: 30,
          durationSeconds: 0,
        ),
      );
      
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: now.subtract(const Duration(days: 4)),
          activityType: ActivityType.cycling,
          durationSeconds: 1800, // 30 minutes in seconds
        ),
      );
      
      final time = await WorkoutHistoryService.getTimeLast7Days();
      // durationSeconds takes precedence, so first workout has 0 seconds, second has 1800 seconds = 30 minutes
      expect(time, 30); // Only the second workout counts (30 minutes)
    });

    test('should clear all workouts', () async {
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime(2024, 1, 15),
          activityType: ActivityType.gym,
        ),
      );
      
      await WorkoutHistoryService.clearAll();
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      
      expect(workouts.length, 0);
    });
  });
}
