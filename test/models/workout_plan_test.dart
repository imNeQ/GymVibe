import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/models/workout_plan.dart';

void main() {
  group('WorkoutPlan', () {
    test('should create WorkoutPlan with weekly schedule', () {
      const plan = WorkoutPlan(
        weeklySchedule: {
          1: ['workout-1'], // Monday
          2: ['workout-2'], // Tuesday
          3: <String>[],    // Wednesday - rest
          4: ['workout-3'], // Thursday
          5: ['workout-4'], // Friday
          6: <String>[],    // Saturday - rest
          7: <String>[],    // Sunday - rest
        },
      );
      
      expect(plan.weeklySchedule.length, 7);
      expect(plan.weeklySchedule[1], ['workout-1']);
      expect(plan.weeklySchedule[3], isEmpty);
    });

    test('should get workout for specific day', () {
      const plan = WorkoutPlan(
        weeklySchedule: {
          1: ['workout-1'],
          2: ['workout-2'],
          3: <String>[],
          4: ['workout-3'],
          5: ['workout-4'],
          6: <String>[],
          7: <String>[],
        },
      );
      
      expect(plan.getWorkoutForDay(1), 'workout-1');
      expect(plan.getWorkoutForDay(2), 'workout-2');
      expect(plan.getWorkoutForDay(3), isNull);
      expect(plan.getWorkoutForDay(4), 'workout-3');
      expect(plan.getWorkoutForDay(5), 'workout-4');
      expect(plan.getWorkoutForDay(6), isNull);
      expect(plan.getWorkoutForDay(7), isNull);
    });

    test('should handle empty schedule', () {
      const plan = WorkoutPlan(
        weeklySchedule: {},
      );
      
      expect(plan.weeklySchedule.isEmpty, true);
      expect(plan.getWorkoutForDay(1), isNull);
    });

    test('should handle all rest days', () {
      const plan = WorkoutPlan(
        weeklySchedule: {
          1: <String>[],
          2: <String>[],
          3: <String>[],
          4: <String>[],
          5: <String>[],
          6: <String>[],
          7: <String>[],
        },
      );
      
      for (int day = 1; day <= 7; day++) {
        expect(plan.getWorkoutForDay(day), isNull);
      }
    });

    test('should handle all workout days', () {
      const plan = WorkoutPlan(
        weeklySchedule: {
          1: ['workout-1'],
          2: ['workout-2'],
          3: ['workout-3'],
          4: ['workout-4'],
          5: ['workout-5'],
          6: ['workout-6'],
          7: ['workout-7'],
        },
      );
      
      for (int day = 1; day <= 7; day++) {
        expect(plan.getWorkoutForDay(day), 'workout-$day');
      }
    });

    test('should return null for day not in schedule', () {
      const plan = WorkoutPlan(
        weeklySchedule: {
          1: ['workout-1'],
          2: ['workout-2'],
        },
      );
      
      expect(plan.getWorkoutForDay(3), isNull);
      expect(plan.getWorkoutForDay(8), isNull);
    });
  });
}
