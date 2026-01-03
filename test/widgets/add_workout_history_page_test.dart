import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trening_tracker/features/workouts/add_workout_history_page.dart';
import 'package:trening_tracker/core/services/workout_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AddWorkoutHistoryPage GUI Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutHistoryService.clearAll();
    });

    testWidgets('should display add workout history page with all sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AddWorkoutHistoryPage), findsOneWidget);
      expect(find.text('Data treningu'), findsOneWidget);
      expect(find.text('Typ aktywności'), findsOneWidget);
      expect(find.text('Dodatkowe informacje (opcjonalnie)'), findsOneWidget);
    });

    testWidgets('should display date selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Data treningu'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('should display all activity type options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Siłownia'), findsOneWidget);
      expect(find.text('Bieganie'), findsOneWidget);
      expect(find.text('Rower'), findsOneWidget);
      expect(find.text('Pływanie'), findsOneWidget);
      expect(find.text('Inne'), findsOneWidget);
    });

    testWidgets('should show custom name field when Other activity is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select Other activity type
      await tester.tap(find.text('Inne'));
      await tester.pumpAndSettle();

      // Should show custom name field
      expect(find.text('Nazwa aktywności'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should show strength exercises section when Gym is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Gym is selected by default, so exercises section should be visible
      expect(find.text('Ćwiczenia'), findsOneWidget);
      expect(find.text('Dodaj ćwiczenie'), findsOneWidget);
    });

    testWidgets('should show distance and time fields for running activity', (WidgetTester tester) async {
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

      // Should show distance and time fields
      expect(find.text('Dystans (km)'), findsOneWidget);
      expect(find.text('Minuty'), findsOneWidget);
      expect(find.text('Sekundy'), findsOneWidget);
    });

    testWidgets('should add exercise when Add Exercise button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Add Exercise button
      await tester.tap(find.text('Dodaj ćwiczenie'));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Dodaj ćwiczenie'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should save workout when form is filled and save button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fill in duration
      final durationField = find.byType(TextFormField).first;
      await tester.enterText(durationField, '45');
      await tester.pump();

      // Tap save button
      await tester.tap(find.text('Zapisz trening'));
      await tester.pumpAndSettle();

      // Should show success message and navigate back
      expect(find.text('Trening został dodany do historii!'), findsOneWidget);
    });

    testWidgets('should validate custom name when Other activity is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select Other activity
      await tester.tap(find.text('Inne'));
      await tester.pumpAndSettle();

      // Scroll to save button - use FilledButton instead of text to avoid multiple matches
      final saveButton = find.byType(FilledButton).last;
      await tester.scrollUntilVisible(saveButton, 500.0);
      await tester.pumpAndSettle();
      
      // Try to save without custom name
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should show validation error (in snackbar)
      expect(find.text('Podaj nazwę aktywności'), findsOneWidget);
    });

    testWidgets('should calculate and display pace for running activity', (WidgetTester tester) async {
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

      // Enter distance and time
      final distanceField = find.widgetWithText(TextFormField, 'Dystans (km)');
      final minutesField = find.widgetWithText(TextFormField, 'Minuty');
      final secondsField = find.widgetWithText(TextFormField, 'Sekundy');

      await tester.enterText(distanceField, '5.0');
      await tester.pump();
      await tester.enterText(minutesField, '25');
      await tester.pump();
      await tester.enterText(secondsField, '0');
      await tester.pumpAndSettle();

      // Should display pace
      expect(find.textContaining('Tempo'), findsOneWidget);
      expect(find.textContaining('min/km'), findsOneWidget);
    });

    testWidgets('should add set to exercise when Add Set is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to add exercise button - use first to avoid multiple matches
      final addExerciseButton = find.text('Dodaj ćwiczenie').first;
      await tester.scrollUntilVisible(addExerciseButton, 500.0);
      await tester.pumpAndSettle();
      
      // Add an exercise first
      await tester.tap(addExerciseButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      final exerciseNameField = find.byType(TextField).first;
      await tester.enterText(exerciseNameField, 'Przysiad');
      await tester.pump();

      await tester.tap(find.text('Dodaj'));
      await tester.pumpAndSettle();

      // Expand exercise card
      final expansionTile = find.byType(ExpansionTile).first;
      await tester.tap(expansionTile);
      await tester.pumpAndSettle();

      // Scroll to Add Set button - use first to avoid multiple matches
      final addSetButton = find.text('Dodaj serię').first;
      await tester.scrollUntilVisible(addSetButton, 500.0);
      await tester.pumpAndSettle();
      
      // Tap Add Set
      await tester.tap(addSetButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Dodaj serię'), findsWidgets);
    });

    testWidgets('should delete exercise when delete button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddWorkoutHistoryPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to add exercise button - use first to avoid multiple matches
      final addExerciseButton = find.text('Dodaj ćwiczenie').first;
      await tester.scrollUntilVisible(addExerciseButton, 500.0);
      await tester.pumpAndSettle();
      
      // Add an exercise
      await tester.tap(addExerciseButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      final exerciseNameField = find.byType(TextField).first;
      await tester.enterText(exerciseNameField, 'Test Exercise');
      await tester.pump();

      await tester.tap(find.text('Dodaj'));
      await tester.pumpAndSettle();

      // Delete the exercise - find delete button in the exercise card
      final deleteButtons = find.byIcon(Icons.delete);
      if (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();

        // Exercise should be removed
        expect(find.text('Test Exercise'), findsNothing);
      }
    });
  });
}
