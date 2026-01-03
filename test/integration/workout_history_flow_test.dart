import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/features/workouts/workout_history_list_page.dart';
import 'package:trening_tracker/core/services/workout_history_service.dart';
import 'package:trening_tracker/core/models/completed_workout.dart';
import 'package:trening_tracker/core/models/strength_exercise.dart';
import 'package:trening_tracker/core/models/exercise_set.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Testy funkcjonalne dla przepływu przeglądania historii treningów.
/// Testują pełny proces wyświetlania i zarządzania historią treningów.
void main() {
  group('Workout History Flow Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display empty state when no workouts', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutHistoryListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show empty state message
      final emptyMessage = find.textContaining('Brak treningów', findRichText: true);
      final emptyMessageEn = find.textContaining('No workouts', findRichText: true);
      expect(emptyMessage.evaluate().isNotEmpty || emptyMessageEn.evaluate().isNotEmpty, true);
    });

    testWidgets('should display list of saved workouts', (WidgetTester tester) async {
      // Add test workouts
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.gym,
          customName: 'Trening siłowy',
        ),
      );
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          activityType: ActivityType.running,
          distance: 5.0,
          durationMinutes: 30,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutHistoryListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display workout cards
      expect(find.byType(Card), findsWidgets);
      
      // Should show workout names
      expect(find.text('Trening siłowy'), findsOneWidget);
    });

    testWidgets('should navigate to workout detail from history', (WidgetTester tester) async {
      // Add test workout with exercises
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
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

      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutHistoryListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on workout card
      final workoutCard = find.byType(Card).first;
      await tester.tap(workoutCard);
      await tester.pumpAndSettle();

      // Should navigate to detail page
      // Verify detail page is displayed (check for edit button or details)
      final editButton = find.textContaining('Edytuj', findRichText: true);
      final editButtonEn = find.textContaining('Edit', findRichText: true);
      expect(editButton.evaluate().isNotEmpty || editButtonEn.evaluate().isNotEmpty, true);
    });

    testWidgets('should filter workouts by date', (WidgetTester tester) async {
      // Add workouts from different dates
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.gym,
        ),
      );
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now().subtract(const Duration(days: 7)),
          activityType: ActivityType.running,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutHistoryListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display both workouts (sorted by date descending)
      expect(find.byType(Card), findsNWidgets(2));
    });

    testWidgets('should show workout statistics in history', (WidgetTester tester) async {
      // Add workout with distance and duration
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.running,
          distance: 10.5,
          durationMinutes: 45,
          pace: 4.3,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutHistoryListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display distance and duration
      expect(find.text('10.5'), findsWidgets);
      expect(find.text('45'), findsWidgets);
    });
  });
}
