import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/models/completed_workout.dart';
import 'package:trening_tracker/core/models/strength_exercise.dart';
import 'package:trening_tracker/core/models/exercise_set.dart';

void main() {
  group('CompletedWorkout', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create CompletedWorkout with basic fields', () {
      final workout = CompletedWorkout(
        completedAt: testDate,
        activityType: ActivityType.gym,
      );
      
      expect(workout.completedAt, testDate);
      expect(workout.activityType, ActivityType.gym);
      expect(workout.workoutId, isNull);
      expect(workout.customName, isNull);
      expect(workout.durationMinutes, isNull);
      expect(workout.distance, isNull);
      expect(workout.notes, isNull);
    });

    test('should create CompletedWorkout with all fields', () {
      final workout = CompletedWorkout(
        workoutId: 'workout-1',
        completedAt: testDate,
        activityType: ActivityType.running,
        customName: 'Poranny bieg',
        durationMinutes: 30,
        durationSeconds: 45,
        distance: 5.5,
        pace: 5.5,
        notes: 'Świetny trening!',
      );
      
      expect(workout.workoutId, 'workout-1');
      expect(workout.customName, 'Poranny bieg');
      expect(workout.durationMinutes, 30);
      expect(workout.durationSeconds, 45);
      expect(workout.distance, 5.5);
      expect(workout.pace, 5.5);
      expect(workout.notes, 'Świetny trening!');
    });

    test('should calculate totalDurationSeconds from durationSeconds', () {
      final workout = CompletedWorkout(
        completedAt: testDate,
        activityType: ActivityType.running,
        durationSeconds: 120,
      );
      
      expect(workout.totalDurationSeconds, 120);
    });

    test('should calculate totalDurationSeconds from durationMinutes', () {
      final workout = CompletedWorkout(
        completedAt: testDate,
        activityType: ActivityType.running,
        durationMinutes: 30,
      );
      
      expect(workout.totalDurationSeconds, 1800);
    });

    test('should return null for totalDurationSeconds when both are null', () {
      final workout = CompletedWorkout(
        completedAt: testDate,
        activityType: ActivityType.gym,
      );
      
      expect(workout.totalDurationSeconds, isNull);
    });

    test('should calculate pace correctly', () {
      final pace = CompletedWorkout.calculatePace(5.0, 1500); // 5km in 25 minutes
      
      expect(pace, closeTo(5.0, 0.1)); // 5 min/km
    });

    test('should return null for pace when distance is null', () {
      final pace = CompletedWorkout.calculatePace(null, 1500);
      
      expect(pace, isNull);
    });

    test('should return null for pace when totalSeconds is null', () {
      final pace = CompletedWorkout.calculatePace(5.0, null);
      
      expect(pace, isNull);
    });

    test('should return null for pace when distance is zero', () {
      final pace = CompletedWorkout.calculatePace(0.0, 1500);
      
      expect(pace, isNull);
    });

    test('should convert to JSON', () {
      final workout = CompletedWorkout(
        workoutId: 'workout-1',
        completedAt: testDate,
        activityType: ActivityType.gym,
        customName: 'Trening siłowy',
        durationMinutes: 45,
        notes: 'Notatka',
        strengthExercises: [
          StrengthExercise(
            name: 'Przysiad',
            sets: [ExerciseSet(weight: 50.0, reps: 10)],
          ),
        ],
      );
      
      final json = workout.toJson();
      
      expect(json['workoutId'], 'workout-1');
      expect(json['completedAt'], testDate.toIso8601String());
      expect(json['activityType'], 'gym');
      expect(json['customName'], 'Trening siłowy');
      expect(json['durationMinutes'], 45);
      expect(json['notes'], 'Notatka');
      expect(json['strengthExercises'], isA<List>());
      expect(json['strengthExercises'].length, 1);
    });

    test('should create from JSON', () {
      final json = {
        'workoutId': 'workout-1',
        'completedAt': testDate.toIso8601String(),
        'activityType': 'running',
        'customName': 'Bieg',
        'durationMinutes': 30,
        'durationSeconds': 15,
        'distance': 5.0,
        'pace': 6.0,
        'notes': 'Notatka',
      };
      
      final workout = CompletedWorkout.fromJson(json);
      
      expect(workout.workoutId, 'workout-1');
      expect(workout.completedAt, testDate);
      expect(workout.activityType, ActivityType.running);
      expect(workout.customName, 'Bieg');
      expect(workout.durationMinutes, 30);
      expect(workout.durationSeconds, 15);
      expect(workout.distance, 5.0);
      expect(workout.pace, 6.0);
      expect(workout.notes, 'Notatka');
    });

    test('should create from JSON with strength exercises', () {
      final json = {
        'completedAt': testDate.toIso8601String(),
        'activityType': 'gym',
        'strengthExercises': [
          {
            'name': 'Przysiad',
            'sets': [
              {'weight': 50.0, 'reps': 10},
            ],
          },
        ],
      };
      
      final workout = CompletedWorkout.fromJson(json);
      
      expect(workout.strengthExercises, isNotNull);
      expect(workout.strengthExercises!.length, 1);
      expect(workout.strengthExercises![0].name, 'Przysiad');
      expect(workout.strengthExercises![0].sets.length, 1);
    });

    test('should get display name from customName', () {
      final workout = CompletedWorkout(
        completedAt: testDate,
        activityType: ActivityType.other,
        customName: 'Moja aktywność',
      );
      
      expect(workout.getDisplayName(), 'Moja aktywność');
    });

    test('should get activity type display name', () {
      expect(
        CompletedWorkout.getActivityTypeDisplayName(ActivityType.gym),
        'Siłownia',
      );
      expect(
        CompletedWorkout.getActivityTypeDisplayName(ActivityType.running),
        'Bieganie',
      );
      expect(
        CompletedWorkout.getActivityTypeDisplayName(ActivityType.cycling),
        'Rower',
      );
    });
  });
}
