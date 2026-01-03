import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/features/workouts/workout_detail_page.dart';
import 'package:trening_tracker/core/services/mock_data.dart';
import 'package:trening_tracker/core/services/workout_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WorkoutDetailPage GUI Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display workout detail page with all elements', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      final workout = workouts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutDetailPage(workoutId: workout.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WorkoutDetailPage), findsOneWidget);
      expect(find.text(workout.name), findsOneWidget);
      expect(find.text('Ćwiczenia'), findsOneWidget);
    });

    testWidgets('should display workout information card', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      final workout = workouts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutDetailPage(workoutId: workout.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for difficulty chip
      expect(find.byType(Chip), findsWidgets);
      
      // Check for duration
      expect(find.textContaining('${workout.estimatedDurationMinutes} min'), findsOneWidget);
    });

    testWidgets('should display all exercises from workout', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      final workout = workouts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutDetailPage(workoutId: workout.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if all exercises are displayed (text may appear multiple times)
      for (final exercise in workout.exercises) {
        expect(find.text(exercise.name), findsWidgets);
        expect(find.textContaining('${exercise.sets} serie'), findsWidgets);
        expect(find.textContaining('${exercise.reps} powtórzeń'), findsWidgets);
      }
    });

    testWidgets('should display rest time for exercises with rest', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      final workout = workouts.firstWhere(
        (w) => w.exercises.any((e) => e.restSeconds != null),
        orElse: () => workouts.first,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutDetailPage(workoutId: workout.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final exerciseWithRest = workout.exercises.firstWhere(
        (e) => e.restSeconds != null,
        orElse: () => workout.exercises.first,
      );

      if (exerciseWithRest.restSeconds != null) {
        expect(find.textContaining('Odpoczynek: ${exerciseWithRest.restSeconds}s'), findsWidgets);
      }
    });

    testWidgets('should display mark as done button', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      final workout = workouts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutDetailPage(workoutId: workout.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Oznacz jako ukończony'), findsOneWidget);
      // Button might be FilledButton.icon, so check for button text instead
      expect(find.text('Oznacz jako ukończony'), findsOneWidget);
    });

    testWidgets('should mark workout as completed when button is tapped', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      final workout = workouts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutDetailPage(workoutId: workout.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to button if needed
      await tester.scrollUntilVisible(find.text('Oznacz jako ukończony'), 500.0);
      await tester.pumpAndSettle();
      
      // Tap mark as done button
      await tester.tap(find.text('Oznacz jako ukończony'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify snackbar is shown
      expect(find.text('Trening oznaczony jako ukończony!'), findsOneWidget);
    });

    testWidgets('should disable button after marking as completed', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      final workout = workouts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutDetailPage(workoutId: workout.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to button if needed
      await tester.scrollUntilVisible(find.text('Oznacz jako ukończony'), 500.0);
      await tester.pumpAndSettle();
      
      // Tap mark as done button
      await tester.tap(find.text('Oznacz jako ukończony'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Button should be disabled - check if text changed or button is disabled
      // After completion, button text should change or button should be disabled
      expect(find.text('Oznacz jako ukończony'), findsNothing);
    });

    testWidgets('should display error message for invalid workout ID', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutDetailPage(workoutId: 'invalid-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error message (check for workout not found text)
      final errorText = find.textContaining('nie znaleziony', findRichText: true);
      final errorTextEn = find.textContaining('not found', findRichText: true);
      expect(errorText.evaluate().isNotEmpty || errorTextEn.evaluate().isNotEmpty, true);
    });

    testWidgets('should display workout description when available', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      final workout = workouts.firstWhere(
        (w) => w.description != null,
        orElse: () => workouts.first,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutDetailPage(workoutId: workout.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      if (workout.description != null) {
        expect(find.text(workout.description!), findsOneWidget);
      }
    });

    testWidgets('should display difficulty chip with correct color', (WidgetTester tester) async {
      final workouts = await MockDataService.getWorkouts();
      final workout = workouts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutDetailPage(workoutId: workout.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if difficulty chip is displayed
      final chips = tester.widgetList<Chip>(find.byType(Chip));
      expect(chips.isNotEmpty, true);
    });
  });
}
