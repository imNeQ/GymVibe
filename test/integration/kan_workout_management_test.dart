import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/core/services/workout_history_service.dart';
import 'package:trening_tracker/core/models/completed_workout.dart';
import 'package:trening_tracker/core/models/strength_exercise.dart';
import 'package:trening_tracker/core/models/exercise_set.dart';
import 'package:trening_tracker/features/workouts/add_workout_history_page.dart';
import 'package:trening_tracker/features/workouts/workout_history_list_page.dart';
import 'package:trening_tracker/features/workouts/workout_history_detail_page.dart';
import 'package:trening_tracker/features/workouts/edit_workout_history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kompleksowe testy dla funkcjonalności zarządzania treningami (KAN-15, KAN-16, KAN-17, KAN-18, KAN-19, KAN-20, KAN-21, KAN-22)
void main() {
  group('KAN-15, KAN-16, KAN-17, KAN-18: Dodawanie treningów', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('KAN-15: should add new gym workout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify form is displayed
      expect(find.text('Data treningu'), findsOneWidget);
      expect(find.text('Typ aktywności'), findsOneWidget);

      // Gym is selected by default, so we can just fill duration and save
      await tester.scrollUntilVisible(find.byType(TextFormField), 500.0);
      await tester.pumpAndSettle();

      final durationField = find.byType(TextFormField).first;
      await tester.enterText(durationField, '60');
      await tester.pump();

      // Save workout - use FilledButton instead of text to avoid multiple matches
      final saveButton = find.byType(FilledButton).last;
      await tester.scrollUntilVisible(saveButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify workout was saved
      expect(find.text('Trening został dodany do historii!'), findsOneWidget);
    });

    testWidgets('KAN-16: should add strength exercise details to gym workout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add exercise - use first to avoid multiple matches
      final addExerciseButton = find.text('Dodaj ćwiczenie').first;
      await tester.scrollUntilVisible(addExerciseButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(addExerciseButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Enter exercise name
      final exerciseNameField = find.byType(TextField).first;
      await tester.enterText(exerciseNameField, 'Przysiad');
      await tester.pump();

      await tester.tap(find.text('Dodaj'));
      await tester.pumpAndSettle();

      // Verify exercise was added
      expect(find.text('Przysiad'), findsOneWidget);

      // Expand exercise and add set
      final expansionTile = find.byType(ExpansionTile).first;
      await tester.tap(expansionTile);
      await tester.pumpAndSettle();

      // Use first to avoid multiple matches (button and dialog title)
      final addSetButton = find.text('Dodaj serię').first;
      await tester.scrollUntilVisible(addSetButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(addSetButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Fill set details
      final weightField = find.widgetWithText(TextField, 'Ciężar (kg)');
      final repsField = find.widgetWithText(TextField, 'Powtórzenia');

      await tester.enterText(weightField, '100');
      await tester.pump();
      await tester.enterText(repsField, '10');
      await tester.pump();

      await tester.tap(find.text('Dodaj'));
      await tester.pumpAndSettle();

      // Verify set was added
      expect(find.textContaining('100'), findsWidgets);
      expect(find.textContaining('10'), findsWidgets);
    });

    testWidgets('KAN-17: should add running workout with distance and time', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select Running activity
      await tester.tap(find.text('Bieganie'));
      await tester.pumpAndSettle();

      // Fill distance and time
      await tester.scrollUntilVisible(find.text('Dystans (km)'), 500.0);
      await tester.pumpAndSettle();

      final distanceField = find.widgetWithText(TextFormField, 'Dystans (km)');
      final minutesField = find.widgetWithText(TextFormField, 'Minuty');
      final secondsField = find.widgetWithText(TextFormField, 'Sekundy');

      await tester.enterText(distanceField, '5.0');
      await tester.pump();
      await tester.enterText(minutesField, '25');
      await tester.pump();
      await tester.enterText(secondsField, '0');
      await tester.pumpAndSettle();

      // Verify pace is calculated
      expect(find.textContaining('Tempo'), findsOneWidget);
      expect(find.textContaining('min/km'), findsOneWidget);

      // Save workout - use FilledButton instead of text to avoid multiple matches
      final saveButton = find.byType(FilledButton).last;
      await tester.scrollUntilVisible(saveButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Trening został dodany do historii!'), findsOneWidget);
    });

    testWidgets('KAN-17: should add cycling workout with distance', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select Cycling activity
      await tester.tap(find.text('Rower'));
      await tester.pumpAndSettle();

      // Fill distance and time
      await tester.scrollUntilVisible(find.text('Dystans (km)'), 500.0);
      await tester.pumpAndSettle();

      final distanceField = find.widgetWithText(TextFormField, 'Dystans (km)');
      final minutesField = find.widgetWithText(TextFormField, 'Minuty');

      await tester.enterText(distanceField, '20.5');
      await tester.pump();
      await tester.enterText(minutesField, '60');
      await tester.pumpAndSettle();

      // Save workout - use FilledButton instead of text to avoid multiple matches
      final saveButton = find.byType(FilledButton).last;
      await tester.scrollUntilVisible(saveButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Trening został dodany do historii!'), findsOneWidget);
    });

    testWidgets('KAN-18: should add notes to workout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to notes field
      await tester.scrollUntilVisible(find.text('Notatki (opcjonalnie)'), 500.0);
      await tester.pumpAndSettle();

      final notesField = find.widgetWithText(TextFormField, 'Notatki (opcjonalnie)');
      await tester.enterText(notesField, 'Świetny trening! Czułem się silny.');
      await tester.pump();

      // Save workout - use FilledButton instead of text to avoid multiple matches
      final saveButton = find.byType(FilledButton).last;
      await tester.scrollUntilVisible(saveButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Trening został dodany do historii!'), findsOneWidget);

      // Verify notes were saved by checking workout history
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      expect(workouts.length, 1);
      expect(workouts.first.notes, 'Świetny trening! Czułem się silny.');
    });
  });

  group('KAN-19: Lista wszystkich treningów', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display empty state when no workouts', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Brak treningów w historii'), findsOneWidget);
      expect(find.text('Dodaj trening, aby zobaczyć go tutaj'), findsOneWidget);
    });

    testWidgets('should display list of all workouts', (WidgetTester tester) async {
      // Add multiple workouts
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
          home: Scaffold(
            body: WorkoutHistoryListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify workouts are displayed
      expect(find.text('Trening siłowy'), findsOneWidget);
      expect(find.text('5.0 km'), findsOneWidget);
    });

    testWidgets('should navigate to workout detail when card is tapped', (WidgetTester tester) async {
      await WorkoutHistoryService.saveCustomWorkout(
        CompletedWorkout(
          completedAt: DateTime.now(),
          activityType: ActivityType.gym,
          customName: 'Test Workout',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on workout card
      await tester.tap(find.text('Test Workout'));
      await tester.pumpAndSettle();

      // Verify navigation to detail page
      expect(find.byType(WorkoutHistoryDetailPage), findsOneWidget);
      expect(find.text('Szczegóły treningu'), findsOneWidget);
    });
  });

  group('KAN-20: Szczegóły pojedynczego treningu', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display workout details', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
        customName: 'Test Workout',
        durationMinutes: 60,
        notes: 'Test notes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Workout'), findsOneWidget);
      expect(find.text('Test notes'), findsOneWidget);
    });

    testWidgets('should display strength exercises if present', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
        strengthExercises: [
          StrengthExercise(
            name: 'Przysiad',
            sets: [
              ExerciseSet(weight: 100.0, reps: 10),
              ExerciseSet(weight: 100.0, reps: 8),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ćwiczenia'), findsOneWidget);
      expect(find.text('Przysiad'), findsOneWidget);
      expect(find.textContaining('100'), findsWidgets);
    });

    testWidgets('should display cardio details if present', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.running,
        distance: 5.0,
        pace: 5.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('5.0 km'), findsOneWidget);
      expect(find.textContaining('Tempo'), findsOneWidget);
    });
  });

  group('KAN-21: Edycja treningu', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should open edit page from workout detail', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
        customName: 'Original Name',
        notes: 'Original notes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Verify edit page is opened
      expect(find.byType(EditWorkoutHistoryPage), findsOneWidget);
      expect(find.text('Edytuj trening'), findsOneWidget);
    });

    testWidgets('should pre-fill form with existing workout data', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime(2024, 1, 15),
        activityType: ActivityType.gym,
        customName: 'Test Workout',
        durationMinutes: 45,
        notes: 'Test notes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditWorkoutHistoryPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify form is pre-filled (check for notes field)
      await tester.scrollUntilVisible(find.text('Notatki (opcjonalnie)'), 500.0);
      await tester.pumpAndSettle();

      final notesField = find.widgetWithText(TextFormField, 'Notatki (opcjonalnie)');
      final notesText = tester.widget<TextFormField>(notesField).controller?.text ?? '';
      expect(notesText, contains('Test notes'));
    });

    testWidgets('should update workout when saved', (WidgetTester tester) async {
      final originalWorkout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
        customName: 'Original Name',
        notes: 'Original notes',
      );

      await WorkoutHistoryService.saveCustomWorkout(originalWorkout);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditWorkoutHistoryPage(completedWorkout: originalWorkout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Change notes
      await tester.scrollUntilVisible(find.text('Notatki (opcjonalnie)'), 500.0);
      await tester.pumpAndSettle();

      final notesField = find.widgetWithText(TextFormField, 'Notatki (opcjonalnie)');
      await tester.enterText(notesField, 'Updated notes');
      await tester.pump();

      // Save changes - use FilledButton instead of text to avoid multiple matches
      final saveButton = find.byType(FilledButton).last;
      await tester.scrollUntilVisible(saveButton, 500.0);
      await tester.pumpAndSettle();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify update message
      expect(find.text('Trening został zaktualizowany!'), findsOneWidget);

      // Verify workout was updated
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      expect(workouts.length, 1);
      expect(workouts.first.notes, 'Updated notes');
    });
  });

  group('KAN-22: Usuwanie treningu', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should show delete confirmation dialog', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Usuń trening'), findsOneWidget);
      expect(find.textContaining('Czy na pewno'), findsOneWidget);
      expect(find.text('Anuluj'), findsOneWidget);
      expect(find.text('Usuń'), findsOneWidget);
    });

    testWidgets('should delete workout when confirmed', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
        customName: 'To Be Deleted',
      );

      await WorkoutHistoryService.saveCustomWorkout(workout);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Confirm deletion - use widgetWithText to find FilledButton with text, fallback to text.first
      final deleteButton = find.widgetWithText(FilledButton, 'Usuń');
      if (deleteButton.evaluate().isEmpty) {
        await tester.tap(find.text('Usuń').first);
      } else {
        await tester.tap(deleteButton);
      }
      await tester.pumpAndSettle();

      // Verify deletion message - use findsAny as SnackBar may disappear quickly
      expect(find.text('Trening został usunięty'), findsAny);

      // Verify workout was deleted
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      expect(workouts.length, 0);
    });

    testWidgets('should cancel deletion when cancel is tapped', (WidgetTester tester) async {
      final workout = CompletedWorkout(
        completedAt: DateTime.now(),
        activityType: ActivityType.gym,
      );

      await WorkoutHistoryService.saveCustomWorkout(workout);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutHistoryDetailPage(completedWorkout: workout),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Cancel deletion
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();

      // Verify dialog is closed and workout still exists
      expect(find.text('Usuń trening'), findsNothing);
      final workouts = await WorkoutHistoryService.getCompletedWorkouts();
      expect(workouts.length, 1);
    });
  });
}
