import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/navigation/main_navigation.dart';
import 'package:trening_tracker/features/workouts/add_workout_history_page.dart';
import 'package:trening_tracker/core/services/workout_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Testy funkcjonalne dla przepływu dodawania treningu.
/// Testują pełny proces dodawania treningu do historii.
void main() {
  group('Add Workout Flow Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should complete full flow of adding a gym workout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap FAB to add workout
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify AddWorkoutHistoryPage is displayed
      expect(find.byType(AddWorkoutHistoryPage), findsOneWidget);

      // Verify form is present
      expect(find.byType(Form), findsOneWidget);

      // Activity type should default to gym
      // Verify strength exercises section is visible
      final addExerciseButton = find.textContaining('Dodaj ćwiczenie', findRichText: true);
      final addExerciseButtonEn = find.textContaining('Add Exercise', findRichText: true);
      expect(addExerciseButton.evaluate().isNotEmpty || addExerciseButtonEn.evaluate().isNotEmpty, true);
    });

    testWidgets('should allow selecting different activity types', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddWorkoutHistoryPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find activity type radio buttons
      expect(find.byType(RadioListTile), findsWidgets);

      // Tap on Running activity type
      final runningOption = find.textContaining('Bieganie', findRichText: true);
      final runningOptionEn = find.textContaining('Running', findRichText: true);
      if (runningOption.evaluate().isNotEmpty) {
        await tester.tap(runningOption.first);
      } else if (runningOptionEn.evaluate().isNotEmpty) {
        await tester.tap(runningOptionEn.first);
      }
      await tester.pumpAndSettle();

      // Verify distance and duration fields are visible for running
      final distanceField = find.textContaining('Dystans', findRichText: true);
      final distanceFieldEn = find.textContaining('Distance', findRichText: true);
      expect(distanceField.evaluate().isNotEmpty || distanceFieldEn.evaluate().isNotEmpty, true);
    });

    testWidgets('should save workout and update dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      await tester.pumpAndSettle();

      // Get initial workout count
      final initialCount = await WorkoutHistoryService.getTotalWorkouts();

      // Navigate to add workout
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill in basic workout info
      // For gym workout, we can just save with default values
      final saveButton = find.textContaining('Zapisz', findRichText: true);
      final saveButtonEn = find.textContaining('Save', findRichText: true);
      
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton.first);
      } else if (saveButtonEn.evaluate().isNotEmpty) {
        await tester.tap(saveButtonEn.first);
      }
      await tester.pumpAndSettle();

      // Should navigate back to dashboard
      expect(find.byType(MainNavigation), findsOneWidget);

      // Verify workout was saved
      final newCount = await WorkoutHistoryService.getTotalWorkouts();
      expect(newCount, greaterThan(initialCount));
    });

    testWidgets('should show validation errors for required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddWorkoutHistoryPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Try to save without filling required fields for "Other" activity
      // First select "Other" activity type
      final otherOption = find.textContaining('Inne', findRichText: true);
      final otherOptionEn = find.textContaining('Other', findRichText: true);
      if (otherOption.evaluate().isNotEmpty) {
        await tester.tap(otherOption.first);
        await tester.pump();
      } else if (otherOptionEn.evaluate().isNotEmpty) {
        await tester.tap(otherOptionEn.first);
        await tester.pump();
      }

      // Try to save
      final saveButton = find.textContaining('Zapisz', findRichText: true);
      final saveButtonEn = find.textContaining('Save', findRichText: true);
      
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton.first);
      } else if (saveButtonEn.evaluate().isNotEmpty) {
        await tester.tap(saveButtonEn.first);
      }
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
